import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/ingest/content_kind.dart';
import 'library_controllers.dart';

final _sectionProvider = FutureProvider.family<(Section, List<Chunk>), int>((
  ref,
  sectionId,
) async {
  final repository = ref.watch(libraryRepositoryProvider);
  return (
    await repository.section(sectionId),
    await repository.chunksOfSection(sectionId),
  );
});

/// The extracted text of one section, passage by passage.
class SectionScreen extends ConsumerWidget {
  const SectionScreen({super.key, required this.sectionId});

  final int sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_sectionProvider(sectionId));
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (data) {
          AsyncData(:final value) => value.$1.title,
          _ => 'Section',
        }),
      ),
      body: switch (data) {
        AsyncData(value: (_, final chunks)) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chunks.length,
          separatorBuilder: (_, _) => const Divider(height: 32),
          itemBuilder: (context, index) {
            final chunk = chunks[index];
            final kind = ContentKind.values.byName(chunk.kind);
            final pages = chunk.pageStart == chunk.pageEnd
                ? 'p. ${chunk.pageStart}'
                : 'pp. ${chunk.pageStart}–${chunk.pageEnd}';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind.isStudy ? pages : '$pages · Skipped: ${kind.label}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  chunk.body,
                  style: kind.isStudy
                      ? null
                      : TextStyle(color: theme.colorScheme.outline),
                ),
              ],
            );
          },
        ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
