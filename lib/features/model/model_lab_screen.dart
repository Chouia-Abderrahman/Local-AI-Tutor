import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/llm/model_catalog.dart';
import '../../core/llm/model_checks.dart';
import 'model_controllers.dart';

/// Choose, download and test the on-device model.
class ModelLabScreen extends ConsumerWidget {
  const ModelLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ramBytes = switch (ref.watch(totalMemoryProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final recommended = recommendedModel(ramBytes);
    final downloads = ref.watch(modelDownloadsProvider);
    final active = ref.watch(activeModelProvider);
    final sideloaded = switch (ref.watch(modelStoreProvider)) {
      AsyncData(:final value) => value.sideloadedFiles(),
      _ => const [],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI model'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(modelDownloadsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _DeviceCard(ramBytes: ramBytes, recommended: recommended),
          const _SectionTitle('Models'),
          for (final spec in modelCatalog)
            _ModelTile(
              spec: spec,
              status: downloads[spec.id] ?? const DownloadStatus.absent(),
              recommended: spec.id == recommended.id,
              activePath: active.path,
            ),
          if (sideloaded.isNotEmpty) ...[
            const _SectionTitle('Copied to this phone'),
            for (final file in sideloaded)
              Card(
                child: ListTile(
                  title: Text(file.path.split('/').last),
                  subtitle: Text(formatBytes(file.lengthSync())),
                  trailing: active.path == file.path
                      ? const Chip(label: Text('In use'))
                      : TextButton(
                          onPressed: () => ref
                              .read(activeModelProvider.notifier)
                              .select(file.path),
                          child: const Text('Use'),
                        ),
                ),
              ),
          ],
          const _SectionTitle('Loaded model'),
          _ActiveModelCard(state: active),
          const _SectionTitle('Tests'),
          const _TestsCard(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.ramBytes, required this.recommended});

  final int? ramBytes;
  final ModelSpec recommended;

  @override
  Widget build(BuildContext context) {
    final ram = ramBytes == null
        ? 'unknown'
        : '${(ramBytes! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.smartphone),
        title: Text('This device has $ram of RAM'),
        subtitle: Text('Recommended model: ${recommended.name}'),
      ),
    );
  }
}

class _ModelTile extends ConsumerWidget {
  const _ModelTile({
    required this.spec,
    required this.status,
    required this.recommended,
    required this.activePath,
  });

  final ModelSpec spec;
  final DownloadStatus status;
  final bool recommended;
  final String? activePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.read(modelDownloadsProvider.notifier);
    final theme = Theme.of(context);
    final isActive = status.path != null && status.path == activePath;

    final Widget trailing = switch (status.phase) {
      DownloadPhase.absent || DownloadPhase.failed => TextButton(
        onPressed: () => _confirmDownload(context, ref),
        child: Text(status.phase == DownloadPhase.failed ? 'Retry' : 'Get'),
      ),
      DownloadPhase.running => IconButton(
        tooltip: 'Cancel download',
        icon: const Icon(Icons.close),
        onPressed: () => downloads.cancel(spec),
      ),
      DownloadPhase.ready => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            const Chip(label: Text('In use'))
          else
            TextButton(
              onPressed: () =>
                  ref.read(activeModelProvider.notifier).select(status.path!),
              child: const Text('Use'),
            ),
          PopupMenuButton<String>(
            onSelected: (_) => _confirmDelete(context, ref),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete file')),
            ],
          ),
        ],
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Row(
            children: [
              Flexible(child: Text(spec.name)),
              if (recommended) ...[
                const SizedBox(width: 8),
                Text(
                  'Recommended',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${formatBytes(spec.sizeBytes)} · ${spec.summary}'),
              if (status.phase == DownloadPhase.running) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: status.fraction),
                const SizedBox(height: 4),
                Text(
                  status.fraction == null
                      ? 'Starting download…'
                      : '${(status.fraction! * 100).toStringAsFixed(0)}% of '
                            '${formatBytes(spec.sizeBytes)}',
                ),
              ],
              if (status.phase == DownloadPhase.failed)
                Text(
                  'Download failed: ${status.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
          ),
          trailing: trailing,
          isThreeLine: status.phase != DownloadPhase.absent,
        ),
      ),
    );
  }

  Future<void> _confirmDownload(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download ${spec.name}?'),
        content: Text(
          'The file is ${formatBytes(spec.sizeBytes)}. Use Wi-Fi if mobile '
          'data costs you money. You can keep using the app while it '
          'downloads.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(modelDownloadsProvider.notifier).start(spec);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${spec.name}?'),
        content: Text(
          'This frees ${formatBytes(spec.sizeBytes)}. You can download it '
          'again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(modelDownloadsProvider.notifier).delete(spec);
    }
  }
}

class _ActiveModelCard extends ConsumerWidget {
  const _ActiveModelCard({required this.state});

  final ActiveModelState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(activeModelProvider.notifier);
    final theme = Theme.of(context);
    final (String status, Widget? action) = switch (state.phase) {
      _ when state.path == null => ('No model chosen yet.', null),
      ModelPhase.none => (
        'Not loaded.',
        FilledButton(onPressed: notifier.load, child: const Text('Load')),
      ),
      ModelPhase.loading => ('Loading…', null),
      ModelPhase.ready => (
        'Ready (${state.backend ?? 'unknown backend'}).',
        OutlinedButton(onPressed: notifier.unload, child: const Text('Unload')),
      ),
      ModelPhase.failed => (
        'Could not load: ${state.error}',
        FilledButton(onPressed: notifier.load, child: const Text('Try again')),
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.fileName ?? 'None', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Row(
              children: [
                if (state.phase == ModelPhase.loading) ...[
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(status)),
              ],
            ),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}

class _TestsCard extends ConsumerWidget {
  const _TestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lab = ref.watch(modelLabProvider);
    final notifier = ref.read(modelLabProvider.notifier);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: lab.busy ? null : notifier.runSpeedTest,
                  child: const Text('Speed test'),
                ),
                FilledButton.tonal(
                  onPressed: lab.busy ? null : notifier.runQuestionTest,
                  child: const Text('Write a question'),
                ),
                FilledButton.tonal(
                  onPressed: lab.busy ? null : notifier.runStreamTest,
                  child: const Text('Stream text'),
                ),
                if (lab.busy)
                  OutlinedButton(
                    onPressed: notifier.stop,
                    child: const Text('Stop'),
                  ),
              ],
            ),
            if (lab.step != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(lab.step!)),
                ],
              ),
            ],
            if (lab.error != null) ...[
              const SizedBox(height: 16),
              Text(
                lab.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            if (lab.speed != null) ...[
              const SizedBox(height: 16),
              _SpeedView(result: lab.speed!),
            ],
            if (lab.question != null) ...[
              const SizedBox(height: 16),
              _QuestionView(check: lab.question!),
            ],
            if (lab.streamed.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(lab.streamed),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeedView extends StatelessWidget {
  const _SpeedView({required this.result});

  final SpeedResult result;

  @override
  Widget build(BuildContext context) {
    String seconds(Duration d) =>
        '${(d.inMilliseconds / 1000).toStringAsFixed(1)} s';
    final reuse = result.cachedPromptShare;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speed', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Reads ${result.readTokensPerSecond.toStringAsFixed(1)} tokens/s, '
          'writes ${result.writeTokensPerSecond.toStringAsFixed(1)} tokens/s.',
        ),
        Text(
          'First question on a new passage: ${seconds(result.firstQuestion)}.',
        ),
        Text(
          'Next question on the same passage: '
          '${seconds(result.nextQuestion)}'
          '${reuse == null ? '' : ' (${(reuse * 100).toStringAsFixed(0)}% of the prompt reused)'}.',
        ),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.check});

  final QuestionCheck check;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final json = check.json;
    final distractors = [
      for (final d in (json['distractors'] as List?) ?? const []) '$d',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question (${(check.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} s)',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text('${json['question']}', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text('✓ ${json['answer']}'),
        for (final d in distractors) Text('✗ $d'),
        const SizedBox(height: 8),
        Text(
          'Source: "${'${json['quote']}'.replaceAll(RegExp(r'^["“”]+|["“”]+$'), '')}"',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        Text('${json['explanation']}', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        if (check.usedGrammar)
          Text(
            'The first reply was not valid JSON, so the slower constrained '
            'retry wrote this one.',
            style: theme.textTheme.bodySmall,
          ),
        if (check.ok)
          Text(
            'Passed the quick checks.',
            style: TextStyle(color: theme.colorScheme.primary),
          )
        else
          for (final problem in check.problems)
            Text(problem, style: TextStyle(color: theme.colorScheme.error)),
      ],
    );
  }
}
