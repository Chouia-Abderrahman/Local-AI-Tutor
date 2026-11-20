import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/library_repository.dart';
import '../../core/generate/generation_repository.dart';
import '../generate/generate_controllers.dart';
import '../generate/generate_sheet.dart';
import '../generate/progress_card.dart';
import '../mastery/mastery_view.dart';
import 'library_controllers.dart';

/// A document's outline: its sections, which are studied and which skipped,
/// and how many questions each has.
class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outline = ref.watch(documentOutlineProvider(documentId));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (outline) {
            AsyncData(:final value) => value.document.title,
            _ => 'Document',
          }),
          actions: [
            IconButton(
              tooltip: 'Delete document',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Outline'),
              Tab(text: 'Mastery'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            switch (outline) {
              AsyncData(:final value) => _OutlineView(outline: value),
              AsyncError(:final error) => Center(child: Text('$error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
            MasteryView(documentId: documentId),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this document?'),
        content: const Text(
          'Its questions and your study progress for it are deleted too.',
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
    if (ok != true) return;
    await ref.read(libraryRepositoryProvider).deleteDocument(documentId);
    if (context.mounted) context.go('/library');
  }
}

class _OutlineView extends ConsumerWidget {
  const _OutlineView({required this.outline});

  final DocumentOutline outline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final doc = outline.document;
    final counts =
        ref.watch(sectionCountsProvider(doc.id)).value ??
        const <int, SectionCounts>{};
    final questions = counts.values.fold(0, (n, c) => n + c.questions);
    final skipped = outline.sections.where((s) => s.isSkipped).length;
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
                  '${doc.pageCount} pages · ${outline.sections.length} sections'
                  '${doc.language == null || doc.language == 'und' ? '' : ' · ${doc.language!.toUpperCase()}'}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${outline.studyChunks} passages to study'
                  '${skipped > 0 ? '; $skipped sections skipped (contents, references…)' : ''}.',
                ),
                if (questions > 0) Text('$questions questions so far.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: outline.studyChunks == 0
                      ? null
                      : () => showGenerateSheet(context, documentId: doc.id),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    questions == 0 ? 'Generate questions' : 'Generate more',
                  ),
                ),
              ],
            ),
          ),
        ),
        GenerationProgressCard(documentId: doc.id),
        const SizedBox(height: 8),
        for (final summary in outline.sections)
          _SectionTile(
            documentId: doc.id,
            summary: summary,
            counts: counts[summary.section.id],
          ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.documentId,
    required this.summary,
    required this.counts,
  });

  final int documentId;
  final SectionSummary summary;
  final SectionCounts? counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = summary.section;
    final pages = section.pageStart == section.pageEnd
        ? 'p. ${section.pageStart}'
        : 'pp. ${section.pageStart}–${section.pageEnd}';
    final generated = counts == null || counts!.questions == 0
        ? ''
        : ' · ${counts!.questions} questions';
    final detail = summary.isSkipped
        ? 'Skipped: ${summary.skippedKinds.map((k) => k.label).join(', ')}'
        : summary.studyChunks == 0
        ? pages
        : '$pages · ${summary.studyChunks} '
              '${summary.studyChunks == 1 ? 'passage' : 'passages'}$generated';
    final openable = summary.studyChunks + summary.skippedKinds.length > 0;
    return Padding(
      padding: EdgeInsets.only(left: (section.level - 1) * 16.0),
      child: ListTile(
        dense: section.level > 1,
        title: Text(
          section.title,
          style: summary.isSkipped
              ? TextStyle(color: theme.colorScheme.outline)
              : section.level == 1
              ? theme.textTheme.titleMedium
              : null,
        ),
        subtitle: Text(detail),
        trailing: summary.isSkipped
            ? null
            : IconButton(
                tooltip: 'Generate for this section',
                icon: const Icon(Icons.auto_awesome_outlined),
                onPressed: () => showGenerateSheet(
                  context,
                  documentId: documentId,
                  sectionId: section.id,
                  sectionTitle: section.title,
                ),
              ),
        onTap: openable
            ? () => context.go('/library/doc/$documentId/section/${section.id}')
            : null,
      ),
    );
  }
}
