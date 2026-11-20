import 'dart:convert';

import 'package:fsrs/fsrs.dart' as fsrs;

import '../db/database.dart';

/// Mastery of one topic (a section with its subsections).
class TopicMastery {
  const TopicMastery({
    required this.section,
    required this.depth,
    required this.facts,
    required this.seen,
    required this.recallSum,
    required this.durable,
    required this.due,
  });

  final Section section;

  /// 0 for top-level topics.
  final int depth;

  /// Active facts in the topic and its subtopics.
  final int facts;
  final int seen;

  /// Sum over facts of the chance of recalling them a week from now
  /// (unseen facts count 0). See [mastery].
  final double recallSum;

  /// Facts with stability of 21 days or more.
  final int durable;
  final int due;

  /// Headline mastery: the chance of still recalling the topic's facts a
  /// week from now, unseen facts counted as 0. Recall "now" would call a
  /// fact you just missed 90%+ known (you have just seen the answer);
  /// looking a week ahead reflects how well it is actually learned, and
  /// still fades when you stop reviewing.
  double get mastery => facts == 0 ? 0 : recallSum / facts;
  double get coverage => facts == 0 ? 0 : seen / facts;
  double get durableShare => facts == 0 ? 0 : durable / facts;
  bool get started => seen > 0;

  /// Too few facts for a confident number.
  bool get fewItems => facts < 3;
}

/// How far ahead [TopicMastery.mastery] looks.
const masteryHorizon = Duration(days: 7);

/// Computes mastery for every section of a document, rolling subsections up
/// into their parents (weighted by fact count).
List<TopicMastery> computeMastery({
  required List<Section> sections,
  required List<Fact> facts,
  required List<FactCard> cards,
  required fsrs.Scheduler scheduler,
  required DateTime now,
}) {
  final utcNow = now.toUtc();
  final cardByFact = {for (final c in cards) c.factId: c};

  // Own (not rolled-up) numbers per section.
  final own = <int, _Tally>{};
  for (final fact in facts) {
    if (fact.status != 'active') continue;
    final tally = own.putIfAbsent(fact.sectionId, _Tally.new);
    tally.facts++;
    final card = cardByFact[fact.id];
    if (card == null) continue;
    tally.seen++;
    final fsrsCard = fsrs.Card.fromMap(
      Map<String, dynamic>.from(jsonDecode(card.fsrsJson) as Map),
    );
    tally.recall += scheduler.getCardRetrievability(
      fsrsCard,
      currentDateTime: utcNow.add(masteryHorizon),
    );
    if ((card.stability ?? 0) >= 21) tally.durable++;
    if (!card.due.isAfter(utcNow)) tally.due++;
  }

  final children = <int?, List<Section>>{};
  for (final s in sections) {
    children.putIfAbsent(s.parentId, () => []).add(s);
  }
  for (final list in children.values) {
    list.sort((a, b) => a.ord.compareTo(b.ord));
  }

  final result = <TopicMastery>[];
  _Tally visit(Section section, int depth) {
    final total = _Tally()..add(own[section.id]);
    final index = result.length;
    result.add(_placeholder(section, depth));
    for (final child in children[section.id] ?? const <Section>[]) {
      total.add(visit(child, depth + 1));
    }
    result[index] = TopicMastery(
      section: section,
      depth: depth,
      facts: total.facts,
      seen: total.seen,
      recallSum: total.recall,
      durable: total.durable,
      due: total.due,
    );
    return total;
  }

  for (final root in children[null] ?? const <Section>[]) {
    visit(root, 0);
  }
  return result;
}

TopicMastery _placeholder(Section section, int depth) => TopicMastery(
  section: section,
  depth: depth,
  facts: 0,
  seen: 0,
  recallSum: 0,
  durable: 0,
  due: 0,
);

class _Tally {
  int facts = 0;
  int seen = 0;
  double recall = 0;
  int durable = 0;
  int due = 0;

  void add(_Tally? other) {
    if (other == null) return;
    facts += other.facts;
    seen += other.seen;
    recall += other.recall;
    durable += other.durable;
    due += other.due;
  }
}
