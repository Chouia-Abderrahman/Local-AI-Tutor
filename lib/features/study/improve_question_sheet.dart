import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/db/database.dart';
import '../../core/generate/improve.dart';
import '../../core/generate/json_model.dart';
import '../../core/llm/llm_engine.dart';
import '../../core/study/study_repository.dart';
import '../generate/generate_controllers.dart';
import '../model/model_use.dart';
import 'study_controllers.dart';

/// Rewrites the question on screen from its source text. Shows the new
/// version next to the old one; returns the stored question when the learner
/// keeps it, and null when they keep the original.
Future<Question?> showImproveQuestion(
  BuildContext context, {
  required StudyItem item,
}) => showModalBottomSheet<Question>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (_) => _ImproveSheet(item: item),
);

enum _Step { ask, working, review, failed }

/// What a learner can tap instead of typing.
const _problems = [
  'The wording is unclear',
  'The wrong answers are too obvious',
  'The marked answer is wrong',
  'It is too easy',
  'It is too hard',
];

String _kind(String type) => switch (type) {
  'mcq' => 'Multiple choice',
  'cloze' => 'Fill in the blank',
  _ => 'Flashcard',
};

class _ImproveSheet extends ConsumerStatefulWidget {
  const _ImproveSheet({required this.item});

  final StudyItem item;

  @override
  ConsumerState<_ImproveSheet> createState() => _ImproveSheetState();
}

class _ImproveSheetState extends ConsumerState<_ImproveSheet> {
  final _feedback = TextEditingController();
  _Step _step = _Step.ask;
  QuestionRewrite? _rewrite;
  String? _modelId;
  String? _error;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Question get _question => widget.item.question;

  Future<void> _improve() async {
    setState(() => _step = _Step.working);
    final note = _feedback.text.trim();
    try {
      final fact = widget.item.fact;
      final (rewrite, modelId) = await ref
          .read(modelUseProvider)
          .run(
            title: 'Improving a question',
            documentId: fact.documentId,
            body: (engine) async {
              final generation = ref.read(generationRepositoryProvider);
              final (passage, _) = await generation.passage(fact.chunkId);
              // The question may resemble itself; it must not copy another.
              final others = await generation.existingQuestionTexts(
                fact.documentId,
              );
              others.remove('${_question.prompt} ${_question.answer}');
              final rewrite = await QuestionImprover(EngineJsonModel(engine))
                  .improve(
                    question: _question,
                    fact: fact,
                    passage: passage,
                    feedback: note.isEmpty ? null : note,
                    otherQuestions: others,
                  );
              return (rewrite, engine.modelName ?? 'unknown');
            },
          );
      if (!mounted) return;
      setState(() {
        _rewrite = rewrite;
        _modelId = modelId;
        _step = _Step.review;
      });
    } on ImproveFailure catch (failure) {
      if (mounted) {
        setState(() {
          _error = failure.message;
          _step = _Step.failed;
        });
      }
    } on LlmException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _step = _Step.failed;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not improve it: $error';
          _step = _Step.failed;
        });
      }
    }
  }

  Future<void> _keep() async {
    final updated = await ref
        .read(studyRepositoryProvider)
        .replaceQuestion(_question.id, _rewrite!, modelId: _modelId!);
    if (mounted) Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Tokens.gutter,
          0,
          Tokens.gutter,
          12 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Improve this question', style: context.text.titleLarge),
              const SizedBox(height: 2),
              Text(
                '${_kind(_question.type)} · rewritten from the source text',
                style: context.text.bodySmall,
              ),
              ...switch (_step) {
                _Step.ask => _ask(context),
                _Step.working => _working(context),
                _Step.review => _review(context),
                _Step.failed => _failed(context),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _current(BuildContext context) => Panel(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_question.prompt, style: context.text.bodyMedium),
        const SizedBox(height: 6),
        Text(
          'Answer: ${_question.answer}',
          style: context.text.bodySmall?.copyWith(
            color: context.scheme.onSurface,
          ),
        ),
      ],
    ),
  );

  List<Widget> _ask(BuildContext context) => [
    const SectionLabel('Now'),
    _current(context),
    const SectionLabel('What is wrong with it? (optional)'),
    Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final problem in _problems)
          ActionChip(
            label: Text(problem),
            onPressed: () => setState(() => _feedback.text = problem),
          ),
      ],
    ),
    const SizedBox(height: 10),
    TextField(
      controller: _feedback,
      minLines: 1,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        hintText: 'For example: two of the options mean the same thing',
      ),
    ),
    const SizedBox(height: 16),
    FilledButton.icon(
      onPressed: _improve,
      icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
      label: const Text('Improve'),
    ),
  ];

  List<Widget> _working(BuildContext context) => [
    const SizedBox(height: 28),
    const Center(child: CircularProgressIndicator()),
    const SizedBox(height: 16),
    Text(
      'Rewriting it from the source text and checking the new version. '
      'This can take a minute on a phone.',
      textAlign: TextAlign.center,
      style: context.text.bodySmall,
    ),
    const SizedBox(height: 12),
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
  ];

  List<Widget> _review(BuildContext context) {
    final rewrite = _rewrite!;
    final colors = context.colors;
    return [
      const SectionLabel('New version'),
      Panel(
        padding: const EdgeInsets.all(12),
        borderColor: colors.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rewrite.prompt, style: context.text.bodyMedium),
            const SizedBox(height: 8),
            Text(
              '✓ ${rewrite.answer}',
              style: context.text.bodyMedium?.copyWith(color: colors.success),
            ),
            for (final wrong in rewrite.distractors)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text('✗ $wrong', style: context.text.bodySmall),
              ),
            if (rewrite.explanation != null) ...[
              const SizedBox(height: 8),
              Text(rewrite.explanation!, style: context.text.bodySmall),
            ],
          ],
        ),
      ),
      const SectionLabel('Was'),
      _current(context),
      const SizedBox(height: 16),
      FilledButton(onPressed: _keep, child: const Text('Use the new version')),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _Step.ask),
              child: const Text('Try again'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep the original'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _failed(BuildContext context) => [
    const SizedBox(height: 20),
    Text(
      _error ?? 'Could not improve it.',
      style: context.text.bodyMedium?.copyWith(color: context.colors.danger),
    ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: () => setState(() => _step = _Step.ask),
      child: const Text('Back'),
    ),
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Keep the original'),
    ),
  ];
}
