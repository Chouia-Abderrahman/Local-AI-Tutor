import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/ingest/importer.dart';
import 'package:pdf_study_assistant/core/ingest/pdf_extractor.dart';

import '../support/pdfium.dart';

void main() {
  setUpAll(initPdfiumForTests);

  late AppDatabase db;
  late Directory storage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    storage = Directory.systemTemp.createTempSync('imports');
  });

  tearDown(() async {
    await db.close();
    storage.deleteSync(recursive: true);
  });

  DocumentImporter importer() => DocumentImporter(
    db: db,
    storageDir: storage,
    extractPdf: PdfExtractor.extract,
  );

  Future<List<Section>> sectionsOf(int documentId) =>
      (db.select(db.sections)
            ..where((s) => s.documentId.equals(documentId))
            ..orderBy([(s) => OrderingTerm(expression: s.ord)]))
          .get();

  Future<List<Chunk>> chunksOf(int documentId) =>
      (db.select(db.chunks)
            ..where((c) => c.documentId.equals(documentId))
            ..orderBy([(c) => OrderingTerm(expression: c.ord)]))
          .get();

  test('imports a PDF along its bookmarks', () async {
    final result = await importer().importFile('test/fixtures/textbook.pdf');
    expect(result.alreadyImported, isFalse);

    final doc = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(result.documentId))).getSingle();
    expect(doc.status, 'ready');
    expect(doc.pageCount, 5);
    expect(doc.language, 'en');
    expect(File(doc.sourcePath!).existsSync(), isTrue);

    final sections = await sectionsOf(doc.id);
    expect(sections.map((s) => s.title), [
      'textbook',
      '1 Cells',
      '1.1 Cell membranes',
      '1.2 Osmosis',
      '2 Energy',
      '2.1 ATP',
      '2.2 Cellular respiration',
      'References',
    ]);
    final cells = sections[1];
    expect(sections[2].parentId, cells.id);
    expect(sections[2].level, 2);
    // Page ranges come from where the text is, so sections don't overlap.
    final osmosisSection = sections[3];
    expect((osmosisSection.pageStart, osmosisSection.pageEnd), (3, 3));
    expect((cells.pageStart, cells.pageEnd), (3, 3));
    expect((sections[4].pageStart, sections[4].pageEnd), (4, 4));

    final chunks = await chunksOf(doc.id);
    final study = chunks.where((c) => c.kind == 'study').toList();
    final osmosis = study.singleWhere((c) => c.headingPath.endsWith('Osmosis'));
    expect(osmosis.headingPath, '1 Cells › 1.2 Osmosis');
    expect(osmosis.body, startsWith('Osmosis is the movement of water'));
    expect(osmosis.pageStart, 3);
    // Paragraphs are kept apart; lines inside a paragraph are joined.
    expect(osmosis.body.split('\n\n'), hasLength(3));
    // The running header and page numbers are gone.
    for (final chunk in chunks) {
      expect(chunk.body, isNot(contains('Fixture Press -')));
    }
    expect(
      chunks.where((c) => c.kind != 'study').map((c) => c.kind),
      containsAll(['front', 'toc', 'refs']),
    );
    expect(result.studyChunks, study.length);
  });

  test('without bookmarks, finds the same headings from the text', () async {
    final result = await importer().importFile(
      'test/fixtures/textbook_no_outline.pdf',
    );
    final titles = (await sectionsOf(result.documentId)).map((s) => s.title);
    expect(
      titles,
      containsAllInOrder([
        '1 Cells',
        '1.1 Cell membranes',
        '1.2 Osmosis',
        '2 Energy',
        '2.1 ATP',
        '2.2 Cellular respiration',
        'References',
      ]),
    );
    final chunks = await chunksOf(result.documentId);
    final osmosis = chunks.singleWhere(
      (c) => c.kind == 'study' && c.headingPath.endsWith('1.2 Osmosis'),
    );
    expect(osmosis.headingPath, '1 Cells › 1.2 Osmosis');
    expect(
      chunks.where((c) => c.body.contains('........')).map((c) => c.kind),
      everyElement('toc'),
    );
  });

  test('importing the same file again returns the existing document', () async {
    final first = await importer().importFile('test/fixtures/textbook.pdf');
    final again = await importer().importFile('test/fixtures/textbook.pdf');
    expect(again.alreadyImported, isTrue);
    expect(again.documentId, first.documentId);
    expect(await db.select(db.documents).get(), hasLength(1));
  });

  test('imports Markdown notes and makes them searchable', () async {
    final file = File('${storage.path}/my_notes.md')
      ..writeAsStringSync(
        '# Cells\n\nCells are the basic unit of life.\n\n'
        '## Osmosis\n\nWater crosses membranes by osmosis.\n',
      );
    final result = await importer().importFile(file.path);
    final doc = await (db.select(
      db.documents,
    )..where((d) => d.id.equals(result.documentId))).getSingle();
    expect(doc.title, 'my notes');
    final hits = await db
        .customSelect(
          "SELECT rowid FROM chunks_fts WHERE chunks_fts MATCH 'osmosis'",
        )
        .get();
    expect(hits, isNotEmpty);
  });

  test('rejects unsupported files', () async {
    final file = File('${storage.path}/photo.jpg')..writeAsBytesSync([1, 2]);
    await expectLater(
      importer().importFile(file.path),
      throwsA(isA<UnsupportedFileException>()),
    );
  });
}
