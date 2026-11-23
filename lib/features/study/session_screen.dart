import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/ui.dart';
import '../../core/generate/cloze.dart';
import '../../core/study/study_repository.dart';
import '../web/fact_check_sheet.dart';
import 'study_controllers.dart';
import 'widgets/card_face.dart';
import 'widgets/choice_list.dart';
import 'widgets/flip_card.dart';
import 'widgets/grade_buttons.dart';

/// A study session: one card at a time. Multiple-choice questions lead; the
/// card turns over on an answer and shows the source.
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
    final asking =
        state.phase == SessionPhase.asking ||
        state.phase == SessionPhase.answered;

    return Scaffold(
      body: SafeArea(
        child: switch (state.phase) {
          SessionPhase.loading => Column(
            children: [
              _CloseRow(onClose: () => context.go('/study')),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          SessionPhase.empty => Column(
            children: [
              _CloseRow(onClose: () => context.go('/study')),
              Expanded(
                child: EmptyState(
                  icon: Icons.check_rounded,
                  title: 'Nothing to study right now',
                  body: 'Reviews come back when they are due.',
                  action: OutlinedButton(
                    onPressed: () => context.go('/study'),
                    child: const Text('Back to Study'),
                  ),
                ),
              ),
            ],
          ),
          SessionPhase.finished => _Finished(state: state),
          _ when asking => Column(
            children: [
              _TopBar(
                state: state,
                onClose: () => context.go('/study'),
                onReport: (factIsWrong) =>
                    controller.report(factIsWrong: factIsWrong),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Tokens.gutter, 8, 20, 0),
                  child: _CardStage(state: state, onReveal: controller.reveal),
                ),
              ),
              _AnswerArea(state: state, typed: _typed),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _CloseRow extends StatelessWidget {
  const _CloseRow({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: IconButton(
        tooltip: 'End session',
        icon: const Icon(Icons.close_rounded),
        onPressed: onClose,
      ),
    ),
  );
}

/// Close, progress, the running tally and the report menu.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.onClose,
    required this.onReport,
  });

  final SessionState state;
  final VoidCallback onClose;
  final ValueChanged<bool> onReport;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = state.queue.length;
    final missed = state.reviewed - state.correct;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'End session',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClose,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Study', style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${state.index + 1} of $total',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Report a problem',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) => onReport(value == 'fact'),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ThinBar(value: state.index / total, height: 4),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pill(
                label: '${state.correct}',
                dense: true,
                icon: Icons.check_rounded,
                color: colors.success,
              ),
              const SizedBox(width: 8),
              Pill(
                label: '$missed',
                dense: true,
                icon: Icons.close_rounded,
                color: colors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _kind(String type) => switch (type) {
  'mcq' => 'Multiple choice',
  'cloze' => 'Fill in the blank',
  _ => 'Flashcard',
};

/// The card, with a deal-in animation whenever the question changes.
class _CardStage extends StatelessWidget {
  const _CardStage({required this.state, required this.onReveal});

  final SessionState state;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final item = state.current!;
    final type = item.question.type;
    final answered = state.phase == SessionPhase.answered;
    final prompt = type == 'cloze'
        ? item.question.prompt.replaceAll(clozeBlank, '______')
        : item.question.prompt;
    final footer = _CardFooter(item: item);

    final front = CardFace(
      eyebrow: _kind(type),
      headline: prompt,
      tag: item.headingPath,
      footer: footer,
    );
    final back = CardFace(
      isBack: true,
      eyebrow: 'Answer',
      headline: item.question.answer,
      tag: item.headingPath,
      echo: prompt,
      badge: _verdict(context),
      body: _AnswerBody(item: item),
      footer: footer,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 340),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) =>
          Stack(alignment: Alignment.center, children: [...previous, ?current]),
      child: KeyedSubtree(
        key: ValueKey('${state.index}:${item.question.id}'),
        child: FlipCard(
          isFlipped: answered,
          onFlip: onReveal,
          // Only a flashcard turns by hand, and only to its answer; the
          // other kinds turn when answered, so they can't be peeked at.
          gesturesEnabled: type == 'flashcard' && !answered,
          front: front,
          back: back,
        ),
      ),
    );
  }

  /// How the answer turned out, shown on the answer face.
  Widget? _verdict(BuildContext context) {
    final colors = context.colors;
    final type = state.current!.question.type;
    final bool correct;
    final String said;
    if (type == 'mcq') {
      final chosen = state.chosen;
      if (chosen == null) return null;
      correct = chosen == state.correctOption;
      said = state.options[chosen];
    } else if (state.typedCorrect != null) {
      correct = state.typedCorrect!;
      said = state.typed.trim();
    } else {
      return null;
    }
    // Quoting the answer only helps while it fits on the chip.
    final label = correct
        ? 'Correct'
        : said.isNotEmpty && said.length <= 28
        ? 'You said "$said"'
        : 'Not quite';
    return Pill(
      label: label,
      icon: correct ? Icons.check_rounded : Icons.close_rounded,
      color: correct ? colors.success : colors.danger,
    );
  }
}

/// Bottom strip of a card face: new or not, and where it comes from.
class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fresh = item.isNew || item.isNewQuestion;
    final label = [
      if (item.isNew)
        'New card'
      else if (item.isNewQuestion)
        'New question'
      else
        'Review',
      if (item.pageStart != null) 'page ${item.pageStart}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: fresh ? colors.accent : colors.faint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

/// On the answer face: the explanation, the source sentence, and why the
/// wrong options are wrong.
class _AnswerBody extends ConsumerWidget {
  const _AnswerBody({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final (why, whyWrong) = item.explanation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (why != null && why.isNotEmpty) ...[
          Text(
            why,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(
              color: context.scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          item.pageStart == null
              ? 'From the text'
              : 'From the text, page ${item.pageStart}',
          style: context.text.labelSmall,
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colors.accent, width: 2)),
          ),
          child: Text(
            '“${item.fact.quote}”',
            style: context.text.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        for (final (i, note) in whyWrong.indexed)
          if (i < item.distractors.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '✗ ${item.distractors[i]}: $note',
                style: context.text.bodySmall,
              ),
            ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: colors.muted,
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
      ],
    );
  }
}

/// The controls under the card: whatever the question needs right now.
class _AnswerArea extends ConsumerWidget {
  const _AnswerArea({required this.state, required this.typed});

  final SessionState state;
  final TextEditingController typed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider.notifier);
    final item = state.current!;
    final type = item.question.type;
    final answered = state.phase == SessionPhase.answered;
    final previews = state.previews;
    final next = previews[fsrs.Rating.again];

    void haptic(bool right) =>
        right ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();

    // Which controls, and a key so a change of controls animates.
    final (String stage, Widget child) = switch (type) {
      'mcq' when !answered => (
        'choose',
        ChoiceList(
          choices: state.options,
          onPick: (i) {
            haptic(i == state.correctOption);
            controller.choose(i);
          },
        ),
      ),
      'mcq' when state.chosen == state.correctOption => (
        'sure',
        GradeButtonBar(
          // They picked right: only how sure they were is left to say.
          grades: const [fsrs.Rating.good, fsrs.Rating.hard],
          previews: previews,
          onGrade: controller.rate,
        ),
      ),
      'mcq' => (
        'wrong',
        WrongAnswerBar(onContinue: controller.next, delay: next),
      ),
      'cloze' when !answered => (
        'type',
        _TypedAnswer(typed: typed, controller: controller),
      ),
      'cloze' when state.typedCorrect == true => (
        'right',
        RightAnswerBar(
          onContinue: controller.next,
          delay: previews[fsrs.Rating.good],
        ),
      ),
      'cloze' when state.typedCorrect == false => (
        'wrong',
        WrongAnswerBar(onContinue: controller.next, delay: next),
      ),
      _ when !answered => ('reveal', RevealHint(onReveal: controller.reveal)),
      _ => (
        'grade',
        GradeButtonBar(previews: previews, onGrade: controller.rate),
      ),
    };

    return ConstrainedBox(
      // Long options scroll instead of squeezing the card away.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.46,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Tokens.gutter,
          16,
          Tokens.gutter,
          16,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey('${state.index}:$stage'),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The answer box of a fill-in-the-blank card.
class _TypedAnswer extends StatelessWidget {
  const _TypedAnswer({required this.typed, required this.controller});

  final TextEditingController typed;
  final SessionController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: typed,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Missing word or phrase'),
        onChanged: controller.setTyped,
        onSubmitted: (_) => controller.checkTyped(),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: controller.checkTyped,
              child: const Text('Check'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: controller.reveal,
              child: const Text('Show answer'),
            ),
          ),
        ],
      ),
    ],
  );
}

class _Finished extends StatelessWidget {
  const _Finished({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percent = state.reviewed == 0
        ? 0
        : (state.correct * 100 / state.reviewed).round();
    final missed = state.reviewed - state.correct;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 38, color: colors.success),
            ),
            const SizedBox(height: 24),
            Text('Session done', style: context.text.displaySmall),
            const SizedBox(height: 8),
            Text(
              '${state.reviewed} answers · $percent% right',
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: 28),
            Panel(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: _Metric(
                      value: '${state.correct}',
                      caption: 'Right',
                      color: colors.success,
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      value: '$missed',
                      caption: 'To revisit',
                      color: colors.danger,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/study'),
                child: const Text('Back to Study'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.caption,
    required this.color,
  });

  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: context.text.displaySmall?.copyWith(color: color)),
      const SizedBox(height: 4),
      Text(caption.toUpperCase(), style: context.text.labelSmall),
    ],
  );
}
