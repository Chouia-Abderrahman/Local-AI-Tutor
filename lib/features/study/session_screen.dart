import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/generate/cloze.dart';
import '../../core/study/study_repository.dart';
import '../web/fact_check_sheet.dart';
import 'study_controllers.dart';

/// A study session: one question at a time, with feedback from the source.
class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, this.documentId, this.sectionId});

  final int? documentId;

  /// Limits the session to one topic and its subtopics.
  final int? sectionId;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _typed = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(sessionControllerProvider.notifier)
          .start(documentId: widget.documentId, sectionId: widget.sectionId),
    );
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final controller = ref.read(sessionControllerProvider.notifier);
    ref.listen(sessionControllerProvider.select((s) => s.index), (_, _) {
      _typed.clear();
    });
    final total = state.queue.length;
    final asking =
        state.phase == SessionPhase.asking ||
        state.phase == SessionPhase.answered;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'End session',
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/study'),
        ),
        titleSpacing: 0,
        title: Text(asking ? '${state.index + 1} of $total' : 'Study'),
        actions: [
          if (state.current != null)
            PopupMenuButton<String>(
              tooltip: 'Report a problem',
              icon: const Icon(Icons.flag_outlined, size: 21),
              onSelected: (value) =>
                  controller.report(factIsWrong: value == 'fact'),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'question',
                  child: Text('This question is bad'),
                ),
                PopupMenuItem(
                  value: 'fact',
                  child: Text('The fact itself is wrong'),
                ),
              ],
            ),
          const SizedBox(width: 4),
        ],
        bottom: total == 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: ThinBar(value: state.index / total, height: 2),
              ),
      ),
      body: SafeArea(
        child: switch (state.phase) {
          SessionPhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          SessionPhase.empty => EmptyState(
            icon: Icons.check,
            title: 'Nothing to study right now',
            body: 'Reviews come back when they are due.',
            action: OutlinedButton(
              onPressed: () => context.go('/study'),
              child: const Text('Back to Study'),
            ),
          ),
          SessionPhase.finished => _Finished(state: state),
          _ => _QuestionView(state: state, typed: _typed),
        },
      ),
    );
  }
}

class _QuestionView extends ConsumerWidget {
  const _QuestionView({required this.state, required this.typed});

  final SessionState state;
  final TextEditingController typed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = state.current!;
    final controller = ref.read(sessionControllerProvider.notifier);
    final answered = state.phase == SessionPhase.answered;
    final type = item.question.type;
    final kind = switch (type) {
      'mcq' => 'Multiple choice',
      'cloze' => 'Fill in the blank',
      _ => 'Flashcard',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 16, Tokens.gutter, 24),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(kind.toUpperCase(), style: context.text.labelSmall),
            if (item.isNew) const Tag('New', tone: TagTone.accent),
            if (item.headingPath != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                ),
                child: Text(
                  '· ${item.headingPath!}',
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          type == 'cloze'
              ? item.question.prompt.replaceAll(clozeBlank, '______')
              : item.question.prompt,
          style: context.text.titleLarge?.copyWith(fontSize: 20, height: 1.35),
        ),
        const SizedBox(height: 20),
        if (type == 'mcq') ...[
          for (final (i, option) in state.options.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Option(
                letter: String.fromCharCode(65 + i),
                text: option,
                isCorrect: answered && i == state.correctOption,
                isWrongChoice:
                    answered && i == state.chosen && i != state.correctOption,
                dimmed:
                    answered && i != state.correctOption && i != state.chosen,
                onPressed: answered ? null : () => controller.choose(i),
              ),
            ),
          if (!answered)
            InkWell(
              borderRadius: BorderRadius.circular(Tokens.radius),
              onTap: controller.toggleUnsure,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: state.unsure,
                      onChanged: (_) => controller.toggleUnsure(),
                    ),
                    Text("I'm not sure", style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
        ] else if (type == 'cloze' && !answered) ...[
          TextField(
            controller: typed,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Missing word or phrase',
            ),
            onChanged: controller.setTyped,
            onSubmitted: (_) => controller.checkTyped(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed: controller.checkTyped,
                child: const Text('Check'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: controller.reveal,
                child: const Text('Show answer'),
              ),
            ],
          ),
        ] else if (!answered)
          FilledButton(
            onPressed: controller.reveal,
            child: const Text('Show answer'),
          ),
        if (answered) ...[
          if (type != 'mcq') _AnswerLine(item: item, state: state),
          const SizedBox(height: 14),
          _Feedback(item: item),
          const SizedBox(height: 18),
          if (!state.rated)
            _RatingButtons(onRate: controller.rate)
          else
            FilledButton(
              onPressed: controller.next,
              child: const Text('Continue'),
            ),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.text,
    required this.isCorrect,
    required this.isWrongChoice,
    required this.dimmed,
    required this.onPressed,
  });

  final String letter;
  final String text;
  final bool isCorrect;
  final bool isWrongChoice;
  final bool dimmed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.scheme;
    final accent = isCorrect
        ? colors.success
        : isWrongChoice
        ? colors.danger
        : null;
    final background = accent == null
        ? scheme.surfaceContainerLowest
        : Color.alphaBlend(
            accent.withValues(alpha: 0.10),
            scheme.surfaceContainerLowest,
          );
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radius),
        side: BorderSide(
          color: accent ?? scheme.outline,
          width: accent == null ? 1 : 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 11, 12, 11),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent ?? scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(Tokens.radiusSmall),
                ),
                child: Text(
                  letter,
                  style: context.text.labelMedium?.copyWith(
                    color: accent == null ? colors.muted : scheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: context.text.bodyLarge?.copyWith(
                    color: dimmed ? colors.muted : null,
                  ),
                ),
              ),
              if (isCorrect) Icon(Icons.check, size: 20, color: accent),
              if (isWrongChoice) Icon(Icons.close, size: 20, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({required this.item, required this.state});

  final StudyItem item;
  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final verdict = switch (state.typedCorrect) {
      true => 'Correct: ',
      false => 'Answer: ',
      null => '',
    };
    return Text(
      '$verdict${item.question.answer}',
      style: context.text.titleMedium?.copyWith(
        color: state.typedCorrect == false
            ? context.colors.danger
            : context.colors.success,
      ),
    );
  }
}

class _Feedback extends ConsumerWidget {
  const _Feedback({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (why, whyWrong) = item.explanation;
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text(
              item.pageStart == null
                  ? 'From the text'
                  : 'From the text, page ${item.pageStart}',
              style: context.text.labelSmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: context.colors.accent, width: 2),
              ),
            ),
            child: Text(
              '“${item.fact.quote}”',
              style: context.text.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (why != null && why.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(why, style: context.text.bodyMedium),
            ),
          for (final (i, note) in whyWrong.indexed)
            if (i < item.distractors.length)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                child: Text(
                  '✗ ${item.distractors[i]}: $note',
                  style: context.text.bodySmall,
                ),
              ),
          const SizedBox(height: 6),
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
                onPressed: () => showFactCheck(
                  context,
                  ref,
                  fact: item.fact,
                  questionId: item.question.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({required this.onRate});

  final void Function(fsrs.Rating rating) onRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('HOW WELL DID YOU KNOW IT?', style: context.text.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (i, (rating, label)) in [
              (fsrs.Rating.again, 'Again'),
              (fsrs.Rating.hard, 'Hard'),
              (fsrs.Rating.good, 'Good'),
              (fsrs.Rating.easy, 'Easy'),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: rating == fsrs.Rating.good
                    ? FilledButton(
                        onPressed: () => onRate(rating),
                        child: Text(label),
                      )
                    : OutlinedButton(
                        style: rating == fsrs.Rating.again
                            ? OutlinedButton.styleFrom(
                                foregroundColor: context.colors.danger,
                              )
                            : null,
                        onPressed: () => onRate(rating),
                        child: Text(label),
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final percent = state.reviewed == 0
        ? 0
        : (state.correct * 100 / state.reviewed).round();
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppMark(size: 44, badge: true),
            const SizedBox(height: 16),
            Text('Session done', style: context.text.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '${state.reviewed} answers · $percent% right',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.muted,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ThinBar(
                value: percent / 100,
                height: 4,
                color: percent >= 80
                    ? context.colors.success
                    : context.colors.accent,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/study'),
              child: const Text('Back to Study'),
            ),
          ],
        ),
      ),
    );
  }
}
