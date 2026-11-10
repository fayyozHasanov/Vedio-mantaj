import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Brand colours.
abstract final class AppColors {
  static const emerald = Color(0xFF075B46);
  static const deepGreen = Color(0xFF103D32);
  static const gold = Color(0xFFC8A45D);
  static const ivory = Color(0xFFF8F7F2);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF202923);
  static const textSecondary = Color(0xFF89928C);

  // Dark mode counterparts.
  static const darkBackground = Color(0xFF0B1714);
  static const darkCard = Color(0xFF13241F);
  static const darkElevated = Color(0xFF1A2E28);
  static const darkText = Color(0xFFF1EFE7);
  static const darkTextSecondary = Color(0xFF97A39C);
  static const emeraldLight = Color(0xFF2F9A7B);

  static const danger = Color(0xFFB4442F);
}

/// Extra semantic colours not covered by [ColorScheme].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.card,
    required this.textSecondary,
    required this.gold,
    required this.track,
    required this.prayer,
    required this.fasting,
    required this.shadow,
    required this.heroStart,
    required this.heroEnd,
  });

  final Color card;
  final Color textSecondary;
  final Color gold;
  final Color track;
  final Color prayer;
  final Color fasting;
  final Color shadow;
  final Color heroStart;
  final Color heroEnd;

  static const light = AppPalette(
    card: AppColors.card,
    textSecondary: AppColors.textSecondary,
    gold: AppColors.gold,
    track: Color(0xFFECEBE4),
    prayer: AppColors.emerald,
    fasting: AppColors.gold,
    shadow: Color(0x14103D32),
    heroStart: AppColors.emerald,
    heroEnd: AppColors.deepGreen,
  );

  static const dark = AppPalette(
    card: AppColors.darkCard,
    textSecondary: AppColors.darkTextSecondary,
    gold: Color(0xFFD6B677),
    track: Color(0xFF223830),
    prayer: AppColors.emeraldLight,
    fasting: Color(0xFFD6B677),
    shadow: Color(0x40000000),
    heroStart: Color(0xFF0C4A3A),
    heroEnd: Color(0xFF0A2620),
  );

  @override
  AppPalette copyWith({
    Color? card,
    Color? textSecondary,
    Color? gold,
    Color? track,
    Color? prayer,
    Color? fasting,
    Color? shadow,
    Color? heroStart,
    Color? heroEnd,
  }) => AppPalette(
    card: card ?? this.card,
    textSecondary: textSecondary ?? this.textSecondary,
    gold: gold ?? this.gold,
    track: track ?? this.track,
    prayer: prayer ?? this.prayer,
    fasting: fasting ?? this.fasting,
    shadow: shadow ?? this.shadow,
    heroStart: heroStart ?? this.heroStart,
    heroEnd: heroEnd ?? this.heroEnd,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      card: Color.lerp(card, other.card, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      track: Color.lerp(track, other.track, t)!,
      prayer: Color.lerp(prayer, other.prayer, t)!,
      fasting: Color.lerp(fasting, other.fasting, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

/// Spacing scale.
/// Maximum width of page content; on iPad the content is centred.
const double kMaxContentWidth = 680;

/// Page padding that keeps a phone-like reading width on wide screens.
EdgeInsets pagePadding(
  BuildContext context, {
  double top = 0,
  double bottom = 32,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final side = width > kMaxContentWidth + 2 * Gap.page
      ? (width - kMaxContentWidth) / 2
      : Gap.page;
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 28.0;
  static const page = 20.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    scheme: const ColorScheme.light(
      primary: AppColors.emerald,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDDEBE5),
      onPrimaryContainer: AppColors.deepGreen,
      secondary: AppColors.gold,
      onSecondary: AppColors.deepGreen,
      secondaryContainer: Color(0xFFF3EAD7),
      onSecondaryContainer: Color(0xFF5A4520),
      surface: AppColors.ivory,
      onSurface: AppColors.text,
      surfaceContainerHighest: Color(0xFFEFEEE7),
      outline: Color(0xFFDAD9D0),
      outlineVariant: Color(0xFFE8E7E0),
      error: AppColors.danger,
    ),
    palette: AppPalette.light,
    text: AppColors.text,
    textSecondary: AppColors.textSecondary,
    cardColor: AppColors.card,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    scheme: const ColorScheme.dark(
      primary: AppColors.emeraldLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF173B31),
      onPrimaryContainer: Color(0xFFCFE7DD),
      secondary: Color(0xFFD6B677),
      onSecondary: AppColors.deepGreen,
      secondaryContainer: Color(0xFF3A3121),
      onSecondaryContainer: Color(0xFFF1E1BE),
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkElevated,
      outline: Color(0xFF2C443C),
      outlineVariant: Color(0xFF22362F),
      error: Color(0xFFE07A62),
    ),
    palette: AppPalette.dark,
    text: AppColors.darkText,
    textSecondary: AppColors.darkTextSecondary,
    cardColor: AppColors.darkCard,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required AppPalette palette,
    required Color text,
    required Color textSecondary,
    required Color cardColor,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      // Native iOS uses the system font (SF Pro). The web build bundles
      // Inter so it renders the same offline.
      fontFamily: kIsWeb ? 'Inter' : null,
      brightness: brightness,
      colorScheme: scheme,
    );
    final t = base.textTheme.apply(bodyColor: text, displayColor: text);
    final textTheme = t.copyWith(
      displaySmall: t.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.05,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineSmall: t.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: t.bodyMedium?.copyWith(height: 1.4),
      bodySmall: t.bodySmall?.copyWith(color: textSecondary, height: 1.35),
      labelSmall: t.labelSmall?.copyWith(
        color: textSecondary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
    final shape16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: [palette],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: shape16,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: shape16,
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: shape16,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFF2F1EB)
            : AppColors.darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : textSecondary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? AppColors.deepGreen
            : AppColors.darkElevated,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppColors.gold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: Colors.white,
          shape: shape16,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
