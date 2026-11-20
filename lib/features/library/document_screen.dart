import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/library_repository.dart';
import 'library_controllers.dart';

/// A document's outline: its sections, which are studied and which skipped.
class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outline = ref.watch(documentOutlineProvider(documentId));
    return Scaffold(
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
      ),
      body: switch (outline) {
        AsyncData(:final value) => _OutlineView(outline: value),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
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

class _OutlineView extends StatelessWidget {
  const _OutlineView({required this.outline});

  final DocumentOutline outline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = outline.document;
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final summary in outline.sections)
          _SectionTile(documentId: doc.id, summary: summary),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.documentId, required this.summary});

  final int documentId;
  final SectionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = summary.section;
    final pages = section.pageStart == section.pageEnd
        ? 'p. ${section.pageStart}'
        : 'pp. ${section.pageStart}–${section.pageEnd}';
    final detail = summary.isSkipped
        ? 'Skipped: ${summary.skippedKinds.map((k) => k.label).join(', ')}'
        : summary.studyChunks == 0
        ? pages
        : '$pages · ${summary.studyChunks} '
              '${summary.studyChunks == 1 ? 'passage' : 'passages'}';
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
        onTap: summary.studyChunks + summary.skippedKinds.length == 0
            ? null
            : () =>
                  context.go('/library/doc/$documentId/section/${section.id}'),
      ),
    );
  }
}
