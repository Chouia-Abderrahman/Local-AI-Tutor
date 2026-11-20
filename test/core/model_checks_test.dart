import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/llm/fake_llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/model_checks.dart';

Map<String, Object?> _goodQuestion() => {
  'quote':
      'A solution with a lower solute concentration than the cell\'s '
      'cytoplasm is called hypotonic.',
  'question': 'What is a solution with a lower solute concentration called?',
  'answer': 'Hypotonic',
  'distractors': ['Hypertonic', 'Isotonic', 'Saturated'],
  'explanation': 'Hypo means below: fewer solutes than the cytoplasm.',
};

void main() {
  group('basicQuestionProblems', () {
    test('accepts a well-formed question', () {
      expect(basicQuestionProblems(_goodQuestion(), samplePassage), isEmpty);
    });

    test('tolerates case and whitespace differences in the quote', () {
      final q = _goodQuestion()
        ..['quote'] =
            'a solution with a LOWER solute   concentration than the cell\'s '
            'cytoplasm is called hypotonic';
      expect(basicQuestionProblems(q, samplePassage), isEmpty);
    });

    test('flags an invented quote', () {
      final q = _goodQuestion()..['quote'] = 'Osmosis requires ATP.';
      expect(
        basicQuestionProblems(q, samplePassage),
        contains(contains('not copied exactly')),
      );
    });

    test('flags a distractor equal to the answer and duplicates', () {
      final q = _goodQuestion()
        ..['distractors'] = ['hypotonic', 'Isotonic', 'Isotonic'];
      final problems = basicQuestionProblems(q, samplePassage);
      expect(problems, contains(contains('same as the right one')));
      expect(problems, contains(contains('Two wrong answers')));
    });

    test('flags a question that contains its answer', () {
      final q = _goodQuestion()
        ..['question'] = 'Is a hypotonic solution lower in solutes?';
      expect(
        basicQuestionProblems(q, samplePassage),
        contains(contains('gives away')),
      );
    });
  });

  group('ModelChecks', () {
    test('question() sends the passage first and checks the reply', () async {
      final engine = FakeLlmEngine()..enqueue(_goodQuestion());
      final check = await ModelChecks(engine).question();
      expect(check.ok, isTrue);
      final call = engine.calls.single;
      expect(call.schema, same(mcqSchema));
      expect(call.messages.first.role, LlmRole.system);
      // The passage comes before the task so its cache can be reused.
      final user = call.userText;
      expect(user.indexOf(samplePassage), lessThan(user.indexOf('Write one')));
    });

    test('speed() runs the full sequence on any engine', () async {
      final engine = FakeLlmEngine(
        responder: (messages, schema) =>
            schema == null ? 'ok' : _goodQuestion(),
      );
      final steps = <String>[];
      final result = await ModelChecks(engine).speed(onStep: steps.add);
      expect(steps, hasLength(5));
      expect(result.question.ok, isTrue);
      expect(engine.calls, hasLength(5));
    });
  });
}
