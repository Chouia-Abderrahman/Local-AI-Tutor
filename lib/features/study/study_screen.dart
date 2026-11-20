import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../library/library_controllers.dart';
import 'study_controllers.dart';

/// What is due today, overall and per document.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(null));
    final documents = ref.watch(documentsProvider).value ?? const [];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(studyOverviewProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: switch (overview) {
                  AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        '${value.due} due · ${value.newAvailable} new · '
                        '${value.reviewedToday} reviewed today',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: value.due + value.newAvailable == 0
                            ? null
                            : () => context.go('/study/session'),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Study everything'),
                      ),
                      if (value.due + value.newAvailable == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            value.reviewedToday > 0
                                ? 'All caught up. Come back later for reviews.'
                                : 'Generate questions for a document in the '
                                      'Library first.',
                          ),
                        ),
                    ],
                  ),
                  AsyncError(:final error) => Text('$error'),
                  _ => const LinearProgressIndicator(),
                },
              ),
            ),
            const SizedBox(height: 8),
            for (final doc in documents.where((d) => d.status == 'ready'))
              _DocumentStudyTile(doc: doc),
          ],
        ),
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
    final available = overview == null
        ? 0
        : overview.due + overview.newAvailable;
    return Card(
      child: ListTile(
        title: Text(doc.title),
        subtitle: Text(
          overview == null
              ? ''
              : '${overview.due} due · ${overview.newAvailable} new',
        ),
        trailing: FilledButton.tonal(
          onPressed: available == 0
              ? null
              : () => context.go('/study/session?doc=${doc.id}'),
          child: const Text('Study'),
        ),
      ),
    );
  }
}
