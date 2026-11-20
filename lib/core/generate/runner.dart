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

  /// Loads the model if needed; null when no model is available.
  final Future<JsonModel?> Function() prepareModel;

  final _states = StreamController<RunnerState>.broadcast();
  RunnerState _state = const RunnerState();
  bool _paused = false;
  Future<void>? _loop;

  /// Seconds per finished item, per stage, for time estimates.
  final Map<String, List<double>> _durations = {};

  static const maxAttempts = 2;

  Stream<RunnerState> get states => _states.stream;
  RunnerState get state => _state;

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
      kick();
    }
    return jobId;
  }

  /// Resumes work left by an earlier run of the app.
  Future<void> resumePending() async {
    await repo.resetInterrupted();
    if (await repo.hasQueuedWork()) kick();
  }

  void pause() {
    _paused = true;
    _emit(_copy(paused: true));
  }

  void resume() {
    _paused = false;
    kick();
  }

  Future<void> cancelJob(int jobId) async {
    await repo.setJobStatus(jobId, 'cancelled');
  }

  /// Starts the work loop unless it is already running.
  void kick() {
    _loop ??= _run().whenComplete(() => _loop = null);
  }

  /// Completes when the current loop has stopped (for tests).
  Future<void> idle() => _loop ?? Future<void>.value();

  Future<void> _run() async {
    if (_paused) return;
    final model = await prepareModel();
    if (model == null) {
      _emit(
        const RunnerState(message: 'Load an AI model to generate questions.'),
      );
      return;
    }
    while (!_paused) {
      final item = await repo.nextItem();
      if (item == null) break;
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
        final heading = await _process(item, model);
        _durations
            .putIfAbsent(item.stage, () => [])
            .add(watch.elapsedMilliseconds / 1000);
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
    _emit(RunnerState(paused: _paused));
  }

  /// Runs one item; returns the heading it worked on, for the status line.
  Future<String> _process(WorkItem item, JsonModel model) async {
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

    if (item.stage == Stage.facts) {
      // Facts are shared by all qualities: extract them once per chunk.
      if (!await repo.hasFacts(chunk.id)) {
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
    return chunk.headingPath;
  }

  int? _secondsLeft(JobSummary? summary) {
    if (summary == null) return null;
    var seconds = 0.0;
    for (final entry in summary.remainingByStage.entries) {
      final samples = _durations[entry.key];
      if (samples == null || samples.isEmpty) return null;
      final recent = samples.length > 5
          ? samples.sublist(samples.length - 5)
          : samples;
      seconds += entry.value * recent.reduce((a, b) => a + b) / recent.length;
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
