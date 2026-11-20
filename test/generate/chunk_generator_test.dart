import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/generate/checks.dart';
import 'package:pdf_study_assistant/core/generate/chunk_generator.dart';
import 'package:pdf_study_assistant/core/generate/json_model.dart';
import 'package:pdf_study_assistant/core/generate/profile.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

const _passage =
    'Osmosis is the movement of water across a selectively permeable '
    'membrane, from a region where water is more concentrated to a region '
    'where it is less concentrated. A solution with a lower solute '
    'concentration than the cytoplasm is called hypotonic, and a cell placed '
    'in it swells as water flows in. Animal cells, which lack a cell wall, '
    'can burst.';

const _input = PassageInput(
  chunkId: 1,
  text: _passage,
  headingPath: 'Cells › Osmosis',
  language: 'en',
);

typedef _Handler = Map<String, Object?> Function(String userText);

class _ScriptedModel implements JsonModel {
  _ScriptedModel(this.handlers);

  final Map<String, _Handler> handlers;
  final List<String> stages = [];

  @override
  String get modelName => 'scripted';

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) async {
    stages.add(stage);
    final handler = handlers[stage];
    if (handler == null) throw StateError('No handler for $stage');
    return handler(messages.last.text);
  }
}

/// Answers a blind prompt: picks the option equal to [correct][question],
/// or a wrong one for questions listed in [wrongFor].
_Handler _blind(
  Map<String, String> correct, {
  Set<String> wrongFor = const {},
}) => (text) {
  final answers = <Map<String, Object?>>[];
  final blocks = RegExp(
    r'^(\d+)\. (.+)\nA\) (.+)\nB\) (.+)\nC\) (.+)\nD\) (.+)$',
    multiLine: true,
  ).allMatches(text);
  for (final block in blocks) {
    final question = block.group(2)!;
    final options = [for (var i = 3; i <= 6; i++) block.group(i)!];
    var index = options.indexOf(correct[question] ?? '');
    if (wrongFor.contains(question)) index = (index + 1) % 4;
    answers.add({
      'question': int.parse(block.group(1)!),
      'choice': 'ABCD'[index],
    });
  }
  return {'answers': answers};
};

Map<String, Object?> _mcq(int fact, String q, String a, List<String> d) => {
  'fact': fact,
  'question': q,
  'answer': a,
  'distractors': d,
  'explanation': 'Because the passage says so.',
};

void main() {
  group('facts stage', () {
    test('keeps verified facts, builds cloze cards and flashcards', () async {
      final model = _ScriptedModel({
        'facts': (_) => {
          'facts': [
            {
              // Quoted with quotation marks and lowercase: still found.
              'quote':
                  '"a solution with a lower solute concentration than the cytoplasm is called hypotonic, and a cell placed in it swells as water flows in"',
              'statement':
                  'A hypotonic solution has fewer solutes than the cytoplasm.',
              'key_term': 'hypotonic',
              'importance': 3,
              'front':
                  'What is a solution with fewer solutes than the cytoplasm called?',
              'back': 'Hypotonic',
            },
            {
              'quote': 'Osmosis requires energy from ATP.',
              'statement': 'Invented.',
              'key_term': 'ATP',
              'importance': 2,
              'front': 'What does osmosis need?',
              'back': 'ATP',
            },
            {
              'quote':
                  'A solution with a lower solute concentration than the cytoplasm is called hypotonic, and a cell placed in it swells as water flows in.',
              'statement':
                  'A hypotonic solution has fewer solutes than the cytoplasm.',
              'key_term': 'hypotonic',
              'importance': 2,
              'front': 'Duplicate?',
              'back': 'Yes',
            },
            {
              'quote': 'Animal cells, which lack a cell wall, can burst.',
              'statement': 'Animal cells can burst because they have no wall.',
              'key_term': 'cell wall',
              'importance': 2,
              'front': 'Why can animal cells burst?',
              'back': 'They lack a cell wall',
            },
          ],
        },
      });
      final result = await ChunkGenerator(
        model: model,
        profile: GenerationProfile.preset(Quality.quick),
      ).facts(_input);

      expect(result.facts, hasLength(2));
      final first = result.facts.first;
      expect(first.quote, startsWith('A solution with a lower'));
      expect(_passage.substring(first.quoteStart, first.quoteEnd), first.quote);
      expect(first.importance, 3);

      final reasons = result.rejections.map((r) => r.reason);
      expect(reasons, containsAll(['quoteNotFound', 'duplicateFact']));

      final types = result.questions.map((q) => q.type).toList();
      expect(types.where((t) => t == QuestionType.cloze), hasLength(2));
      expect(types.where((t) => t == QuestionType.flashcard), hasLength(2));
      final cloze = result.questions.firstWhere(
        (q) => q.type == QuestionType.cloze,
      );
      expect(cloze.prompt, contains('is called _____'));
      expect(cloze.answer, 'hypotonic');
      expect(model.stages, ['facts']);
    });
  });

  group('questions stage', () {
    const facts = [
      FactInput(
        id: 10,
        statement: 'A hypotonic solution has fewer solutes than the cytoplasm.',
        quote:
            'A solution with a lower solute concentration than the cytoplasm is called hypotonic, and a cell placed in it swells as water flows in.',
      ),
      FactInput(
        id: 11,
        statement: 'Animal cells can burst because they have no wall.',
        quote: 'Animal cells, which lack a cell wall, can burst.',
      ),
    ];
    const q1 =
        'What is a solution with fewer solutes than the cytoplasm called?';
    const q2 = 'What can happen to an animal cell in such a solution?';

    test('Standard: code checks, then the blind check decides', () async {
      final model = _ScriptedModel({
        'mcq': (_) => {
          'questions': [
            _mcq(1, q1, 'Hypotonic', ['Hypertonic', 'Isotonic', 'Saturated']),
            _mcq(2, q2, 'It can burst', [
              'It shrinks',
              'It stays the same',
              'It divides',
            ]),
            // Rejected by code: a wrong answer that the passage says is true.
            _mcq(2, 'Which is true of animal cells?', 'They have membranes', [
              'Animal cells, which lack a cell wall, can burst',
              'They glow',
              'They float',
            ]),
          ],
        },
        'blind': _blind({q1: 'Hypotonic', q2: 'It can burst'}, wrongFor: {q2}),
      });
      final result = await ChunkGenerator(
        model: model,
        profile: GenerationProfile.preset(Quality.standard),
      ).questions(_input, facts);

      expect(result.questions.map((q) => q.prompt), [q1]);
      final kept = result.questions.single;
      expect(kept.type, QuestionType.mcq);
      expect(kept.factIndex, 0);
      expect(kept.checks['blind'], 1);
      final reasons = result.rejections.map((r) => r.reason).toList();
      expect(reasons, contains(CheckFailure.distractorTrueInSource.name));
      expect(reasons, contains(CheckFailure.blindMismatch.name));
      expect(model.stages, ['mcq', 'blind']);
    });

    test(
      'Thorough: the critique rewrites a question the blind check failed',
      () async {
        const fixed = 'In which solution can an animal cell burst?';
        final model = _ScriptedModel({
          'mcq': (_) => {
            'questions': [
              _mcq(1, q1, 'Hypotonic', ['Hypertonic', 'Isotonic', 'Saturated']),
              _mcq(
                1,
                'Which solution has fewer solutes than the cytoplasm?',
                'A hypotonic one',
                ['A hypertonic one', 'An isotonic one', 'A saturated one'],
              ),
              _mcq(2, q2, 'It can burst', [
                'It shrinks',
                'It stays the same',
                'It divides',
              ]),
            ],
          },
          'blind': _blind(
            {
              q1: 'Hypotonic',
              'Which solution has fewer solutes than the cytoplasm?':
                  'A hypotonic one',
              q2: 'It can burst',
              fixed: 'Hypotonic',
            },
            wrongFor: {q2},
          ),
          // Reviews are matched to questions by their text, not position.
          'critique': (text) => {
            'reviews': [
              for (final m in RegExp(
                r'^(\d+)\. (.+)$',
                multiLine: true,
              ).allMatches(text))
                if (m.group(2) == q2)
                  {
                    'question': int.parse(m.group(1)!),
                    'ok': false,
                    'problem': 'Ambiguous: shrinking is also possible.',
                    'fixed_question': fixed,
                    'fixed_answer': 'Hypotonic',
                    'fixed_distractors': [
                      'Hypertonic',
                      'Isotonic',
                      'Concentrated',
                    ],
                    'fixed_explanation':
                        'Water flows in until the cell bursts.',
                  }
                else
                  {
                    'question': int.parse(m.group(1)!),
                    'ok': true,
                    'problem': '',
                  },
            ],
          },
        });
        final result = await ChunkGenerator(
          model: model,
          profile: GenerationProfile.preset(Quality.thorough),
        ).questions(_input, facts);

        // One question per fact: the best of fact 1's two candidates, and
        // fact 2's rewritten question.
        expect(result.questions, hasLength(2));
        final rewritten = result.questions.firstWhere((q) => q.factIndex == 1);
        expect(rewritten.prompt, fixed);
        expect(rewritten.checks['critique'], 'rewritten');
        expect(model.stages, ['mcq', 'blind', 'critique', 'blind']);
      },
    );
  });

  test('profiles drop depths their quality cannot handle', () {
    final quick = GenerationProfile.preset(
      Quality.quick,
      depths: {Depth.recall, Depth.analyze},
    );
    expect(quick.usableDepths, [Depth.recall]);
    final thorough = GenerationProfile.preset(
      Quality.thorough,
      depths: {Depth.apply, Depth.analyze},
    );
    expect(thorough.usableDepths, [Depth.apply, Depth.analyze]);
    final roundTrip = GenerationProfile.fromJson(thorough.toJson());
    expect(roundTrip.usableDepths, thorough.usableDepths);
    expect(roundTrip.critique, isTrue);
  });
}
