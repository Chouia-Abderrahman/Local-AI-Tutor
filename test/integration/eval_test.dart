// Generates questions for the fixture textbook with a real model and writes
// a report to build/eval/. Skipped unless TEST_MODEL names a model file;
// start it with:
//   TEST_MODEL=models/Qwen3.5-4B-Q4_K_M.gguf EVAL_QUALITY=standard \
//     flutter test --tags model test/integration/eval_test.dart
@Tags(['model'])
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/generate/generation_repository.dart';
import 'package:pdf_study_assistant/core/generate/json_model.dart';
import 'package:pdf_study_assistant/core/generate/profile.dart';
import 'package:pdf_study_assistant/core/generate/runner.dart';
import 'package:pdf_study_assistant/core/ingest/importer.dart';
import 'package:pdf_study_assistant/core/ingest/pdf_extractor.dart';
import 'package:pdf_study_assistant/core/llm/llamadart_engine.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';

import '../support/pdfium.dart';

/// Times each stage's model calls.
class _TimedModel implements JsonModel {
  _TimedModel(this.inner);

  final JsonModel inner;
  final Map<String, List<int>> millis = {};

  @override
  String get modelName => inner.modelName;

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) async {
    final watch = Stopwatch()..start();
    try {
      return await inner.json(
        stage: stage,
        messages: messages,
        schema: schema,
        maxTokens: maxTokens,
        temperature: temperature,
      );
    } finally {
      millis.putIfAbsent(stage, () => []).add(watch.elapsedMilliseconds);
      print('  $stage call: ${watch.elapsedMilliseconds} ms');
    }
  }
}

void main() {
  // Runs only when TEST_MODEL names a model file, so a plain `flutter test`
  // stays fast.
  final modelPath = Platform.environment['TEST_MODEL'] ?? '';
  final quality = Quality.values.byName(
    Platform.environment['EVAL_QUALITY'] ?? 'standard',
  );
  final available = File(modelPath).existsSync();

  test(
    'eval: ${quality.name} on the fixture textbook',
    () async {
      await initPdfiumForTests();
      final db = AppDatabase(NativeDatabase.memory());
      final storage = Directory.systemTemp.createTempSync('eval');
      addTearDown(() async {
        await db.close();
        storage.deleteSync(recursive: true);
      });
      final imported = await DocumentImporter(
        db: db,
        storageDir: storage,
        extractPdf: PdfExtractor.extract,
      ).importFile('test/fixtures/textbook.pdf');

      final engine = LlamadartEngine();
      addTearDown(engine.dispose);
      await engine.load(modelPath);
      final model = _TimedModel(EngineJsonModel(engine));
      final repo = GenerationRepository(db);
      final runner = GenerationRunner(
        repo: repo,
        prepareModel: (_) async => model,
      );

      final watch = Stopwatch()..start();
      await runner.start(
        documentId: imported.documentId,
        profile: GenerationProfile.preset(
          quality,
          depths: {Depth.recall, Depth.understand, Depth.apply},
        ),
      );
      await runner.idle();
      final total = watch.elapsed;

      final questions = await db.select(db.questions).get();
      final facts = await db.select(db.facts).get();
      final rejections = await db.select(db.rejections).get();
      final chunks = (await db.select(db.chunks).get())
          .where((c) => c.kind == 'study')
          .length;

      final byType = <String, int>{};
      for (final q in questions) {
        byType[q.type] = (byType[q.type] ?? 0) + 1;
      }
      final reasons = <String, int>{};
      for (final r in rejections) {
        final key = '${r.stage}: ${r.reason}';
        reasons[key] = (reasons[key] ?? 0) + 1;
      }

      final report = StringBuffer()
        ..writeln('# Eval: ${engine.modelName}, ${quality.name}')
        ..writeln()
        ..writeln(
          '$chunks passages, ${facts.length} facts, '
          '${questions.length} questions $byType, '
          'total ${total.inSeconds} s.',
        )
        ..writeln()
        ..writeln('## Model calls')
        ..writeln();
      model.millis.forEach((stage, list) {
        final mean = list.reduce((a, b) => a + b) / list.length / 1000;
        report.writeln(
          '- $stage: ${list.length} calls, mean ${mean.toStringAsFixed(1)} s',
        );
      });
      report
        ..writeln()
        ..writeln('## Rejections')
        ..writeln();
      reasons.forEach((reason, n) => report.writeln('- $reason: $n'));
      report
        ..writeln()
        ..writeln('## Questions')
        ..writeln();
      for (final fact in facts) {
        report.writeln('### ${fact.statement}');
        report.writeln('> ${fact.quote}');
        report.writeln();
        for (final q in questions.where((q) => q.factId == fact.id)) {
          report.writeln('- **${q.type}** (${q.depth}) ${q.prompt}');
          report.writeln('  - answer: ${q.answer}');
          if (q.distractorsJson != null) {
            report.writeln(
              '  - wrong: ${(jsonDecode(q.distractorsJson!) as List).join(' | ')}',
            );
          }
          if (q.explanation != null) {
            report.writeln('  - why: ${q.explanation}');
          }
          if (q.checksJson != null) {
            report.writeln('  - checks: ${q.checksJson}');
          }
        }
        report.writeln();
      }
      report
        ..writeln('## Rejected items')
        ..writeln();
      for (final r in rejections) {
        report.writeln('- ${r.stage} / ${r.reason}: ${r.payload}');
      }

      final out = File('build/eval/${engine.modelName}-${quality.name}.md')
        ..createSync(recursive: true);
      out.writeAsStringSync(report.toString());
      print(report);
      print('Report: ${out.path}');

      expect(facts, isNotEmpty);
    },
    skip: modelPath.isEmpty
        ? 'Set TEST_MODEL=models/<file>.gguf to run the real model.'
        : available
        ? false
        : 'Model file not found: $modelPath',
    timeout: const Timeout(Duration(minutes: 90)),
  );
}
