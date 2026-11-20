import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/generate/estimate.dart';
import '../../core/generate/generation_repository.dart';
import '../../core/generate/json_model.dart';
import '../../core/generate/runner.dart';
import '../../core/ingest/content_kind.dart';
import '../model/model_controllers.dart';

final generationRepositoryProvider = Provider<GenerationRepository>(
  (ref) => GenerationRepository(ref.watch(databaseProvider)),
);

final generationRunnerProvider = Provider<GenerationRunner>((ref) {
  final db = ref.watch(databaseProvider);
  final runner = GenerationRunner(
    repo: ref.watch(generationRepositoryProvider),
    prepareModel: () async {
      final ready = await ref.read(activeModelProvider.notifier).ensureLoaded();
      if (!ready) return null;
      return CachedJsonModel(EngineJsonModel(ref.read(llmEngineProvider)), db);
    },
  );
  ref.onDispose(() => unawaited(runner.dispose()));
  return runner;
});

final runnerStateProvider = StreamProvider<RunnerState>((ref) {
  final runner = ref.watch(generationRunnerProvider);
  return runner.states;
});

/// Resumes generation left unfinished by an earlier run of the app. Watched
/// once by the home shell.
final generationBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(generationRunnerProvider).resumePending();
});

/// Unfinished jobs of a document.
final openJobsProvider = StreamProvider.family<List<Job>, int>(
  (ref, documentId) =>
      ref.watch(generationRepositoryProvider).watchOpenJobs(documentId),
);

final jobSummaryProvider = FutureProvider.family<JobSummary?, int>((
  ref,
  jobId,
) {
  // Recompute as the runner makes progress.
  ref.watch(runnerStateProvider);
  return ref.watch(generationRepositoryProvider).summary(jobId);
});

final sectionCountsProvider =
    FutureProvider.family<Map<int, SectionCounts>, int>((ref, documentId) {
      ref.watch(runnerStateProvider);
      return ref
          .watch(generationRepositoryProvider)
          .countsBySection(documentId);
    });

final sectionFactsProvider =
    FutureProvider.family<List<FactWithQuestions>, int>((ref, sectionId) {
      ref.watch(runnerStateProvider);
      return ref.watch(generationRepositoryProvider).factsOfSection(sectionId);
    });

/// The latest speed test for the model in use, or a rough guess.
final modelSpeedProvider = FutureProvider<ModelSpeed>((ref) async {
  final model = ref.watch(activeModelProvider);
  final name = model.fileName;
  if (name == null) return ModelSpeed.phoneGuess;
  final db = ref.watch(databaseProvider);
  final run =
      await (db.select(db.benchmarkRuns)
            ..where((b) => b.modelName.equals(name))
            ..orderBy([
              (b) => OrderingTerm(
                expression: b.createdAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .getSingleOrNull();
  if (run == null) return ModelSpeed.phoneGuess;
  return ModelSpeed(
    readTokensPerSecond: run.readTokensPerSecond,
    writeTokensPerSecond: run.writeTokensPerSecond,
    measured: true,
  );
});

/// Token sizes of a document's study chunks, by section, for estimates.
final chunkTokensProvider = FutureProvider.family<Map<int, List<int>>, int>((
  ref,
  documentId,
) async {
  final db = ref.watch(databaseProvider);
  final chunks =
      await (db.select(db.chunks)..where(
            (c) =>
                c.documentId.equals(documentId) &
                c.kind.equals(ContentKind.study.name),
          ))
          .get();
  final bySection = <int, List<int>>{};
  for (final chunk in chunks) {
    bySection.putIfAbsent(chunk.sectionId, () => []).add(chunk.tokenEstimate);
  }
  return bySection;
});
