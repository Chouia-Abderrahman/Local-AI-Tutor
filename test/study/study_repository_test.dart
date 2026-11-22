import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/study/study_repository.dart';

void main() {
  late AppDatabase db;
  late StudyRepository repo;
  late DateTime now;
  late int documentId;
  late int sectionId;
  late int chunkId;

  Future<int> addFact(String statement, {int importance = 2}) async {
    final id = await db
        .into(db.facts)
        .insert(
          FactsCompanion.insert(
            documentId: documentId,
            chunkId: chunkId,
            sectionId: sectionId,
            statement: statement,
            quote: '$statement.',
            quoteStart: 0,
            quoteEnd: statement.length,
            keyTerm: statement.split(' ').last,
            importance: Value(importance),
          ),
        );
    for (final type in ['mcq', 'flashcard', 'cloze']) {
      await db
          .into(db.questions)
          .insert(
            QuestionsCompanion.insert(
              factId: id,
              type: type,
              depth: 'recall',
              prompt: '$type about $statement?',
              answer: 'answer',
              distractorsJson: Value(type == 'mcq' ? '["x","y","z"]' : null),
              quality: 'standard',
              modelId: 'test',
              promptVersion: 1,
            ),
          );
    }
    return id;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 20, 10);
    repo = StudyRepository(
      db,
      scheduler: fsrs.Scheduler(enableFuzzing: false),
      clock: () => now,
    );
    documentId = await db
        .into(db.documents)
        .insert(DocumentsCompanion.insert(title: 'Bio', sha256: 'x'));
    sectionId = await db
        .into(db.sections)
        .insert(
          SectionsCompanion.insert(
            documentId: documentId,
            title: 'Cells',
            level: 1,
            ord: 0,
            pageStart: 1,
            pageEnd: 1,
          ),
        );
    chunkId = await db
        .into(db.chunks)
        .insert(
          ChunksCompanion.insert(
            documentId: documentId,
            sectionId: sectionId,
            ord: 0,
            body: 'text',
            headingPath: 'Cells',
            pageStart: 3,
            pageEnd: 3,
            tokenEstimate: 10,
            sha256: 'y',
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'a first session offers new facts, most important first, as MCQ',
    () async {
      await addFact('osmosis moves water', importance: 1);
      final key = await addFact('ATP stores energy', importance: 3);
      final session = await repo.buildSession(documentId: documentId);
      expect(session, hasLength(2));
      expect(session.first.fact.id, key);
      expect(session.first.isNew, isTrue);
      expect(session.first.question.type, 'mcq');
      expect(session.first.pageStart, 3);
    },
  );

  test('reviews schedule the card; a lapse comes back soon', () async {
    final fact = await addFact('osmosis moves water');
    final item = (await repo.buildSession()).single;

    final wrong = await repo.recordReview(
      factId: fact,
      questionId: item.question.id,
      rating: fsrs.Rating.again,
      correct: false,
    );
    expect(wrong.dueSoon(now), isTrue);

    // Not due yet: the session is empty until the learning step passes.
    expect(await repo.buildSession(), isEmpty);
    now = now.add(const Duration(minutes: 20));
    final again = await repo.buildSession();
    expect(again.single.isNew, isFalse);
    // The same wording isn't asked twice in a row.
    expect(again.single.question.id, isNot(item.question.id));

    final good = await repo.recordReview(
      factId: fact,
      questionId: again.single.question.id,
      rating: fsrs.Rating.good,
      correct: true,
    );
    expect(good.due.isAfter(now), isTrue);
    final reviews = await db.select(db.reviews).get();
    expect(reviews.map((r) => r.rating), [1, 3]);
  });

  test('the daily new-fact limit counts facts started today', () async {
    for (var i = 0; i < 5; i++) {
      await addFact('fact number $i');
    }
    final first = await repo.buildSession(newPerDay: 3);
    expect(first, hasLength(3));
    for (final item in first) {
      await repo.recordReview(
        factId: item.fact.id,
        questionId: item.question.id,
        rating: fsrs.Rating.good,
      );
    }
    // Later the same day: the budget is used up (the 3 are in learning).
    now = now.add(const Duration(minutes: 1));
    expect(
      (await repo.buildSession(newPerDay: 3)).where((i) => i.isNew),
      isEmpty,
    );
  });

  test(
    'recall probability is high right after a good review, then fades',
    () async {
      final fact = await addFact('osmosis moves water');
      final item = (await repo.buildSession()).single;
      await repo.recordReview(
        factId: fact,
        questionId: item.question.id,
        rating: fsrs.Rating.good,
      );
      final soon = (await repo.recallNow([fact]))[fact]!;
      now = now.add(const Duration(days: 30));
      final later = (await repo.recallNow([fact]))[fact]!;
      expect(soon, greaterThan(0.9));
      expect(later, lessThan(soon));
    },
  );

  test(
    'reporting a question rotates it out; a wrong fact leaves the schedule',
    () async {
      final fact = await addFact('osmosis moves water');
      final first = (await repo.buildSession()).single;
      await repo.report(first.question.id);
      final next = (await repo.buildSession()).single;
      expect(next.question.id, isNot(first.question.id));
      await repo.report(next.question.id, factIsWrong: true);
      expect(await repo.buildSession(), isEmpty);
      final overview = await repo.overview();
      expect(overview.newAvailable, 0);
      expect(fact, isPositive);
    },
  );

  group('answers', () {
    test('multiple choice never earns Easy', () {
      expect(ratingForChoice(correct: false), fsrs.Rating.again);
      expect(ratingForChoice(correct: true), fsrs.Rating.good);
      expect(ratingForChoice(correct: true, unsure: true), fsrs.Rating.hard);
      expect(ratingForChoice(correct: true, slow: true), fsrs.Rating.hard);
    });

    test('typed answers allow case, punctuation and one typo', () {
      expect(typedAnswerMatches('Hypotonic', 'hypotonic'), isTrue);
      expect(typedAnswerMatches('hypotnic', 'hypotonic'), isTrue);
      expect(typedAnswerMatches('ATP.', 'ATP'), isTrue);
      expect(typedAnswerMatches('ADP', 'ATP'), isFalse);
      expect(typedAnswerMatches('', 'ATP'), isFalse);
      expect(typedAnswerMatches('hypertonic', 'hypotonic'), isFalse);
    });

    test('multiple choice leads; recall fills in behind it', () {
      Question q(int id, String type) => Question(
        id: id,
        factId: 1,
        type: type,
        depth: 'recall',
        prompt: '',
        answer: '',
        quality: 'standard',
        modelId: '',
        promptVersion: 1,
        status: 'active',
        createdAt: DateTime(2026),
      );
      final qs = [q(1, 'cloze'), q(2, 'mcq'), q(3, 'flashcard')];
      expect(
        StudyRepository.chooseQuestion(qs, reviewed: false, stable: false).type,
        'mcq',
      );
      // Multiple choice leads, for reviews too.
      expect(
        StudyRepository.chooseQuestion(qs, reviewed: true, stable: false).type,
        'mcq',
      );
      expect(
        StudyRepository.chooseQuestion(qs, reviewed: true, stable: true).type,
        'mcq',
      );
      // A well-known fact asked as multiple choice last time is asked as
      // recall now.
      expect(
        StudyRepository.chooseQuestion(
          qs,
          reviewed: true,
          stable: true,
          lastQuestionId: 2,
        ).type,
        'cloze',
      );
      // Otherwise the wording just asked is avoided.
      expect(
        StudyRepository.chooseQuestion(
          qs,
          reviewed: true,
          stable: true,
          lastQuestionId: 1,
        ).type,
        'mcq',
      );
      // A lone multiple choice from an earlier session is asked again...
      expect(
        StudyRepository.chooseQuestion(
          qs,
          reviewed: true,
          stable: false,
          lastQuestionId: 2,
          allowRepeat: true,
        ).type,
        'mcq',
      );
      // ...but not one that was just missed.
      expect(
        StudyRepository.chooseQuestion(
          qs,
          reviewed: true,
          stable: false,
          lastQuestionId: 2,
        ).type,
        'cloze',
      );
    });
  });
}
