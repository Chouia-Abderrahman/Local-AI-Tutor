import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/database.dart';
import '../model/model_setup_banner.dart';
import '../study/study_controllers.dart';
import 'library_controllers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(importControllerProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      final result = next.result;
      if (result != null) {
        final scanned = result.nearlyEmptyPages.length;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.alreadyImported
                  ? '${next.fileName} is already in your library.'
                  : 'Imported ${next.fileName}: '
                        '${plural(result.sections, 'section')}.'
                        '${scanned > 0 ? ' ${plural(scanned, 'page')} had no text.' : ''}',
            ),
          ),
        );
        ref.read(importControllerProvider.notifier).acknowledge();
        context.go('/library/doc/${result.documentId}');
      } else if (next.error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Import failed: ${next.error}')),
        );
        ref.read(importControllerProvider.notifier).acknowledge();
      }
    });

    final importState = ref.watch(importControllerProvider);
    final documents = ref.watch(documentsProvider);
    void import() =>
        ref.read(importControllerProvider.notifier).pickAndImport();

    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(),
        actions: const [ModelStatusButton(), SizedBox(width: 8)],
      ),
      floatingActionButton: switch (documents) {
        AsyncData(:final value) when value.isNotEmpty =>
          FloatingActionButton.extended(
            onPressed: importState.busy ? null : import,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Import'),
          ),
        _ => null,
      },
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Tokens.gutter, 4, Tokens.gutter, 96),
        children: [
          const ModelSetupBanner(),
          if (importState.busy) _ImportProgress(state: importState),
          switch (documents) {
            AsyncData(:final value) when value.isEmpty => EmptyState(
              mark: true,
              title: 'Your study shelf is empty',
              body:
                  'Import a PDF, a text file or Markdown notes. Questions, '
                  'flashcards and answers are written on this phone; nothing '
                  'is uploaded.',
              action: FilledButton.icon(
                onPressed: importState.busy ? null : import,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Import a document'),
              ),
            ),
            AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Today(),
                SectionLabel(
                  'Documents',
                  trailing: Text(
                    '${value.length}',
                    style: context.text.labelSmall,
                  ),
                ),
                PanelList(
                  children: [for (final doc in value) _DocumentRow(doc)],
                ),
              ],
            ),
            AsyncError(:final error) => Text(
              'Could not load documents: $error',
            ),
            _ => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ],
      ),
    );
  }
}

/// What to study today, across all documents.
class _Today extends ConsumerWidget {
  const _Today();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(studyOverviewProvider(null)).value;
    if (overview == null) return const SizedBox.shrink();
    final waiting = overview.due + overview.newAvailable;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatRow(
              stats: [
                Stat(
                  value: '${overview.due}',
                  label: 'Due',
                  highlight: overview.due > 0,
                ),
                Stat(value: '${overview.newAvailable}', label: 'New'),
                Stat(value: '${overview.reviewedToday}', label: 'Done today'),
              ],
            ),
            if (waiting > 0) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/study/session'),
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text('Study ${plural(waiting, 'card')}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImportProgress extends StatelessWidget {
  const _ImportProgress({required this.state});

  final ImportState state;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox.square(
                dimension: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Importing ${state.fileName}',
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ThinBar(value: state.fraction ?? 0),
          const SizedBox(height: 6),
          Text(state.stage ?? '', style: context.text.bodySmall),
        ],
      ),
    ),
  );
}

class _DocumentRow extends ConsumerWidget {
  const _DocumentRow(this.doc);

  final StudyDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = doc.status == 'ready'
        ? ref.watch(studyOverviewProvider(doc.id)).value
        : null;
    final extension = doc.sourcePath == null
        ? 'PDF'
        : p.extension(doc.sourcePath!).replaceFirst('.', '').toUpperCase();
    final failed = doc.status == 'failed';
    final language = doc.language == null || doc.language == 'und'
        ? ''
        : ' · ${doc.language!.toUpperCase()}';
    final subtitle = switch (doc.status) {
      'ready' => '${plural(doc.pageCount, 'page')}$language',
      'failed' => 'Import failed: ${doc.errorMessage ?? 'unknown error'}',
      _ => 'Importing…',
    };
    final due = overview?.due ?? 0;
    return PanelRow(
      leading: FileGlyph(
        label: extension.isEmpty ? 'DOC' : extension,
        failed: failed,
      ),
      title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (due > 0) Tag('$due due', tone: TagTone.accent),
          Icon(Icons.chevron_right, size: 20, color: context.colors.muted),
        ],
      ),
      onTap: () => context.go('/library/doc/${doc.id}'),
    );
  }
}
