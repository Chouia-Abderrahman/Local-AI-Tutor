import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/db/library_repository.dart';
import '../../core/ingest/importer.dart';
import '../../core/ingest/ocr.dart';
import '../../core/ingest/pdf_extractor.dart';
import '../model/model_controllers.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => LibraryRepository(ref.watch(databaseProvider)),
);

final documentsProvider = StreamProvider<List<StudyDocument>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchDocuments(),
);

final documentOutlineProvider = FutureProvider.family<DocumentOutline, int>(
  (ref, documentId) => ref.watch(libraryRepositoryProvider).outline(documentId),
);

/// The model a document uses: its own choice, or the app default.
final documentModelProvider = Provider.family<ResolvedModel, int>((
  ref,
  documentId,
) {
  final documents = ref.watch(documentsProvider).value ?? const [];
  final document = documents.where((d) => d.id == documentId).firstOrNull;
  return resolveModel(
    document: document?.modelPath,
    appDefault: ref.watch(activeModelProvider.select((s) => s.path)),
  );
});

final importerProvider = FutureProvider<DocumentImporter>((ref) async {
  final support = await getApplicationSupportDirectory();
  final temp = await getTemporaryDirectory();
  return DocumentImporter(
    db: ref.watch(databaseProvider),
    storageDir: Directory(p.join(support.path, 'documents')),
    extractPdf: (path, {required title, onProgress}) async {
      // Text recognition for scanned pages (ML Kit runs on Android/iOS).
      final ocr = Platform.isAndroid || Platform.isIOS
          ? MlKitPageOcr(tempDir: temp)
          : null;
      try {
        return await PdfExtractor.extract(
          path,
          title: title,
          onProgress: onProgress,
          ocr: ocr,
        );
      } finally {
        await ocr?.close();
      }
    },
  );
});

@immutable
class ImportState {
  const ImportState({
    this.busy = false,
    this.fileName,
    this.stage,
    this.fraction,
    this.error,
    this.result,
  });

  final bool busy;
  final String? fileName;
  final String? stage;
  final double? fraction;
  final String? error;

  /// Set once when an import finishes; the screen reacts and clears it.
  final ImportResult? result;
}

class ImportController extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportState();

  /// Lets the user pick a file, then imports it.
  Future<void> pickAndImport() async {
    if (state.busy) return;
    final List<PlatformFile> files;
    try {
      files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: DocumentImporter.supportedExtensions,
      );
    } on Object catch (error) {
      state = ImportState(error: 'Could not open the file picker: $error');
      return;
    }
    final file = files.firstOrNull;
    if (file?.path == null) return;
    await importPath(file!.path!, fileName: file.name);
  }

  Future<void> importPath(String path, {String? fileName}) async {
    if (state.busy) return;
    final name = fileName ?? p.basename(path);
    state = ImportState(busy: true, fileName: name, stage: 'Starting');
    try {
      final importer = await ref.read(importerProvider.future);
      final result = await importer.importFile(
        path,
        fileName: name,
        onProgress: (progress) {
          if (ref.mounted) {
            state = ImportState(
              busy: true,
              fileName: name,
              stage: progress.stage,
              fraction: progress.fraction,
            );
          }
        },
      );
      if (ref.mounted) state = ImportState(fileName: name, result: result);
    } on Object catch (error) {
      if (ref.mounted) state = ImportState(fileName: name, error: '$error');
    }
  }

  /// Called by the screen after it has shown the result or error.
  void acknowledge() => state = const ImportState();
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);
