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

    // Not due yet: it is only offered as extra practice until the learning
    // step passes.
    expect((await repo.buildSession()).single.ahead, isTrue);
    now = now.add(const Duration(minutes: 20));
    final again = await repo.buildSession();
    expect(again.single.isNew, isFalse);
    expect(again.single.ahead, isFalse);
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

    test('multiple choice leads; recall fills in behind it', () {
      final qs = [q(1, 'cloze'), q(2, 'mcq'), q(3, 'flashcard')];
      expect(
        StudyRepository.chooseQuestion(qs, reviewed: false, stable: false).type,
        'mcq',
      );
      expect(
        StudyRepository.chooseQuestion(qs, reviewed: true, stable: false).type,
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
      // The wording just asked is avoided.
      expect(
        StudyRepository.chooseQuestion(
          qs,
          reviewed: true,
          stable: false,
          lastQuestionId: 2,
        ).type,
        'cloze',
      );
      // A fact with a single question asks it again.
      expect(
        StudyRepository.chooseQuestion(
          [q(2, 'mcq')],
          reviewed: true,
          stable: false,
          lastQuestionId: 2,
        ).id,
        2,
      );
    });

    test('every question gets a turn before any is asked twice', () {
      final qs = [q(1, 'mcq'), q(2, 'mcq'), q(3, 'cloze'), q(4, 'flashcard')];
      final asks = <int, QuestionAsks>{};
      final order = <int>[];
      int? last;
      for (var i = 0; i < 8; i++) {
        final pick = StudyRepository.chooseQuestion(
          qs,
          reviewed: i > 0,
          stable: false,
          lastQuestionId: last,
          asks: asks,
        );
        order.add(pick.id);
        last = pick.id;
        final old = asks[pick.id]?.count ?? 0;
        asks[pick.id] = QuestionAsks(old + 1, DateTime(2026, 1, 1, i));
      }
      // The first four are all different, and the next four go round again
      // in the same order.
      expect(order.take(4).toSet(), {1, 2, 3, 4});
      expect(order.skip(4), order.take(4));
    });

    test('a question never asked beats one asked often', () {
      final qs = [q(1, 'mcq'), q(2, 'cloze')];
      final pick = StudyRepository.chooseQuestion(
        qs,
        reviewed: true,
        stable: false,
        asks: {1: QuestionAsks(5, DateTime(2026))},
      );
      expect(pick.id, 2);
    });
  });

  group('no limit on studying', () {
    test('new facts are not capped per day unless asked', () async {
      for (var i = 0; i < 25; i++) {
        await addFact('fact number $i');
      }
      final first = await repo.buildSession(maxItems: 10);
      for (final item in first) {
        await repo.recordReview(
          factId: item.fact.id,
          questionId: item.question.id,
          rating: fsrs.Rating.good,
        );
      }
      // Ten were started today; the next session still offers new facts.
      final more = await repo.buildSession(maxItems: 10);
      expect(more.where((i) => i.isNew), hasLength(10));
      expect((await repo.overview()).newAvailable, 15);
    });

    test(
      'with nothing waiting, known facts are offered ahead of schedule',
      () async {
        final fact = await addFact('osmosis moves water');
        final item = (await repo.buildSession()).single;
        for (var i = 0; i < 6; i++) {
          final outcome = await repo.recordReview(
            factId: fact,
            questionId: item.question.id,
            rating: fsrs.Rating.good,
            correct: true,
          );
          if (outcome.state == fsrs.State.review) break;
          now = outcome.due.add(const Duration(minutes: 1));
        }
        var overview = await repo.overview();
        expect(overview.due, 0);
        // The other two questions were never asked, so they come first...
        expect(overview.unseen, 1);
        // ...and once every question has had its turn, extra practice remains.
        for (var i = 0; i < 2; i++) {
          final next = (await repo.buildSession()).single;
          await repo.recordReview(
            factId: fact,
            questionId: next.question.id,
            rating: fsrs.Rating.good,
            correct: true,
          );
        }
        overview = await repo.overview();
        expect(overview.waiting, 0);
        expect(overview.ahead, 1);
        expect(overview.canStudy, isTrue);
        final practice = (await repo.buildSession()).single;
        expect(practice.ahead, isTrue);
        expect(practice.isNew, isFalse);
      },
    );

    test('new facts take turns across topics, empty topics first', () async {
      final other = await db
          .into(db.sections)
          .insert(
            SectionsCompanion.insert(
              documentId: documentId,
              title: 'Energy',
              level: 1,
              ord: 1,
              pageStart: 2,
              pageEnd: 2,
            ),
          );
      // Three important facts in Cells, one less important in Energy.
      for (var i = 0; i < 3; i++) {
        await addFact('cell fact $i', importance: 3);
      }
      sectionId = other;
      await addFact('energy fact', importance: 1);
      final session = await repo.buildSession();
      final topics = session.map((i) => i.fact.sectionId).toList();
      // Without turn-taking the Energy fact would come last of four.
      expect(topics.take(2).toSet(), hasLength(2));
    });
  });

  group('unseen questions', () {
    /// Reviews a fact with [questionId] until it leaves its learning steps.
    Future<void> know(int fact, int questionId) async {
      for (var i = 0; i < 6; i++) {
        final outcome = await repo.recordReview(
          factId: fact,
          questionId: questionId,
          rating: fsrs.Rating.good,
          correct: true,
        );
        if (outcome.state == fsrs.State.review) return;
        now = outcome.due.add(const Duration(minutes: 1));
      }
      fail('the card never graduated');
    }

    test(
      'a known fact that is not due is offered once with a question never asked',
      () async {
        final fact = await addFact('osmosis moves water');
        final first = (await repo.buildSession()).single;
        await know(fact, first.question.id);
        // Not due, but two of its questions were never asked.
        var overview = await repo.overview();
        expect(overview.due, 0);
        expect(overview.unseen, 1);
        expect(overview.waiting, 1);

        final seen = <int>{first.question.id};
        for (var i = 0; i < 2; i++) {
          final session = await repo.buildSession();
          expect(session, hasLength(1));
          expect(session.single.isNew, isFalse);
          expect(session.single.isNewQuestion, isTrue);
          expect(seen.add(session.single.question.id), isTrue);
          await repo.recordReview(
            factId: fact,
            questionId: session.single.question.id,
            rating: fsrs.Rating.good,
            correct: true,
          );
        }
        // All three kinds have been asked: nothing is left to introduce.
        overview = await repo.overview();
        expect(overview.unseen, 0);
        expect(overview.waiting, 0);
        expect(
          await repo.buildSession(),
          everyElement(
            predicate<StudyItem>((i) => i.ahead && !i.isNewQuestion),
          ),
        );
      },
    );

    test(
      'due reviews, new facts and unseen questions share a session',
      () async {
        final known = await addFact('osmosis moves water');
        final item = (await repo.buildSession()).single;
        await know(known, item.question.id);
        await addFact('ATP stores energy');
        final session = await repo.buildSession();
        expect(session.map((i) => i.isNew), [true, false]);
        expect(session.last.isNewQuestion, isTrue);
      },
    );

    test('a new question added to a known fact shows up', () async {
      final fact = await addFact('osmosis moves water');
      await know(fact, (await repo.buildSession()).single.question.id);
      for (var i = 0; i < 2; i++) {
        final item = (await repo.buildSession()).single;
        await repo.recordReview(
          factId: fact,
          questionId: item.question.id,
          rating: fsrs.Rating.good,
          correct: true,
        );
      }
      expect((await repo.buildSession()).single.ahead, isTrue);
      await db
          .into(db.questions)
          .insert(
            QuestionsCompanion.insert(
              factId: fact,
              type: 'mcq',
              depth: 'recall',
              prompt: 'another mcq?',
              answer: 'answer',
              distractorsJson: const Value('["x","y","z"]'),
              quality: 'standard',
              modelId: 'test',
              promptVersion: 1,
            ),
          );
      final session = await repo.buildSession();
      expect(session.single.question.prompt, 'another mcq?');
      expect(session.single.isNewQuestion, isTrue);
    });
  });
}
