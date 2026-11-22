import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/generate/estimate.dart';
import '../../core/generate/profile.dart';
import '../library/library_controllers.dart';
import '../model/model_controllers.dart';
import '../model/model_picker.dart';
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
  useRootNavigator: true,
  isScrollControlled: true,
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
    final profile = GenerationProfile.preset(_quality, depths: _depths);
    final model = ref.watch(documentModelProvider(widget.documentId));
    final speed = ref.watch(modelSpeedProvider(model.path));
    final tokens = ref.watch(chunkTokensProvider(widget.documentId));

    String? estimate;
    var measured = true;
    var passages = 0;
    if (speed case AsyncData(value: final s)) {
      if (tokens case AsyncData(value: final bySection)) {
        final scope = widget.sectionId == null
            ? bySection.values.expand((t) => t).toList()
            : bySection[widget.sectionId] ?? const <int>[];
        passages = scope.length;
        estimate = approxDuration(
          estimateGeneration(chunkTokens: scope, profile: profile, speed: s),
        );
        measured = s.measured;
      }
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Tokens.gutter,
          0,
          Tokens.gutter,
          12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Generate questions', style: context.text.titleLarge),
              const SizedBox(height: 2),
              Text(
                widget.sectionTitle == null
                    ? 'Whole document'
                    : 'Section: ${widget.sectionTitle}',
                style: context.text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SectionLabel('Quality'),
              SegmentedButton<Quality>(
                segments: [
                  for (final q in Quality.values)
                    ButtonSegment(value: q, label: Text(q.label)),
                ],
                selected: {_quality},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _quality = s.single),
              ),
              const SizedBox(height: 6),
              Text(_quality.summary, style: context.text.bodySmall),
              const SectionLabel('Kinds of questions'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
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
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _quality == Quality.quick
                        ? 'Quick has no multiple choice, which sessions lean '
                              'on; Standard and up add it. Apply needs '
                              'Standard; Analyze needs Thorough.'
                        : 'Analyze needs Thorough.',
                    style: context.text.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    PanelRow(
                      leading: Icon(
                        Icons.memory,
                        size: 18,
                        color: context.colors.accent,
                      ),
                      title: Text(model.name),
                      subtitle: Text(
                        model.origin == ModelOrigin.document
                            ? 'Chosen for this document'
                            : 'App default',
                      ),
                      trailing: Text(
                        'Change',
                        style: context.text.labelMedium?.copyWith(
                          color: context.scheme.secondary,
                        ),
                      ),
                      onTap: () =>
                          pickDocumentModel(context, ref, widget.documentId),
                    ),
                    const Divider(),
                    PanelRow(
                      leading: Icon(
                        Icons.schedule,
                        size: 18,
                        color: context.colors.muted,
                      ),
                      title: Text(
                        estimate == null
                            ? 'Estimating…'
                            : '${plural(passages, 'passage')} · $estimate',
                      ),
                      subtitle: Text(
                        measured
                            ? 'From this model\'s speed test. Cards appear as '
                                  'each passage is done.'
                            : 'A rough guess: run the speed test in '
                                  'Settings → AI models for a better one.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _starting || model.path == null
                    ? null
                    : () => _start(profile),
                child: Text(
                  model.path == null ? 'Set up a model first' : 'Start',
                ),
              ),
            ],
          ),
        ),
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
