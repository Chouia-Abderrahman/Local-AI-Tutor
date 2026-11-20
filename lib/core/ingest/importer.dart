import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import 'extracted.dart';
import 'pipeline.dart';
import 'plain_text.dart';
import 'structure.dart';

typedef PdfExtract =
    Future<ExtractedDocument> Function(
      String path, {
      required String title,
      void Function(int done, int total)? onProgress,
    });

class ImportProgress {
  const ImportProgress(this.stage, [this.fraction]);

  final String stage;

  /// 0 to 1, or null when unknown.
  final double? fraction;
}

class ImportResult {
  const ImportResult({
    required this.documentId,
    required this.alreadyImported,
    this.sections = 0,
    this.studyChunks = 0,
    this.skippedChunks = 0,
    this.nearlyEmptyPages = const [],
  });

  final int documentId;
  final bool alreadyImported;
  final int sections;
  final int studyChunks;
  final int skippedChunks;
  final List<int> nearlyEmptyPages;
}

class UnsupportedFileException implements Exception {
  UnsupportedFileException(this.extension);

  final String extension;

  @override
  String toString() =>
      'Can\'t import "$extension" files. Use PDF, TXT or Markdown.';
}

/// Imports a file: copies it into app storage, extracts and structures its
/// text, and stores the document, its sections and its chunks.
class DocumentImporter {
  DocumentImporter({
    required this.db,
    required this.storageDir,
    required this.extractPdf,
  });

  final AppDatabase db;

  /// Where imported files are kept (named by their SHA-256).
  final Directory storageDir;
  final PdfExtract extractPdf;

  static const supportedExtensions = ['pdf', 'txt', 'md', 'markdown'];

  Future<ImportResult> importFile(
    String path, {
    String? fileName,
    void Function(ImportProgress progress)? onProgress,
  }) async {
    final name = fileName ?? p.basename(path);
    final extension = p.extension(name).toLowerCase().replaceFirst('.', '');
    if (!supportedExtensions.contains(extension)) {
      throw UnsupportedFileException(extension);
    }

    onProgress?.call(const ImportProgress('Reading file'));
    final bytes = await File(path).readAsBytes();
    final hash = sha256.convert(bytes).toString();

    final existing = await (db.select(
      db.documents,
    )..where((d) => d.sha256.equals(hash))).getSingleOrNull();
    if (existing != null) {
      if (existing.status == 'ready') {
        return ImportResult(documentId: existing.id, alreadyImported: true);
      }
      // A failed or interrupted earlier import: start over.
      await (db.delete(
        db.documents,
      )..where((d) => d.id.equals(existing.id))).go();
    }

    await storageDir.create(recursive: true);
    final stored = File(p.join(storageDir.path, '$hash.$extension'));
    if (!stored.existsSync()) await stored.writeAsBytes(bytes, flush: true);

    final title = _titleFromFileName(name);
    final documentId = await db
        .into(db.documents)
        .insert(
          DocumentsCompanion.insert(
            title: title,
            sha256: hash,
            sourcePath: Value(stored.path),
          ),
        );

    try {
      final ExtractedDocument extracted;
      if (extension == 'pdf') {
        extracted = await extractPdf(
          stored.path,
          title: title,
          onProgress: (done, total) => onProgress?.call(
            ImportProgress('Reading page $done of $total', done / total),
          ),
        );
      } else {
        extracted = readPlainText(
          utf8.decode(bytes, allowMalformed: true),
          title: title,
          markdown: extension != 'txt',
        );
      }

      onProgress?.call(const ImportProgress('Finding sections'));
      final processed = processDocument(extracted);
      if (processed.chunks.isEmpty) {
        throw const FormatException(
          'No text found. If this is a scanned PDF, text recognition is '
          'needed first.',
        );
      }

      onProgress?.call(const ImportProgress('Saving'));
      final sectionCount = await _store(documentId, title, processed);
      final study = processed.studyChunks.length;
      return ImportResult(
        documentId: documentId,
        alreadyImported: false,
        sections: sectionCount,
        studyChunks: study,
        skippedChunks: processed.chunks.length - study,
        nearlyEmptyPages: processed.nearlyEmptyPages,
      );
    } catch (error) {
      await (db.update(
        db.documents,
      )..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          status: const Value('failed'),
          errorMessage: Value('$error'),
        ),
      );
      rethrow;
    }
  }

  /// Writes sections and chunks in one transaction; returns the number of
  /// sections stored.
  Future<int> _store(
    int documentId,
    String title,
    ProcessedDocument processed,
  ) {
    return db.transaction(() async {
      final sectionIds = <SectionNode, int>{};
      var ord = 0;

      Future<int> insertRow(
        String sectionTitle,
        int level,
        int? parentId,
        int pageStart,
        int pageEnd,
      ) => db
          .into(db.sections)
          .insert(
            SectionsCompanion.insert(
              documentId: documentId,
              parentId: Value(parentId),
              title: sectionTitle,
              level: level,
              ord: ord++,
              pageStart: pageStart,
              pageEnd: pageEnd,
            ),
          );

      Future<void> insertTree(SectionNode node, int? parentId) async {
        final id = await insertRow(
          node.title,
          node.level,
          parentId,
          node.pageStart,
          node.pageEnd,
        );
        sectionIds[node] = id;
        for (final child in node.children) {
          await insertTree(child, id);
        }
      }

      // Text before the first heading becomes a top-level section named
      // after the document.
      final root = processed.root;
      if (root.paragraphs.isNotEmpty) {
        sectionIds[root] = await insertRow(
          title,
          1,
          null,
          root.paragraphs.first.pageStart,
          root.paragraphs.last.pageEnd,
        );
      }
      for (final child in root.children) {
        await insertTree(child, null);
      }

      for (final (index, chunk) in processed.chunks.indexed) {
        await db
            .into(db.chunks)
            .insert(
              ChunksCompanion.insert(
                documentId: documentId,
                sectionId: sectionIds[chunk.section]!,
                ord: index,
                body: chunk.text,
                headingPath: chunk.section.level == 0
                    ? title
                    : chunk.section.path.join(' › '),
                pageStart: chunk.pageStart,
                pageEnd: chunk.pageEnd,
                tokenEstimate: chunk.tokenEstimate,
                kind: Value(chunk.kind.name),
                sha256: sha256.convert(utf8.encode(chunk.text)).toString(),
              ),
            );
      }

      await (db.update(
        db.documents,
      )..where((d) => d.id.equals(documentId))).write(
        DocumentsCompanion(
          pageCount: Value(processed.pageCount),
          language: Value(processed.language),
          status: const Value('ready'),
        ),
      );
      return sectionIds.values.toSet().length;
    });
  }

  static String _titleFromFileName(String name) {
    final base = p
        .basenameWithoutExtension(name)
        .replaceAll(RegExp(r'[_]+'), ' ');
    final cleaned = base.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? 'Untitled' : cleaned;
  }
}
