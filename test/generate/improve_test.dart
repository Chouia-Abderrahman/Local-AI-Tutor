import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/chunk_generator.dart';
import 'package:pdf_study_assistant/core/generate/improve.dart';
import 'package:pdf_study_assistant/core/generate/json_model.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

const _quote =
    'A solution with a lower solute concentration than the cytoplasm is '
    'called hypotonic, and a cell placed in it swells as water flows in.';
const _passage =
    'Osmosis is the movement of water across a selectively permeable '
    'membrane, from a region where water is more concentrated to a region '
    'where it is less concentrated. $_quote Animal cells, which lack a cell '
    'wall, can burst.';

const _input = PassageInput(
  chunkId: 1,
  text: _passage,
  headingPath: 'Cells › Osmosis',
  language: 'en',
);

final _fact = Fact(
  id: 1,
  documentId: 1,
  chunkId: 1,
  sectionId: 1,
  statement: 'A hypotonic solution has fewer solutes than the cytoplasm.',
  quote: _quote,
  quoteStart: 0,
  quoteEnd: _quote.length,
  keyTerm: 'hypotonic',
  importance: 2,
  status: 'active',
  createdAt: DateTime(2026),
);

Question _question(
  String type,
  String prompt,
  String answer, [
  String? distractors,
]) => Question(
  id: 7,
  factId: 1,
  type: type,
  depth: 'recall',
  prompt: prompt,
  answer: answer,
  distractorsJson: distractors,
  quality: 'standard',
  modelId: 'old',
  promptVersion: 1,
  status: 'active',
  createdAt: DateTime(2026),
);

/// Answers each request with the next scripted reply of its stage. A blind
/// request picks the option equal to [blindPick] (or the first one).
class _Scripted implements JsonModel {
  _Scripted(this.replies, {this.blindPick});

  final Map<String, List<Map<String, Object?>>> replies;
  final String? blindPick;
  final List<String> stages = [];
  final List<String> prompts = [];
  final List<double> temperatures = [];

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
    prompts.add(messages.last.text);
    temperatures.add(temperature);
    if (stage == 'blind') {
      final options = RegExp(
        r'^([A-D])\) (.+)$',
        multiLine: true,
      ).allMatches(messages.last.text).toList();
      final pick =
          options
              .where((m) => m.group(2) == blindPick)
              .map((m) => m.group(1))
              .firstOrNull ??
          options.first.group(1);
      return {
        'answers': [
          {'question': 1, 'choice': pick},
        ],
      };
    }
    return replies[stage]!.removeAt(0);
  }
}

Map<String, Object?> _mcq({
  String question =
      'What is a solution with fewer solutes than the cytoplasm '
      'called?',
  String answer = 'Hypotonic',
  List<String> distractors = const ['Hypertonic', 'Isotonic', 'Saturated'],
}) => {
  'question': question,
  'answer': answer,
  'distractors': distractors,
  'explanation': 'Hypo means under.',
};

void main() {
  final oldMcq = _question(
    'mcq',
    'Which word is it?',
    'Hypotonic',
    '["Hypertonic","Isotonic","Saturated"]',
  );

  group('multiple choice', () {
    test('a checked rewrite is returned', () async {
      final model = _Scripted({
        'improve': [_mcq()],
      }, blindPick: 'Hypotonic');
      final rewrite = await QuestionImprover(model).improve(
        question: oldMcq,
        fact: _fact,
        passage: _input,
        feedback: 'The wording is unclear',
      );
      expect(rewrite.prompt, startsWith('What is a solution'));
      expect(rewrite.answer, 'Hypotonic');
      expect(rewrite.distractors, hasLength(3));
      expect(rewrite.explanation, 'Hypo means under.');
      expect(model.stages, ['improve', 'blind']);
      // The model saw the old question and what was wrong with it.
      expect(model.prompts.first, contains('Which word is it?'));
      expect(model.prompts.first, contains('The wording is unclear'));
    });

    test('a rewrite that fails a code check gets a second try', () async {
      final model = _Scripted({
        'improve': [
          // A wrong option equal to the answer.
          _mcq(distractors: ['Hypotonic', 'Isotonic', 'Saturated']),
          _mcq(),
        ],
      }, blindPick: 'Hypotonic');
      final rewrite = await QuestionImprover(
        model,
      ).improve(question: oldMcq, fact: _fact, passage: _input);
      expect(rewrite.distractors, contains('Isotonic'));
      expect(model.stages, ['improve', 'improve', 'blind']);
      expect(model.temperatures[1], greaterThan(model.temperatures[0]));
    });

    test('a rewrite the blind check disagrees with is not offered', () async {
      final model = _Scripted({
        'improve': [_mcq(), _mcq()],
      }, blindPick: 'Isotonic');
      await expectLater(
        QuestionImprover(
          model,
        ).improve(question: oldMcq, fact: _fact, passage: _input),
        throwsA(
          isA<ImproveFailure>().having(
            (f) => f.message,
            'message',
            contains('different option'),
          ),
        ),
      );
      expect(model.stages, ['improve', 'blind', 'improve', 'blind']);
    });

    test('copying another question of the document is refused', () async {
      final model = _Scripted({
        'improve': [_mcq(), _mcq()],
      }, blindPick: 'Hypotonic');
      await expectLater(
        QuestionImprover(model).improve(
          question: oldMcq,
          fact: _fact,
          passage: _input,
          otherQuestions: [
            'What is a solution with fewer solutes than the cytoplasm '
                'called? Hypotonic',
          ],
        ),
        throwsA(isA<ImproveFailure>()),
      );
    });

    test('handing back the same question is not an improvement', () async {
      final same = _question(
        'mcq',
        'What is a solution with fewer solutes than the cytoplasm called?',
        'Hypotonic',
        '["Hypertonic","Isotonic","Saturated"]',
      );
      final model = _Scripted({
        'improve': [_mcq(), _mcq()],
      }, blindPick: 'Hypotonic');
      await expectLater(
        QuestionImprover(
          model,
        ).improve(question: same, fact: _fact, passage: _input),
        throwsA(isA<ImproveFailure>()),
      );
    });
  });

  group('flashcards and blanks', () {
    test('a flashcard is rewritten and checked against the source', () async {
      final model = _Scripted({
        'improve': [
          // The answer isn't in the source.
          {'front': 'What is it?', 'back': 'Photosynthesis in chloroplasts'},
          {
            'front': 'What happens to a cell in a hypotonic solution?',
            'back': 'It swells',
          },
        ],
      });
      final rewrite = await QuestionImprover(model).improve(
        question: _question('flashcard', 'Hypo?', 'Under'),
        fact: _fact,
        passage: _input,
      );
      expect(rewrite.prompt, contains('hypotonic solution'));
      expect(rewrite.answer, 'It swells');
      expect(rewrite.distractors, isEmpty);
      expect(model.stages, ['improve', 'improve']);
    });

    test('a blank moves to a different word of the sentence', () async {
      final model = _Scripted({
        'improve': [
          // The same word again, then one that appears twice, then a good one.
          {'term': 'hypotonic'},
          {'term': 'solute concentration'},
        ],
      });
      final rewrite = await QuestionImprover(model).improve(
        question: _question(
          'cloze',
          _quote.replaceFirst('hypotonic', '_____'),
          'hypotonic',
        ),
        fact: _fact,
        passage: _input,
      );
      expect(rewrite.answer, 'solute concentration');
      expect(rewrite.prompt, contains('_____'));
      expect(rewrite.prompt, contains('hypotonic'));
      expect(rewrite.prompt, isNot(contains('solute concentration')));
    });
  });
}
