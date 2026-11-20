import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/generate/estimate.dart';
import '../../core/generate/generation_repository.dart';
import 'generate_controllers.dart';

/// Progress of unfinished generation for a document, with pause and cancel.
class GenerationProgressCard extends ConsumerWidget {
  const GenerationProgressCard({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(openJobsProvider(documentId)).value ?? const [];
    if (jobs.isEmpty) return const SizedBox.shrink();
    final job = jobs.first;
    final summary = ref.watch(jobSummaryProvider(job.id)).value;
    final runner = ref.watch(runnerStateProvider).value;
    final runnerNotifier = ref.read(generationRunnerProvider);
    final theme = Theme.of(context);

    final active = runner != null && runner.working && runner.jobId == job.id;
    final paused = runner?.paused ?? false;
    final done = summary?.done ?? 0;
    final total = summary?.total ?? 0;
    final stage = summary?.remainingByStage.containsKey(Stage.facts) ?? true
        ? 'Finding facts, cloze cards and flashcards'
        : 'Writing and checking multiple-choice questions';

    final String status;
    if (paused) {
      status = runner?.message ?? 'Paused.';
    } else if (runner?.message != null && !active) {
      status = runner!.message!;
    } else if (active) {
      final left = runner.secondsLeft;
      status =
          '$stage · $done of $total steps'
          '${left == null ? '' : ' · ${approxDuration(Duration(seconds: left))} left'}';
    } else {
      status = 'Waiting… $done of $total steps done.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generating questions', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: total == 0 ? null : done / total),
            const SizedBox(height: 8),
            Text(status),
            if (active && runner.heading != null)
              Text(
                runner.heading!,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if ((summary?.failed ?? 0) > 0)
              Text(
                '${summary!.failed} passages failed and were skipped.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (paused)
                  FilledButton.tonal(
                    onPressed: runnerNotifier.resume,
                    child: const Text('Resume'),
                  )
                else if (runner?.message != null && !active)
                  FilledButton.tonal(
                    onPressed: () => context.go('/settings/model'),
                    child: const Text('Set up model'),
                  )
                else
                  OutlinedButton(
                    onPressed: runnerNotifier.pause,
                    child: const Text('Pause'),
                  ),
                TextButton(
                  onPressed: () => runnerNotifier.cancelJob(job.id),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
