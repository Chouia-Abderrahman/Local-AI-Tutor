import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
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
          title: Text(
            switch (data) {
              AsyncData(:final value) => value.$1.title,
              _ => 'Section',
            },
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: const TabBar(
            isScrollable: true,
            padding: EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              Tab(text: 'Text', height: 40),
              Tab(text: 'Questions', height: 40),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 16, Tokens.gutter, 32),
      itemCount: chunks.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(),
      ),
      itemBuilder: (context, index) {
        final chunk = chunks[index];
        final kind = ContentKind.values.byName(chunk.kind);
        final pages = chunk.pageStart == chunk.pageEnd
            ? 'Page ${chunk.pageStart}'
            : 'Pages ${chunk.pageStart}–${chunk.pageEnd}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pages.toUpperCase(), style: context.text.labelSmall),
                if (!kind.isStudy) ...[
                  const SizedBox(width: 8),
                  Tag('Skipped: ${kind.label}'),
                ],
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              chunk.body,
              style: context.text.bodyLarge?.copyWith(
                height: 1.6,
                color: kind.isStudy ? null : context.colors.muted,
              ),
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
      AsyncData(:final value) when value.isEmpty => const EmptyState(
        icon: Icons.quiz_outlined,
        title: 'No questions yet',
        body:
            'Use Generate on the document page, or the spark next to this '
            'section.',
      ),
      AsyncData(:final value) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          Tokens.gutter,
          16,
          Tokens.gutter,
          32,
        ),
        itemCount: value.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.fact.statement, style: context.text.titleSmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: context.colors.accent, width: 2),
                    ),
                  ),
                  child: Text(
                    '“${item.fact.quote}”',
                    style: context.text.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final question in item.questions) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: _QuestionView(question: question),
            ),
          ],
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.muted,
                ),
                icon: const Icon(Icons.travel_explore, size: 17),
                label: const Text('Check on the web'),
                onPressed: () => showFactCheck(context, ref, fact: item.fact),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final label = switch (question.type) {
      'cloze' => 'Fill in the blank',
      'flashcard' => 'Flashcard',
      _ => 'Multiple choice',
    };
    final distractors = question.distractorsJson == null
        ? const <String>[]
        : [for (final d in jsonDecode(question.distractorsJson!) as List) '$d'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            Tag(label, tone: TagTone.accent),
            if (question.type == 'mcq') ...[
              Tag(question.depth),
              Tag(question.quality),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(question.prompt, style: context.text.bodyMedium),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check, size: 16, color: context.colors.success),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                question.answer,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        for (final d in distractors)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.close, size: 16, color: context.colors.muted),
                const SizedBox(width: 6),
                Expanded(child: Text(d, style: context.text.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}
