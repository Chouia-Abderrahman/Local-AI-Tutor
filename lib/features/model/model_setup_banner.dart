import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'model_controllers.dart';

/// Shown until a model is chosen and loaded.
class ModelSetupBanner extends ConsumerWidget {
  const ModelSetupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeModelProvider);
    if (state.isReady) return const SizedBox.shrink();

    final (
      String title,
      String body,
      String action,
      VoidCallback onPressed,
    ) = switch (state) {
      ActiveModelState(path: null) => (
        'Set up the AI model',
        'Questions are written by an AI model that runs on this phone. '
            'Download it once (0.5 to 2.7 GB); after that it works '
            'offline.',
        'Choose a model',
        () => context.go('/settings/model'),
      ),
      ActiveModelState(phase: ModelPhase.loading) => (
        'Loading the AI model…',
        'This takes a few seconds.',
        'Details',
        () => context.go('/settings/model'),
      ),
      ActiveModelState(phase: ModelPhase.failed) => (
        'The AI model could not load',
        state.error ?? 'Unknown error.',
        'Fix it',
        () => context.go('/settings/model'),
      ),
      _ => (
        'AI model not loaded',
        '${state.fileName} is ready to load.',
        'Load',
        () => ref.read(activeModelProvider.notifier).load(),
      ),
    };

    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(body),
            const SizedBox(height: 12),
            FilledButton(onPressed: onPressed, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
