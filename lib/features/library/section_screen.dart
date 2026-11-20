import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/generate/generation_repository.dart';
import '../../core/ingest/content_kind.dart';
import '../generate/generate_controllers.dart';
import '../web/fact_check_sheet.dart';
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

/// One section: its text, and the facts and questions generated from it.
class SectionScreen extends ConsumerWidget {
  const SectionScreen({super.key, required this.sectionId});

  final int sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_sectionProvider(sectionId));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (data) {
            AsyncData(:final value) => value.$1.title,
            _ => 'Section',
          }),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Text'),
              Tab(text: 'Questions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            switch (data) {
              AsyncData(value: (_, final chunks)) => _TextTab(chunks: chunks),
              AsyncError(:final error) => Center(child: Text('$error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
            _QuestionsTab(sectionId: sectionId),
          ],
        ),
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({required this.chunks});

  final List<Chunk> chunks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
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
    );
  }
}

class _QuestionsTab extends ConsumerWidget {
  const _QuestionsTab({required this.sectionId});

  final int sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(sectionFactsProvider(sectionId));
    return switch (facts) {
      AsyncData(:final value) when value.isEmpty => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No questions yet. Use "Generate questions" on the document page.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      AsyncData(:final value) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: value.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _FactCard(item: value[index]),
      ),
      AsyncError(:final error) => Center(child: Text('$error')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _FactCard extends ConsumerWidget {
  const _FactCard({required this.item});

  final FactWithQuestions item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.fact.statement, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              '“${item.fact.quote}”',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            for (final question in item.questions) ...[
              const Divider(height: 24),
              _QuestionView(question: question),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('Check on the web'),
                onPressed: () => showFactCheck(context, ref, fact: item.fact),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (question.type) {
      'cloze' => 'Fill in the blank',
      'flashcard' => 'Flashcard',
      _ => 'Multiple choice · ${question.depth} · ${question.quality}',
    };
    final distractors = question.distractorsJson == null
        ? const <String>[]
        : [for (final d in jsonDecode(question.distractorsJson!) as List) '$d'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(question.prompt),
        const SizedBox(height: 4),
        Text('✓ ${question.answer}'),
        for (final d in distractors) Text('✗ $d'),
      ],
    );
  }
}
