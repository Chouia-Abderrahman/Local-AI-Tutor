import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../app/ui.dart';

/// One side of a study card.
///
/// The same widget renders both faces; the back tints its gradient towards the
/// accent so the two sides are easy to tell apart, even mid-flip.
class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.eyebrow,
    required this.headline,
    this.isBack = false,
    this.tag,
    this.badge,
    this.echo,
    this.body,
    this.footer,
  });

  /// Small label at the top-left: the kind of question, or "Answer".
  final String eyebrow;

  /// The question or answer; the reason the card exists.
  final String headline;

  final bool isBack;

  /// Top-right pill: where in the document this comes from.
  final String? tag;

  /// Verdict chip under the header: how the answer turned out.
  final Widget? badge;

  /// The question, repeated small on the back.
  final String? echo;

  /// Supporting content under the headline: explanation, the source quote.
  final Widget? body;

  /// Bottom strip of the card.
  final Widget? footer;

  /// Picks a display size that keeps long content readable without clipping:
  /// a short phrase gets the full display treatment, a sentence steps down.
  static double headlineSize(String text) {
    final length = text.trim().length;
    if (length <= 10) return 40;
    if (length <= 24) return 32;
    if (length <= 48) return 26;
    if (length <= 90) return 22;
    if (length <= 160) return 19;
    return 17;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headlineStyle = TextStyle(
      fontFamily: Tokens.displayFamily,
      fontSize: headlineSize(headline),
      height: 1.22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      color: context.scheme.onSurface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBack
              ? [colors.cardBackTop, colors.cardBackBottom]
              : [colors.cardFrontTop, colors.cardFrontBottom],
        ),
        borderRadius: BorderRadius.circular(Tokens.radiusLarge),
        border: Border.all(
          color: isBack
              ? colors.accent.withValues(alpha: dark ? 0.28 : 0.20)
              : colors.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: dark ? 0.45 : 0.07),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eyebrow.toUpperCase(),
                    style: context.text.labelSmall?.copyWith(
                      color: isBack
                          ? colors.accent.withValues(alpha: 0.85)
                          : colors.faint,
                    ),
                  ),
                ),
                if (tag != null)
                  Flexible(
                    child: Pill(
                      label: tag!,
                      dense: true,
                      color: colors.muted,
                      background: colors.sunken,
                    ),
                  ),
              ],
            ),
            if (badge != null) ...[
              const SizedBox(height: 12),
              Align(child: badge),
            ],
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (echo != null && echo!.trim().isNotEmpty) ...[
                        Text(
                          echo!,
                          textAlign: TextAlign.center,
                          style: context.text.bodyMedium?.copyWith(
                            color: colors.faint,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: headlineStyle,
                      ),
                      if (body != null) ...[
                        const SizedBox(height: 18),
                        Center(
                          child: Container(
                            width: 34,
                            height: 1,
                            color: colors.hairline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        body!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}
