import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/generate/estimate.dart';
import '../../core/generate/profile.dart';
import 'generate_controllers.dart';

/// Opens the sheet to start generating questions for a document, or for one
/// section and its subsections.
Future<void> showGenerateSheet(
  BuildContext context, {
  required int documentId,
  int? sectionId,
  String? sectionTitle,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _GenerateSheet(
    documentId: documentId,
    sectionId: sectionId,
    sectionTitle: sectionTitle,
  ),
);

class _GenerateSheet extends ConsumerStatefulWidget {
  const _GenerateSheet({
    required this.documentId,
    this.sectionId,
    this.sectionTitle,
  });

  final int documentId;
  final int? sectionId;
  final String? sectionTitle;

  @override
  ConsumerState<_GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends ConsumerState<_GenerateSheet> {
  Quality _quality = Quality.standard;
  final Set<Depth> _depths = {Depth.recall, Depth.understand};
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = GenerationProfile.preset(_quality, depths: _depths);
    final speed = ref.watch(modelSpeedProvider);
    final tokens = ref.watch(chunkTokensProvider(widget.documentId));

    String estimate = '';
    if (speed case AsyncData(value: final s)) {
      if (tokens case AsyncData(value: final bySection)) {
        final scope = widget.sectionId == null
            ? bySection.values.expand((t) => t).toList()
            : bySection[widget.sectionId] ?? const <int>[];
        final time = estimateGeneration(
          chunkTokens: scope,
          profile: profile,
          speed: s,
        );
        estimate =
            '${scope.length} passages · about ${formatDuration(time)}'
            '${s.measured ? '' : ' (rough guess: run the speed test in Settings for a better one)'}';
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.sectionTitle == null
                ? 'Generate questions'
                : 'Generate questions for ${widget.sectionTitle}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text('Quality', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Quality>(
              segments: [
                for (final q in Quality.values)
                  ButtonSegment(value: q, label: Text(q.label)),
              ],
              selected: {_quality},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _quality = s.single),
            ),
          ),
          const SizedBox(height: 8),
          Text(_quality.summary),
          const SizedBox(height: 16),
          Text('Kinds of questions', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final depth in Depth.values)
                FilterChip(
                  label: Text(depth.label),
                  selected:
                      _depths.contains(depth) &&
                      depth.minimumQuality.index <= _quality.index,
                  onSelected: depth.minimumQuality.index > _quality.index
                      ? null
                      : (on) => setState(() {
                          on ? _depths.add(depth) : _depths.remove(depth);
                        }),
                ),
            ],
          ),
          if (_quality.index < Quality.thorough.index)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _quality == Quality.quick
                    ? 'Quick writes recall cards. Apply needs Standard, '
                          'Analyze needs Thorough.'
                    : 'Analyze needs Thorough.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
          Text(estimate),
          const SizedBox(height: 4),
          Text(
            'Cards from each passage become available as soon as they are '
            'written. You can keep using the app.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _starting ? null : () => _start(profile),
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _start(GenerationProfile profile) async {
    setState(() => _starting = true);
    final jobId = await ref
        .read(generationRunnerProvider)
        .start(
          documentId: widget.documentId,
          profile: profile,
          sectionIds: widget.sectionId == null ? null : [widget.sectionId!],
        );
    if (!mounted) return;
    Navigator.pop(context);
    if (jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to generate in this part.')),
      );
    }
  }
}
