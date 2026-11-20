import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/llm/json_text.dart';
import 'package:pdf_study_assistant/core/llm/model_checks.dart';

void main() {
  group('extractJsonObjectText', () {
    test('returns a bare object unchanged', () {
      expect(extractJsonObjectText('{"a": 1}'), '{"a": 1}');
    });

    test('skips code fences and chatter', () {
      const reply = 'Sure! Here it is:\n```json\n{"a": {"b": [1, 2]}}\n```\n';
      expect(extractJsonObjectText(reply), '{"a": {"b": [1, 2]}}');
    });

    test('ignores braces inside strings', () {
      const reply = '{"q": "Is } a brace? \\" {", "n": 2} trailing';
      expect(
        extractJsonObjectText(reply),
        '{"q": "Is } a brace? \\" {", "n": 2}',
      );
    });

    test('returns null for an unfinished object', () {
      expect(extractJsonObjectText('{"a": "cut off'), isNull);
      expect(extractJsonObjectText('no json here'), isNull);
    });
  });

  test('describeJsonShape sketches the MCQ schema', () {
    expect(
      describeJsonShape(mcqSchema),
      '{"quote": "...", "question": "...", "answer": "...", '
      '"distractors": ["...", "...", "..."], "explanation": "..."}',
    );
  });

  test('describeJsonShape shows enums and integer ranges', () {
    expect(
      describeJsonShape({
        'type': 'object',
        'properties': {
          'verdict': {
            'type': 'string',
            'enum': ['supports', 'contradicts'],
          },
          'importance': {'type': 'integer', 'minimum': 1, 'maximum': 3},
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
      }),
      '{"verdict": "supports" | "contradicts", "importance": <integer 1-3>, '
      '"tags": ["...", ...]}',
    );
  });
}
