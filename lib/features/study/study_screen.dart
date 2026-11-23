import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/database.dart';
import '../library/library_controllers.dart';
import 'study_controllers.dart';

String _greeting(DateTime now) {
  final hour = now.hour;
  if (hour < 5) return 'Still up';
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// What is due today, overall and per document.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(null));
    final documents = (ref.watch(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(studyOverviewProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Tokens.gutter,
              14,
              Tokens.gutter,
              32,
            ),
            children: [
              Text(_greeting(DateTime.now()), style: context.text.displaySmall),
              const SizedBox(height: 4),
              Text(switch (overview) {
                AsyncData(:final value) when value.waiting > 0 =>
                  '${plural(value.waiting, 'card')} '
                      'waiting for you',
                AsyncData() => 'Nothing waiting right now',
                _ => ' ',
              }, style: context.text.bodyMedium),
              const SizedBox(height: 20),
              switch (overview) {
                AsyncData(:final value) => Panel(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _Ring(
                            done: value.reviewedToday,
                            waiting: value.waiting,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: StatRow(
                              stats: [
                                Stat(
                                  value: '${value.due}',
                                  label: 'Due',
                                  highlight: value.due > 0,
                                ),
                                Stat(
                                  value: '${value.newAvailable}',
                                  label: 'New',
                                ),
                                Stat(value: '${value.unseen}', label: 'Unseen'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: value.waiting == 0
                            ? null
                            : () => context.go('/study/session'),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text('Study everything'),
                      ),
                      if (value.waiting == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            value.reviewedToday > 0
                                ? 'All caught up. Reviews come back when '
                                      'they are due.'
                                : 'Generate questions for a document in the '
                                      'Library first.',
                            style: context.text.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                AsyncError(:final error) => Text('$error'),
                _ => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
              if (documents.isNotEmpty) ...[
                const SectionLabel('By document'),
                for (final doc in documents) ...[
                  _DocumentStudyTile(doc: doc),
                  const SizedBox(height: 12),
                ],
              ],
              SizedBox(height: documents.isEmpty ? 0 : 4),
              Text(
                'Questions lean on multiple choice; a card turns over when '
                'you answer, and shows where in the text it comes from. '
                'Unseen are questions of cards you know that haven\'t been '
                'asked yet.',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: colors.faint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Today's progress as a ring: answered of answered plus still waiting.
class _Ring extends StatelessWidget {
  const _Ring({required this.done, required this.waiting});

  final int done;
  final int waiting;

  @override
  Widget build(BuildContext context) {
    final total = done + waiting;
    final progress = total == 0 ? 1.0 : done / total;
    return SizedBox.square(
      dimension: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: context.colors.sunken,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$done', style: context.text.headlineMedium),
              Text('TODAY', style: context.text.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentStudyTile extends ConsumerWidget {
  const _DocumentStudyTile({required this.doc});

  final StudyDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(doc.id)).value;
    final available = overview?.waiting ?? 0;
    final colors = context.colors;
    return Panel(
      onTap: available == 0
          ? null
          : () => context.go('/study/session?doc=${doc.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.style_outlined, color: colors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: 6),
                if (overview != null)
                  Wrap(
                    spacing: 6,
                    children: [
                      if (overview.due > 0)
                        Pill(
                          label: '${overview.due} due',
                          dense: true,
                          color: colors.accent,
                        ),
                      if (overview.newAvailable > 0)
                        Pill(
                          label: '${overview.newAvailable} new',
                          dense: true,
                          color: colors.success,
                        ),
                      if (overview.unseen > 0)
                        Pill(
                          label: '${overview.unseen} unseen',
                          dense: true,
                          color: colors.muted,
                        ),
                      if (available == 0)
                        Pill(label: 'All caught up', dense: true),
                    ],
                  ),
              ],
            ),
          ),
          if (available > 0)
            Icon(
              Icons.play_circle_fill_rounded,
              color: colors.accent,
              size: 34,
            ),
        ],
      ),
    );
  }
}
