import 'package:flutter/material.dart';

import 'theme.dart';

/// Building blocks shared by the screens: bordered panels, section labels,
/// stats, thin bars, tags, empty states and the brand mark.

/// The Local AI Tutor mark: an open book (two pages) with a spark above the
/// spine. Drawn on a 24-unit grid, the same geometry as the launcher icon.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 28, this.badge = false});

  final double size;

  /// On a dark square, like the app icon.
  final bool badge;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pages = badge ? const Color(0xFFF1EFEA) : context.scheme.onSurface;
    return CustomPaint(
      size: Size.square(size),
      painter: MarkPainter(
        pages: pages,
        spark: context.colors.accent,
        background: badge
            ? (dark ? const Color(0xFF262B32) : const Color(0xFF15171C))
            : null,
      ),
    );
  }
}

class MarkPainter extends CustomPainter {
  const MarkPainter({
    required this.pages,
    required this.spark,
    this.background,
  });

  final Color pages;
  final Color spark;
  final Color? background;

  /// The mark's paths on the 24-unit grid.
  static Path leftPage() => Path()
    ..moveTo(2, 9.2)
    ..lineTo(11, 11.4)
    ..lineTo(11, 21)
    ..lineTo(2, 18.8)
    ..close();

  static Path rightPage() => Path()
    ..moveTo(13, 11.4)
    ..lineTo(22, 9.2)
    ..lineTo(22, 18.8)
    ..lineTo(13, 21)
    ..close();

  static Path sparkPath() {
    const cx = 12.0, cy = 4.6, r = 3.6;
    return Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var scale = size.width / 24;
    if (background != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.width * 0.16),
        ),
        Paint()..color = background!,
      );
      // The mark sits inside the badge with a margin.
      canvas.translate(size.width * 0.18, size.height * 0.17);
      scale = size.width * 0.64 / 24;
    }
    canvas.scale(scale);
    final fill = Paint()
      ..isAntiAlias = true
      ..color = pages;
    canvas.drawPath(leftPage(), fill);
    canvas.drawPath(rightPage(), fill);
    canvas.drawPath(sparkPath(), Paint()..color = spark);
  }

  @override
  bool shouldRepaint(MarkPainter old) =>
      old.pages != pages || old.spark != spark || old.background != background;
}

/// The mark and the app's name, for headers and the about screen.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppMark(size: size, badge: true),
      const SizedBox(width: 10),
      Text(
        'Local AI Tutor',
        style: context.text.titleLarge?.copyWith(letterSpacing: -0.3),
      ),
    ],
  );
}

/// A white (dark: raised) surface with a hairline border.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(20);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: context.colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: color ?? context.scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor ?? context.colors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// Rows in one bordered panel, separated by hairlines.
class PanelList extends StatelessWidget {
  const PanelList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Panel(
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const Divider(),
          child,
        ],
      ],
    ),
  );
}

/// A small uppercase label above a group, with an optional action.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(2, 20, 2, 8),
  });

  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(
          child: Text(text.toUpperCase(), style: context.text.labelSmall),
        ),
        ?trailing,
      ],
    ),
  );
}

/// A number with a label, for stat rows.
class Stat extends StatelessWidget {
  const Stat({
    super.key,
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final String value;
  final String label;

  /// Draws the number in the accent color (for what needs attention).
  final bool highlight;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: context.text.headlineSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          color: highlight ? context.scheme.secondary : null,
        ),
      ),
      const SizedBox(height: 2),
      Text(label.toUpperCase(), style: context.text.labelSmall),
    ],
  );
}

/// Stats side by side, split by hairlines.
class StatRow extends StatelessWidget {
  const StatRow({super.key, required this.stats});

  final List<Stat> stats;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        for (final (i, stat) in stats.indexed) ...[
          if (i > 0) ...[
            VerticalDivider(width: 1, color: context.colors.hairline),
            const SizedBox(width: 12),
          ],
          Expanded(child: stat),
        ],
      ],
    ),
  );
}

/// A thin progress bar with rounded ends that eases to each new value.
class ThinBar extends StatelessWidget {
  const ThinBar({
    super.key,
    required this.value,
    this.height = 3,
    this.color,
    this.track,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? track;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: track ?? context.colors.sunken),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, eased, _) => FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: eased,
              child: ColoredBox(color: color ?? context.colors.accent),
            ),
          ),
        ],
      ),
    ),
  );
}

enum TagTone { neutral, accent, success, danger, solid }

/// A small label: "Recommended", "Default", "Skipped".
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.tone = TagTone.neutral, this.icon});

  final String text;
  final TagTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;
    final (Color background, Color foreground) = switch (tone) {
      TagTone.neutral => (colors.sunken, colors.muted),
      TagTone.accent => (colors.accentSoft, colors.accent),
      TagTone.success => (
        colors.success.withValues(alpha: 0.12),
        colors.success,
      ),
      TagTone.danger => (colors.danger.withValues(alpha: 0.12), colors.danger),
      TagTone.solid => (scheme.primary, scheme.onPrimary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: context.text.labelMedium?.copyWith(
              color: foreground,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A centered message for empty screens, with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.mark = false,
    required this.title,
    this.body,
    this.action,
  });

  final IconData? icon;

  /// Shows the brand mark instead of an icon.
  final bool mark;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mark)
            const AppMark(size: 48, badge: true)
          else if (icon != null)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colors.accent),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: context.text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

/// A compact control naming a model; tapping it changes the model.
class ModelChip extends StatelessWidget {
  const ModelChip({
    super.key,
    required this.name,
    this.note,
    this.onTap,
    this.loading = false,
  });

  final String name;

  /// "default", "this document", …
  final String? note;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    color: context.scheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: BorderSide(color: context.colors.hairline),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox.square(
                dimension: 12,
                child: CircularProgressIndicator(strokeWidth: 1.6),
              )
            else
              Icon(Icons.memory, size: 14, color: context.colors.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium,
              ),
            ),
            if (note != null) ...[
              const SizedBox(width: 4),
              Text(
                note!,
                style: context.text.labelMedium?.copyWith(
                  color: context.colors.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            if (onTap != null)
              Icon(Icons.unfold_more, size: 14, color: context.colors.muted),
          ],
        ),
      ),
    ),
  );
}

/// A compact row inside a [PanelList]: leading icon, title, subtitle and a
/// trailing widget.
class PanelRow extends StatelessWidget {
  const PanelRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle.merge(
                  style: context.text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: context.text.bodySmall,
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

/// A glyph for a file type: PDF, TXT, MD.
class FileGlyph extends StatelessWidget {
  const FileGlyph({super.key, required this.label, this.failed = false});

  final String label;
  final bool failed;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 40,
    alignment: Alignment.bottomCenter,
    padding: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
      color: failed ? context.scheme.errorContainer : context.colors.accentSoft,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: context.text.labelSmall?.copyWith(
        color: failed ? context.scheme.onErrorContainer : null,
        letterSpacing: 0.4,
      ),
    ),
  );
}

/// A sheet's title row, for bottom sheets.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: context.text.bodySmall),
        ],
      ],
    ),
  );
}

String plural(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : (many ?? '${one}s')}';

/// An on/off switch, to match the rest of the UI.
class SharpSwitch extends StatelessWidget {
  const SharpSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 44,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? scheme.primary : context.colors.sunken,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: value ? scheme.primary : context.colors.hairline,
            ),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value
                  ? scheme.onPrimary
                  : (enabled ? scheme.onSurfaceVariant : scheme.outline),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded badge with an optional icon: a verdict, a count.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color,
    this.background,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.colors.muted;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background ?? foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (dense ? context.text.labelSmall : context.text.labelMedium)
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "in 10 min", "in 4 days": how long until a card comes back.
String formatDelay(Duration delay) {
  final minutes = delay.inMinutes;
  if (minutes < 1) return 'in <1 min';
  if (minutes < 60) return 'in $minutes min';
  final hours = delay.inHours;
  if (hours < 24) return 'in ${plural(hours, 'hour')}';
  final days = delay.inDays;
  if (days < 30) return 'in ${plural(days, 'day')}';
  if (days < 365) return 'in ${plural((days / 30).round(), 'month')}';
  return 'in ${plural((days / 365).round(), 'year')}';
}

/// "5 min ago", "3 days ago", or a date for older things.
String timeAgo(DateTime at) {
  final d = DateTime.now().difference(at.toLocal());
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes} min ago';
  if (d.inDays < 1) return '${d.inHours} h ago';
  if (d.inDays < 7) return '${plural(d.inDays, 'day')} ago';
  final local = at.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
