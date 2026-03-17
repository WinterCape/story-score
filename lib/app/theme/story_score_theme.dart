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
  static ThemeData themeFor(
    ThemeMode mode,
    Brightness platformBrightness,
  ) {
    return switch (mode) {
      ThemeMode.dark => darkTheme,
      ThemeMode.light => lightTheme,
      ThemeMode.system => platformBrightness == Brightness.dark
          ? darkTheme
          : lightTheme,
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
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: TextTokens.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextTokens.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
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
    primary: ColorTokens.softViolet,
    onPrimary: Colors.white,
    primaryContainer: ColorTokens.darkSurfaceVariant,
    onPrimaryContainer: ColorTokens.darkOnSurface,
    secondary: ColorTokens.auroraTeal,
    onSecondary: Colors.black,
    secondaryContainer: ColorTokens.midnightBlue,
    onSecondaryContainer: ColorTokens.auroraTeal,
    tertiary: ColorTokens.goldAccent,
    onTertiary: Colors.black,
    tertiaryContainer: ColorTokens.darkSurfaceVariant,
    onTertiaryContainer: ColorTokens.goldAccentLight,
    error: ColorTokens.coralAccent,
    onError: Colors.black,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: ColorTokens.darkBackground,
    onSurface: ColorTokens.darkOnSurface,
    surfaceContainerHighest: ColorTokens.darkSurface,
    onSurfaceVariant: ColorTokens.darkOnSurfaceVariant,
    outline: ColorTokens.darkOnSurfaceVariant,
    outlineVariant: ColorTokens.darkSurfaceVariant,
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
    primaryContainer: ColorTokens.lightSurfaceVariant,
    onPrimaryContainer: ColorTokens.lightOnSurface,
    secondary: ColorTokens.auroraTeal,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD4F5F2),
    onSecondaryContainer: Color(0xFF0D3D38),
    tertiary: ColorTokens.lightGoldAccent,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFF0D4),
    onTertiaryContainer: Color(0xFF4A3200),
    error: ColorTokens.coralAccent,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: ColorTokens.lightBackground,
    onSurface: ColorTokens.lightOnSurface,
    surfaceContainerHighest: ColorTokens.lightSurface,
    onSurfaceVariant: ColorTokens.lightOnSurfaceVariant,
    outline: ColorTokens.lightOnSurfaceVariant,
    outlineVariant: ColorTokens.lightSurfaceVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ColorTokens.darkBackground,
    onInverseSurface: ColorTokens.darkOnSurface,
    inversePrimary: ColorTokens.softViolet,
  );
}
