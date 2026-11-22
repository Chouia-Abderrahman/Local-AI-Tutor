import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// The options of a multiple-choice question, one per row.
///
/// Sits where the grade buttons sit afterwards, so answering (pick, judge,
/// move on) stays under the thumb. Rows are lettered because four
/// similar-looking answers are much easier to scan when each has a handle.
class ChoiceList extends StatelessWidget {
  const ChoiceList({
    super.key,
    required this.choices,
    required this.onPick,
    this.enabled = true,
  });

  final List<String> choices;

  /// Called with the index of the option that was tapped.
  final ValueChanged<int> onPick;

  final bool enabled;

  static const _letters = 'ABCDEFGH';

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < choices.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        _ChoiceRow(
          letter: i < _letters.length ? _letters[i] : '•',
          label: choices[i],
          enabled: enabled,
          onTap: () => onPick(i),
        ),
      ],
    ],
  );
}

class _ChoiceRow extends StatefulWidget {
  const _ChoiceRow({
    required this.letter,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_ChoiceRow> createState() => _ChoiceRowState();
}

class _ChoiceRowState extends State<_ChoiceRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = widget.enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _pressed
                  ? colors.accent.withValues(alpha: 0.12)
                  : colors.raised,
              borderRadius: BorderRadius.circular(Tokens.radius),
              border: Border.all(
                color: _pressed
                    ? colors.accent.withValues(alpha: 0.45)
                    : colors.hairline,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.letter,
                    style: context.text.labelSmall?.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    // An option that is cut off can't be chosen: you can't
                    // pick what you can't read.
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.scheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
