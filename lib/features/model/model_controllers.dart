import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:llamadart/llamadart.dart'
    show
        ModelDownloadController,
        ModelDownloadTaskSnapshot,
        ModelDownloadTaskStage,
        ModelSource;

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/llm/model_catalog.dart';
import '../../core/llm/model_checks.dart';

// ---------------------------------------------------------------------------
// Active model: which file is in use and whether it is loaded.

enum ModelPhase { none, loading, ready, failed }

@immutable
class ActiveModelState {
  const ActiveModelState({
    this.path,
    this.phase = ModelPhase.none,
    this.backend,
    this.error,
  });

  final String? path;
  final ModelPhase phase;
  final String? backend;
  final String? error;

  String? get fileName => path?.split('/').last;
  bool get isReady => phase == ModelPhase.ready;
}

class ActiveModel extends Notifier<ActiveModelState> {
  static const settingKey = 'active_model_path';

  @override
  ActiveModelState build() {
    Future.microtask(_restore);
    return const ActiveModelState();
  }

  LlmEngine get _engine => ref.read(llmEngineProvider);

  Future<void> _restore() async {
    final path = await ref.read(databaseProvider).getSetting(settingKey);
    if (!ref.mounted || path == null || state.path != null) return;
    if (File(path).existsSync()) state = ActiveModelState(path: path);
  }

  /// Makes [path] the model the app uses, and loads it.
  Future<void> select(String path) async {
    await ref.read(databaseProvider).setSetting(settingKey, path);
    if (!ref.mounted) return;
    state = ActiveModelState(path: path);
    await load();
  }

  /// Loads the chosen model if it isn't loaded yet. False when no model has
  /// been chosen or loading failed.
  Future<bool> ensureLoaded() async {
    if (state.isReady && _engine.isLoaded) return true;
    if (state.path == null) await _restore();
    if (state.path == null) return false;
    await load();
    return state.isReady;
  }

  Future<void> load() async {
    final path = state.path;
    if (path == null || state.phase == ModelPhase.loading) return;
    state = ActiveModelState(path: path, phase: ModelPhase.loading);
    try {
      await _engine.load(path);
      final backend = await _engine.backendName();
      if (!ref.mounted) return;
      state = ActiveModelState(
        path: path,
        phase: ModelPhase.ready,
        backend: backend,
      );
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = ActiveModelState(
        path: path,
        phase: ModelPhase.failed,
        error: '$error',
      );
    }
  }

  Future<void> unload() async {
    await _engine.unload();
    if (ref.mounted) state = ActiveModelState(path: state.path);
  }

  /// Unloads and forgets the chosen model (used when its file is deleted).
  Future<void> forget() async {
    await _engine.unload();
    await ref.read(databaseProvider).setSetting(settingKey, null);
    if (ref.mounted) state = const ActiveModelState();
  }
}

final activeModelProvider = NotifierProvider<ActiveModel, ActiveModelState>(
  ActiveModel.new,
);

// ---------------------------------------------------------------------------
// Downloads of catalog models.

enum DownloadPhase { absent, running, ready, failed }

@immutable
class DownloadStatus {
  const DownloadStatus(
    this.phase, {
    this.fraction,
    this.receivedBytes,
    this.path,
    this.error,
  });

  const DownloadStatus.absent() : this(DownloadPhase.absent);

  final DownloadPhase phase;
  final double? fraction;
  final int? receivedBytes;
  final String? path;
  final String? error;
}

class ModelDownloads extends Notifier<Map<String, DownloadStatus>> {
  final _controllers = <String, ModelDownloadController>{};
  final _subscriptions =
      <String, StreamSubscription<ModelDownloadTaskSnapshot>>{};

  @override
  Map<String, DownloadStatus> build() {
    ref.onDispose(() {
      for (final subscription in _subscriptions.values) {
        unawaited(subscription.cancel());
      }
      for (final controller in _controllers.values) {
        unawaited(controller.dispose());
      }
    });
    Future.microtask(refresh);
    return const {};
  }

  /// Re-reads which catalog models are on the device.
  Future<void> refresh() async {
    try {
      final store = await ref.read(modelStoreProvider.future);
      final next = {...state};
      for (final spec in modelCatalog) {
        if (next[spec.id]?.phase == DownloadPhase.running) continue;
        final path = await store.downloadedPath(spec);
        next[spec.id] = path == null
            ? const DownloadStatus.absent()
            : DownloadStatus(DownloadPhase.ready, path: path);
      }
      if (ref.mounted) state = next;
    } on Object catch (error) {
      debugPrint('Could not read downloaded models: $error');
    }
  }

  /// Downloads [spec]. When no model is in use yet, the download becomes the
  /// active model.
  Future<void> start(ModelSpec spec) async {
    if (state[spec.id]?.phase == DownloadPhase.running) return;
    final store = await ref.read(modelStoreProvider.future);
    await _release(spec.id);
    final controller = store.newDownload();
    _controllers[spec.id] = controller;
    _subscriptions[spec.id] = controller.snapshots.listen((snapshot) {
      if (snapshot.isRunning) {
        _put(
          spec.id,
          DownloadStatus(
            DownloadPhase.running,
            fraction: snapshot.fraction,
            receivedBytes: snapshot.progress?.receivedBytes,
          ),
        );
      }
    });
    _put(spec.id, const DownloadStatus(DownloadPhase.running));
    try {
      final entry = await controller.start(ModelSource.parse(spec.source));
      _put(spec.id, DownloadStatus(DownloadPhase.ready, path: entry.filePath));
      if (ref.mounted && ref.read(activeModelProvider).path == null) {
        await ref.read(activeModelProvider.notifier).select(entry.filePath);
      }
    } on Object catch (error) {
      final snapshot = controller.snapshot;
      _put(
        spec.id,
        snapshot.stage == ModelDownloadTaskStage.cancelled
            ? const DownloadStatus.absent()
            : DownloadStatus(
                DownloadPhase.failed,
                error: snapshot.errorMessage ?? '$error',
              ),
      );
    } finally {
      await _release(spec.id);
    }
  }

  void cancel(ModelSpec spec) => _controllers[spec.id]?.cancel();

  Future<void> delete(ModelSpec spec) async {
    final path = state[spec.id]?.path;
    if (path != null && ref.read(activeModelProvider).path == path) {
      await ref.read(activeModelProvider.notifier).forget();
    }
    final store = await ref.read(modelStoreProvider.future);
    await store.delete(spec);
    _put(spec.id, const DownloadStatus.absent());
  }

  Future<void> _release(String id) async {
    await _subscriptions.remove(id)?.cancel();
    await _controllers.remove(id)?.dispose();
  }

  void _put(String id, DownloadStatus status) {
    if (ref.mounted) state = {...state, id: status};
  }
}

final modelDownloadsProvider =
    NotifierProvider<ModelDownloads, Map<String, DownloadStatus>>(
      ModelDownloads.new,
    );

// ---------------------------------------------------------------------------
// Model Lab: speed test, question test, streaming test.

@immutable
class LabState {
  const LabState({
    this.busy = false,
    this.step,
    this.speed,
    this.question,
    this.streamed = '',
    this.error,
  });

  final bool busy;
  final String? step;
  final SpeedResult? speed;
  final QuestionCheck? question;
  final String streamed;
  final String? error;

  static const _unset = Object();

  LabState copyWith({
    bool? busy,
    Object? step = _unset,
    SpeedResult? speed,
    QuestionCheck? question,
    String? streamed,
    Object? error = _unset,
  }) => LabState(
    busy: busy ?? this.busy,
    step: identical(step, _unset) ? this.step : step as String?,
    speed: speed ?? this.speed,
    question: question ?? this.question,
    streamed: streamed ?? this.streamed,
    error: identical(error, _unset) ? this.error : error as String?,
  );
}

class ModelLab extends Notifier<LabState> {
  StreamSubscription<LlmChunk>? _stream;

  @override
  LabState build() {
    ref.onDispose(() => _stream?.cancel());
    return const LabState();
  }

  Future<void> runSpeedTest() => _run((engine) async {
    final result = await ModelChecks(engine).speed(onStep: _step);
    final db = ref.read(databaseProvider);
    await db
        .into(db.benchmarkRuns)
        .insert(
          BenchmarkRunsCompanion.insert(
            modelName: engine.modelName ?? 'unknown',
            backend: await engine.backendName(),
            readTokensPerSecond: result.readTokensPerSecond,
            writeTokensPerSecond: result.writeTokensPerSecond,
            firstQuestionMs: result.firstQuestion.inMilliseconds,
            nextQuestionMs: result.nextQuestion.inMilliseconds,
            cachedPromptShare: Value(result.cachedPromptShare),
          ),
        );
    if (ref.mounted) {
      state = state.copyWith(speed: result, question: result.question);
    }
  });

  Future<void> runQuestionTest() => _run((engine) async {
    _step('Writing a question');
    final question = await ModelChecks(engine).question();
    if (ref.mounted) state = state.copyWith(question: question);
  });

  Future<void> runStreamTest() async {
    if (state.busy) return;
    state = const LabState(busy: true, step: 'Loading model');
    if (!await ref.read(activeModelProvider.notifier).ensureLoaded()) {
      if (ref.mounted) {
        state = const LabState(error: 'Choose and load a model first.');
      }
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(step: 'Streaming');
    final buffer = StringBuffer();
    final sinceFlush = Stopwatch()..start();
    void flush() {
      if (ref.mounted) state = state.copyWith(streamed: buffer.toString());
      sinceFlush.reset();
    }

    _stream = ref
        .read(llmEngineProvider)
        .stream(const [
          LlmMessage.user(
            'Explain osmosis to a 12-year-old in about 120 words.',
          ),
        ], params: const LlmParams(maxTokens: 220, temperature: 0.7))
        .listen(
          (chunk) {
            buffer.write(chunk.text);
            if (sinceFlush.elapsedMilliseconds > 50 || chunk.isLast) flush();
          },
          onError: (Object error) {
            if (ref.mounted) {
              state = state.copyWith(busy: false, step: null, error: '$error');
            }
          },
          onDone: () {
            _stream = null;
            flush();
            if (ref.mounted) state = state.copyWith(busy: false, step: null);
          },
        );
  }

  void stop() {
    unawaited(_stream?.cancel());
    _stream = null;
    ref.read(llmEngineProvider).cancel();
    if (state.busy) state = state.copyWith(busy: false, step: null);
  }

  void _step(String step) {
    if (ref.mounted) state = state.copyWith(step: step);
  }

  Future<void> _run(Future<void> Function(LlmEngine engine) body) async {
    if (state.busy) return;
    state = const LabState(busy: true, step: 'Loading model');
    try {
      if (!await ref.read(activeModelProvider.notifier).ensureLoaded()) {
        final error = ref.read(activeModelProvider).error;
        throw LlmException(error ?? 'Choose and load a model first.');
      }
      await body(ref.read(llmEngineProvider));
      if (ref.mounted) state = state.copyWith(busy: false, step: null);
    } on Object catch (error) {
      if (ref.mounted) {
        state = state.copyWith(busy: false, step: null, error: '$error');
      }
    }
  }
}

final modelLabProvider = NotifierProvider<ModelLab, LabState>(ModelLab.new);
