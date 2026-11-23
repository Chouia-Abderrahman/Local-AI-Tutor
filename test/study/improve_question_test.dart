import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/improve.dart';
import 'package:pdf_study_assistant/features/study/session_screen.dart';
import 'package:pdf_study_assistant/features/study/study_controllers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int factId;
  late int questionId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final doc = await db
        .into(db.documents)
        .insert(DocumentsCompanion.insert(title: 'Bio', sha256: 'x'));
    final section = await db
        .into(db.sections)
        .insert(
          SectionsCompanion.insert(
            documentId: doc,
            title: 'Cells',
            level: 1,
            ord: 0,
            pageStart: 1,
            pageEnd: 1,
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
            headingPath: 'Cells',
            pageStart: 1,
            pageEnd: 1,
            tokenEstimate: 10,
            sha256: 'y',
          ),
        );
    factId = await db
        .into(db.facts)
        .insert(
          FactsCompanion.insert(
            documentId: doc,
            chunkId: chunk,
            sectionId: section,
            statement: 'ATP stores energy.',
            quote: 'ATP stores energy.',
            quoteStart: 0,
            quoteEnd: 18,
            keyTerm: 'ATP',
          ),
        );
    questionId = await db
        .into(db.questions)
        .insert(
          QuestionsCompanion.insert(
            factId: factId,
            type: 'mcq',
            depth: 'recall',
            prompt: 'What stores energy?',
            answer: 'ATP',
            distractorsJson: const Value('["ADP","DNA","RNA"]'),
            explanation: const Value('{"why":"old","why_wrong":["a","b","c"]}'),
            quality: 'standard',
            modelId: 'old-model',
            promptVersion: 1,
          ),
        );
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  const rewrite = QuestionRewrite(
    prompt: 'Which molecule holds the cell\'s energy?',
    answer: 'ATP',
    distractors: ['Water', 'Glucose', 'Oxygen'],
    explanation: 'ATP stores energy.',
  );

  test(
    'an improved question replaces the old one and keeps its history',
    () async {
      final repo = container.read(studyRepositoryProvider);
      await repo.recordReview(
        factId: factId,
        questionId: questionId,
        rating: fsrs.Rating.good,
        correct: true,
      );
      final updated = await repo.replaceQuestion(
        questionId,
        rewrite,
        modelId: 'new-model',
      );
      expect(updated.id, questionId);
      expect(updated.prompt, rewrite.prompt);
      expect(updated.distractorsJson, '["Water","Glucose","Oxygen"]');
      // Notes on the old wrong options don't carry over.
      expect(updated.explanation, 'ATP stores energy.');
      expect(updated.modelId, 'new-model');
      expect(updated.status, 'active');
      final reviews = await db.select(db.reviews).get();
      expect(reviews.single.questionId, questionId);
    },
  );

  test('a card still open is asked again with the new wording', () async {
    final controller = container.read(sessionControllerProvider.notifier);
    await controller.start();
    expect(
      container.read(sessionControllerProvider).current!.question.prompt,
      'What stores energy?',
    );
    expect(container.read(sessionControllerProvider).rated, isFalse);

    final updated = await container
        .read(studyRepositoryProvider)
        .replaceQuestion(questionId, rewrite, modelId: 'm');
    controller.applyImprovedQuestion(updated);
    final after = container.read(sessionControllerProvider);
    expect(after.phase, SessionPhase.asking);
    expect(after.current!.question.prompt, rewrite.prompt);
    // The options were shuffled again, from the new set.
    expect(after.options.toSet(), {'ATP', 'Water', 'Glucose', 'Oxygen'});
    expect(after.correctOption, isNotNull);
  });

  test('a card already answered keeps showing what was answered', () async {
    final controller = container.read(sessionControllerProvider.notifier);
    await controller.start();
    final options = container.read(sessionControllerProvider).options;
    await controller.choose(options.indexOf('ADP'));
    final answered = container.read(sessionControllerProvider);
    expect(answered.rated, isTrue);

    final updated = await container
        .read(studyRepositoryProvider)
        .replaceQuestion(questionId, rewrite, modelId: 'm');
    controller.applyImprovedQuestion(updated);
    final after = container.read(sessionControllerProvider);
    expect(after.phase, SessionPhase.answered);
    expect(after.current!.question.prompt, 'What stores energy?');
    expect(after.chosen, answered.chosen);
    // The missed card comes back a few cards later, worded the new way.
    final comeback = after.queue.skip(after.index + 1);
    for (final item in comeback) {
      expect(item.question.prompt, rewrite.prompt);
    }
  });

  testWidgets('the card menu opens the improve sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SessionScreen()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(find.text('What stores energy?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Improve this question'));
    await tester.pumpAndSettle();

    // The sheet shows the current question, what to say is wrong, and the
    // button; picking a suggestion fills the box.
    expect(find.text('Improve this question'), findsOneWidget);
    expect(find.text('Now'.toUpperCase()), findsOneWidget);
    expect(find.text('Improve'), findsOneWidget);
    await tester.tap(find.text('It is too easy'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'It is too easy'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
