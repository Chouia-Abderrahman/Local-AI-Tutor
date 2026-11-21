import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/database.dart';
import '../../core/web/fact_checker.dart';
import '../model/model_use.dart';
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
    useRootNavigator: true,
    isScrollControlled: true,
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
      final result = await ref
          .read(modelUseProvider)
          .run(
            title: 'Checking a fact on the web',
            documentId: widget.fact.documentId,
            body: (engine) async {
              final checker = await buildFactChecker(ref, engine);
              final db = ref.read(databaseProvider);
              final doc = await (db.select(
                db.documents,
              )..where((d) => d.id.equals(widget.fact.documentId))).getSingle();
              return checker.check(
                claim: widget.fact.statement,
                language: doc.language,
                factId: widget.fact.id,
                questionId: widget.questionId,
              );
            },
          );
      if (mounted) setState(() => _result = result);
    } on Object catch (error) {
      if (mounted) setState(() => _error = 'Could not check: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            Tokens.gutter,
            0,
            Tokens.gutter,
            16,
          ),
          children: [
            Text('Check on the web', style: context.text.titleLarge),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: context.colors.accent, width: 2),
                ),
              ),
              child: Text(
                '“${widget.fact.statement}”',
                style: context.text.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.danger,
                ),
              )
            else if (result == null)
              Row(
                children: [
                  const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Searching and reading pages… This keeps going if you '
                      'leave the app.',
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Tag(
                    result.verdict.label,
                    tone: switch (result.verdict) {
                      Verdict.corroborated => TagTone.success,
                      Verdict.conflict => TagTone.danger,
                      Verdict.notFound => TagTone.neutral,
                    },
                    icon: switch (result.verdict) {
                      Verdict.corroborated => Icons.verified_outlined,
                      Verdict.conflict => Icons.warning_amber,
                      Verdict.notFound => Icons.help_outline,
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Searched "${result.query}" · read '
                      '${plural(result.sources.length, 'page')}',
                      style: context.text.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (result.verdict == Verdict.conflict) ...[
                const SectionLabel(
                  'Your document says',
                  padding: EdgeInsets.fromLTRB(2, 16, 2, 6),
                ),
                Text(
                  '“${widget.fact.quote}”',
                  style: context.text.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              for (final e in result.evidence) ...[
                const SizedBox(height: 12),
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tag(
                        e.supports ? 'Agrees' : 'Disagrees',
                        tone: e.supports ? TagTone.success : TagTone.danger,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '“${e.quote}”',
                        style: context.text.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: e.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied.')),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: context.colors.accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${e.title} · ${e.url}',
                                style: context.text.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (result.verdict == Verdict.conflict) ...[
                const SizedBox(height: 16),
                Text(
                  'Your course may define this differently, and the web can '
                  'be wrong. You decide.',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Keep it'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await (db.update(
                            db.facts,
                          )..where((f) => f.id.equals(widget.fact.id))).write(
                            const FactsCompanion(status: Value('disputed')),
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Mark as wrong'),
                      ),
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
