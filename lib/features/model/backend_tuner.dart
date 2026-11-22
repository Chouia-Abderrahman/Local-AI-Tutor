import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/llm/backend_benchmark.dart';
import '../../core/llm/installed_model.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/llm/model_checks.dart';
import '../generate/generate_controllers.dart';
import 'model_controllers.dart';
import 'model_use.dart';

@immutable
class TunerState {
  const TunerState({
    this.busy = false,
    this.step,
    this.current,
    this.results = const [],
    this.error,
  });

  final bool busy;

  /// What is happening, in words: "Testing OpenCL · 2 of 3".
  final String? step;
  final LlmBackend? current;

  /// Results so far in the running comparison.
  final List<BackendResult> results;
  final String? error;
}

/// Tests the default model on every backend, keeps the results and switches
/// to the fastest. The user can still pick another backend by hand.
class BackendTuner extends Notifier<TunerState> {
  /// Settings key of the latest results for a model file.
  static String resultKey(String modelFile) => 'backend_bench:$modelFile';

  /// Set while a comparison runs. Still set at the next launch means the
  /// app died during it, most likely in a GPU driver.
  static const runKey = 'backend_bench_run';

  bool _stop = false;

  @override
  TunerState build() {
    Future.microtask(_recover);
    return const TunerState();
  }

  AppDatabase get _db => ref.read(databaseProvider);

  /// Skips the backends not tested yet; the one running finishes first.
  void stop() => _stop = true;

  Future<void> run() async {
    if (state.busy) return;
    final models = ref.read(activeModelProvider.notifier);
    final path = await models.defaultPath();
    if (path == null) {
      state = const TunerState(error: 'Set up a model first.');
      return;
    }
    _stop = false;
    state = const TunerState(busy: true, step: 'Starting');
    final results = <BackendResult>[];
    try {
      await ref.read(modelUseProvider).exclusive(
        'Comparing CPU, OpenCL and Vulkan',
        detail: modelDisplayName(path),
        () async {
          final engine = ref.read(llmEngineProvider);
          final backends = LlmBackend.values;
          for (final (i, backend) in backends.indexed) {
            if (_stop) {
              results.add(
                BackendResult(
                  backend: backend,
                  status: BackendStatus.notTested,
                  note: 'Skipped.',
                ),
              );
              continue;
            }
            state = TunerState(
              busy: true,
              current: backend,
              results: [...results],
              step: 'Testing ${backend.label} · ${i + 1} of ${backends.length}',
            );
            // If the app dies in the driver, the next launch knows
            // which backend did it.
            await _db.setSetting(
              runKey,
              jsonEncode({
                'path': path,
                'current': backend.name,
                'done': [for (final r in results) r.toJson()],
              }),
            );
            results.add(await _testOne(engine, models, path, backend));
          }
        },
      );
      await _finish(path, results);
      if (ref.mounted) state = const TunerState();
    } on Object catch (error) {
      await _db.setSetting(runKey, null);
      if (ref.mounted) state = TunerState(error: '$error');
    }
  }

  Future<BackendResult> _testOne(
    LlmEngine engine,
    ActiveModel models,
    String path,
    LlmBackend backend,
  ) async {
    try {
      final actual = await models.loadOn(path, backend);
      // Asked for a GPU and got the CPU: the driver is missing or refused
      // the model, and the speed would just be the CPU's again.
      if (backend != LlmBackend.cpu &&
          !actual.toLowerCase().contains(backend.name)) {
        return BackendResult(
          backend: backend,
          status: BackendStatus.unavailable,
          note: 'This phone ran it on the CPU instead.',
        );
      }
      final base = state.step;
      final speed = await ModelChecks(engine).quickSpeed(
        onStep: (step) {
          if (ref.mounted && state.busy) {
            state = TunerState(
              busy: true,
              current: backend,
              results: state.results,
              step: '$base · $step',
            );
          }
        },
      );
      return BackendResult(
        backend: backend,
        status: BackendStatus.ok,
        readTokensPerSecond: speed.readTokensPerSecond,
        writeTokensPerSecond: speed.writeTokensPerSecond,
      );
    } on Object catch (error) {
      return BackendResult.failed(backend, '$error');
    }
  }

  /// Saves [results], and switches to the fastest backend.
  Future<void> _finish(String path, List<BackendResult> results) async {
    final bench = BackendBenchmark(
      modelFile: p.basename(path),
      at: DateTime.now(),
      results: results,
    );
    await _db.setSetting(resultKey(bench.modelFile), bench.toJsonString());
    await _db.setSetting(runKey, null);
    final best = bench.fastest;
    final models = ref.read(activeModelProvider.notifier);
    if (best != null) {
      await models.setBackend(best.backend);
      // Time estimates for generation use the speed of the backend in use.
      await _db
          .into(_db.benchmarkRuns)
          .insert(
            BenchmarkRunsCompanion.insert(
              modelName: bench.modelFile,
              backend: best.backend.label,
              readTokensPerSecond: best.readTokensPerSecond,
              writeTokensPerSecond: best.writeTokensPerSecond,
              firstQuestionMs: 0,
              nextQuestionMs: 0,
              cachedPromptShare: const Value(null),
            ),
          );
      ref.invalidate(modelSpeedProvider);
    } else {
      // Nothing ran: stay on the CPU, which every phone can use.
      await models.setBackend(LlmBackend.cpu);
    }
    ref.invalidate(lastBenchmarkProvider);
  }

  /// The app died during a comparison: the backend it was testing is the
  /// culprit. Record that, and switch to the best of the rest.
  Future<void> _recover() async {
    final raw = await _db.getSetting(runKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      final path = json['path'] as String;
      final crashed = LlmBackend.values.byName(json['current'] as String);
      final done = [
        for (final r in json['done'] as List)
          BackendResult.fromJson(Map<String, Object?>.from(r as Map)),
      ];
      // Let the model settings settle first (a GPU load that never finished
      // sends the app back to the CPU).
      final models = ref.read(activeModelProvider.notifier);
      await models.currentBackend();
      final results = [
        ...done,
        BackendResult.failed(
          crashed,
          'The app stopped while testing this. Not used.',
        ),
        for (final b in LlmBackend.values)
          if (b != crashed && !done.any((r) => r.backend == b))
            BackendResult(
              backend: b,
              status: BackendStatus.notTested,
              note: 'The test was interrupted.',
            ),
      ];
      await _finish(path, results);
      models.backendNotice =
          '${crashed.label} stopped the app during the speed test, so it was '
          'left out.';
    } on Object catch (error) {
      debugPrint('Could not recover the backend test: $error');
      await _db.setSetting(runKey, null);
    }
  }
}

final backendTunerProvider = NotifierProvider<BackendTuner, TunerState>(
  BackendTuner.new,
);

/// The latest backend comparison for the default model, if there is one.
final lastBenchmarkProvider = FutureProvider<BackendBenchmark?>((ref) async {
  final path = ref.watch(activeModelProvider.select((s) => s.path));
  if (path == null) return null;
  final db = ref.watch(databaseProvider);
  return BackendBenchmark.tryParse(
    await db.getSetting(BackendTuner.resultKey(p.basename(path))),
  );
});
