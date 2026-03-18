import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'text_tokens.dart';
import 'theme_extensions.dart';

/// Central theme configuration for the StoryScore app.
///
/// Use [darkTheme] and [lightTheme] to obtain fully configured [ThemeData]
/// instances, or call [themeFor] to resolve the correct theme from a
/// [ThemeMode] and the platform brightness.
abstract final class StoryScoreTheme {
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Fully configured dark [ThemeData] using Material 3.
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Fully configured light [ThemeData] using Material 3.
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  /// Resolves the correct [ThemeData] for the given [mode] and the current
  /// platform [platformBrightness].
  ///
  /// * [ThemeMode.dark]   -> always dark theme
  /// * [ThemeMode.light]  -> always light theme
  /// * [ThemeMode.system] -> follows [platformBrightness]
  static ThemeData themeFor(ThemeMode mode, Brightness platformBrightness) {
    return switch (mode) {
      ThemeMode.dark => darkTheme,
      ThemeMode.light => lightTheme,
      ThemeMode.system =>
        platformBrightness == Brightness.dark ? darkTheme : lightTheme,
    };
  }

  // ---------------------------------------------------------------------------
  // Private builder
  // ---------------------------------------------------------------------------

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final extension = isDark
        ? StoryScoreThemeExtension.dark
        : StoryScoreThemeExtension.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: TextTokens.fontFamily,
      textTheme: TextTokens.textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? ColorTokens.darkSurface : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black26,
        centerTitle: true,
        shape: isDark
            ? const Border(
                bottom: BorderSide(
                  color: ColorTokens.goldAccent,
                  width: 0.5,
                ),
              )
            : null,
      ),
      cardTheme: CardThemeData(
        color: isDark ? ColorTokens.darkCard : ColorTokens.lightCard,
        elevation: isDark ? 2 : 1,
        shadowColor: isDark
            ? ColorTokens.darkBackground.withValues(alpha: 0.6)
            : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: isDark
              ? BorderSide.none
              : const BorderSide(
                  color: ColorTokens.lightCardBorder,
                  width: 0.5,
                ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? ColorTokens.burgundy : ColorTokens.lightPrimary,
          foregroundColor: Colors.white,
          textStyle: TextTokens.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextTokens.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? ColorTokens.darkCard : ColorTokens.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? ColorTokens.darkCard : colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      extensions: [extension],
    );
  }

  // ---------------------------------------------------------------------------
  // Color schemes
  // ---------------------------------------------------------------------------

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ColorTokens.goldAccent,
    onPrimary: Colors.black,
    primaryContainer: ColorTokens.darkCardVariant,
    onPrimaryContainer: ColorTokens.parchment,
    secondary: ColorTokens.burgundy,
    onSecondary: Colors.white,
    secondaryContainer: ColorTokens.darkCard,
    onSecondaryContainer: ColorTokens.dustyRose,
    tertiary: ColorTokens.dustyRose,
    onTertiary: Colors.black,
    tertiaryContainer: ColorTokens.darkCardVariant,
    onTertiaryContainer: ColorTokens.dustyRose,
    error: ColorTokens.coral,
    onError: Colors.black,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: ColorTokens.darkBackground,
    onSurface: ColorTokens.parchment,
    surfaceContainerHighest: ColorTokens.darkSurface,
    onSurfaceVariant: ColorTokens.mutedText,
    outline: ColorTokens.mutedText,
    outlineVariant: ColorTokens.darkCardVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ColorTokens.lightBackground,
    onInverseSurface: ColorTokens.lightOnSurface,
    inversePrimary: ColorTokens.lightPrimary,
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorTokens.lightPrimary,
    onPrimary: Colors.white,
    primaryContainer: ColorTokens.lightSurface,
    onPrimaryContainer: ColorTokens.lightOnSurface,
    secondary: ColorTokens.goldAccent,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFFFFF0D4),
    onSecondaryContainer: Color(0xFF4A3200),
    tertiary: ColorTokens.dustyRose,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE0E8),
    onTertiaryContainer: Color(0xFF4A0020),
    error: ColorTokens.coral,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: ColorTokens.lightBackground,
    onSurface: ColorTokens.lightOnSurface,
    surfaceContainerHighest: ColorTokens.lightCard,
    onSurfaceVariant: ColorTokens.lightOnSurfaceVariant,
    outline: ColorTokens.lightOnSurfaceVariant,
    outlineVariant: ColorTokens.lightSurface,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ColorTokens.darkBackground,
    onInverseSurface: ColorTokens.parchment,
    inversePrimary: ColorTokens.goldAccent,
  );
}
