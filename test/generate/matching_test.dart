import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/text/matching.dart';

const _source =
    'Osmosis is the movement of water across a selectively permeable '
    'membrane, from a region where water is more concentrated to a region '
    'where it is less concentrated.\n\nA solution with a lower solute '
    'concentration than the cytoplasm is called hypotonic, and a cell placed '
    'in it swells as water flows in. Animal cells, which lack a cell wall, '
    'can burst.';

void main() {
  group('findQuote', () {
    test('exact match returns the source span and its own text', () {
      final match = findQuote(
        _source,
        'Animal cells, which lack a cell wall, can burst.',
      )!;
      expect(match.isExact, isTrue);
      expect(match.text, 'Animal cells, which lack a cell wall, can burst.');
      expect(_source.substring(match.start, match.end), match.text);
    });

    test('tolerates quotes, case, line breaks and a missing period', () {
      final match = findQuote(
        _source,
        '"osmosis is the movement of water across a selectively permeable '
        'membrane, from a region where water is MORE concentrated to a '
        'region where it is less concentrated"',
      )!;
      expect(match.isExact, isTrue);
      expect(match.text, startsWith('Osmosis is the movement'));
      expect(match.text, endsWith('less concentrated.'));
    });

    test('curly apostrophes and dashes match straight ones', () {
      const text = 'The cell’s membrane — a thin layer — controls entry.';
      expect(
        findQuote(
          text,
          "The cell's membrane - a thin layer - controls entry",
        )?.isExact,
        isTrue,
      );
    });

    test('accepts a near-verbatim copy with a word changed', () {
      final match = findQuote(
        _source,
        'A solution with a lower solute concentration than the cytoplasm is '
        'named hypotonic, and a cell placed in it swells as water flows in.',
      );
      expect(match, isNotNull);
      expect(match!.score, greaterThan(0.85));
      expect(match.text, contains('is called hypotonic'));
    });

    test('refuses a copy that adds a negation', () {
      expect(
        findQuote(
          _source,
          'A solution with a lower solute concentration than the cytoplasm '
          'is not called hypotonic, and a cell placed in it swells as water '
          'flows in.',
        ),
        isNull,
      );
    });

    test('refuses an invented sentence', () {
      expect(findQuote(_source, 'Osmosis requires ATP to move water.'), isNull);
    });
  });

  group('words and similarity', () {
    test('contentWords drops stopwords and plural s', () {
      expect(contentWords('The membranes of the cells'), {'membrane', 'cell'});
    });

    test('similarity and coverage', () {
      expect(
        similarity('higher solute concentration', 'high solute concentration'),
        greaterThan(0.6),
      );
      expect(similarity('Hypotonic', 'Isotonic'), 0);
      expect(coverage('lower solute concentration', _source), 1.0);
      expect(coverage('requires ATP energy', _source), lessThan(0.5));
    });

    test('containsPhrase matches whole words only', () {
      expect(containsPhrase('Water flows into the cell.', 'the cell'), isTrue);
      expect(containsPhrase('Cellular respiration', 'cell'), isFalse);
    });
  });
}
