import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A card that flips around its vertical axis.
///
/// The flip is *finger-tracked*: a horizontal drag rotates the card in real
/// time and, on release, either completes the turn or springs back depending
/// on how far and how fast it was thrown.
///
/// The card turns the way the finger goes: the edge nearest you follows the
/// finger, so a swipe to the right turns it as if you pushed it to the right,
/// whichever face is showing. (An earlier version fixed the spin by the first
/// movement of the drag, so a swipe turned the card one way from its front and
/// the other way from its back.)
///
/// [isFlipped] is owned by the parent, so the study screen stays the source
/// of truth for whether the answer is showing; the widget animates towards it.
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

  /// Called when a gesture asks for the opposite side. The parent is expected
  /// to toggle [isFlipped].
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
  /// The card's turn in half-turns: 0 is the front, 1 the back, 2 the front
  /// again. It is not wrapped, so a drag one way and a drag the other way
  /// turn the card visibly different ways instead of snapping through zero.
  late final AnimationController _turn = AnimationController.unbounded(
    vsync: this,
    value: widget.isFlipped ? 1 : 0,
  );

  /// The whole number of half-turns the card is heading for or resting at.
  late double _target;

  double _dragStart = 0;
  double _dragOffset = 0;
  bool _isDragging = false;

  /// Fraction of the card's width that amounts to a full half-turn. Less than
  /// one so the flip completes comfortably inside a thumb's reach.
  static const double _dragTravel = 0.55;

  static int _side(double halfTurns) => halfTurns.round() % 2;

  int get _wantedSide => widget.isFlipped ? 1 : 0;

  @override
  void initState() {
    super.initState();
    // Not a field initializer: a `late` one would be read for the first time
    // after the parent has already changed `isFlipped`.
    _target = widget.isFlipped ? 1 : 0;
    _turn.addStatusListener((status) {
      // The parent may not have toggled after asking to (it can refuse):
      // end up on the side it says.
      if (status == AnimationStatus.completed && !_isDragging) _reconcile();
    });
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) _reconcile();
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  /// Turns the card to the side the parent asks for, if it is not already
  /// heading there. It goes back towards the front-and-back range rather than
  /// piling on more turns.
  void _reconcile() {
    if (_side(_target) == _wantedSide) return;
    final base = _turn.value.round();
    final target = _side(base.toDouble()) == _wantedSide
        ? base
        : (base > 0 ? base - 1 : base + 1);
    _animateTo(target.toDouble());
  }

  void _animateTo(double target) {
    _target = target;
    _turn.animateTo(
      target,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
    );
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStart = _turn.value;
    _dragOffset = 0;
    _turn.stop();
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (width <= 0) return;
    _dragOffset += details.primaryDelta ?? 0;
    // Dragging right turns the card so its near edge goes right, which is a
    // decreasing angle (the near edge of a positive turn moves left). At most
    // one half-turn either way from where the drag began.
    final travelled = -_dragOffset / (width * _dragTravel);
    _turn.value = (_dragStart + travelled).clamp(
      _dragStart - 1,
      _dragStart + 1,
    );
  }

  void _onDragEnd(DragEndDetails details, double width) {
    _isDragging = false;

    final value = _turn.value;
    // Where the card rested before the drag.
    final from = _target;
    // The finger's speed as half-turns per second; right is negative.
    final spin = width <= 0
        ? 0.0
        : -details.velocity.pixelsPerSecond.dx / (width * _dragTravel);
    final moved = value - from;

    // Distance decides, but a quick flick in the direction it was already
    // going counts even if the card barely moved.
    final flicked =
        spin.abs() > 700 / (width <= 0 ? 1 : width * _dragTravel) &&
        (moved == 0 || moved.sign == spin.sign);
    final target = flicked ? from + spin.sign : value.roundToDouble();

    if (_side(target) != _wantedSide) widget.onFlip();
    _animateTo(target);
  }

  void _onTap() {
    if (!widget.tapToFlip || !widget.gesturesEnabled) return;
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final enabled = widget.gesturesEnabled;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          onHorizontalDragStart: enabled ? _onDragStart : null,
          onHorizontalDragUpdate: enabled
              ? (details) => _onDragUpdate(details, width)
              : null,
          onHorizontalDragEnd: enabled
              ? (details) => _onDragEnd(details, width)
              : null,
          child: AnimatedBuilder(
            animation: _turn,
            builder: (context, child) {
              final halfTurns = _turn.value;
              final angle = halfTurns * math.pi;
              final wrapped = halfTurns % 2;
              final showingBack = wrapped > 0.5 && wrapped < 1.5;

              // Pull the card back slightly as it turns, so the edge doesn't
              // appear to clip through the screen at 90°.
              final scale = 1 - 0.05 * math.sin(angle).abs();

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
