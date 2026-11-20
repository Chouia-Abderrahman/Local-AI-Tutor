// Runs a real model on the development machine. Skipped unless TEST_MODEL
// names a model file; start it with:
//   TEST_MODEL=models/Qwen3.5-0.8B-Q4_K_M.gguf \
//     flutter test --tags model test/integration/model_host_test.dart
@Tags(['model'])
library;

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/llm/llamadart_engine.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/model_checks.dart';

void main() {
  // Runs only when TEST_MODEL names a model file, so a plain `flutter test`
  // stays fast.
  final modelPath = Platform.environment['TEST_MODEL'] ?? '';
  final available = File(modelPath).existsSync();

  test(
    'real model: schema-valid JSON, streaming and speed',
    () async {
      final engine = LlamadartEngine();
      addTearDown(engine.dispose);
      await engine.load(modelPath);
      print('model: ${engine.modelName} on ${await engine.backendName()}');

      final streamed = StringBuffer();
      LlmChunk? last;
      await for (final chunk in engine.stream(const [
        LlmMessage.user('Name three parts of a plant cell, comma-separated.'),
      ], params: const LlmParams(maxTokens: 40))) {
        streamed.write(chunk.text);
        last = chunk;
      }
      print('streamed: ${streamed.toString().trim()}');
      expect(streamed.toString().trim(), isNotEmpty);
      expect(last?.isLast, isTrue);

      final speed = await ModelChecks(engine).speed(onStep: print);
      print(
        'read ${speed.readTokensPerSecond.toStringAsFixed(1)} tok/s, '
        'write ${speed.writeTokensPerSecond.toStringAsFixed(1)} tok/s, '
        'first question ${speed.firstQuestion.inMilliseconds} ms, '
        'next question ${speed.nextQuestion.inMilliseconds} ms, '
        'prompt reused ${speed.cachedPromptShare}',
      );
      print('question: ${speed.question.json}');
      print('problems: ${speed.question.problems}');
      print('needed the slow constrained retry: ${speed.question.usedGrammar}');

      expect(speed.writeTokensPerSecond, greaterThan(0));
      expect(speed.question.json['distractors'], hasLength(3));
      // Qwen3.5 is a hybrid (recurrent + attention) model, so llama.cpp
      // cannot reuse a cached prompt prefix; cachedPromptShare is 0 there.
    },
    skip: modelPath.isEmpty
        ? 'Set TEST_MODEL=models/<file>.gguf to run the real model.'
        : available
        ? false
        : 'Model file not found: $modelPath',
  );
}
