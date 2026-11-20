import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.phase == SessionPhase.asking ||
                  state.phase == SessionPhase.answered
              ? '${state.index + 1} of $total'
              : 'Study',
        ),
        actions: [
          if (state.current != null)
            PopupMenuButton<String>(
              tooltip: 'Report a problem',
              icon: const Icon(Icons.flag_outlined),
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
        ],
        bottom: total == 0
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (state.index / total).clamp(0, 1),
                ),
              ),
      ),
      body: SafeArea(
        child: switch (state.phase) {
          SessionPhase.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          SessionPhase.empty => const _Message(
            icon: Icons.check_circle_outline,
            text: 'Nothing to study right now.',
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
    final theme = Theme.of(context);
    final answered = state.phase == SessionPhase.answered;
    final type = item.question.type;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          [
            if (item.headingPath != null) item.headingPath!,
            if (item.isNew) 'New',
          ].join(' · '),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          type == 'cloze'
              ? item.question.prompt.replaceAll(clozeBlank, '______')
              : item.question.prompt,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        if (type == 'mcq') ...[
          for (final (i, option) in state.options.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionButton(
                text: option,
                isCorrect: answered && i == state.correctOption,
                isWrongChoice:
                    answered && i == state.chosen && i != state.correctOption,
                onPressed: answered ? null : () => controller.choose(i),
              ),
            ),
          if (!answered)
            CheckboxListTile(
              value: state.unsure,
              onChanged: (_) => controller.toggleUnsure(),
              title: const Text("I'm not sure"),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
        ] else if (type == 'cloze' && !answered) ...[
          TextField(
            controller: typed,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Missing word or phrase',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 16),
          _Feedback(item: item),
          const SizedBox(height: 16),
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

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.isCorrect,
    required this.isWrongChoice,
    required this.onPressed,
  });

  final String text;
  final bool isCorrect;
  final bool isWrongChoice;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isCorrect
        ? scheme.primary
        : isWrongChoice
        ? scheme.error
        : null;
    return OutlinedButton(
      onPressed: onPressed ?? () {},
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
        side: color == null ? null : BorderSide(color: color, width: 2),
        foregroundColor: color,
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (isCorrect) Icon(Icons.check, color: color),
          if (isWrongChoice) Icon(Icons.close, color: color),
        ],
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
    final theme = Theme.of(context);
    final verdict = switch (state.typedCorrect) {
      true => 'Correct: ',
      false => 'Answer: ',
      null => '',
    };
    return Text(
      '$verdict${item.question.answer}',
      style: theme.textTheme.titleMedium?.copyWith(
        color: state.typedCorrect == false
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
    );
  }
}

class _Feedback extends ConsumerWidget {
  const _Feedback({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (why, whyWrong) = item.explanation;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.pageStart == null
                  ? 'From the text'
                  : 'From the text, page ${item.pageStart}',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '“${item.fact.quote}”',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            if (why != null && why.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(why),
            ],
            for (final (i, note) in whyWrong.indexed)
              if (i < item.distractors.length)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '✗ ${item.distractors[i]}: $note',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.travel_explore, size: 18),
                label: const Text('Check on the web'),
                onPressed: () => showFactCheck(
                  context,
                  ref,
                  fact: item.fact,
                  questionId: item.question.id,
                ),
              ),
            ),
          ],
        ),
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
        const Text('How well did you know it?'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (rating, label) in [
              (fsrs.Rating.again, 'Again'),
              (fsrs.Rating.hard, 'Hard'),
              (fsrs.Rating.good, 'Good'),
              (fsrs.Rating.easy, 'Easy'),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: rating == fsrs.Rating.good
                      ? FilledButton(
                          onPressed: () => onRate(rating),
                          child: Text(label),
                        )
                      : OutlinedButton(
                          onPressed: () => onRate(rating),
                          child: Text(label),
                        ),
                ),
              ),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Session done',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${state.reviewed} answers · $percent% right'),
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

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 16),
        Text(text),
      ],
    ),
  );
}
