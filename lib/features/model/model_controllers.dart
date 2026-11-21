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
import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/llm/installed_model.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/llm/model_catalog.dart';
import '../../core/llm/model_checks.dart';
import 'model_use.dart';

// ---------------------------------------------------------------------------
// Models in use: the app's default, and the one in memory.

enum ModelPhase { none, loading, ready, failed }

@immutable
class ActiveModelState {
  const ActiveModelState({
    this.path,
    this.loadedPath,
    this.targetPath,
    this.phase = ModelPhase.none,
    this.backend,
    this.error,
  });

  /// The app's default model, chosen in Settings.
  final String? path;

  /// The model in memory. It differs from [path] while a document or a
  /// conversation with its own model is working.
  final String? loadedPath;

  /// The model being loaded, or the one that last failed to load.
  final String? targetPath;
  final ModelPhase phase;
  final String? backend;
  final String? error;

  String? get fileName => path == null ? null : p.basename(path!);
  bool get isReady => phase == ModelPhase.ready;

  /// The model a status line should name: the one loading (or that failed),
  /// else the one in memory, else the default.
  String? get currentPath => switch (phase) {
    ModelPhase.loading || ModelPhase.failed => targetPath,
    _ => loadedPath ?? path,
  };

  static const _unset = Object();

  ActiveModelState copyWith({
    Object? path = _unset,
    Object? loadedPath = _unset,
    Object? targetPath = _unset,
    ModelPhase? phase,
    Object? backend = _unset,
    Object? error = _unset,
  }) => ActiveModelState(
    path: identical(path, _unset) ? this.path : path as String?,
    loadedPath: identical(loadedPath, _unset)
        ? this.loadedPath
        : loadedPath as String?,
    targetPath: identical(targetPath, _unset)
        ? this.targetPath
        : targetPath as String?,
    phase: phase ?? this.phase,
    backend: identical(backend, _unset) ? this.backend : backend as String?,
    error: identical(error, _unset) ? this.error : error as String?,
  );
}

class ActiveModel extends Notifier<ActiveModelState> {
  static const settingKey = 'active_model_path';

  /// Loads run one after another, so two callers never swap models under
  /// each other.
  Future<void> _lock = Future<void>.value();

  @override
  ActiveModelState build() {
    Future.microtask(_restore);
    return const ActiveModelState();
  }

  LlmEngine get _engine => ref.read(llmEngineProvider);

  Future<void> _restore() async {
    final path = await ref.read(databaseProvider).getSetting(settingKey);
    if (!ref.mounted || path == null || state.path != null) return;
    if (File(path).existsSync()) state = state.copyWith(path: path);
  }

  /// The default model's file, once read from the settings.
  Future<String?> defaultPath() async {
    if (state.path == null) await _restore();
    return ref.mounted ? state.path : null;
  }

  /// Makes [path] the app's default model, and loads it.
  Future<void> select(String path) async {
    await ref.read(databaseProvider).setSetting(settingKey, path);
    if (!ref.mounted) return;
    state = state.copyWith(path: path);
    await ensureLoaded(path: path);
  }

  /// Makes sure [path] (by default, the default model) is the model in
  /// memory, loading it in place of another one if needed. False when there
  /// is no model or it failed to load.
  Future<bool> ensureLoaded({String? path}) {
    final done = _lock.then((_) => _ensure(path));
    _lock = done.then((_) {}, onError: (Object _) {});
    return done;
  }

  Future<bool> _ensure(String? path) async {
    final target = path ?? await defaultPath();
    if (target == null || !ref.mounted) return false;
    if (_engine.isLoaded && state.loadedPath == target && state.isReady) {
      return true;
    }
    state = state.copyWith(
      targetPath: target,
      phase: ModelPhase.loading,
      error: null,
    );
    try {
      await _engine.load(target);
      final backend = await _engine.backendName();
      if (!ref.mounted) return false;
      state = state.copyWith(
        loadedPath: target,
        phase: ModelPhase.ready,
        backend: backend,
      );
      return true;
    } on Object catch (error) {
      if (!ref.mounted) return false;
      // A failed load leaves no model in memory.
      state = state.copyWith(
        loadedPath: null,
        phase: ModelPhase.failed,
        backend: null,
        error: '$error',
      );
      return false;
    }
  }

  /// Loads the default model.
  Future<void> load() => ensureLoaded();

  Future<void> unload() async {
    await _lock;
    await _engine.unload();
    if (ref.mounted) {
      state = state.copyWith(
        loadedPath: null,
        phase: ModelPhase.none,
        backend: null,
      );
    }
  }

  /// Unloads and forgets the default model (used when its file is deleted).
  Future<void> forget() async {
    await _lock;
    await _engine.unload();
    await ref.read(databaseProvider).setSetting(settingKey, null);
    if (ref.mounted) state = const ActiveModelState();
  }
}

final activeModelProvider = NotifierProvider<ActiveModel, ActiveModelState>(
  ActiveModel.new,
);

/// Every model file on this phone: downloads first, in catalog order, then
/// files copied in by hand.
final installedModelsProvider = FutureProvider<List<InstalledModel>>((
  ref,
) async {
  final downloads = ref.watch(modelDownloadsProvider);
  final store = await ref.watch(modelStoreProvider.future);
  final seen = <String>{};
  final models = <InstalledModel>[];
  for (final spec in modelCatalog) {
    final status = downloads[spec.id];
    final path = status?.path;
    if (status?.phase != DownloadPhase.ready || path == null) continue;
    final file = File(path);
    if (!file.existsSync() || !seen.add(path)) continue;
    models.add(
      InstalledModel(path: path, sizeBytes: file.lengthSync(), spec: spec),
    );
  }
  for (final file in store.sideloadedFiles()) {
    if (!seen.add(file.path)) continue;
    models.add(
      InstalledModel(
        path: file.path,
        sizeBytes: file.lengthSync(),
        spec: catalogSpecForFile(p.basename(file.path)),
        copiedIn: true,
      ),
    );
  }
  return models;
});

/// Where a model choice comes from.
enum ModelOrigin { conversation, document, appDefault }

/// The model something uses, and whose choice it is.
@immutable
class ResolvedModel {
  const ResolvedModel(this.path, this.origin);

  /// Null when no model is available at all.
  final String? path;
  final ModelOrigin origin;

  String get name => path == null ? 'No model' : modelDisplayName(path!);
}

/// The conversation's choice, then the document's, then the app default:
/// the first whose file is still on the phone.
ResolvedModel resolveModel({
  String? conversation,
  String? document,
  String? appDefault,
}) {
  bool exists(String path) => File(path).existsSync();
  if (conversation != null && exists(conversation)) {
    return ResolvedModel(conversation, ModelOrigin.conversation);
  }
  if (document != null && exists(document)) {
    return ResolvedModel(document, ModelOrigin.document);
  }
  return ResolvedModel(
    appDefault != null && exists(appDefault) ? appDefault : null,
    ModelOrigin.appDefault,
  );
}

/// Which model a document, or one of its conversations, uses (see
/// [resolveModel]), and where those choices are saved.
class ModelResolver {
  ModelResolver(this._ref);

  final Ref _ref;

  Future<String?> pathFor({int? documentId, int? threadId}) async {
    final db = _ref.read(databaseProvider);
    String? threadChoice;
    if (threadId != null) {
      threadChoice = (await (db.select(
        db.chatThreads,
      )..where((t) => t.id.equals(threadId))).getSingleOrNull())?.modelPath;
    }
    String? documentChoice;
    if (documentId != null) {
      documentChoice = (await (db.select(
        db.documents,
      )..where((d) => d.id.equals(documentId))).getSingleOrNull())?.modelPath;
    }
    final fallback = await _ref
        .read(activeModelProvider.notifier)
        .defaultPath();
    return resolveModel(
      conversation: threadChoice,
      document: documentChoice,
      appDefault: fallback,
    ).path;
  }

  /// Sets the model of a document (null: the app default).
  Future<void> setDocumentModel(int documentId, String? path) async {
    final db = _ref.read(databaseProvider);
    await (db.update(db.documents)..where((d) => d.id.equals(documentId)))
        .write(DocumentsCompanion(modelPath: Value(path)));
  }

  /// Sets the model of a conversation (null: the document's model).
  Future<void> setThreadModel(int threadId, String? path) async {
    final db = _ref.read(databaseProvider);
    await (db.update(db.chatThreads)..where((t) => t.id.equals(threadId)))
        .write(ChatThreadsCompanion(modelPath: Value(path)));
  }
}

final modelResolverProvider = Provider<ModelResolver>(ModelResolver.new);

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
// Model tests: speed, one question, streaming. Each runs on a chosen model
// (by default, the app default) through ModelUse.

@immutable
class LabState {
  const LabState({
    this.busy = false,
    this.modelPath,
    this.step,
    this.speed,
    this.question,
    this.streamed = '',
    this.error,
  });

  final bool busy;

  /// The model the latest test ran on.
  final String? modelPath;
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
    modelPath: modelPath,
    step: identical(step, _unset) ? this.step : step as String?,
    speed: speed ?? this.speed,
    question: question ?? this.question,
    streamed: streamed ?? this.streamed,
    error: identical(error, _unset) ? this.error : error as String?,
  );
}

class ModelLab extends Notifier<LabState> {
  StreamSubscription<LlmChunk>? _stream;
  Completer<void>? _streamDone;

  @override
  LabState build() {
    ref.onDispose(() => _stream?.cancel());
    return const LabState();
  }

  Future<void> runSpeedTest({String? path}) =>
      _run('Speed test', path, (engine) async {
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

  Future<void> runQuestionTest({String? path}) =>
      _run('Question test', path, (engine) async {
        _step('Writing a question');
        final question = await ModelChecks(engine).question();
        if (ref.mounted) state = state.copyWith(question: question);
      });

  Future<void> runStreamTest({String? path}) => _run('Streaming test', path, (
    engine,
  ) async {
    _step('Streaming');
    final buffer = StringBuffer();
    final sinceFlush = Stopwatch()..start();
    void flush() {
      if (ref.mounted) state = state.copyWith(streamed: buffer.toString());
      sinceFlush.reset();
    }

    final done = _streamDone = Completer<void>();
    _stream = engine
        .stream(const [
          LlmMessage.user(
            'Explain osmosis to a 12-year-old in about 120 words.',
          ),
        ], params: const LlmParams(maxTokens: 220, temperature: 0.7))
        .listen(
          (chunk) {
            buffer.write(chunk.text);
            if (sinceFlush.elapsedMilliseconds > 50 || chunk.isLast) {
              flush();
            }
          },
          onError: (Object error) {
            if (!done.isCompleted) done.completeError(error);
          },
          onDone: () {
            if (!done.isCompleted) done.complete();
          },
        );
    try {
      await done.future;
    } finally {
      _stream = null;
      _streamDone = null;
      flush();
    }
  });

  void stop() {
    unawaited(_stream?.cancel());
    _stream = null;
    ref.read(llmEngineProvider).cancel();
    final done = _streamDone;
    if (done != null && !done.isCompleted) done.complete();
  }

  void _step(String step) {
    if (ref.mounted) state = state.copyWith(step: step);
  }

  Future<void> _run(
    String title,
    String? path,
    Future<void> Function(LlmEngine engine) body,
  ) async {
    if (state.busy) return;
    final target =
        path ?? await ref.read(activeModelProvider.notifier).defaultPath();
    state = LabState(busy: true, modelPath: target, step: 'Loading model');
    try {
      if (target == null) {
        throw LlmException('Choose a model first.');
      }
      await ref
          .read(modelUseProvider)
          .run(
            title: title,
            detail: modelDisplayName(target),
            modelPath: target,
            body: body,
          );
      if (ref.mounted) state = state.copyWith(busy: false, step: null);
    } on LlmCancelledException {
      if (ref.mounted) state = state.copyWith(busy: false, step: null);
    } on Object catch (error) {
      if (ref.mounted) {
        state = state.copyWith(busy: false, step: null, error: '$error');
      }
    }
  }
}

final modelLabProvider = NotifierProvider<ModelLab, LabState>(ModelLab.new);
