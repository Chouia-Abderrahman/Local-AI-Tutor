import 'package:flutter/material.dart';

/// Local AI Tutor's look: ink and paper neutrals, one amber accent, compact
/// spacing and nearly square corners.
abstract final class Tokens {
  /// Cards, buttons, inputs, chips.
  static const radius = 4.0;

  /// Tags, badges, bars.
  static const radiusSmall = 2.0;

  /// Top corners of sheets, and dialogs.
  static const radiusLarge = 6.0;

  /// Side padding of pages.
  static const gutter = 16.0;

  static const fontFamily = 'SourceSans3';
}

/// Colors outside the Material color scheme, for both brightnesses.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.masteryLow,
    required this.masteryMid,
    required this.masteryHigh,
    required this.hairline,
    required this.muted,
  });

  /// The amber of the brand mark: progress, highlights, the AI spark.
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color danger;
  final Color masteryLow;
  final Color masteryMid;
  final Color masteryHigh;

  /// 1 px borders and dividers.
  final Color hairline;

  /// Secondary text.
  final Color muted;

  static const light = AppColors(
    accent: Color(0xFFE39A2D),
    onAccent: Color(0xFF1A1206),
    success: Color(0xFF1E7A4F),
    warning: Color(0xFFA15C07),
    danger: Color(0xFFB42318),
    masteryLow: Color(0xFFC4502A),
    masteryMid: Color(0xFFD99A26),
    masteryHigh: Color(0xFF2E8B5B),
    hairline: Color(0xFFE3E0D9),
    muted: Color(0xFF5E626B),
  );

  static const dark = AppColors(
    accent: Color(0xFFF0AE4C),
    onAccent: Color(0xFF1A1206),
    success: Color(0xFF5BC98F),
    warning: Color(0xFFF0AE4C),
    danger: Color(0xFFF3877C),
    masteryLow: Color(0xFFD9653D),
    masteryMid: Color(0xFFE0A63A),
    masteryHigh: Color(0xFF45B07A),
    hairline: Color(0xFF272C33),
    muted: Color(0xFFA2A6AD),
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? danger,
    Color? masteryLow,
    Color? masteryMid,
    Color? masteryHigh,
    Color? hairline,
    Color? muted,
  }) => AppColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    masteryLow: masteryLow ?? this.masteryLow,
    masteryMid: masteryMid ?? this.masteryMid,
    masteryHigh: masteryHigh ?? this.masteryHigh,
    hairline: hairline ?? this.hairline,
    muted: muted ?? this.muted,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      masteryLow: mix(masteryLow, other.masteryLow),
      masteryMid: mix(masteryMid, other.masteryMid),
      masteryHigh: mix(masteryHigh, other.masteryHigh),
      hairline: mix(hairline, other.hairline),
      muted: mix(muted, other.muted),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors {
    final theme = Theme.of(this);
    return theme.extension<AppColors>() ??
        (theme.brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
  }

  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

abstract final class AppTheme {
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF15171C),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE8E6E0),
    onPrimaryContainer: Color(0xFF15171C),
    secondary: Color(0xFFA15C07),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFBEBD0),
    onSecondaryContainer: Color(0xFF4A2A03),
    tertiary: Color(0xFF1E7A4F),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFDDF0E5),
    onTertiaryContainer: Color(0xFF0B3B24),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFDE7E5),
    onErrorContainer: Color(0xFF5C0F0A),
    surface: Color(0xFFF6F5F2),
    onSurface: Color(0xFF15171C),
    onSurfaceVariant: Color(0xFF5E626B),
    surfaceDim: Color(0xFFDDDBD5),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFBFAF8),
    surfaceContainer: Color(0xFFF1EFEB),
    surfaceContainerHigh: Color(0xFFEBE9E4),
    surfaceContainerHighest: Color(0xFFE3E1DB),
    outline: Color(0xFFC9C6BE),
    outlineVariant: Color(0xFFE3E0D9),
    inverseSurface: Color(0xFF23262C),
    onInverseSurface: Color(0xFFF1EFEA),
    inversePrimary: Color(0xFFF1EFEA),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF1EFEA),
    onPrimary: Color(0xFF101215),
    primaryContainer: Color(0xFF2B3038),
    onPrimaryContainer: Color(0xFFF1EFEA),
    secondary: Color(0xFFF0AE4C),
    onSecondary: Color(0xFF231502),
    secondaryContainer: Color(0xFF3D2A0C),
    onSecondaryContainer: Color(0xFFFFDDAA),
    tertiary: Color(0xFF5BC98F),
    onTertiary: Color(0xFF062615),
    tertiaryContainer: Color(0xFF143A26),
    onTertiaryContainer: Color(0xFFBFEFD3),
    error: Color(0xFFF3877C),
    onError: Color(0xFF3B0904),
    errorContainer: Color(0xFF52140F),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0F1114),
    onSurface: Color(0xFFEDEBE6),
    onSurfaceVariant: Color(0xFFA2A6AD),
    surfaceDim: Color(0xFF0B0D10),
    surfaceBright: Color(0xFF2A2F36),
    surfaceContainerLowest: Color(0xFF16191E),
    surfaceContainerLow: Color(0xFF191C21),
    surfaceContainer: Color(0xFF1B1F24),
    surfaceContainerHigh: Color(0xFF22262C),
    surfaceContainerHighest: Color(0xFF2A2F36),
    outline: Color(0xFF3D434C),
    outlineVariant: Color(0xFF272C33),
    inverseSurface: Color(0xFFEDEBE6),
    onInverseSurface: Color(0xFF15171C),
    inversePrimary: Color(0xFF15171C),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  static ThemeData light() => _build(_lightScheme, AppColors.light);
  static ThemeData dark() => _build(_darkScheme, AppColors.dark);

  static TextTheme _textTheme(ColorScheme scheme, AppColors colors) {
    final ink = scheme.onSurface;
    TextStyle style(
      double size,
      double height, {
      FontWeight weight = FontWeight.w400,
      double spacing = 0,
      Color? color,
    }) => TextStyle(
      fontFamily: Tokens.fontFamily,
      fontSize: size,
      height: height,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color ?? ink,
    );
    return TextTheme(
      displaySmall: style(34, 1.1, weight: FontWeight.w600, spacing: -0.8),
      headlineMedium: style(26, 1.15, weight: FontWeight.w600, spacing: -0.5),
      headlineSmall: style(22, 1.2, weight: FontWeight.w600, spacing: -0.3),
      titleLarge: style(19, 1.25, weight: FontWeight.w600, spacing: -0.2),
      titleMedium: style(16, 1.3, weight: FontWeight.w600, spacing: -0.1),
      titleSmall: style(14.5, 1.3, weight: FontWeight.w600),
      bodyLarge: style(16, 1.45),
      bodyMedium: style(14.5, 1.4),
      bodySmall: style(13, 1.35, color: colors.muted),
      labelLarge: style(14.5, 1.2, weight: FontWeight.w600, spacing: 0.1),
      labelMedium: style(12.5, 1.2, weight: FontWeight.w600, spacing: 0.2),
      // Overlines: section labels, small caps-like tags.
      labelSmall: style(
        11,
        1.2,
        weight: FontWeight.w700,
        spacing: 0.9,
        color: colors.muted,
      ),
    );
  }

  static ThemeData _build(ColorScheme scheme, AppColors colors) {
    final text = _textTheme(scheme, colors);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Tokens.radius)),
    );
    final hairline = BorderSide(color: colors.hairline);
    const compact = VisualDensity(horizontal: -1, vertical: -2);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 14);
    const buttonSize = Size(0, 40);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: Tokens.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      visualDensity: compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 52,
        titleSpacing: Tokens.gutter,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Tokens.radius)),
          side: hairline,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
          visualDensity: compact,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: buttonSize,
          padding: buttonPadding,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
          visualDensity: compact,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shape,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
          visualDensity: compact,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: shape, visualDensity: compact),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: shape,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
        extendedTextStyle: text.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: colors.muted),
        labelStyle: text.bodyMedium?.copyWith(color: colors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radius),
          borderSide: BorderSide(color: scheme.onSurface, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Tokens.radius),
          borderSide: BorderSide(color: colors.hairline),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          side: BorderSide(color: scheme.outline),
        ),
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.secondaryContainer,
        checkmarkColor: scheme.onSecondaryContainer,
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape,
          visualDensity: compact,
          side: BorderSide(color: scheme.outline),
          backgroundColor: scheme.surfaceContainerLowest,
          foregroundColor: scheme.onSurface,
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: shape,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : colors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.onSecondaryContainer
                : colors.muted,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.onSurface, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: scheme.onSurface,
        unselectedLabelColor: colors.muted,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        dividerColor: colors.hairline,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        overlayColor: WidgetStatePropertyAll(
          scheme.onSurface.withValues(alpha: 0.04),
        ),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        visualDensity: compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
        minVerticalPadding: 8,
        horizontalTitleGap: 12,
        iconColor: colors.muted,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surfaceContainerLow,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleSize: const Size(28, 3),
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Tokens.radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Tokens.radiusLarge)),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Tokens.radius)),
          side: hairline,
        ),
        textStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: colors.accent,
        shape: shape,
        insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        elevation: 2,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(Tokens.radiusSmall),
        ),
        textStyle: text.labelMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 3,
        borderRadius: BorderRadius.zero,
        strokeWidth: 2.5,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Tokens.radiusSmall)),
        ),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        visualDensity: compact,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStatePropertyAll(scheme.outline),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(3),
        radius: const Radius.circular(Tokens.radiusSmall),
        thumbColor: WidgetStatePropertyAll(scheme.outline),
      ),
      // No iconTheme color: IconButton takes a non-default ambient icon color
      // as its foreground for every variant, which hid the white icon of
      // filled buttons. App bars and the navigation bar set their own.
    );
  }
}
