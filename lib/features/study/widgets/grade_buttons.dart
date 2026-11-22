import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' as fsrs;

import '../../../app/theme.dart';
import '../../../app/ui.dart';

/// The three answers to "how well did you know it?", as FSRS ratings: the
/// middle one carries "I knew it, but it was shaky", where most real recall
/// sits.
extension RecallRating on fsrs.Rating {
  String get recallLabel => switch (this) {
    fsrs.Rating.again => "I don't remember",
    fsrs.Rating.hard => 'Not clearly',
    _ => 'I remember',
  };

  IconData get recallIcon => switch (this) {
    fsrs.Rating.again => Icons.refresh_rounded,
    fsrs.Rating.hard => Icons.waves_rounded,
    _ => Icons.check_rounded,
  };

  Color recallColor(AppColors colors) => switch (this) {
    fsrs.Rating.again => colors.danger,
    fsrs.Rating.hard => colors.warning,
    _ => colors.success,
  };
}

/// The recall answers, stacked full width so the real wording fits.
class GradeButtonBar extends StatelessWidget {
  const GradeButtonBar({
    super.key,
    required this.onGrade,
    this.previews = const {},
    this.grades = const [fsrs.Rating.good, fsrs.Rating.hard, fsrs.Rating.again],
  });

  final ValueChanged<fsrs.Rating> onGrade;

  /// When the card would come back after each answer.
  final Map<fsrs.Rating, Duration> previews;

  /// Which answers to offer, the most positive first: closest to the thumb.
  /// A correctly picked option leaves out "I don't remember".
  final List<fsrs.Rating> grades;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < grades.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        GradeButton(
          rating: grades[i],
          delay: previews[grades[i]],
          onTap: () => onGrade(grades[i]),
        ),
      ],
    ],
  );
}

/// What replaces the options after a wrong answer. There is nothing to grade:
/// a wrong answer is "I don't remember", so the only control is the one that
/// moves on, and it says what was recorded.
class WrongAnswerBar extends StatelessWidget {
  const WrongAnswerBar({
    super.key,
    required this.onContinue,
    this.delay,
    this.recorded = true,
  });

  final VoidCallback onContinue;
  final Duration? delay;

  /// The answer counted as "I don't remember".
  final bool recorded;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.danger;
    return Column(
      children: [
        if (recorded) ...[
          Text(
            'Counted as "${fsrs.Rating.again.recallLabel}"',
            style: context.text.labelMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 10),
        ],
        GradeButton(
          rating: fsrs.Rating.again,
          icon: Icons.arrow_forward_rounded,
          label: 'Next card',
          delay: delay,
          onTap: onContinue,
        ),
      ],
    );
  }
}

/// A right answer already counted: only the way on is left.
class RightAnswerBar extends StatelessWidget {
  const RightAnswerBar({super.key, required this.onContinue, this.delay});

  final VoidCallback onContinue;
  final Duration? delay;

  @override
  Widget build(BuildContext context) => GradeButton(
    rating: fsrs.Rating.good,
    icon: Icons.arrow_forward_rounded,
    label: 'Next card',
    delay: delay,
    onTap: onContinue,
  );
}

class GradeButton extends StatefulWidget {
  const GradeButton({
    super.key,
    required this.rating,
    required this.onTap,
    this.icon,
    this.label,
    this.delay,
  });

  final fsrs.Rating rating;
  final VoidCallback onTap;
  final IconData? icon;

  /// Replaces the rating's own wording.
  final String? label;
  final Duration? delay;

  @override
  State<GradeButton> createState() => _GradeButtonState();
}

class _GradeButtonState extends State<GradeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.rating.recallColor(context.colors);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: _pressed ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(Tokens.radius),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon ?? widget.rating.recallIcon,
                  size: 17,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label ?? widget.rating.recallLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(color: color),
                ),
              ),
              if (widget.delay != null) ...[
                const SizedBox(width: 8),
                Text(
                  formatDelay(widget.delay!),
                  maxLines: 1,
                  style: context.text.labelMedium?.copyWith(
                    color: color.withValues(alpha: 0.75),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The prompt that sits where the answer buttons will appear before a flip,
/// with a gentle drift hinting at the swipe.
class RevealHint extends StatefulWidget {
  const RevealHint({super.key, required this.onReveal});

  final VoidCallback onReveal;

  @override
  State<RevealHint> createState() => _RevealHintState();
}

class _RevealHintState extends State<RevealHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: widget.onReveal,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.sunken,
          borderRadius: BorderRadius.circular(Tokens.radius),
          border: Border.all(color: colors.hairline),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(-4 - t * 3, 0),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: colors.faint.withValues(alpha: 0.5 + t * 0.4),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Swipe or tap the card to reveal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelMedium,
                  ),
                ),
                const SizedBox(width: 6),
                Transform.translate(
                  offset: Offset(4 + t * 3, 0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.faint.withValues(alpha: 0.5 + t * 0.4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
