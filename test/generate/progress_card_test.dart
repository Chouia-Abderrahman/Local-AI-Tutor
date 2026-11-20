import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/generation_repository.dart';
import 'package:pdf_study_assistant/core/generate/profile.dart';
import 'package:pdf_study_assistant/core/generate/runner.dart';
import 'package:pdf_study_assistant/core/ingest/importer.dart';
import 'package:pdf_study_assistant/features/generate/generate_controllers.dart';
import 'package:pdf_study_assistant/features/generate/progress_card.dart';

void main() {
  testWidgets('a battery pause shows its reason and a Resume button', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final storage = Directory.systemTemp.createTempSync('progress_card');
    late int documentId;
    await tester.runAsync(() async {
      final notes = File('${storage.path}/notes.md')
        ..writeAsStringSync(
          '# Cells\n\nOsmosis moves water across selectively permeable '
          'membranes. Hypotonic solutions make animal cells swell.\n',
        );
      final result = await DocumentImporter(
        db: db,
        storageDir: storage,
        extractPdf: (path, {required title, onProgress}) =>
            throw UnimplementedError(),
      ).importFile(notes.path);
      documentId = result.documentId;
      await GenerationRepository(db).createJob(
        documentId: documentId,
        profile: GenerationProfile.preset(Quality.quick),
      );
    });

    const reason =
        'Paused to save battery (15%). It continues when you plug in the '
        'phone.';
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          runnerStateProvider.overrideWith(
            (ref) =>
                Stream.value(const RunnerState(paused: true, message: reason)),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: GenerationProgressCard(documentId: documentId)),
        ),
      ),
    );
    for (var i = 0; i < 10 && find.text(reason).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text(reason), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Set up model'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(db.close);
    storage.deleteSync(recursive: true);
  });
}
