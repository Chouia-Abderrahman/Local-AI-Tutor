import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/generate/checks.dart';
import 'package:pdf_study_assistant/core/generate/cloze.dart';

const _passage =
    'A solution with a lower solute concentration than the cytoplasm is '
    'called hypotonic, and a cell placed in it swells as water flows in. '
    'Animal cells, which lack a cell wall, can burst. In a hypertonic '
    'solution water leaves the cell and it shrinks.';
const _quote =
    'A solution with a lower solute concentration than the cytoplasm is '
    'called hypotonic, and a cell placed in it swells as water flows in.';
const _statement = 'A hypotonic solution has fewer solutes than the cytoplasm.';

List<CheckFailure> _mcq({
  String question =
      'What is a solution with fewer solutes than the cytoplasm called?',
  String answer = 'Hypotonic',
  List<String> distractors = const ['Hypertonic', 'Isotonic', 'Saturated'],
  String? language = 'en',
  bool grounding = true,
}) => checkMcq(
  question: question,
  answer: answer,
  distractors: distractors,
  quote: _quote,
  statement: _statement,
  passage: _passage,
  language: language,
  requireGrounding: grounding,
);

void main() {
  group('multiple choice', () {
    test('a good question passes', () {
      expect(_mcq(), isEmpty);
    });

    test('a wrong answer the passage says is true is rejected', () {
      expect(
        _mcq(
          distractors: const [
            'Animal cells, which lack a cell wall, can burst',
            'Isotonic',
            'Saturated',
          ],
        ),
        contains(CheckFailure.distractorTrueInSource),
      );
    });

    test('a wrong answer equal to or containing the answer is rejected', () {
      expect(
        _mcq(distractors: const ['hypotonic', 'Isotonic', 'Saturated']),
        contains(CheckFailure.distractorEqualsAnswer),
      );
      expect(
        _mcq(
          distractors: const ['Hypotonic or isotonic', 'Isotonic', 'Saturated'],
        ),
        contains(CheckFailure.distractorContainsAnswer),
      );
    });

    test('"all of the above" is rejected', () {
      expect(
        _mcq(distractors: const ['All of the above', 'Isotonic', 'Saturated']),
        contains(CheckFailure.allOfTheAbove),
      );
    });

    test('a much longer right answer is a (soft) length bias', () {
      final failures = _mcq(
        answer:
            'Hypotonic, because it has a lower solute concentration than the cytoplasm',
      );
      expect(failures, contains(CheckFailure.lengthBias));
      expect(CheckFailure.lengthBias.soft, isTrue);
    });

    test('two wrong answers that say the same thing are flagged', () {
      final failures = _mcq(
        question: 'In which direction does water move during osmosis?',
        answer: 'From lower to higher solute concentration',
        distractors: const [
          'From higher to lower solute concentration',
          'From higher to lower solute concentrations',
          'Only through the cell wall',
        ],
        grounding: false,
      );
      expect(failures, contains(CheckFailure.distractorsSimilar));
      // Opposite directions share every word but are different answers.
      expect(failures, isNot(contains(CheckFailure.distractorEqualsAnswer)));
    });

    test('the same answer with an extra article counts as equal', () {
      expect(
        _mcq(distractors: const ['A hypotonic', 'Isotonic', 'Saturated']),
        contains(CheckFailure.distractorEqualsAnswer),
      );
    });

    test('a question that contains its answer is rejected', () {
      expect(
        _mcq(
          question:
              'Is a hypotonic solution lower in solutes than the cytoplasm?',
        ),
        contains(CheckFailure.answerInQuestion),
      );
    });

    test('an answer not backed by the source is rejected for recall', () {
      expect(
        _mcq(
          answer: 'Mitochondria',
          distractors: const ['Ribosome', 'Nucleus', 'Vacuole'],
        ),
        contains(CheckFailure.answerNotGrounded),
      );
      expect(
        _mcq(
          answer: 'Mitochondria',
          distractors: const ['Ribosome', 'Nucleus', 'Vacuole'],
          grounding: false,
        ),
        isNot(contains(CheckFailure.answerNotGrounded)),
      );
    });

    test('output in another language is rejected', () {
      expect(
        _mcq(
          question:
              'Comment appelle-t-on une solution moins concentrée que le cytoplasme ?',
          answer: 'Une solution hypotonique',
          distractors: const [
            'Une solution hypertonique',
            'Une solution isotonique',
            'Une solution saturée',
          ],
          grounding: false,
        ),
        contains(CheckFailure.languageMismatch),
      );
    });
  });

  group('flashcards', () {
    test('good, empty, ungrounded and give-away cards', () {
      expect(
        checkFlashcard(
          front: 'What is a hypotonic solution?',
          back: 'Lower solute concentration than the cytoplasm',
          quote: _quote,
          statement: _statement,
        ),
        isEmpty,
      );
      expect(
        checkFlashcard(
          front: '',
          back: 'x',
          quote: _quote,
          statement: _statement,
        ),
        [CheckFailure.empty],
      );
      expect(
        checkFlashcard(
          front: 'What powers cells?',
          back: 'Mitochondria make ATP',
          quote: _quote,
          statement: _statement,
        ),
        contains(CheckFailure.answerNotGrounded),
      );
      expect(
        checkFlashcard(
          front: 'Is a hypotonic solution hypotonic?',
          back: 'hypotonic',
          quote: _quote,
          statement: _statement,
        ),
        contains(CheckFailure.answerInQuestion),
      );
    });
  });

  group('cloze', () {
    test('blanks the key term once, keeping the source casing', () {
      final cloze = buildCloze(_quote, 'hypotonic')!;
      expect(cloze.answer, 'hypotonic');
      expect(cloze.prompt, contains('is called $clozeBlank, and'));
    });

    test('multi-word terms tolerate whitespace differences', () {
      final cloze = buildCloze(
        'Proteins act as channels,  pumps and receptors.',
        'channels, pumps',
      )!;
      expect(cloze.answer, 'channels,  pumps');
    });

    test('refuses missing, repeated, stopword-only and oversized terms', () {
      expect(buildCloze(_quote, 'mitochondria'), isNull);
      expect(buildCloze('Water moves and water stays.', 'water'), isNull);
      expect(buildCloze(_quote, 'the'), isNull);
      expect(
        buildCloze('Osmosis is diffusion.', 'Osmosis is diffusion'),
        isNull,
      );
    });
  });
}
