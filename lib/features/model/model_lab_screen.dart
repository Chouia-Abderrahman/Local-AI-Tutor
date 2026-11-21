import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/llm/installed_model.dart';
import '../../core/llm/model_catalog.dart';
import '../../core/llm/model_checks.dart';
import 'model_controllers.dart';

/// The models on this phone: which one is the default, downloads, and tests.
class ModelLabScreen extends ConsumerStatefulWidget {
  const ModelLabScreen({super.key});

  @override
  ConsumerState<ModelLabScreen> createState() => _ModelLabScreenState();
}

class _ModelLabScreenState extends ConsumerState<ModelLabScreen> {
  /// The model the tests run on; null: the default.
  String? _testPath;

  @override
  Widget build(BuildContext context) {
    final ramBytes = ref.watch(totalMemoryProvider).value;
    final recommended = recommendedModel(ramBytes);
    final downloads = ref.watch(modelDownloadsProvider);
    final active = ref.watch(activeModelProvider);
    final installed = ref.watch(installedModelsProvider).value ?? const [];
    final notDownloaded = [
      for (final spec in modelCatalog)
        if (downloads[spec.id]?.phase != DownloadPhase.ready) spec,
    ];
    final testPath = installed.any((m) => m.path == _testPath)
        ? _testPath
        : active.path;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI models'),
        actions: [
          IconButton(
            tooltip: 'Look for models again',
            icon: const Icon(Icons.refresh, size: 21),
            onPressed: () {
              ref.read(modelDownloadsProvider.notifier).refresh();
              ref.invalidate(installedModelsProvider);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Tokens.gutter, 4, Tokens.gutter, 32),
        children: [
          Panel(
            child: Row(
              children: [
                Icon(Icons.smartphone, color: context.colors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ramBytes == null
                            ? 'This phone'
                            : 'This phone: '
                                  '${(ramBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB of RAM',
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Recommended: ${recommended.name}. Documents and '
                        'conversations can each use another model.',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionLabel(
            'On this phone',
            trailing: Text(
              '${installed.length}',
              style: context.text.labelSmall,
            ),
          ),
          if (installed.isEmpty)
            Panel(
              child: Text(
                'No model yet. Download one below; it works offline after '
                'that.',
                style: context.text.bodyMedium,
              ),
            )
          else
            PanelList(
              children: [
                for (final model in installed)
                  _InstalledRow(
                    model: model,
                    isDefault: model.path == active.path,
                    inMemory: model.path == active.loadedPath && active.isReady,
                    loading:
                        active.phase == ModelPhase.loading &&
                        active.targetPath == model.path,
                    recommended: model.spec?.id == recommended.id,
                    onTest: () => setState(() => _testPath = model.path),
                  ),
              ],
            ),
          if (active.phase == ModelPhase.failed && active.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                active.error!,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ),
          if (notDownloaded.isNotEmpty) ...[
            const SectionLabel('Download'),
            PanelList(
              children: [
                for (final spec in notDownloaded)
                  _DownloadRow(
                    spec: spec,
                    status: downloads[spec.id] ?? const DownloadStatus.absent(),
                    recommended: spec.id == recommended.id,
                  ),
              ],
            ),
          ],
          const SectionLabel('Test a model'),
          _TestsPanel(
            installed: installed,
            path: testPath,
            onPath: (path) => setState(() => _testPath = path),
          ),
        ],
      ),
    );
  }
}

class _InstalledRow extends ConsumerWidget {
  const _InstalledRow({
    required this.model,
    required this.isDefault,
    required this.inMemory,
    required this.loading,
    required this.recommended,
    required this.onTest,
  });

  final InstalledModel model;
  final bool isDefault;
  final bool inMemory;
  final bool loading;
  final bool recommended;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.read(activeModelProvider.notifier);
    return PanelRow(
      leading: Icon(
        isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
        size: 20,
        color: isDefault ? context.scheme.onSurface : context.colors.muted,
      ),
      title: Text(model.name),
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(formatBytes(model.sizeBytes)),
          if (isDefault) const Tag('Default', tone: TagTone.solid),
          if (loading) const Tag('Loading…', tone: TagTone.accent),
          if (inMemory) const Tag('In memory', tone: TagTone.success),
          if (recommended) const Tag('Recommended', tone: TagTone.accent),
          if (model.copiedIn) const Tag('Copied in'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        tooltip: 'More',
        icon: Icon(Icons.more_vert, size: 20, color: context.colors.muted),
        onSelected: (value) async {
          switch (value) {
            case 'default':
              await models.select(model.path);
            case 'test':
              onTest();
            case 'unload':
              await models.unload();
            case 'delete':
              await _confirmDelete(context, ref);
          }
        },
        itemBuilder: (_) => [
          if (!isDefault)
            const PopupMenuItem(value: 'default', child: Text('Make default')),
          const PopupMenuItem(value: 'test', child: Text('Test this model')),
          if (inMemory)
            const PopupMenuItem(value: 'unload', child: Text('Unload')),
          if (model.spec != null)
            const PopupMenuItem(value: 'delete', child: Text('Delete file')),
        ],
      ),
      onTap: isDefault ? null : () => models.select(model.path),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final spec = model.spec!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Delete ${spec.name}?'),
        content: Text(
          'This frees ${formatBytes(model.sizeBytes)}. Documents and '
          'conversations that use it switch to the default model. You can '
          'download it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(modelDownloadsProvider.notifier).delete(spec);
      ref.invalidate(installedModelsProvider);
    }
  }
}

class _DownloadRow extends ConsumerWidget {
  const _DownloadRow({
    required this.spec,
    required this.status,
    required this.recommended,
  });

  final ModelSpec spec;
  final DownloadStatus status;
  final bool recommended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.read(modelDownloadsProvider.notifier);
    final running = status.phase == DownloadPhase.running;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          spec.name,
                          style: context.text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (recommended)
                          const Tag('Recommended', tone: TagTone.accent),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatBytes(spec.sizeBytes)} · ${spec.summary}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (running)
                IconButton(
                  tooltip: 'Cancel download',
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => downloads.cancel(spec),
                )
              else
                OutlinedButton.icon(
                  icon: const Icon(Icons.download, size: 18),
                  label: Text(
                    status.phase == DownloadPhase.failed ? 'Retry' : 'Get',
                  ),
                  onPressed: () => _confirmDownload(context, ref),
                ),
            ],
          ),
          if (running) ...[
            const SizedBox(height: 10),
            ThinBar(value: status.fraction ?? 0),
            const SizedBox(height: 6),
            Text(
              status.fraction == null
                  ? 'Starting download…'
                  : '${(status.fraction! * 100).toStringAsFixed(0)}% of '
                        '${formatBytes(spec.sizeBytes)} · keeps going if you '
                        'leave the app',
              style: context.text.bodySmall,
            ),
          ],
          if (status.phase == DownloadPhase.failed)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Download failed: ${status.error}',
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDownload(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text('Download ${spec.name}?'),
        content: Text(
          'The file is ${formatBytes(spec.sizeBytes)}, from Hugging Face. '
          'Use Wi-Fi if mobile data costs you money. It keeps downloading '
          'if you leave the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(modelDownloadsProvider.notifier).start(spec);
  }
}

class _TestsPanel extends ConsumerWidget {
  const _TestsPanel({
    required this.installed,
    required this.path,
    required this.onPath,
  });

  final List<InstalledModel> installed;
  final String? path;
  final void Function(String? path) onPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lab = ref.watch(modelLabProvider);
    final notifier = ref.read(modelLabProvider.notifier);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (installed.isEmpty)
            Text('Download a model to test it.', style: context.text.bodySmall)
          else ...[
            DropdownButtonFormField<String>(
              initialValue: path,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Model'),
              items: [
                for (final m in installed)
                  DropdownMenuItem(value: m.path, child: Text(m.name)),
              ],
              onChanged: lab.busy ? null : onPath,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: lab.busy
                      ? null
                      : () => notifier.runSpeedTest(path: path),
                  child: const Text('Speed test'),
                ),
                OutlinedButton(
                  onPressed: lab.busy
                      ? null
                      : () => notifier.runQuestionTest(path: path),
                  child: const Text('Write a question'),
                ),
                OutlinedButton(
                  onPressed: lab.busy
                      ? null
                      : () => notifier.runStreamTest(path: path),
                  child: const Text('Stream text'),
                ),
                if (lab.busy)
                  TextButton(
                    onPressed: notifier.stop,
                    child: const Text('Stop'),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'The speed test also improves the time estimates for this '
                'model.',
                style: context.text.bodySmall,
              ),
            ),
          ],
          if (lab.step != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lab.modelPath == null
                        ? lab.step!
                        : '${lab.step!} · ${modelDisplayName(lab.modelPath!)}',
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
          ],
          if (lab.error != null) ...[
            const SizedBox(height: 12),
            Text(
              lab.error!,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.danger,
              ),
            ),
          ],
          if (lab.speed != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _SpeedView(result: lab.speed!),
          ],
          if (lab.question != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _QuestionView(check: lab.question!),
          ],
          if (lab.streamed.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(lab.streamed, style: context.text.bodyMedium),
          ],
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatRow(
          stats: [
            Stat(
              value: result.readTokensPerSecond.toStringAsFixed(0),
              label: 'Read tok/s',
            ),
            Stat(
              value: result.writeTokensPerSecond.toStringAsFixed(1),
              label: 'Write tok/s',
            ),
            Stat(value: seconds(result.firstQuestion), label: 'A question'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Next question on the same passage: '
          '${seconds(result.nextQuestion)}.',
          style: context.text.bodySmall,
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
    final json = check.json;
    final distractors = [
      for (final d in (json['distractors'] as List?) ?? const []) '$d',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A TEST QUESTION · '
          '${(check.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} S',
          style: context.text.labelSmall,
        ),
        const SizedBox(height: 6),
        Text('${json['question']}', style: context.text.titleSmall),
        const SizedBox(height: 6),
        Text('✓ ${json['answer']}', style: context.text.bodyMedium),
        for (final d in distractors)
          Text('✗ $d', style: context.text.bodySmall),
        const SizedBox(height: 8),
        Text(
          'Source: "${'${json['quote']}'.replaceAll(RegExp(r'^["“”]+|["“”]+$'), '')}"',
          style: context.text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        if (check.usedGrammar)
          Text(
            'The first replies were not valid JSON, so the slower '
            'constrained retry wrote this one.',
            style: context.text.bodySmall,
          ),
        if (check.ok)
          Text(
            'Passed the quick checks.',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.success,
            ),
          )
        else
          for (final problem in check.problems)
            Text(
              problem,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.danger,
              ),
            ),
      ],
    );
  }
}
