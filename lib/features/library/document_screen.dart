import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/library_repository.dart';
import '../../core/generate/generation_repository.dart';
import '../chat/chat_controllers.dart';
import '../generate/generate_controllers.dart';
import '../generate/generate_sheet.dart';
import '../generate/progress_card.dart';
import '../mastery/mastery_view.dart';
import '../model/model_controllers.dart';
import '../model/model_picker.dart';
import '../study/study_controllers.dart';
import 'library_controllers.dart';

/// A document's outline: its sections, which are studied and which skipped,
/// and how many questions each has; and its mastery map.
class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key, required this.documentId});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outline = ref.watch(documentOutlineProvider(documentId));
    final doc = outline.value?.document;
    final language =
        doc == null || doc.language == null || doc.language == 'und'
        ? ''
        : ' · ${doc.language!.toUpperCase()}';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc?.title ?? 'Document',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (outline case AsyncData(:final value))
                Text(
                  '${plural(value.document.pageCount, 'page')} · '
                  '${plural(value.sections.length, 'section')}$language',
                  style: context.text.bodySmall,
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Chat about this document',
              icon: const Icon(Icons.chat_bubble_outline, size: 21),
              onPressed: () {
                ref.read(chatDocumentProvider.notifier).select(documentId);
                context.go('/chat/conversation');
              },
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert, size: 21),
              onSelected: (value) => switch (value) {
                'model' => pickDocumentModel(context, ref, documentId),
                _ => _confirmDelete(context, ref),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'model', child: Text('AI model…')),
                PopupMenuItem(value: 'delete', child: Text('Delete document')),
              ],
            ),
            const SizedBox(width: 4),
          ],
          bottom: const TabBar(
            isScrollable: true,
            padding: EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              Tab(text: 'Outline', height: 40),
              Tab(text: 'Mastery', height: 40),
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
          'Its questions, conversations and your study progress for it are '
          'deleted too.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.scheme.error,
              foregroundColor: context.scheme.onError,
            ),
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
    final doc = outline.document;
    final counts =
        ref.watch(sectionCountsProvider(doc.id)).value ??
        const <int, SectionCounts>{};
    final questions = counts.values.fold(0, (n, c) => n + c.questions);
    final skipped = outline.sections.where((s) => s.isSkipped).length;
    final overview = ref.watch(studyOverviewProvider(doc.id)).value;
    final model = ref.watch(documentModelProvider(doc.id));
    final waiting = overview == null ? 0 : overview.due + overview.newAvailable;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 12, Tokens.gutter, 32),
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatRow(
                stats: [
                  Stat(value: '${outline.studyChunks}', label: 'Passages'),
                  Stat(value: '$questions', label: 'Questions'),
                  Stat(
                    value: '${overview?.due ?? 0}',
                    label: 'Due',
                    highlight: (overview?.due ?? 0) > 0,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              InkWell(
                onTap: () => pickDocumentModel(context, ref, doc.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.memory,
                        size: 18,
                        color: context.colors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text('Model', style: context.text.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          model.name +
                              (model.origin == ModelOrigin.appDefault &&
                                      model.path != null
                                  ? '  (default)'
                                  : ''),
                          style: context.text.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Change',
                        style: context.text.labelMedium?.copyWith(
                          color: context.scheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: outline.studyChunks == 0
                          ? null
                          : () =>
                                showGenerateSheet(context, documentId: doc.id),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        questions == 0 ? 'Generate' : 'Generate more',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: waiting == 0
                          ? null
                          : () => context.go('/study/session?doc=${doc.id}'),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: Text(waiting == 0 ? 'Study' : 'Study $waiting'),
                    ),
                  ),
                ],
              ),
              if (skipped > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '${plural(skipped, 'section')} skipped: contents, index, '
                  'references and the like.',
                  style: context.text.bodySmall,
                ),
              ],
            ],
          ),
        ),
        GenerationProgressCard(documentId: doc.id),
        SectionLabel(
          'Outline',
          trailing: Text(
            '${outline.sections.length}',
            style: context.text.labelSmall,
          ),
        ),
        PanelList(
          children: [
            for (final summary in outline.sections)
              _SectionRow(
                documentId: doc.id,
                summary: summary,
                counts: counts[summary.section.id],
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.documentId,
    required this.summary,
    required this.counts,
  });

  final int documentId;
  final SectionSummary summary;
  final SectionCounts? counts;

  @override
  Widget build(BuildContext context) {
    final section = summary.section;
    final pages = section.pageStart == section.pageEnd
        ? 'p. ${section.pageStart}'
        : 'pp. ${section.pageStart}–${section.pageEnd}';
    final questions = counts?.questions ?? 0;
    final detail = summary.isSkipped
        ? '$pages · ${summary.skippedKinds.map((k) => k.label).join(', ')}'
        : summary.studyChunks == 0
        ? pages
        : '$pages · ${plural(summary.studyChunks, 'passage')}'
              '${questions == 0 ? '' : ' · ${plural(questions, 'question')}'}';
    final openable = summary.studyChunks + summary.skippedKinds.length > 0;
    final depth = (section.level - 1).clamp(0, 4);
    return InkWell(
      onTap: openable
          ? () => context.go('/library/doc/$documentId/section/${section.id}')
          : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.0 + depth * 14, 9, 4, 9),
        child: Row(
          children: [
            if (depth > 0) ...[
              Container(width: 2, height: 30, color: context.colors.hairline),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          section.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              (depth == 0
                                      ? context.text.titleSmall
                                      : context.text.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ))
                                  ?.copyWith(
                                    color: summary.isSkipped
                                        ? context.colors.muted
                                        : null,
                                  ),
                        ),
                      ),
                      if (summary.isSkipped) ...[
                        const SizedBox(width: 6),
                        const Tag('Skipped'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: context.text.bodySmall),
                ],
              ),
            ),
            if (!summary.isSkipped && summary.studyChunks > 0)
              IconButton(
                tooltip: 'Generate for this section',
                icon: Icon(
                  Icons.auto_awesome_outlined,
                  size: 19,
                  color: context.colors.muted,
                ),
                onPressed: () => showGenerateSheet(
                  context,
                  documentId: documentId,
                  sectionId: section.id,
                  sectionTitle: section.title,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
