import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/llm/installed_model.dart';
import 'model_controllers.dart';

/// Shown when no model is set up, or the model failed to load. Models load
/// by themselves when something needs them, so there is no "Load" step.
class ModelSetupBanner extends ConsumerWidget {
  const ModelSetupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeModelProvider);
    final (String title, String body, String action)? content = switch (state) {
      ActiveModelState(path: null, phase: != ModelPhase.loading) => (
        'Set up the on-device model',
        'Questions and answers are written by an AI model that runs on this '
            'phone. Download one once (0.5 to 2.7 GB); after that it works '
            'offline.',
        'Choose a model',
      ),
      ActiveModelState(phase: ModelPhase.failed) => (
        'The AI model could not load',
        state.error ?? 'Unknown error.',
        'Open AI models',
      ),
      _ => null,
    };
    if (content == null) return const SizedBox.shrink();
    final (title, body, action) = content;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Panel(
        color: context.scheme.secondaryContainer.withValues(alpha: 0.5),
        borderColor: context.colors.accent.withValues(alpha: 0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.memory, color: context.scheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  const SizedBox(height: 4),
                  Text(body, style: context.text.bodyMedium),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.go('/settings/model'),
                    child: Text(action),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact status of the model in memory, for app bars: a dot (green:
/// loaded, amber: loading, red: failed, gray: idle) and the model's name.
class ModelStatusButton extends ConsumerWidget {
  const ModelStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeModelProvider);
    final path = state.currentPath;
    final name = path == null ? 'No model' : modelDisplayName(path);
    final colors = context.colors;
    final (Color dot, String tooltip) = switch (state.phase) {
      ModelPhase.ready => (colors.success, '$name is loaded'),
      ModelPhase.loading => (colors.accent, 'Loading $name'),
      ModelPhase.failed => (colors.danger, '$name failed to load'),
      ModelPhase.none => (
        context.scheme.outline,
        path == null ? 'No model set up' : '$name loads when needed',
      ),
    };
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radius),
        onTap: () => context.go('/settings/model'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Tokens.radius),
            border: Border.all(color: context.colors.hairline),
            color: context.scheme.surfaceContainerLowest,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.phase == ModelPhase.loading)
                SizedBox.square(
                  dimension: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: dot,
                  ),
                )
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dot,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
