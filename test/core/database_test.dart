import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> addDocumentWithChunk(String body) async {
    final docId = await db
        .into(db.documents)
        .insert(DocumentsCompanion.insert(title: 'Biology', sha256: 'abc'));
    final sectionId = await db
        .into(db.sections)
        .insert(
          SectionsCompanion.insert(
            documentId: docId,
            title: 'Osmosis',
            level: 1,
            ord: 0,
            pageStart: 1,
            pageEnd: 2,
          ),
        );
    await db
        .into(db.chunks)
        .insert(
          ChunksCompanion.insert(
            documentId: docId,
            sectionId: sectionId,
            ord: 0,
            body: body,
            headingPath: 'Cells › Osmosis',
            pageStart: 1,
            pageEnd: 1,
            tokenEstimate: 20,
            sha256: 'def',
          ),
        );
    return docId;
  }

  Future<List<int>> search(String query) async {
    final rows = await db
        .customSelect(
          'SELECT rowid FROM chunks_fts WHERE chunks_fts MATCH ?',
          variables: [Variable.withString(query)],
        )
        .get();
    return [for (final row in rows) row.read<int>('rowid')];
  }

  test('full-text search finds chunks, ignoring accents', () async {
    await addDocumentWithChunk('La membrane cellulaire laisse passer l\'eau.');
    expect(await search('cellulaire'), hasLength(1));
    expect(await search('membrane eau'), hasLength(1));
    expect(await search('osmosis'), hasLength(1), reason: 'heading is indexed');
    expect(await search('photosynthesis'), isEmpty);
  });

  test('deleting a document removes its chunks and their index rows', () async {
    final docId = await addDocumentWithChunk('Water crosses the membrane.');
    await (db.delete(db.documents)..where((d) => d.id.equals(docId))).go();
    expect(await db.select(db.chunks).get(), isEmpty);
    expect(await search('membrane'), isEmpty);
  });

  test('settings round-trip and can be cleared', () async {
    expect(await db.getSetting('k'), isNull);
    await db.setSetting('k', 'v1');
    await db.setSetting('k', 'v2');
    expect(await db.getSetting('k'), 'v2');
    await db.setSetting('k', null);
    expect(await db.getSetting('k'), isNull);
  });
}
