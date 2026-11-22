import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_study_assistant/app/providers.dart';
import 'package:pdf_study_assistant/core/db/database.dart';
import 'package:pdf_study_assistant/core/llm/backend_benchmark.dart';
import 'package:pdf_study_assistant/core/llm/fake_llm_engine.dart';
import 'package:pdf_study_assistant/core/llm/llm_engine.dart';
import 'package:pdf_study_assistant/features/model/backend_tuner.dart';
import 'package:pdf_study_assistant/features/model/model_controllers.dart';

class _NoDownloads extends ModelDownloads {
  @override
  Map<String, DownloadStatus> build() => const {};
}

BackendResult _ok(LlmBackend b, double write) => BackendResult(
  backend: b,
  status: BackendStatus.ok,
  readTokensPerSecond: write * 5,
  writeTokensPerSecond: write,
);

void main() {
  group('picking the fastest', () {
    BackendBenchmark bench(List<BackendResult> r) =>
        BackendBenchmark(modelFile: 'm.gguf', at: DateTime(2026), results: r);

    test('the backend that writes fastest wins', () {
      final b = bench([
        _ok(LlmBackend.cpu, 8),
        _ok(LlmBackend.opencl, 20),
        _ok(LlmBackend.vulkan, 12),
      ]);
      expect(b.fastest!.backend, LlmBackend.opencl);
    });

    test('the CPU wins a near tie, as the safer choice', () {
      final b = bench([_ok(LlmBackend.cpu, 10), _ok(LlmBackend.opencl, 10.4)]);
      expect(b.fastest!.backend, LlmBackend.cpu);
    });

    test('reading counts as well as writing', () {
      BackendResult speed(LlmBackend b, double read, double write) =>
          BackendResult(
            backend: b,
            status: BackendStatus.ok,
            readTokensPerSecond: read,
            writeTokensPerSecond: write,
          );
      // The numbers measured on a Snapdragon phone: OpenCL reads faster but
      // writes slower, and for a typical question they come out level, so
      // the CPU stays.
      final phone = bench([
        speed(LlmBackend.cpu, 46, 10.4),
        speed(LlmBackend.opencl, 74.6, 8.1),
      ]);
      expect(phone.fastest!.backend, LlmBackend.cpu);
      // A GPU that reads far faster wins even though it writes a bit slower.
      final reader = bench([
        speed(LlmBackend.cpu, 40, 10),
        speed(LlmBackend.opencl, 400, 9),
      ]);
      expect(reader.fastest!.backend, LlmBackend.opencl);
      expect(
        reader.resultFor(LlmBackend.opencl)!.typicalSeconds,
        lessThan(reader.resultFor(LlmBackend.cpu)!.typicalSeconds),
      );
    });

    test('backends that did not run are never chosen', () {
      final b = bench([
        _ok(LlmBackend.cpu, 5),
        BackendResult.failed(LlmBackend.opencl, 'driver error'),
        const BackendResult(
          backend: LlmBackend.vulkan,
          status: BackendStatus.unavailable,
        ),
      ]);
      expect(b.fastest!.backend, LlmBackend.cpu);
      expect(
        bench([BackendResult.failed(LlmBackend.cpu, 'x')]).fastest,
        isNull,
      );
    });

    test('results survive being saved and read back', () {
      final b = bench([
        _ok(LlmBackend.cpu, 8),
        BackendResult.failed(LlmBackend.vulkan, 'boom'),
      ]);
      final back = BackendBenchmark.tryParse(b.toJsonString())!;
      expect(back.modelFile, 'm.gguf');
      expect(back.results.length, 2);
      expect(back.resultFor(LlmBackend.cpu)!.writeTokensPerSecond, 8);
      expect(back.resultFor(LlmBackend.vulkan)!.note, 'boom');
      expect(BackendBenchmark.tryParse('not json'), isNull);
      expect(BackendBenchmark.tryParse(null), isNull);
    });
  });

  group('the speed comparison', () {
    late Directory dir;
    late String model;
    late AppDatabase db;
    late FakeLlmEngine engine;
    late ProviderContainer container;

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('tuner');
      model = (File('${dir.path}/M-Q4_0.gguf')..writeAsStringSync('gguf')).path;
      db = AppDatabase(NativeDatabase.memory());
      engine = FakeLlmEngine(responder: (_, _) => 'ok ok ok ok ok ok ok ok')
        ..reportBackends = true
        ..speeds.addAll({
          LlmBackend.cpu: (50, 8),
          LlmBackend.opencl: (200, 20),
          LlmBackend.vulkan: (150, 12),
        });
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          llmEngineProvider.overrideWithValue(engine as LlmEngine),
          modelDownloadsProvider.overrideWith(_NoDownloads.new),
        ],
      );
      await db.setSetting(ActiveModel.settingKey, model);
    });

    tearDown(() async {
      container.dispose();
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('tests every backend, saves the results and switches to the '
        'fastest', () async {
      await container.read(backendTunerProvider.notifier).run();
      final bench = BackendBenchmark.tryParse(
        await db.getSetting(BackendTuner.resultKey('M-Q4_0.gguf')),
      )!;
      expect(bench.results.map((r) => r.backend), LlmBackend.values);
      expect(bench.results.every((r) => r.ok), isTrue);
      expect(bench.fastest!.backend, LlmBackend.opencl);
      expect(
        bench.resultFor(LlmBackend.opencl)!.writeTokensPerSecond,
        closeTo(20, 0.5),
      );
      // The fastest is in use, remembered, and nothing is left half done.
      expect(
        container.read(activeModelProvider.notifier).backend,
        LlmBackend.opencl,
      );
      expect(await db.getSetting(ActiveModel.backendKey), 'opencl');
      expect(await db.getSetting(BackendTuner.runKey), isNull);
      expect(await db.getSetting(ActiveModel.loadingKey), isNull);
      expect(container.read(backendTunerProvider).busy, isFalse);
      expect(container.read(backendTunerProvider).error, isNull);
      // The last result shows up for the model.
      final last = await container.read(lastBenchmarkProvider.future);
      expect(last!.fastest!.backend, LlmBackend.opencl);
    });

    test('the user can still override the choice afterwards', () async {
      await container.read(backendTunerProvider.notifier).run();
      await container
          .read(activeModelProvider.notifier)
          .setBackend(LlmBackend.vulkan);
      expect(
        container.read(activeModelProvider.notifier).backend,
        LlmBackend.vulkan,
      );
      // The saved comparison is untouched: it still says OpenCL was fastest.
      final last = await container.read(lastBenchmarkProvider.future);
      expect(last!.fastest!.backend, LlmBackend.opencl);
    });

    test('a GPU that quietly runs on the CPU is not credited', () async {
      engine.fallsBackToCpu.add(LlmBackend.opencl);
      await container.read(backendTunerProvider.notifier).run();
      final bench = BackendBenchmark.tryParse(
        await db.getSetting(BackendTuner.resultKey('M-Q4_0.gguf')),
      )!;
      expect(
        bench.resultFor(LlmBackend.opencl)!.status,
        BackendStatus.unavailable,
      );
      expect(bench.fastest!.backend, LlmBackend.vulkan);
      expect(
        container.read(activeModelProvider.notifier).backend,
        LlmBackend.vulkan,
      );
    });

    test('GPUs that fail leave the CPU', () async {
      engine.failOnGpu = true;
      await container.read(backendTunerProvider.notifier).run();
      final bench = BackendBenchmark.tryParse(
        await db.getSetting(BackendTuner.resultKey('M-Q4_0.gguf')),
      )!;
      expect(bench.resultFor(LlmBackend.opencl)!.status, BackendStatus.failed);
      expect(bench.resultFor(LlmBackend.vulkan)!.status, BackendStatus.failed);
      expect(
        container.read(activeModelProvider.notifier).backend,
        LlmBackend.cpu,
      );
      expect(await db.getSetting(ActiveModel.loadingKey), isNull);
    });

    test('a test the app died in is settled at the next launch', () async {
      // The app died while Vulkan was being tested; CPU and OpenCL were done.
      await db.setSetting(ActiveModel.backendKey, LlmBackend.vulkan.name);
      await db.setSetting(ActiveModel.loadingKey, model);
      await db.setSetting(
        BackendTuner.runKey,
        '{"path":"$model","current":"vulkan","done":['
        '{"backend":"cpu","status":"ok","read":250,"write":8,"note":null},'
        '{"backend":"opencl","status":"ok","read":900,"write":20,"note":null}'
        ']}',
      );
      container.read(backendTunerProvider);
      await pumpEventQueue();
      final bench = BackendBenchmark.tryParse(
        await db.getSetting(BackendTuner.resultKey('M-Q4_0.gguf')),
      )!;
      expect(bench.resultFor(LlmBackend.vulkan)!.status, BackendStatus.failed);
      expect(bench.fastest!.backend, LlmBackend.opencl);
      final models = container.read(activeModelProvider.notifier);
      expect(models.backend, LlmBackend.opencl);
      expect(models.backendNotice, contains('Vulkan'));
      expect(await db.getSetting(BackendTuner.runKey), isNull);
      expect(await db.getSetting(ActiveModel.loadingKey), isNull);
    });
  });
}
