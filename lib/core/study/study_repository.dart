import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

import '../db/database.dart';
import '../text/matching.dart';
import 'mastery.dart';

/// One fact to review in a session, with the question chosen to ask it.
class StudyItem {
  const StudyItem({
    required this.fact,
    required this.question,
    required this.isNew,
    this.pageStart,
    this.headingPath,
  });

  final Fact fact;
  final Question question;
  final bool isNew;
  final int? pageStart;
  final String? headingPath;

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
  });

  final int due;
  final int newAvailable;
  final int reviewedToday;
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

  /// Due cards first (most overdue first), then new facts up to the daily
  /// limit, interleaved so topics mix.
  Future<List<StudyItem>> buildSession({
    int? documentId,
    int? sectionId,
    int newPerDay = 20,
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

    final newToday = await _newStartedToday();
    final newBudget = math.max(0, newPerDay - newToday);
    final fresh =
        [
          for (final id in ids)
            if (!carded.contains(id)) scope[id]!,
        ]..sort((a, b) {
          final byImportance = b.importance.compareTo(a.importance);
          return byImportance != 0 ? byImportance : a.id.compareTo(b.id);
        });

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

    final session = <StudyItem>[];
    var d = 0, n = 0;
    while (session.length < maxItems &&
        (d < dueItems.length || n < newItems.length)) {
      // Two reviews, then one new fact.
      for (var k = 0; k < 2 && d < dueItems.length; k++) {
        session.add(dueItems[d++]);
      }
      if (n < newItems.length) session.add(newItems[n++]);
    }
    return session.take(maxItems).toList();
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
    final lastAsked = avoidQuestionId ?? await _lastQuestionId(fact.id);
    final question = chooseQuestion(
      questions,
      reviewed: card != null,
      stable: (card?.stability ?? 0) >= 7,
      lastQuestionId: lastAsked,
    );
    final chunk = await (db.select(
      db.chunks,
    )..where((c) => c.id.equals(fact.chunkId))).getSingleOrNull();
    return StudyItem(
      fact: fact,
      question: question,
      isNew: card == null,
      pageStart: chunk?.pageStart,
      headingPath: chunk?.headingPath,
    );
  }

  /// New facts start with multiple choice when there is one (recognition
  /// first); well-known facts get recall (cloze, flashcard). The question
  /// asked last time is avoided so the wording isn't memorized.
  static Question chooseQuestion(
    List<Question> questions, {
    required bool reviewed,
    required bool stable,
    int? lastQuestionId,
  }) {
    List<Question> ofType(String type) =>
        questions.where((q) => q.type == type).toList();
    final order = !reviewed
        ? ['mcq', 'flashcard', 'cloze']
        : stable
        ? ['cloze', 'flashcard', 'mcq']
        : ['flashcard', 'mcq', 'cloze'];
    final candidates = [
      for (final type in order) ...ofType(type),
    ].where((q) => q.id != lastQuestionId).toList();
    return candidates.isNotEmpty ? candidates.first : questions.first;
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
