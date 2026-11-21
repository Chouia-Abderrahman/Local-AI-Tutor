import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/database.dart';
import '../library/library_controllers.dart';
import 'study_controllers.dart';

/// What is due today, overall and per document.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(null));
    final documents = (ref.watch(documentsProvider).value ?? const [])
        .where((d) => d.status == 'ready')
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studyOverviewProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Tokens.gutter,
            4,
            Tokens.gutter,
            32,
          ),
          children: [
            switch (overview) {
              AsyncData(:final value) => Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Today', style: context.text.titleSmall),
                    const SizedBox(height: 12),
                    StatRow(
                      stats: [
                        Stat(
                          value: '${value.due}',
                          label: 'Due',
                          highlight: value.due > 0,
                        ),
                        Stat(value: '${value.newAvailable}', label: 'New'),
                        Stat(
                          value: '${value.reviewedToday}',
                          label: 'Done today',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: value.due + value.newAvailable == 0
                          ? null
                          : () => context.go('/study/session'),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text('Study everything'),
                    ),
                    if (value.due + value.newAvailable == 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          value.reviewedToday > 0
                              ? 'All caught up. Reviews come back when they '
                                    'are due.'
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
              PanelList(
                children: [
                  for (final doc in documents) _DocumentStudyRow(doc: doc),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocumentStudyRow extends ConsumerWidget {
  const _DocumentStudyRow({required this.doc});

  final StudyDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(doc.id)).value;
    final available = overview == null
        ? 0
        : overview.due + overview.newAvailable;
    return PanelRow(
      title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        overview == null
            ? ''
            : '${overview.due} due · ${overview.newAvailable} new',
      ),
      trailing: available == 0
          ? Icon(Icons.check, size: 18, color: context.colors.success)
          : OutlinedButton(
              onPressed: () => context.go('/study/session?doc=${doc.id}'),
              child: const Text('Study'),
            ),
    );
  }
}
