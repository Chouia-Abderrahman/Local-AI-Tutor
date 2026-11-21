import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/study/mastery.dart';
import '../../core/study/treemap.dart';
import '../generate/generate_controllers.dart';
import '../generate/generate_sheet.dart';
import '../study/study_controllers.dart';

final masteryProvider = FutureProvider.family<List<TopicMastery>, int>((
  ref,
  documentId,
) {
  // Refresh when sessions end or generation adds facts.
  ref.watch(studyOverviewProvider(documentId));
  ref.watch(runnerStateProvider);
  return ref.watch(studyRepositoryProvider).mastery(documentId);
});

/// Mastery color: gray when not started, then rust through amber to green.
Color masteryColor(BuildContext context, TopicMastery topic) {
  if (!topic.started) return context.scheme.surfaceContainerHighest;
  final colors = context.colors;
  final m = topic.mastery.clamp(0.0, 1.0);
  return m < 0.5
      ? Color.lerp(colors.masteryLow, colors.masteryMid, m / 0.5)!
      : Color.lerp(colors.masteryMid, colors.masteryHigh, (m - 0.5) / 0.5)!;
}

/// The mastery map of a document: a topic list or a treemap.
class MasteryView extends ConsumerStatefulWidget {
  const MasteryView({super.key, required this.documentId});

  final int documentId;

  @override
  ConsumerState<MasteryView> createState() => _MasteryViewState();
}

class _MasteryViewState extends ConsumerState<MasteryView> {
  bool _map = false;

  @override
  Widget build(BuildContext context) {
    final mastery = ref.watch(masteryProvider(widget.documentId));
    return switch (mastery) {
      AsyncData(:final value) when value.every((t) => t.facts == 0) =>
        const EmptyState(
          icon: Icons.insights_outlined,
          title: 'No mastery map yet',
          body:
              'Generate questions and study a little: each topic then shows '
              'how much you would still recall a week from now.',
        ),
      AsyncData(:final value) => _content(context, value),
      AsyncError(:final error) => Center(child: Text('$error')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _content(BuildContext context, List<TopicMastery> topics) {
    final roots = topics.where((t) => t.depth == 0 && t.facts > 0).toList();
    final facts = roots.fold(0, (n, t) => n + t.facts);
    final seen = roots.fold(0, (n, t) => n + t.seen);
    final due = roots.fold(0, (n, t) => n + t.due);
    final overall = facts == 0
        ? 0.0
        : roots.fold(0.0, (n, t) => n + t.recallSum) / facts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 12, Tokens.gutter, 32),
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(overall * 100).round()}%',
                    style: context.text.displaySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('MASTERY', style: context.text.labelSmall),
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.view_list_outlined, size: 18),
                        tooltip: 'List',
                      ),
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.dashboard_outlined, size: 18),
                        tooltip: 'Map',
                      ),
                    ],
                    selected: {_map},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() => _map = s.single),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ThinBar(value: overall, height: 4),
              const SizedBox(height: 10),
              Text(
                'The chance you would still recall these facts a week from '
                'now. $seen of $facts facts seen · $due due.',
                style: context.text.bodySmall,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    context.go('/study/session?doc=${widget.documentId}'),
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text('Study'),
              ),
            ],
          ),
        ),
        const SectionLabel('Topics'),
        if (_map)
          _Treemap(documentId: widget.documentId, topics: topics)
        else
          PanelList(
            children: [
              for (final topic in topics)
                if (topic.facts > 0)
                  _TopicRow(documentId: widget.documentId, topic: topic),
            ],
          ),
        const SizedBox(height: 12),
        _Legend(),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget swatch(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: context.text.bodySmall),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        swatch(context.scheme.surfaceContainerHighest, 'Not started'),
        swatch(colors.masteryLow, 'Fading'),
        swatch(colors.masteryMid, 'Learning'),
        swatch(colors.masteryHigh, 'Known'),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.documentId, required this.topic});

  final int documentId;
  final TopicMastery topic;

  @override
  Widget build(BuildContext context) {
    final percent = (topic.mastery * 100).round();
    return InkWell(
      onTap: () => showTopicActions(context, documentId, topic),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0 + topic.depth * 14, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic.section.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: topic.depth == 0
                        ? context.text.titleSmall
                        : context.text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  topic.started ? '$percent%' : 'Not started',
                  style: context.text.labelMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: topic.started ? null : context.colors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ThinBar(
              value: topic.started ? topic.mastery : 0,
              height: 4,
              color: masteryColor(context, topic),
            ),
            const SizedBox(height: 5),
            Text(
              '${topic.seen} of ${topic.facts} facts seen'
              '${topic.due > 0 ? ' · ${topic.due} due' : ''}'
              '${topic.fewItems ? ' · few items' : ''}',
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-level topics sized by fact count and colored by mastery, each split
/// into its subtopics.
class _Treemap extends StatelessWidget {
  const _Treemap({required this.documentId, required this.topics});

  final int documentId;
  final List<TopicMastery> topics;

  @override
  Widget build(BuildContext context) {
    final roots = topics.where((t) => t.depth == 0 && t.facts > 0).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 1.1;
        final rects = squarify([
          for (final t in roots) t.facts.toDouble(),
        ], Rect.fromLTWH(0, 0, width, height));
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              for (final (i, root) in roots.indexed)
                ..._tiles(context, root, rects[i]),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _tiles(BuildContext context, TopicMastery root, Rect rect) {
    final children = [
      for (final t in topics)
        if (t.section.parentId == root.section.id && t.facts > 0) t,
    ];
    final ownFacts = root.facts - children.fold(0, (n, c) => n + c.facts);
    // Subtopics split the parent's tile; the parent's own facts keep a share.
    final parts = [if (ownFacts > 0 || children.isEmpty) root, ...children];
    final sizes = [
      for (final p in parts)
        (identical(p, root)
                ? (children.isEmpty ? root.facts : ownFacts)
                : p.facts)
            .toDouble(),
    ];
    final inner = rect.deflate(1.5);
    final rects = squarify(sizes, inner);
    return [
      for (final (i, part) in parts.indexed)
        Positioned.fromRect(
          rect: rects[i].deflate(1),
          child: _Tile(
            topic: part,
            label: identical(part, root) || children.isEmpty
                ? root.section.title
                : part.section.title,
            onTap: () => showTopicActions(context, documentId, part),
          ),
        ),
    ];
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.topic, required this.label, required this.onTap});

  final TopicMastery topic;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = masteryColor(context, topic);
    final textColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : const Color(0xFF15171C);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(Tokens.radiusSmall),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: LayoutBuilder(
            builder: (context, c) => c.maxHeight < 28 || c.maxWidth < 40
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                      if (c.maxHeight > 48)
                        Text(
                          topic.started
                              ? '${(topic.mastery * 100).round()}%'
                              : 'new',
                          style: context.text.bodySmall?.copyWith(
                            color: textColor.withValues(alpha: 0.85),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Study, read, or generate more for one topic.
Future<void> showTopicActions(
  BuildContext context,
  int documentId,
  TopicMastery topic,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  builder: (sheet) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(topic.section.title, style: sheet.text.titleLarge),
          const SizedBox(height: 4),
          Text(
            topic.started
                ? 'Mastery ${(topic.mastery * 100).round()}% · '
                      '${topic.seen} of ${topic.facts} facts seen · '
                      '${(topic.durableShare * 100).round()}% well learned'
                : 'Not started · ${topic.facts} facts',
            style: sheet.text.bodySmall,
          ),
          const SizedBox(height: 12),
          PanelList(
            children: [
              PanelRow(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Study this topic'),
                onTap: () {
                  Navigator.pop(sheet);
                  context.go(
                    '/study/session?doc=$documentId&section=${topic.section.id}',
                  );
                },
              ),
              PanelRow(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Read text and questions'),
                onTap: () {
                  Navigator.pop(sheet);
                  context.go(
                    '/library/doc/$documentId/section/${topic.section.id}',
                  );
                },
              ),
              PanelRow(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: const Text('Generate more questions'),
                onTap: () {
                  Navigator.pop(sheet);
                  showGenerateSheet(
                    context,
                    documentId: documentId,
                    sectionId: topic.section.id,
                    sectionTitle: topic.section.title,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
