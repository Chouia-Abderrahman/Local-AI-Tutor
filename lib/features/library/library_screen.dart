import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../model/model_setup_banner.dart';
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
                  ? '${next.fileName} was already imported.'
                  : 'Imported ${next.fileName}: ${result.sections} sections.'
                        '${scanned > 0 ? ' $scanned pages had no text (scanned?).' : ''}',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: importState.busy
            ? null
            : () => ref.read(importControllerProvider.notifier).pickAndImport(),
        icon: const Icon(Icons.add),
        label: const Text('Import'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const ModelSetupBanner(),
          if (importState.busy) _ImportProgressCard(state: importState),
          switch (documents) {
            AsyncData(:final value) when value.isEmpty => const _EmptyLibrary(),
            AsyncData(:final value) => Column(
              children: [for (final doc in value) _DocumentTile(doc)],
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

class _ImportProgressCard extends StatelessWidget {
  const _ImportProgressCard({required this.state});

  final ImportState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importing ${state.fileName}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: state.fraction),
            const SizedBox(height: 4),
            Text(state.stage ?? ''),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile(this.doc);

  final StudyDocument doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = switch (doc.status) {
      'ready' =>
        '${doc.pageCount} ${doc.pageCount == 1 ? 'page' : 'pages'}'
            '${doc.language == null || doc.language == 'und' ? '' : ' · ${doc.language!.toUpperCase()}'}',
      'failed' => 'Import failed: ${doc.errorMessage ?? 'unknown error'}',
      _ => 'Importing…',
    };
    return Card(
      child: ListTile(
        leading: Icon(
          doc.status == 'failed'
              ? Icons.error_outline
              : Icons.description_outlined,
          color: doc.status == 'failed' ? theme.colorScheme.error : null,
        ),
        title: Text(doc.title),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/library/doc/${doc.id}'),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No documents yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Import a PDF, a text file or Markdown notes.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
