import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Local AI Tutor's look: warm paper (dark: deep ink) with a violet accent,
/// rounded surfaces, Fraunces for what you study and Inter for the rest.
/// The palette and card styling follow the Verso flashcard app.
abstract final class Tokens {
  /// Buttons, inputs, option rows, panels.
  static const radius = 16.0;

  /// Tags, badges, small tiles.
  static const radiusSmall = 8.0;

  /// Sheets, dialogs and flashcards.
  static const radiusLarge = 28.0;

  /// Side padding of pages.
  static const gutter = 20.0;

  /// UI face.
  static const fontFamily = 'Inter';

  /// Display face, for question cards and big headings.
  static const displayFamily = 'Fraunces';
}

/// Colors outside the Material color scheme, for both brightnesses.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.masteryLow,
    required this.masteryMid,
    required this.masteryHigh,
    required this.hairline,
    required this.muted,
    required this.faint,
    required this.sunken,
    required this.raised,
    required this.cardFrontTop,
    required this.cardFrontBottom,
    required this.cardBackTop,
    required this.cardBackBottom,
    required this.shadow,
  });

  /// Violet: progress, highlights, the AI spark, primary buttons.
  final Color accent;
  final Color onAccent;

  /// The accent as a faint wash, for selected rows and badges.
  final Color accentSoft;

  /// "I remember": a right answer.
  final Color success;

  /// "Not clearly": a shaky one.
  final Color warning;

  /// "I don't remember": a wrong answer.
  final Color danger;
  final Color masteryLow;
  final Color masteryMid;
  final Color masteryHigh;

  /// 1 px borders and dividers.
  final Color hairline;

  /// Secondary text.
  final Color muted;

  /// Tertiary text: captions, eyebrows, placeholders.
  final Color faint;

  /// Recessed fills: inputs, tracks, hint bars.
  final Color sunken;

  /// Raised fills: option rows, panels.
  final Color raised;

  final Color cardFrontTop;
  final Color cardFrontBottom;
  final Color cardBackTop;
  final Color cardBackBottom;
  final Color shadow;

  static AppColors _make({
    required Color accent,
    required Color onAccent,
    required double soft,
    required Color success,
    required Color warning,
    required Color danger,
    required Color masteryLow,
    required Color masteryMid,
    required Color masteryHigh,
    required Color hairline,
    required Color muted,
    required Color faint,
    required Color sunken,
    required Color raised,
    required Color frontTop,
    required Color frontBottom,
    required double backTopMix,
    required double backBottomMix,
    required Color shadow,
  }) => AppColors(
    accent: accent,
    onAccent: onAccent,
    accentSoft: accent.withValues(alpha: soft),
    success: success,
    warning: warning,
    danger: danger,
    masteryLow: masteryLow,
    masteryMid: masteryMid,
    masteryHigh: masteryHigh,
    hairline: hairline,
    muted: muted,
    faint: faint,
    sunken: sunken,
    raised: raised,
    cardFrontTop: frontTop,
    cardFrontBottom: frontBottom,
    cardBackTop: Color.lerp(frontTop, accent, backTopMix)!,
    cardBackBottom: Color.lerp(frontBottom, accent, backBottomMix)!,
    shadow: shadow,
  );

  static final light = _make(
    accent: const Color(0xFF6D4AE0),
    onAccent: Colors.white,
    soft: 0.10,
    success: const Color(0xFF15805C),
    warning: const Color(0xFFC07C17),
    danger: const Color(0xFFD3384E),
    masteryLow: const Color(0xFFC4502A),
    masteryMid: const Color(0xFFD99A26),
    masteryHigh: const Color(0xFF2E8B5B),
    hairline: const Color(0xFFE5E0D7),
    muted: const Color(0xFF5E5E6B),
    faint: const Color(0xFF9B9BA6),
    sunken: const Color(0xFFF1EEE8),
    raised: Colors.white,
    frontTop: Colors.white,
    frontBottom: const Color(0xFFF7F4EF),
    backTopMix: 0.06,
    backBottomMix: 0.12,
    shadow: const Color(0xFF1B1B26),
  );

  static final dark = _make(
    accent: const Color(0xFF9B85FF),
    onAccent: const Color(0xFF0A0A10),
    soft: 0.14,
    success: const Color(0xFF47D19A),
    warning: const Color(0xFFF5B841),
    danger: const Color(0xFFFF6B75),
    masteryLow: const Color(0xFFD9653D),
    masteryMid: const Color(0xFFE0A63A),
    masteryHigh: const Color(0xFF45B07A),
    hairline: const Color(0xFF2A2A36),
    muted: const Color(0xFF9E9DAB),
    faint: const Color(0xFF6A6976),
    sunken: const Color(0xFF101018),
    raised: const Color(0xFF1B1B25),
    frontTop: const Color(0xFF1E1E29),
    frontBottom: const Color(0xFF15151E),
    backTopMix: 0.14,
    backBottomMix: 0.07,
    shadow: Colors.black,
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? success,
    Color? warning,
    Color? danger,
    Color? masteryLow,
    Color? masteryMid,
    Color? masteryHigh,
    Color? hairline,
    Color? muted,
    Color? faint,
    Color? sunken,
    Color? raised,
    Color? cardFrontTop,
    Color? cardFrontBottom,
    Color? cardBackTop,
    Color? cardBackBottom,
    Color? shadow,
  }) => AppColors(
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    accentSoft: accentSoft ?? this.accentSoft,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    masteryLow: masteryLow ?? this.masteryLow,
    masteryMid: masteryMid ?? this.masteryMid,
    masteryHigh: masteryHigh ?? this.masteryHigh,
    hairline: hairline ?? this.hairline,
    muted: muted ?? this.muted,
    faint: faint ?? this.faint,
    sunken: sunken ?? this.sunken,
    raised: raised ?? this.raised,
    cardFrontTop: cardFrontTop ?? this.cardFrontTop,
    cardFrontBottom: cardFrontBottom ?? this.cardFrontBottom,
    cardBackTop: cardBackTop ?? this.cardBackTop,
    cardBackBottom: cardBackBottom ?? this.cardBackBottom,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      accentSoft: mix(accentSoft, other.accentSoft),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      masteryLow: mix(masteryLow, other.masteryLow),
      masteryMid: mix(masteryMid, other.masteryMid),
      masteryHigh: mix(masteryHigh, other.masteryHigh),
      hairline: mix(hairline, other.hairline),
      muted: mix(muted, other.muted),
      faint: mix(faint, other.faint),
      sunken: mix(sunken, other.sunken),
      raised: mix(raised, other.raised),
      cardFrontTop: mix(cardFrontTop, other.cardFrontTop),
      cardFrontBottom: mix(cardFrontBottom, other.cardFrontBottom),
      cardBackTop: mix(cardBackTop, other.cardBackTop),
      cardBackBottom: mix(cardBackBottom, other.cardBackBottom),
      shadow: mix(shadow, other.shadow),
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
  static const _canvasLight = Color(0xFFFBF9F6);
  static const _canvasDark = Color(0xFF0A0A10);
  static const _inkLight = Color(0xFF17171F);
  static const _inkDark = Color(0xFFF3F2EF);

  static ColorScheme _scheme(Brightness brightness, AppColors c) {
    final dark = brightness == Brightness.dark;
    final canvas = dark ? _canvasDark : _canvasLight;
    final ink = dark ? _inkDark : _inkLight;
    final surface = dark ? const Color(0xFF14141C) : Colors.white;
    // Opaque washes of the accent for "container" slots.
    Color wash(double amount) =>
        Color.alphaBlend(c.accent.withValues(alpha: amount), surface);
    return ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: wash(0.14),
      onPrimaryContainer: c.accent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: wash(0.14),
      onSecondaryContainer: dark ? ink : c.accent,
      tertiary: c.success,
      onTertiary: dark ? const Color(0xFF062615) : Colors.white,
      tertiaryContainer: Color.alphaBlend(
        c.success.withValues(alpha: 0.16),
        surface,
      ),
      onTertiaryContainer: c.success,
      error: c.danger,
      onError: dark ? const Color(0xFF3B0904) : Colors.white,
      errorContainer: Color.alphaBlend(
        c.danger.withValues(alpha: 0.14),
        surface,
      ),
      onErrorContainer: c.danger,
      surface: canvas,
      onSurface: ink,
      onSurfaceVariant: c.muted,
      surfaceDim: c.sunken,
      surfaceBright: c.raised,
      surfaceContainerLowest: surface,
      surfaceContainerLow: canvas,
      surfaceContainer: c.sunken,
      surfaceContainerHigh: dark ? c.raised : const Color(0xFFF4F1EB),
      surfaceContainerHighest: dark ? const Color(0xFF242431) : c.sunken,
      outline: dark ? const Color(0xFF3A3A48) : const Color(0xFFD6D0C5),
      outlineVariant: c.hairline,
      inverseSurface: ink,
      onInverseSurface: canvas,
      inversePrimary: c.accent,
      shadow: c.shadow,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
  }

  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static TextTheme _textTheme(ColorScheme scheme, AppColors colors) {
    final ink = scheme.onSurface;
    TextStyle ui(
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
    TextStyle display(double size, double height, {double spacing = -0.3}) =>
        TextStyle(
          fontFamily: Tokens.displayFamily,
          fontSize: size,
          height: height,
          fontWeight: FontWeight.w600,
          letterSpacing: spacing,
          color: ink,
        );
    return TextTheme(
      displayLarge: display(44, 1.12, spacing: -0.8),
      displayMedium: display(34, 1.16, spacing: -0.5),
      displaySmall: display(28, 1.2),
      headlineLarge: display(26, 1.22),
      headlineMedium: display(22, 1.26, spacing: 0),
      headlineSmall: ui(19, 1.3, weight: FontWeight.w600, spacing: -0.2),
      titleLarge: ui(18, 1.3, weight: FontWeight.w600, spacing: -0.2),
      titleMedium: ui(15.5, 1.35, weight: FontWeight.w600, spacing: -0.1),
      titleSmall: ui(14, 1.35, weight: FontWeight.w600),
      bodyLarge: ui(16, 1.45),
      bodyMedium: ui(14.5, 1.45, color: colors.muted),
      bodySmall: ui(13, 1.4, color: colors.muted),
      labelLarge: ui(15, 1.2, weight: FontWeight.w600),
      labelMedium: ui(13, 1.2, weight: FontWeight.w500, color: colors.muted),
      // Overlines: section labels, eyebrows.
      labelSmall: ui(
        11.5,
        1.2,
        weight: FontWeight.w600,
        spacing: 0.8,
        color: colors.faint,
      ),
    );
  }

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final dark = brightness == Brightness.dark;
    final scheme = _scheme(brightness, colors);
    final text = _textTheme(scheme, colors);
    final surface = scheme.surfaceContainerLowest;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Tokens.radius)),
    );
    final hairline = BorderSide(color: colors.hairline);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 22);
    const buttonSize = Size(0, 50);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: Tokens.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleSpacing: Tokens.gutter,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
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
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          shape: shape,
          minimumSize: buttonSize,
          padding: buttonPadding,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: buttonSize,
          padding: buttonPadding,
          foregroundColor: scheme.onSurface,
          side: hairline,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shape,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          foregroundColor: colors.accent,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.muted),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        extendedTextStyle: text.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.sunken,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: colors.faint),
        labelStyle: text.bodyMedium,
        border: border(colors.hairline),
        enabledBorder: border(colors.hairline),
        focusedBorder: border(colors.accent, 1.6),
        errorBorder: border(colors.danger),
        disabledBorder: border(colors.hairline),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: hairline,
        backgroundColor: colors.sunken,
        selectedColor: colors.accentSoft,
        checkmarkColor: colors.accent,
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape,
          side: hairline,
          backgroundColor: surface,
          foregroundColor: scheme.onSurface,
          selectedBackgroundColor: colors.accentSoft,
          selectedForegroundColor: colors.accent,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.accentSoft,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? colors.accent
                : colors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? colors.accent
                : colors.muted,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.accent, width: 3),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colors.accent,
        unselectedLabelColor: colors.muted,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        dividerColor: colors.hairline,
        tabAlignment: TabAlignment.start,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        overlayColor: WidgetStatePropertyAll(colors.accentSoft),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
        minVerticalPadding: 8,
        horizontalTitleGap: 12,
        iconColor: colors.muted,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleSize: const Size(36, 4),
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Tokens.radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radius),
          side: hairline,
        ),
        textStyle: text.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: colors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        elevation: 2,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: text.labelSmall?.copyWith(color: scheme.onInverseSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.sunken,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 4,
        borderRadius: BorderRadius.circular(999),
        strokeWidth: 3,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colors.accent : null,
        ),
        checkColor: WidgetStatePropertyAll(colors.onAccent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? colors.onAccent : surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.sunken,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.hairline,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.sunken,
        thumbColor: colors.accent,
        overlayColor: colors.accentSoft,
        trackHeight: 5,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(3),
        radius: const Radius.circular(2),
        thumbColor: WidgetStatePropertyAll(scheme.outline),
      ),
      // Quieter page transition than the default zoom.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      // No iconTheme color: IconButton takes a non-default ambient icon color
      // as its foreground for every variant, which hid the white icon of
      // filled buttons. App bars and the navigation bar set their own.
    );
  }
}
