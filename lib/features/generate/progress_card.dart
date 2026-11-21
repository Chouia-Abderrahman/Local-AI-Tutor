import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
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

    final active = runner != null && runner.working && runner.jobId == job.id;
    final paused = runner?.paused ?? false;
    final blocked = runner?.message != null && !active && !paused;
    final done = summary?.done ?? 0;
    final total = summary?.total ?? 0;
    final stage = summary?.remainingByStage.containsKey(Stage.facts) ?? true
        ? 'Finding facts, cloze cards and flashcards'
        : 'Writing and checking multiple-choice questions';

    final String status;
    if (paused) {
      status = runner?.message ?? 'Paused.';
    } else if (blocked) {
      status = runner!.message!;
    } else if (active) {
      final left = runner.secondsLeft;
      status =
          '$stage${left == null ? '' : ' · ${approxDuration(Duration(seconds: left))} left'}';
    } else {
      status = 'Waiting to start…';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (active)
                  const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    paused ? Icons.pause_circle_outline : Icons.schedule,
                    size: 16,
                    color: context.colors.muted,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    paused ? 'Generation paused' : 'Generating questions',
                    style: context.text.titleSmall,
                  ),
                ),
                Text(
                  '$done/$total',
                  style: context.text.labelMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ThinBar(value: total == 0 ? 0 : done / total),
            const SizedBox(height: 8),
            Text(status, style: context.text.bodySmall),
            if (active && runner.heading != null)
              Text(
                runner.heading!,
                style: context.text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if ((summary?.failed ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${plural(summary!.failed, 'passage')} failed and '
                  '${summary.failed == 1 ? 'was' : 'were'} skipped.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.danger,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => runnerNotifier.cancelJob(job.id),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: context.colors.muted),
                  ),
                ),
                const SizedBox(width: 4),
                if (paused)
                  FilledButton.tonal(
                    onPressed: runnerNotifier.resume,
                    child: const Text('Resume'),
                  )
                else if (blocked)
                  FilledButton.tonal(
                    onPressed: () => context.go('/settings/model'),
                    child: const Text('Set up model'),
                  )
                else
                  OutlinedButton(
                    onPressed: runnerNotifier.pause,
                    child: const Text('Pause'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
