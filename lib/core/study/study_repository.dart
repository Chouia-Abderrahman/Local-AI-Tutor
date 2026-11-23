import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

import '../db/database.dart';
import '../generate/improve.dart';
import '../generate/prompts.dart' show promptVersion;
import '../text/matching.dart';
import 'mastery.dart';

/// One fact to review in a session, with the question chosen to ask it.
class StudyItem {
  const StudyItem({
    required this.fact,
    required this.question,
    required this.isNew,
    this.isNewQuestion = false,
    this.ahead = false,
    this.pageStart,
    this.headingPath,
  });

  final Fact fact;
  final Question question;

  /// The fact has no card yet.
  final bool isNew;

  /// The fact is known, but this question has never been asked.
  final bool isNewQuestion;

  /// Extra practice: the fact isn't due yet.
  final bool ahead;
  final int? pageStart;
  final String? headingPath;

  /// The same item with [question] swapped for an improved version.
  StudyItem withQuestion(Question question) => StudyItem(
    fact: fact,
    question: question,
    isNew: isNew,
    isNewQuestion: isNewQuestion,
    ahead: ahead,
    pageStart: pageStart,
    headingPath: headingPath,
  );

  List<String> get distractors => question.distractorsJson == null
      ? const []
      : [for (final d in jsonDecode(question.distractorsJson!) as List) '$d'];

  /// Explanation and, at Deep quality, why each wrong answer is wrong.
  (String?, List<String>) get explanation {
    final raw = question.explanation;
    if (raw == null || !raw.startsWith('{')) return (raw, const []);
    final json = jsonDecode(raw) as Map;
    return (
      json['why'] as String?,
      [for (final n in (json['why_wrong'] as List? ?? const [])) '$n'],
    );
  }
}

class StudyOverview {
  const StudyOverview({
    required this.due,
    required this.newAvailable,
    required this.reviewedToday,
    this.unseen = 0,
    this.ahead = 0,
  });

  final int due;
  final int newAvailable;
  final int reviewedToday;

  /// Facts that are not due but still have a question never asked.
  final int unseen;

  /// Known facts that aren't due, which can be studied ahead of schedule.
  final int ahead;

  /// What is waiting by the schedule.
  int get waiting => due + newAvailable + unseen;

  /// Whether a session has anything to offer: what is waiting, or else
  /// extra practice.
  bool get canStudy => waiting + ahead > 0;
}

/// How often and when a question was asked.
class QuestionAsks {
  const QuestionAsks(this.count, this.last);

  final int count;
  final DateTime? last;
}

class ReviewOutcome {
  const ReviewOutcome({required this.due, required this.state});

  final DateTime due;
  final fsrs.State state;

  /// Due again within the session (a learning step), so it comes back.
  bool dueSoon(DateTime now) =>
      state != fsrs.State.review && due.difference(now).inMinutes <= 15;
}

/// Maps a multiple-choice answer to an FSRS rating. Recognizing an answer is
/// weaker evidence than recalling it, so it never earns Easy.
fsrs.Rating ratingForChoice({
  required bool correct,
  bool unsure = false,
  bool slow = false,
}) {
  if (!correct) return fsrs.Rating.again;
  return unsure || slow ? fsrs.Rating.hard : fsrs.Rating.good;
}

/// Whether a typed cloze answer counts: same words, or one typo in a longer
/// answer.
bool typedAnswerMatches(String typed, String answer) {
  final a = normalizeForMatch(
    typed,
  ).replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), '');
  final b = normalizeForMatch(
    answer,
  ).replaceAll(RegExp(r'[^\p{L}\p{N} ]', unicode: true), '');
  if (a.isEmpty) return false;
  if (a == b) return true;
  if (b.length >= 5 && _editDistance(a, b) <= 1) return true;
  return b.length >= 12 && _editDistance(a, b) <= 2;
}

int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
      ].reduce(math.min);
    }
    previous = current;
  }
  return previous[b.length];
}

/// Spaced-repetition state and sessions. One FSRS card per fact; each review
/// asks one of the fact's questions.
class StudyRepository {
  StudyRepository(
    this.db, {
    fsrs.Scheduler? scheduler,
    DateTime Function()? clock,
  }) : scheduler = scheduler ?? fsrs.Scheduler(),
       _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final fsrs.Scheduler scheduler;
  final DateTime Function() _clock;

  DateTime get _now => _clock().toUtc();

  DateTime get _startOfToday {
    final local = _clock().toLocal();
    return DateTime(local.year, local.month, local.day).toUtc();
  }

  /// Due cards first (most overdue first), then new facts, then facts that
  /// are known but have a question never asked. They are interleaved: two
  /// reviews, one new fact, one unseen question. New facts take turns across
  /// topics, topics with nothing started first, so none is left out.
  ///
  /// There is no daily limit unless [newPerDay] sets one. When nothing is
  /// due, new or unseen, the session offers known facts ahead of schedule,
  /// soonest due first, so there is always more to study.
  Future<List<StudyItem>> buildSession({
    int? documentId,
    int? sectionId,
    int? newPerDay,
    int maxItems = 40,
  }) async {
    final scope = await _scopedFacts(documentId, sectionId);
    if (scope.isEmpty) return const [];
    final ids = scope.keys.toList();

    final cards = await (db.select(
      db.factCards,
    )..where((c) => c.factId.isIn(ids))).get();
    final now = _now;
    final due = [
      for (final c in cards)
        if (!c.due.isAfter(now)) c,
    ]..sort((a, b) => a.due.compareTo(b.due));
    final carded = {for (final c in cards) c.factId};

    final newBudget = newPerDay == null
        ? maxItems
        : math.max(0, newPerDay - await _newStartedToday());
    final fresh = _takeTurns(scope, carded);

    final dueItems = <StudyItem>[];
    for (final card in due) {
      final item = await _itemFor(scope[card.factId]!, card);
      if (item != null) dueItems.add(item);
    }
    final newItems = <StudyItem>[];
    for (final fact in fresh) {
      if (newItems.length >= newBudget) break;
      final item = await _itemFor(fact, null);
      if (item != null) newItems.add(item);
    }
    // Known facts that aren't due, soonest first, that still have a question
    // nobody has asked yet.
    final unseenIds = await _factsWithUnseenQuestions([
      for (final c in cards)
        if (_canIntroduceQuestions(c, now)) c.factId,
    ]);
    final unseenItems = <StudyItem>[];
    for (final card
        in cards.where((c) => unseenIds.contains(c.factId)).toList()
          ..sort((a, b) => a.due.compareTo(b.due))) {
      if (unseenItems.length >= maxItems) break;
      final item = await _itemFor(scope[card.factId]!, card);
      if (item != null && item.isNewQuestion) unseenItems.add(item);
    }

    if (dueItems.isEmpty && newItems.isEmpty && unseenItems.isEmpty) {
      // Nothing waiting: practice ahead of schedule.
      final taken = <StudyItem>[];
      for (final card in [...cards]..sort((a, b) => a.due.compareTo(b.due))) {
        if (taken.length >= maxItems) break;
        final item = await _itemFor(scope[card.factId]!, card);
        if (item != null) {
          taken.add(
            StudyItem(
              fact: item.fact,
              question: item.question,
              isNew: false,
              isNewQuestion: item.isNewQuestion,
              ahead: true,
              pageStart: item.pageStart,
              headingPath: item.headingPath,
            ),
          );
        }
      }
      return taken;
    }

    final session = <StudyItem>[];
    var d = 0, n = 0, u = 0;
    while (session.length < maxItems &&
        (d < dueItems.length ||
            n < newItems.length ||
            u < unseenItems.length)) {
      for (var k = 0; k < 2 && d < dueItems.length; k++) {
        session.add(dueItems[d++]);
      }
      if (n < newItems.length) session.add(newItems[n++]);
      if (u < unseenItems.length) session.add(unseenItems[u++]);
    }
    return session.take(maxItems).toList();
  }

  /// Facts with no card yet, ordered so that topics take turns: the topic
  /// with the fewest facts started goes first, and within a topic the most
  /// important fact does.
  List<Fact> _takeTurns(Map<int, Fact> scope, Set<int> carded) {
    final started = <int, int>{};
    final waiting = <int, List<Fact>>{};
    for (final fact in scope.values) {
      if (carded.contains(fact.id)) {
        started[fact.sectionId] = (started[fact.sectionId] ?? 0) + 1;
      } else {
        waiting.putIfAbsent(fact.sectionId, () => []).add(fact);
      }
    }
    for (final facts in waiting.values) {
      facts.sort((a, b) {
        final byImportance = b.importance.compareTo(a.importance);
        return byImportance != 0 ? byImportance : a.id.compareTo(b.id);
      });
    }
    final topics = waiting.keys.toList()
      ..sort((a, b) {
        final byStarted = (started[a] ?? 0).compareTo(started[b] ?? 0);
        return byStarted != 0 ? byStarted : a.compareTo(b);
      });
    final result = <Fact>[];
    for (var round = 0; result.length < scope.length; round++) {
      var added = false;
      for (final topic in topics) {
        if (round < waiting[topic]!.length) {
          result.add(waiting[topic]![round]);
          added = true;
        }
      }
      if (!added) break;
    }
    return result;
  }

  /// The next question for a fact that was just answered, if it comes back
  /// in the same session.
  Future<StudyItem?> nextItemFor(int factId, {int? avoidQuestionId}) async {
    final fact = await (db.select(
      db.facts,
    )..where((f) => f.id.equals(factId))).getSingleOrNull();
    if (fact == null || fact.status != 'active') return null;
    final card = await (db.select(
      db.factCards,
    )..where((c) => c.factId.equals(factId))).getSingleOrNull();
    return _itemFor(fact, card, avoidQuestionId: avoidQuestionId);
  }

  Future<StudyItem?> _itemFor(
    Fact fact,
    FactCard? card, {
    int? avoidQuestionId,
  }) async {
    final questions =
        await (db.select(db.questions)..where(
              (q) => q.factId.equals(fact.id) & q.status.equals('active'),
            ))
            .get();
    if (questions.isEmpty) return null;
    final asks = await _asks(fact.id);
    final question = chooseQuestion(
      questions,
      reviewed: card != null,
      stable: (card?.stability ?? 0) >= 7,
      lastQuestionId: avoidQuestionId ?? await _lastQuestionId(fact.id),
      asks: asks,
    );
    final chunk = await (db.select(
      db.chunks,
    )..where((c) => c.id.equals(fact.chunkId))).getSingleOrNull();
    return StudyItem(
      fact: fact,
      question: question,
      isNew: card == null,
      isNewQuestion: card != null && !asks.containsKey(question.id),
      pageStart: chunk?.pageStart,
      headingPath: chunk?.headingPath,
    );
  }

  /// Picks the question to ask for a fact so that all of them get their turn:
  /// the one asked the fewest times, then the one asked longest ago (never
  /// asked comes first). Only then does the kind decide: multiple choice
  /// leads, recall questions (typed cloze, then flashcard) fill in behind it,
  /// and a fact that is well known (stable) goes to recall after a multiple
  /// choice. The question asked last time is skipped when another exists, so
  /// a missed fact is worded differently.
  static Question chooseQuestion(
    List<Question> questions, {
    required bool reviewed,
    required bool stable,
    int? lastQuestionId,
    Map<int, QuestionAsks> asks = const {},
  }) {
    final lastType = lastQuestionId == null
        ? null
        : questions.where((q) => q.id == lastQuestionId).firstOrNull?.type;
    final order = !reviewed
        ? ['mcq', 'flashcard', 'cloze']
        : stable && lastType == 'mcq'
        ? ['cloze', 'flashcard', 'mcq']
        : ['mcq', 'cloze', 'flashcard'];
    final pool = questions.length > 1
        ? [
            for (final q in questions)
              if (q.id != lastQuestionId) q,
          ]
        : questions;
    final never = DateTime.fromMillisecondsSinceEpoch(0);
    final ranked = [...pool]
      ..sort((a, b) {
        final byCount = (asks[a.id]?.count ?? 0).compareTo(
          asks[b.id]?.count ?? 0,
        );
        if (byCount != 0) return byCount;
        final byLast = (asks[a.id]?.last ?? never).compareTo(
          asks[b.id]?.last ?? never,
        );
        if (byLast != 0) return byLast;
        final byType = order.indexOf(a.type).compareTo(order.indexOf(b.type));
        return byType != 0 ? byType : a.id.compareTo(b.id);
      });
    return ranked.first;
  }

  /// How often and when each question of a fact was asked.
  Future<Map<int, QuestionAsks>> _asks(int factId) async {
    final count = db.reviews.id.count();
    final last = db.reviews.reviewedAt.max();
    final rows =
        await (db.selectOnly(db.reviews)
              ..addColumns([db.reviews.questionId, count, last])
              ..where(
                db.reviews.factId.equals(factId) &
                    db.reviews.questionId.isNotNull(),
              )
              ..groupBy([db.reviews.questionId]))
            .get();
    return {
      for (final r in rows)
        r.read(db.reviews.questionId)!: QuestionAsks(
          r.read(count) ?? 0,
          r.read(last),
        ),
    };
  }

  /// A card that has graduated from learning and isn't due can be asked a
  /// question it hasn't had yet. One still in a learning step comes back
  /// soon on its own, and then picks such a question first.
  bool _canIntroduceQuestions(FactCard card, DateTime now) =>
      card.state == fsrs.State.review.name && card.due.isAfter(now);

  /// Of [factIds], those with an active question that was never asked.
  Future<Set<int>> _factsWithUnseenQuestions(List<int> factIds) async {
    if (factIds.isEmpty) return {};
    final result = <int>{};
    // Stay under SQLite's limit on variables.
    for (var i = 0; i < factIds.length; i += 500) {
      final batch = factIds.sublist(i, math.min(i + 500, factIds.length));
      final rows = await db
          .customSelect(
            'SELECT DISTINCT q.fact_id AS id FROM questions q '
            "WHERE q.status = 'active' "
            'AND q.fact_id IN (${List.filled(batch.length, '?').join(',')}) '
            'AND NOT EXISTS (SELECT 1 FROM reviews r WHERE r.question_id = q.id)',
            variables: [for (final id in batch) Variable.withInt(id)],
            readsFrom: {db.questions, db.reviews},
          )
          .get();
      result.addAll([for (final r in rows) r.read<int>('id')]);
    }
    return result;
  }

  /// When a fact would come back after each answer, for the labels on the
  /// answer buttons.
  Future<Map<fsrs.Rating, Duration>> previewDelays(int factId) async {
    final now = _now;
    final existing = await (db.select(
      db.factCards,
    )..where((c) => c.factId.equals(factId))).getSingleOrNull();
    final card = existing == null
        ? fsrs.Card(cardId: factId, due: now)
        : fsrs.Card.fromMap(
            Map<String, dynamic>.from(jsonDecode(existing.fsrsJson) as Map),
          );
    return {
      for (final rating in [
        fsrs.Rating.again,
        fsrs.Rating.hard,
        fsrs.Rating.good,
      ])
        rating: scheduler
            .reviewCard(card, rating, reviewDateTime: now)
            .card
            .due
            .difference(now),
    };
  }

  Future<ReviewOutcome> recordReview({
    required int factId,
    required int questionId,
    required fsrs.Rating rating,
    bool? correct,
    bool unsure = false,
    int? responseMs,
  }) async {
    final now = _now;
    return db.transaction(() async {
      final existing = await (db.select(
        db.factCards,
      )..where((c) => c.factId.equals(factId))).getSingleOrNull();
      final card = existing == null
          ? fsrs.Card(cardId: factId, due: now)
          : fsrs.Card.fromMap(
              Map<String, dynamic>.from(jsonDecode(existing.fsrsJson) as Map),
            );
      final result = scheduler.reviewCard(
        card,
        rating,
        reviewDateTime: now,
        reviewDuration: responseMs,
      );
      final next = result.card;
      await db
          .into(db.factCards)
          .insertOnConflictUpdate(
            FactCardsCompanion.insert(
              factId: Value(factId),
              fsrsJson: jsonEncode(next.toMap()),
              due: next.due,
              stability: Value(next.stability),
              difficulty: Value(next.difficulty),
              state: next.state.name,
              lastReview: Value(next.lastReview),
            ),
          );
      await db
          .into(db.reviews)
          .insert(
            ReviewsCompanion.insert(
              factId: factId,
              questionId: Value(questionId),
              rating: rating.value,
              correct: Value(correct),
              responseMs: Value(responseMs),
              unsure: Value(unsure),
              reviewedAt: now,
            ),
          );
      return ReviewOutcome(due: next.due, state: next.state);
    });
  }

  /// Takes a bad question out of rotation. When the fact itself is wrong,
  /// the fact leaves the schedule too.
  Future<void> report(int questionId, {bool factIsWrong = false}) async {
    final question = await (db.select(
      db.questions,
    )..where((q) => q.id.equals(questionId))).getSingle();
    await (db.update(db.questions)..where((q) => q.id.equals(questionId)))
        .write(const QuestionsCompanion(status: Value('reported')));
    if (factIsWrong) {
      await (db.update(db.facts)..where((f) => f.id.equals(question.factId)))
          .write(const FactsCompanion(status: Value('disputed')));
    }
  }

  /// Replaces a question with an improved version, in place: it keeps its id
  /// and so its history of being asked. Returns the stored question.
  Future<Question> replaceQuestion(
    int questionId,
    QuestionRewrite rewrite, {
    required String modelId,
  }) async {
    await (db.update(
      db.questions,
    )..where((q) => q.id.equals(questionId))).write(
      QuestionsCompanion(
        prompt: Value(rewrite.prompt),
        answer: Value(rewrite.answer),
        distractorsJson: Value(
          rewrite.distractors.isEmpty ? null : jsonEncode(rewrite.distractors),
        ),
        // Notes on each wrong option belonged to the old options.
        explanation: Value(rewrite.explanation),
        modelId: Value(modelId),
        promptVersion: Value(promptVersion),
        checksJson: Value(jsonEncode({'improved': true})),
      ),
    );
    return (db.select(
      db.questions,
    )..where((q) => q.id.equals(questionId))).getSingle();
  }

  Future<StudyOverview> overview({int? documentId}) async {
    final scope = await _scopedFacts(documentId, null);
    final ids = scope.keys.toList();
    if (ids.isEmpty) {
      return const StudyOverview(due: 0, newAvailable: 0, reviewedToday: 0);
    }
    final cards = await (db.select(
      db.factCards,
    )..where((c) => c.factId.isIn(ids))).get();
    final now = _now;
    final unseen = await _factsWithUnseenQuestions([
      for (final c in cards)
        if (_canIntroduceQuestions(c, now)) c.factId,
    ]);
    final reviewedToday =
        await (db.selectOnly(db.reviews)
              ..addColumns([db.reviews.id.count()])
              ..where(
                db.reviews.reviewedAt.isBiggerOrEqualValue(_startOfToday) &
                    db.reviews.factId.isIn(ids),
              ))
            .map((row) => row.read(db.reviews.id.count()) ?? 0)
            .getSingle();
    return StudyOverview(
      due: cards.where((c) => !c.due.isAfter(now)).length,
      newAvailable: ids.length - cards.length,
      reviewedToday: reviewedToday,
      unseen: unseen.length,
      ahead: cards.where((c) => c.due.isAfter(now)).length - unseen.length,
    );
  }

  /// Active facts with at least one active question, by id. A section
  /// includes its subsections.
  Future<Map<int, Fact>> _scopedFacts(int? documentId, int? sectionId) async {
    final rows = await db
        .customSelect(
          '${sectionId == null ? '' : 'WITH RECURSIVE scope(id) AS (SELECT ? UNION ALL SELECT s.id FROM sections s JOIN scope ON s.parent_id = scope.id) '}'
          'SELECT DISTINCT f.id FROM facts f '
          'JOIN questions q ON q.fact_id = f.id AND q.status = \'active\' '
          "WHERE f.status = 'active' "
          '${documentId == null ? '' : 'AND f.document_id = ? '}'
          '${sectionId == null ? '' : 'AND f.section_id IN (SELECT id FROM scope) '}',
          variables: [
            if (sectionId != null) Variable.withInt(sectionId),
            if (documentId != null) Variable.withInt(documentId),
          ],
          readsFrom: {db.facts, db.questions, db.sections},
        )
        .get();
    final ids = [for (final r in rows) r.read<int>('id')];
    if (ids.isEmpty) return {};
    final facts = await (db.select(
      db.facts,
    )..where((f) => f.id.isIn(ids))).get();
    return {for (final f in facts) f.id: f};
  }

  Future<int> _newStartedToday() async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM (SELECT fact_id, MIN(reviewed_at) AS first '
          'FROM reviews GROUP BY fact_id) WHERE first >= ?',
          variables: [Variable.withDateTime(_startOfToday)],
          readsFrom: {db.reviews},
        )
        .getSingle();
    return row.read<int>('n');
  }

  Future<int?> _lastQuestionId(int factId) async {
    final review =
        await (db.select(db.reviews)
              ..where((r) => r.factId.equals(factId))
              ..orderBy([
                (r) => OrderingTerm(
                  expression: r.reviewedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return review?.questionId;
  }

  /// Mastery of every section of a document.
  Future<List<TopicMastery>> mastery(int documentId) async {
    final sections = await (db.select(
      db.sections,
    )..where((s) => s.documentId.equals(documentId))).get();
    final facts =
        await (db.select(db.facts)..where(
              (f) =>
                  f.documentId.equals(documentId) & f.status.equals('active'),
            ))
            .get();
    final cards = facts.isEmpty
        ? const <FactCard>[]
        : await (db.select(
            db.factCards,
          )..where((c) => c.factId.isIn([for (final f in facts) f.id]))).get();
    return computeMastery(
      sections: sections,
      facts: facts,
      cards: cards,
      scheduler: scheduler,
      now: _clock(),
    );
  }

  /// Predicted probability of recalling each fact now (0 for unseen facts).
  Future<Map<int, double>> recallNow(Iterable<int> factIds) async {
    final cards = await (db.select(
      db.factCards,
    )..where((c) => c.factId.isIn(factIds.toList()))).get();
    final now = _now;
    return {
      for (final c in cards)
        c.factId: scheduler.getCardRetrievability(
          fsrs.Card.fromMap(
            Map<String, dynamic>.from(jsonDecode(c.fsrsJson) as Map),
          ),
          currentDateTime: now,
        ),
    };
  }
}
