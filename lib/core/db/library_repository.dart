import 'dart:io';

import 'package:drift/drift.dart';

import '../ingest/content_kind.dart';
import 'database.dart';

/// A section with counts of its own chunks (not its children's).
class SectionSummary {
  const SectionSummary({
    required this.section,
    required this.studyChunks,
    required this.skippedKinds,
    required this.tokens,
  });

  final Section section;
  final int studyChunks;

  /// Why non-study chunks in this section are skipped.
  final Set<ContentKind> skippedKinds;
  final int tokens;

  bool get isSkipped => studyChunks == 0 && skippedKinds.isNotEmpty;
}

class DocumentOutline {
  const DocumentOutline({required this.document, required this.sections});

  final StudyDocument document;
  final List<SectionSummary> sections;

  int get studyChunks => sections.fold(0, (n, s) => n + s.studyChunks);
}

/// Reads and deletes imported documents.
class LibraryRepository {
  LibraryRepository(this.db);

  final AppDatabase db;

  Stream<List<StudyDocument>> watchDocuments() =>
      (db.select(db.documents)..orderBy([
            (d) =>
                OrderingTerm(expression: d.importedAt, mode: OrderingMode.desc),
          ]))
          .watch();

  Future<DocumentOutline> outline(int documentId) async {
    final document = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(documentId))).getSingle();
    final sections =
        await (db.select(db.sections)
              ..where((s) => s.documentId.equals(documentId))
              ..orderBy([(s) => OrderingTerm(expression: s.ord)]))
            .get();
    final rows = await db
        .customSelect(
          'SELECT section_id, kind, COUNT(*) AS n, SUM(token_estimate) AS t '
          'FROM chunks WHERE document_id = ? GROUP BY section_id, kind',
          variables: [Variable.withInt(documentId)],
          readsFrom: {db.chunks},
        )
        .get();
    final study = <int, int>{};
    final skipped = <int, Set<ContentKind>>{};
    final tokens = <int, int>{};
    for (final row in rows) {
      final sectionId = row.read<int>('section_id');
      final kind = ContentKind.values.byName(row.read<String>('kind'));
      final count = row.read<int>('n');
      tokens[sectionId] = (tokens[sectionId] ?? 0) + row.read<int>('t');
      if (kind.isStudy) {
        study[sectionId] = (study[sectionId] ?? 0) + count;
      } else {
        skipped.putIfAbsent(sectionId, () => {}).add(kind);
      }
    }
    return DocumentOutline(
      document: document,
      sections: [
        for (final section in sections)
          SectionSummary(
            section: section,
            studyChunks: study[section.id] ?? 0,
            skippedKinds: skipped[section.id] ?? const {},
            tokens: tokens[section.id] ?? 0,
          ),
      ],
    );
  }

  Future<Section> section(int sectionId) => (db.select(
    db.sections,
  )..where((s) => s.id.equals(sectionId))).getSingle();

  Future<List<Chunk>> chunksOfSection(int sectionId) =>
      (db.select(db.chunks)
            ..where((c) => c.sectionId.equals(sectionId))
            ..orderBy([(c) => OrderingTerm(expression: c.ord)]))
          .get();

  /// Deletes the document, everything generated from it, and its stored file.
  Future<void> deleteDocument(int documentId) async {
    final document = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(documentId))).getSingleOrNull();
    if (document == null) return;
    await (db.delete(db.documents)..where((d) => d.id.equals(documentId))).go();
    final path = document.sourcePath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
  }
}
