import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// Mastery color: gray when not started, then red through amber to green.
Color masteryColor(BuildContext context, TopicMastery topic) {
  final scheme = Theme.of(context).colorScheme;
  if (!topic.started) return scheme.surfaceContainerHighest;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return HSVColor.fromAHSV(
    1,
    120 * topic.mastery.clamp(0, 1),
    dark ? 0.55 : 0.6,
    dark ? 0.6 : 0.85,
  ).toColor();
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
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Generate questions and study a little to see your mastery '
              'map.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      AsyncData(:final value) => _content(context, value),
      AsyncError(:final error) => Center(child: Text('$error')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _content(BuildContext context, List<TopicMastery> topics) {
    final theme = Theme.of(context);
    final roots = topics.where((t) => t.depth == 0 && t.facts > 0).toList();
    final facts = roots.fold(0, (n, t) => n + t.facts);
    final seen = roots.fold(0, (n, t) => n + t.seen);
    final due = roots.fold(0, (n, t) => n + t.due);
    final overall = facts == 0
        ? 0.0
        : roots.fold(0.0, (n, t) => n + t.recallSum) / facts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mastery ${(overall * 100).round()}%',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'The chance you would still recall these facts a week from '
                  'now. $seen of $facts facts seen · $due due.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () =>
                          context.go('/study/session?doc=${widget.documentId}'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Study'),
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, icon: Icon(Icons.list)),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.dashboard_outlined),
                        ),
                      ],
                      selected: {_map},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) =>
                          setState(() => _map = s.single),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_map)
          _Treemap(documentId: widget.documentId, topics: topics)
        else
          for (final topic in topics)
            if (topic.facts > 0)
              _TopicRow(documentId: widget.documentId, topic: topic),
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
    final theme = Theme.of(context);
    final percent = (topic.mastery * 100).round();
    return Padding(
      padding: EdgeInsets.only(left: topic.depth * 16.0),
      child: InkWell(
        onTap: () => showTopicActions(context, documentId, topic),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.section.title,
                      style: topic.depth == 0
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(topic.started ? '$percent%' : 'Not started'),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: topic.started ? topic.mastery : 0,
                  minHeight: 8,
                  color: masteryColor(context, topic),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${topic.seen} of ${topic.facts} facts seen'
                '${topic.due > 0 ? ' · ${topic.due} due' : ''}'
                '${topic.fewItems ? ' · few items' : ''}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
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
    final inner = rect.deflate(2);
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
        : Colors.black87;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
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
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (c.maxHeight > 48)
                        Text(
                          topic.started
                              ? '${(topic.mastery * 100).round()}%'
                              : 'new',
                          style: TextStyle(color: textColor, fontSize: 12),
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
  showDragHandle: true,
  builder: (sheet) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            topic.section.title,
            style: Theme.of(sheet).textTheme.titleMedium,
          ),
          subtitle: Text(
            topic.started
                ? 'Mastery ${(topic.mastery * 100).round()}% · '
                      '${topic.seen} of ${topic.facts} facts seen · '
                      '${(topic.durableShare * 100).round()}% well learned'
                : 'Not started · ${topic.facts} facts',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.play_arrow),
          title: const Text('Study this topic'),
          onTap: () {
            Navigator.pop(sheet);
            context.go(
              '/study/session?doc=$documentId&section=${topic.section.id}',
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('Read text and questions'),
          onTap: () {
            Navigator.pop(sheet);
            context.go('/library/doc/$documentId/section/${topic.section.id}');
          },
        ),
        ListTile(
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
  ),
);
