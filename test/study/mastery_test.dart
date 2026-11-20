import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/study/mastery.dart';
import 'package:pdf_study_assistant/core/study/treemap.dart';

Section _section(int id, String title, {int? parent, int ord = 0}) => Section(
  id: id,
  documentId: 1,
  parentId: parent,
  title: title,
  level: parent == null ? 1 : 2,
  ord: ord,
  pageStart: 1,
  pageEnd: 1,
);

Fact _fact(int id, int section) => Fact(
  id: id,
  documentId: 1,
  chunkId: 1,
  sectionId: section,
  statement: 's$id',
  quote: 'q$id',
  quoteStart: 0,
  quoteEnd: 1,
  keyTerm: 'k',
  importance: 2,
  status: 'active',
  createdAt: DateTime(2026),
);

void main() {
  final scheduler = fsrs.Scheduler(enableFuzzing: false);
  final now = DateTime.utc(2026, 11, 20, 12);

  FactCard reviewed(int factId, fsrs.Rating rating, DateTime at) {
    final result = scheduler.reviewCard(
      fsrs.Card(cardId: factId, due: at),
      rating,
      reviewDateTime: at,
    );
    final card = result.card;
    return FactCard(
      factId: factId,
      fsrsJson: jsonEncode(card.toMap()),
      due: card.due,
      stability: card.stability,
      difficulty: card.difficulty,
      state: card.state.name,
      lastReview: card.lastReview,
    );
  }

  test('topics roll up subtopics; unseen facts count as zero', () {
    final sections = [
      _section(1, 'Cells'),
      _section(2, 'Membranes', parent: 1, ord: 1),
      _section(3, 'Osmosis', parent: 1, ord: 2),
      _section(4, 'Energy', ord: 3),
    ];
    final facts = [
      _fact(1, 2), _fact(2, 2), // membranes: both reviewed
      _fact(3, 3), _fact(4, 3), // osmosis: one reviewed
      _fact(5, 4), // energy: none
    ];
    final cards = [
      reviewed(1, fsrs.Rating.good, now.subtract(const Duration(minutes: 5))),
      reviewed(2, fsrs.Rating.good, now.subtract(const Duration(minutes: 5))),
      reviewed(3, fsrs.Rating.again, now.subtract(const Duration(hours: 3))),
    ];
    final mastery = computeMastery(
      sections: sections,
      facts: facts,
      cards: cards,
      scheduler: scheduler,
      now: now,
    );
    final byTitle = {for (final m in mastery) m.section.title: m};

    expect(mastery.map((m) => (m.section.title, m.depth)), [
      ('Cells', 0),
      ('Membranes', 1),
      ('Osmosis', 1),
      ('Energy', 0),
    ]);
    final membranes = byTitle['Membranes']!;
    expect(membranes.coverage, 1);
    expect(membranes.mastery, inInclusiveRange(0.7, 0.95));

    final osmosis = byTitle['Osmosis']!;
    expect(osmosis.coverage, 0.5);
    expect(osmosis.mastery, lessThan(0.35), reason: 'one lapse, one unseen');
    // A fact just missed counts for less than one just answered right.
    expect(osmosis.recallSum, lessThan(membranes.recallSum / 2));
    expect(osmosis.due, 1);

    final cells = byTitle['Cells']!;
    expect(cells.facts, 4);
    expect(cells.seen, 3);
    expect(
      cells.recallSum,
      closeTo(membranes.recallSum + osmosis.recallSum, 1e-9),
    );

    final energy = byTitle['Energy']!;
    expect(energy.started, isFalse);
    expect(energy.fewItems, isTrue);
  });

  test('squarify fills the area proportionally', () {
    const area = Rect.fromLTWH(0, 0, 300, 200);
    final values = <double>[6, 6, 4, 3, 2, 2, 1];
    final rects = squarify(values, area);
    final total = values.reduce((a, b) => a + b);
    for (final (i, rect) in rects.indexed) {
      expect(
        rect.width * rect.height,
        closeTo(values[i] / total * 60000, 1e-6),
      );
      expect(area.contains(rect.topLeft), isTrue);
      expect(rect.right, lessThanOrEqualTo(300 + 1e-6));
      expect(rect.bottom, lessThanOrEqualTo(200 + 1e-6));
    }
    // Squarified: no sliver rectangles.
    for (final rect in rects) {
      final ratio = rect.longestSide / rect.shortestSide;
      expect(ratio, lessThan(4));
    }
  });
}
