import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/web/fact_checker.dart';
import '../generate/generate_controllers.dart';
import 'web_controllers.dart';

/// Checks a fact against the web and shows what was found. Asks first when
/// the document hasn't allowed web lookups yet.
Future<void> showFactCheck(
  BuildContext context,
  WidgetRef ref, {
  required Fact fact,
  int? questionId,
}) async {
  if (!await ensureWebAllowed(context, ref, fact.documentId)) return;
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FactCheckSheet(fact: fact, questionId: questionId),
  );
}

class _FactCheckSheet extends ConsumerStatefulWidget {
  const _FactCheckSheet({required this.fact, this.questionId});

  final Fact fact;
  final int? questionId;

  @override
  ConsumerState<_FactCheckSheet> createState() => _FactCheckSheetState();
}

class _FactCheckSheetState extends ConsumerState<_FactCheckSheet> {
  FactCheckResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      // Generation steps aside while the student waits for this.
      final runner = ref.read(generationRunnerProvider);
      final yielded = runner.state.working && !runner.state.paused;
      if (yielded) {
        runner.pause();
        ref.read(llmEngineProvider).cancel();
        await runner.idle();
      }
      try {
        final checker = await buildFactChecker(ref);
        if (checker == null) {
          setState(() => _error = 'Load an AI model first.');
          return;
        }
        final db = ref.read(databaseProvider);
        final doc = await (db.select(
          db.documents,
        )..where((d) => d.id.equals(widget.fact.documentId))).getSingle();
        final result = await checker.check(
          claim: widget.fact.statement,
          language: doc.language,
          factId: widget.fact.id,
          questionId: widget.questionId,
        );
        if (mounted) setState(() => _result = result);
      } finally {
        if (yielded) runner.resume();
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = 'Could not check: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text('Check on the web', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('“${widget.fact.statement}”'),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: TextStyle(color: theme.colorScheme.error))
            else if (result == null)
              const Row(
                children: [
                  SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Searching and reading pages…')),
                ],
              )
            else ...[
              Row(
                children: [
                  Icon(
                    switch (result.verdict) {
                      Verdict.corroborated => Icons.verified_outlined,
                      Verdict.conflict => Icons.warning_amber,
                      Verdict.notFound => Icons.help_outline,
                    },
                    color: result.verdict == Verdict.conflict
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.verdict.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Searched for "${result.query}" · read '
                '${result.sources.length} pages.',
                style: theme.textTheme.bodySmall,
              ),
              if (result.verdict == Verdict.conflict) ...[
                const SizedBox(height: 12),
                Text('Your document says:', style: theme.textTheme.labelLarge),
                Text(
                  '“${widget.fact.quote}”',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
              for (final e in result.evidence) ...[
                const SizedBox(height: 12),
                Text(
                  e.supports ? 'Agrees:' : 'Disagrees:',
                  style: theme.textTheme.labelLarge,
                ),
                Text(
                  '“${e.quote}”',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: e.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')),
                    );
                  },
                  child: Text(
                    '${e.title} · ${e.url}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
              if (result.verdict == Verdict.conflict) ...[
                const SizedBox(height: 16),
                Text(
                  'Your course may define this differently, and the web can '
                  'be wrong. You decide.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Keep it'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        await (db.update(
                          db.facts,
                        )..where((f) => f.id.equals(widget.fact.id))).write(
                          const FactsCompanion(status: Value('disputed')),
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Mark the fact as wrong'),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
