import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Documents,
    Sections,
    Chunks,
    Facts,
    Questions,
    QuestionSections,
    FactCards,
    Reviews,
    Jobs,
    JobItems,
    LlmCacheEntries,
    Rejections,
    ChatThreads,
    ChatMessages,
    WebPages,
    WebLogEntries,
    FactChecks,
    BenchmarkRuns,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the app database, or uses [executor] (tests pass an in-memory one).
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openDefault());

  static QueryExecutor _openDefault() => driftDatabase(
    name: 'study_assistant',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createSearchIndex();
    },
    onUpgrade: (m, from, to) async {
      // No released version yet: rebuild instead of migrating.
      await customStatement('PRAGMA foreign_keys = OFF');
      await customStatement('DROP TABLE IF EXISTS chunks_fts');
      for (final table in allTables.toList().reversed) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
      await _createSearchIndex();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Full-text index over chunk text and headings, kept in sync by triggers.
  Future<void> _createSearchIndex() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
        body, heading_path,
        content='chunks', content_rowid='id',
        tokenize='unicode61 remove_diacritics 2'
      )''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS chunks_fts_insert AFTER INSERT ON chunks
      BEGIN
        INSERT INTO chunks_fts(rowid, body, heading_path)
        VALUES (new.id, new.body, new.heading_path);
      END''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS chunks_fts_delete AFTER DELETE ON chunks
      BEGIN
        INSERT INTO chunks_fts(chunks_fts, rowid, body, heading_path)
        VALUES ('delete', old.id, old.body, old.heading_path);
      END''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS chunks_fts_update AFTER UPDATE ON chunks
      BEGIN
        INSERT INTO chunks_fts(chunks_fts, rowid, body, heading_path)
        VALUES ('delete', old.id, old.body, old.heading_path);
        INSERT INTO chunks_fts(rowid, body, heading_path)
        VALUES (new.id, new.body, new.heading_path);
      END''');
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String? value) async {
    if (value == null) {
      await (delete(appSettings)..where((t) => t.key.equals(key))).go();
    } else {
      await into(
        appSettings,
      ).insertOnConflictUpdate(AppSetting(key: key, value: value));
    }
  }
}
