import 'dart:async';

import 'package:flutter/foundation.dart';

import '../llm/llm_engine.dart';
import 'chunk_generator.dart';
import 'generation_repository.dart';
import 'json_model.dart';
import 'profile.dart';

@immutable
class RunnerState {
  const RunnerState({
    this.working = false,
    this.paused = false,
    this.message,
    this.jobId,
    this.stage,
    this.heading,
    this.done = 0,
    this.total = 0,
    this.secondsLeft,
  });

  final bool working;
  final bool paused;

  /// Why work isn't progressing, such as no model being loaded.
  final String? message;
  final int? jobId;
  final String? stage;
  final String? heading;
  final int done;
  final int total;

  /// Estimated time left for the current job, once known.
  final int? secondsLeft;
}

/// Works through queued job items one at a time, in the background of the
/// app. Every item is saved as it finishes, so a killed app resumes where it
/// stopped; model outputs are cached, so a retried item doesn't repeat calls.
class GenerationRunner {
  GenerationRunner({required this.repo, required this.prepareModel});

  final GenerationRepository repo;

  /// Loads the model of [documentId] if needed (each document can have its
  /// own); null when no model is available.
  final Future<JsonModel?> Function(int documentId) prepareModel;

  final _states = StreamController<RunnerState>.broadcast();
  RunnerState _state = const RunnerState();
  bool _paused = false;
  String? _pauseReason;
  Future<void>? _loop;

  /// Set when [kick] is called while a loop runs; the loop may already be
  /// on its way out, so it starts again once it ends.
  bool _kickAgain = false;

  /// Seconds per finished item, per stage, for time estimates.
  final Map<String, List<double>> _durations = {};

  static const maxAttempts = 2;

  Stream<RunnerState> get states => _states.stream;
  RunnerState get state => _state;

  /// Whether the work loop runs, including while it loads a model before
  /// its first item (when [RunnerState.working] is still false).
  bool get isActive => _loop != null;

  /// Queues generation and starts working on it.
  Future<int?> start({
    required int documentId,
    required GenerationProfile profile,
    List<int>? sectionIds,
  }) async {
    final jobId = await repo.createJob(
      documentId: documentId,
      profile: profile,
      sectionIds: sectionIds,
    );
    if (jobId != null) {
      _paused = false;
      _pauseReason = null;
      kick();
    }
    return jobId;
  }

  /// Resumes work left by an earlier run of the app.
  Future<void> resumePending() async {
    await repo.resetInterrupted();
    if (await repo.hasQueuedWork()) kick();
  }

  /// Pauses after the current model call. [reason] is shown to the user
  /// (for example, low battery).
  void pause({String? reason}) {
    _paused = true;
    _pauseReason = reason;
    _emit(
      RunnerState(
        paused: true,
        message: reason,
        jobId: _state.jobId,
        stage: _state.stage,
        heading: _state.heading,
        done: _state.done,
        total: _state.total,
      ),
    );
  }

  void resume() {
    _paused = false;
    _pauseReason = null;
    if (_loop != null) {
      // Still inside an item (a model call can't be interrupted): it goes
      // on, so show the work again instead of the pause.
      _emit(
        RunnerState(
          working: true,
          jobId: _state.jobId,
          stage: _state.stage,
          heading: _state.heading,
          done: _state.done,
          total: _state.total,
          secondsLeft: _state.secondsLeft,
        ),
      );
    }
    kick();
  }

  Future<void> cancelJob(int jobId) async {
    await repo.setJobStatus(jobId, 'cancelled');
  }

  /// Starts the work loop unless it is already running.
  void kick() {
    if (_loop != null) {
      _kickAgain = true;
      return;
    }
    _loop = _run().whenComplete(() {
      _loop = null;
      if (_kickAgain) {
        _kickAgain = false;
        if (!_paused) kick();
      }
    });
  }

  /// Completes when no loop is running (for tests).
  Future<void> idle() async {
    while (_loop != null) {
      await _loop;
    }
  }

  Future<void> _run() async {
    if (_paused) return;
    while (!_paused) {
      final item = await repo.nextItem();
      if (item == null) break;
      // Per item: documents can use different models, so the model in
      // memory may change between items.
      final model = await prepareModel(item.documentId);
      if (model == null) {
        _emit(
          const RunnerState(message: 'Load an AI model to generate questions.'),
        );
        return;
      }
      if (_paused) break;
      await repo.setItemStatus(item.itemId, 'running');
      final summary = await repo.summary(item.jobId);
      _emit(
        RunnerState(
          working: true,
          jobId: item.jobId,
          stage: item.stage,
          done: summary?.done ?? 0,
          total: summary?.total ?? 0,
          secondsLeft: _secondsLeft(summary),
        ),
      );
      final watch = Stopwatch()..start();
      try {
        final (:heading, :usedModel) = await _process(item, model);
        // Items with nothing left to do take no time; they would make the
        // estimate far too low.
        if (usedModel) {
          _durations
              .putIfAbsent(item.stage, () => [])
              .add(watch.elapsedMilliseconds / 1000);
        }
        await repo.setItemStatus(item.itemId, 'done');
        _emit(_copy(heading: heading));
      } on LlmCancelledException {
        await repo.setItemStatus(item.itemId, 'queued');
        break;
      } on LlmNotLoadedException {
        await repo.setItemStatus(item.itemId, 'queued');
        _emit(
          const RunnerState(message: 'Load an AI model to generate questions.'),
        );
        return;
      } catch (error, stack) {
        debugPrint(
          'Generation failed for chunk ${item.chunkId}: $error\n$stack',
        );
        final last = item.attempts + 1 >= maxAttempts;
        await repo.setItemStatus(
          item.itemId,
          last ? 'failed' : 'queued',
          error: '$error',
          countAttempt: true,
        );
      }
      await repo.finishCompletedJobs();
    }
    await repo.finishCompletedJobs();
    _emit(RunnerState(paused: _paused, message: _paused ? _pauseReason : null));
  }

  /// Runs one item. Returns the heading it worked on, for the status line,
  /// and whether it called the model.
  Future<({String heading, bool usedModel})> _process(
    WorkItem item,
    JsonModel model,
  ) async {
    final profile = item.profile;
    final generator = ChunkGenerator(
      model: _PausableModel(model, () => _paused),
      profile: profile,
    );
    final needsContext =
        profile.neighborContext &&
        profile.usableDepths.any((d) => d == Depth.apply || d == Depth.analyze);
    final (passage, chunk) = await repo.passage(
      item.chunkId,
      withContext: needsContext,
    );

    var usedModel = false;
    if (item.stage == Stage.facts) {
      // Facts are shared by all qualities: extract them once per chunk.
      if (!await repo.hasFacts(chunk.id)) {
        usedModel = true;
        final result = await generator.facts(passage);
        await repo.saveFacts(
          chunk: chunk,
          result: result,
          profile: profile,
          modelId: model.modelName,
        );
      }
    } else {
      final facts = await repo.factsNeedingQuestions(chunk.id, profile.quality);
      if (facts.isNotEmpty) {
        usedModel = true;
        final result = await generator.questions(
          passage,
          facts,
          existingQuestions: await repo.existingQuestionTexts(chunk.documentId),
        );
        await repo.saveQuestions(
          chunk: chunk,
          facts: facts,
          result: result,
          profile: profile,
          modelId: model.modelName,
        );
      }
    }
    return (heading: chunk.headingPath, usedModel: usedModel);
  }

  int? _secondsLeft(JobSummary? summary) {
    if (summary == null) return null;
    double? average(String stage) {
      final samples = _durations[stage];
      if (samples == null || samples.isEmpty) return null;
      final recent = samples.length > 5
          ? samples.sublist(samples.length - 5)
          : samples;
      return recent.reduce((a, b) => a + b) / recent.length;
    }

    // Until a stage has run once, guess it from the facts stage: writing and
    // blind-checking questions took about 1.6 times as long in the M2 eval.
    final facts = average(Stage.facts);
    var seconds = 0.0;
    for (final entry in summary.remainingByStage.entries) {
      final perItem =
          average(entry.key) ??
          (facts == null
              ? null
              : entry.key == Stage.questions
              ? facts * 1.6
              : facts);
      if (perItem == null) return null;
      seconds += entry.value * perItem;
    }
    return seconds.round();
  }

  RunnerState _copy({bool? paused, String? heading}) => RunnerState(
    working: _state.working && !(paused ?? false),
    paused: paused ?? _state.paused,
    message: _state.message,
    jobId: _state.jobId,
    stage: _state.stage,
    heading: heading ?? _state.heading,
    done: _state.done,
    total: _state.total,
    secondsLeft: _state.secondsLeft,
  );

  void _emit(RunnerState state) {
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }

  Future<void> dispose() async {
    _paused = true;
    await _states.close();
  }
}

/// Stops an item between model calls once the runner is paused, so the chat
/// or a pause button doesn't wait for the rest of the item.
class _PausableModel implements JsonModel {
  _PausableModel(this.inner, this.paused);

  final JsonModel inner;
  final bool Function() paused;

  @override
  String get modelName => inner.modelName;

  @override
  Future<Map<String, Object?>> json({
    required String stage,
    required List<LlmMessage> messages,
    required Map<String, Object?> schema,
    required int maxTokens,
    double temperature = 0.2,
  }) {
    if (paused()) throw LlmCancelledException();
    return inner.json(
      stage: stage,
      messages: messages,
      schema: schema,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }
}
