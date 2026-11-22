import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A card that flips around its vertical axis.
///
/// The flip is *finger-tracked*: a horizontal drag rotates the card in real time
/// and, on release, either completes the turn or springs back depending on how
/// far and how fast it was thrown. That direct manipulation is what makes the
/// gesture feel physical rather than like a button that plays an animation.
///
/// [isFlipped] is owned by the parent so the study screen stays the source of
/// truth for whether the answer is showing; the widget animates towards it.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.onFlip,
    this.tapToFlip = true,
    this.gesturesEnabled = true,
    this.duration = const Duration(milliseconds: 520),
  });

  final Widget front;
  final Widget back;

  /// True when the answer side should be showing.
  final bool isFlipped;

  /// Called when a gesture asks for the opposite side. The parent is expected to
  /// toggle [isFlipped].
  final VoidCallback onFlip;

  final bool tapToFlip;

  /// False locks the card: neither a tap nor a drag turns it. Multiple-choice
  /// cards use this so the answer can't be peeked at before picking.
  final bool gesturesEnabled;

  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.isFlipped ? 1 : 0,
  );

  /// Which way round the card is turning: +1 for a rightward drag, -1 leftward.
  /// Only affects the visual direction of the spin, not which face wins.
  double _sign = 1;

  /// Controller value when the current drag began.
  double _dragStartValue = 0;

  /// Horizontal distance travelled so far in the current drag.
  double _dragOffset = 0;

  bool _isDragging = false;

  /// Fraction of the card's width that amounts to a full half-turn. Less than
  /// one so the flip completes comfortably inside a thumb's reach.
  static const double _dragTravel = 0.55;

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped && !_isDragging) {
      _animateTo(widget.isFlipped ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _controller.animateTo(
      target,
      duration: widget.duration,
      // Gentle overshoot on the way in, plain ease on the way back — a spring
      // that settles rather than bounces.
      curve: Curves.easeOutCubic,
    );
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartValue = _controller.value;
    _dragOffset = 0;
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (width <= 0) return;

    final delta = details.primaryDelta ?? 0;

    // The first meaningful movement picks which way the card appears to spin.
    if (_dragOffset == 0 && delta != 0) {
      _sign = delta < 0 ? -1 : 1;
    }

    _dragOffset += delta;

    // Progress is measured along the direction the drag committed to, so
    // pulling back part-way through unwinds the flip instead of fighting it.
    // Either direction reveals: the card always turns towards its other face.
    final travelled = (_dragOffset * _sign) / (width * _dragTravel);
    final towards = widget.isFlipped ? -1 : 1;

    _controller.value = (_dragStartValue + travelled * towards).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;

    final value = _controller.value;
    final wasFlipped = widget.isFlipped;

    // Distance decides, but a quick flick counts even if the card barely moved.
    final velocity = details.velocity.pixelsPerSecond.dx * _sign;
    final flickedForward = velocity * (wasFlipped ? -1 : 1) > 700;
    final crossedHalfway = wasFlipped ? value < 0.5 : value > 0.5;

    if (crossedHalfway || flickedForward) {
      widget.onFlip();
      _animateTo(wasFlipped ? 0 : 1);
    } else {
      _animateTo(wasFlipped ? 1 : 0);
    }
  }

  void _onTap() {
    if (!widget.tapToFlip || !widget.gesturesEnabled) return;
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final width = constraints.maxWidth;

        final enabled = widget.gesturesEnabled;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          onHorizontalDragStart: enabled ? _onDragStart : null,
          onHorizontalDragUpdate: enabled
              ? (DragUpdateDetails d) => _onDragUpdate(d, width)
              : null,
          onHorizontalDragEnd: enabled ? _onDragEnd : null,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              final value = _controller.value;
              final angle = value * math.pi * _sign;
              final showingBack = value > 0.5;

              // Pull the card back slightly as it turns, so the edge doesn't
              // appear to clip through the screen at 90°.
              final scale = 1 - 0.05 * math.sin(value * math.pi);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0011)
                  ..scaleByDouble(scale, scale, scale, 1)
                  ..rotateY(angle),
                child: showingBack
                    // Counter-rotate so the answer isn't mirrored.
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: widget.back,
                      )
                    : widget.front,
              );
            },
          ),
        );
      },
    );
  }
}
