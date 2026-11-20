import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/features/study/session_screen.dart';

void main() {
  testWidgets('a session: answer MCQ, see the source, type a cloze, finish', (
    tester,
  ) async {
    // A phone-sized screen (1080x2400 at 3x).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    late int mcqFact;
    await tester.runAsync(() async {
      final doc = await db
          .into(db.documents)
          .insert(DocumentsCompanion.insert(title: 'Bio', sha256: 'x'));
      final section = await db
          .into(db.sections)
          .insert(
            SectionsCompanion.insert(
              documentId: doc,
              title: 'Osmosis',
              level: 1,
              ord: 0,
              pageStart: 3,
              pageEnd: 3,
            ),
          );
      final chunk = await db
          .into(db.chunks)
          .insert(
            ChunksCompanion.insert(
              documentId: doc,
              sectionId: section,
              ord: 0,
              body: 'text',
              headingPath: 'Cells › Osmosis',
              pageStart: 3,
              pageEnd: 3,
              tokenEstimate: 10,
              sha256: 'y',
            ),
          );
      Future<int> fact(String quote, int importance) => db
          .into(db.facts)
          .insert(
            FactsCompanion.insert(
              documentId: doc,
              chunkId: chunk,
              sectionId: section,
              statement: quote,
              quote: quote,
              quoteStart: 0,
              quoteEnd: quote.length,
              keyTerm: 'x',
              importance: Value(importance),
            ),
          );
      mcqFact = await fact('A hypotonic solution has fewer solutes.', 3);
      await db
          .into(db.questions)
          .insert(
            QuestionsCompanion.insert(
              factId: mcqFact,
              type: 'mcq',
              depth: 'recall',
              prompt: 'What is a solution with fewer solutes called?',
              answer: 'Hypotonic',
              distractorsJson: const Value(
                '["Hypertonic","Isotonic","Saturated"]',
              ),
              explanation: const Value('Hypo means under.'),
              quality: 'standard',
              modelId: 'test',
              promptVersion: 1,
            ),
          );
      final clozeFact = await fact('ATP stores energy in cells.', 2);
      await db
          .into(db.questions)
          .insert(
            QuestionsCompanion.insert(
              factId: clozeFact,
              type: 'cloze',
              depth: 'recall',
              prompt: '_____ stores energy in cells.',
              answer: 'ATP',
              quality: 'quick',
              modelId: 'test',
              promptVersion: 1,
            ),
          );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: SessionScreen()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    // The important fact comes first, as multiple choice.
    expect(
      find.text('What is a solution with fewer solutes called?'),
      findsOneWidget,
    );
    expect(find.text('1 of 2'), findsOneWidget);
    await tester.tap(find.text('Hypotonic'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    // Feedback shows the source sentence with its page, and the explanation.
    expect(find.text('From the text, page 3'), findsOneWidget);
    expect(
      find.text('“A hypotonic solution has fewer solutes.”'),
      findsOneWidget,
    );
    expect(find.text('Hypo means under.'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Cloze: type the answer (with a typo).
    expect(find.text('______ stores energy in cells.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'atp');
    await tester.tap(find.text('Check'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Correct: ATP'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Session done'), findsOneWidget);
    expect(find.text('2 answers · 100% right'), findsOneWidget);

    final reviews = await tester.runAsync(() => db.select(db.reviews).get());
    expect(reviews!.map((r) => r.rating), [3, 3]);
    expect(reviews.first.factId, mcqFact);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(db.close);
  });
}
