import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';

void main() {
  test('a schema 1 database keeps its data and gains model columns', () async {
    // test/fixtures/db_v1.sqlite was written by the schema 1 code: one
    // document, one chat thread with a message, and the default model.
    final dir = Directory.systemTemp.createTempSync('migration');
    final copy = File('${dir.path}/db.sqlite');
    File('test/fixtures/db_v1.sqlite').copySync(copy.path);
    final db = AppDatabase(NativeDatabase(copy));

    final doc = await db.select(db.documents).getSingle();
    expect(doc.title, 'Cells');
    expect(doc.modelPath, isNull);
    final thread = await db.select(db.chatThreads).getSingle();
    expect(thread.modelPath, isNull);
    final message = await db.select(db.chatMessages).getSingle();
    expect(message.content, 'What is osmosis?');
    expect(await db.getSetting('active_model_path'), '/models/a.gguf');

    await (db.update(db.documents)..where((d) => d.id.equals(doc.id))).write(
      const DocumentsCompanion(modelPath: Value('/models/b.gguf')),
    );
    expect(
      (await db.select(db.documents).getSingle()).modelPath,
      '/models/b.gguf',
    );
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 2);

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
