import 'package:flutter/material.dart';

import 'text_tokens.dart';
import 'theme_extensions.dart';

/// Color palette definition for a premium theme.
@immutable
class PremiumThemePalette {
  const PremiumThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  /// Unique machine-readable identifier.
  final String id;

  /// Human-readable display name.
  final String name;

  /// Primary brand color for the theme.
  final Color primary;

  /// Secondary color for supporting elements.
  final Color secondary;

  /// Accent color for highlights and interactive elements.
  final Color accent;

  /// Scaffold / page background.
  final Color background;

  /// Card / elevated surface color.
  final Color surface;

  /// Text on surfaces.
  final Color onSurface;

  /// Secondary text on surfaces.
  final Color onSurfaceVariant;

  /// Generates a light [ThemeData] from this palette.
  ThemeData toLightTheme() => _buildTheme(Brightness.light);

  /// Generates a dark [ThemeData] from this palette.
  ThemeData toDarkTheme() => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // For light mode, lighten the palette colors for backgrounds
    final bgColor = isDark ? background : _lighten(background, 0.85);
    final surfColor = isDark ? surface : _lighten(surface, 0.90);
    final surfVariant = isDark
        ? Color.lerp(surface, primary, 0.15)!
        : _lighten(Color.lerp(surface, primary, 0.15)!, 0.85);
    final onSurfColor = isDark ? onSurface : _darken(onSurface, 0.85);
    final onSurfVariantColor =
        isDark ? onSurfaceVariant : _darken(onSurfaceVariant, 0.5);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? Colors.white : Colors.white,
      primaryContainer: surfVariant,
      onPrimaryContainer: onSurfColor,
      secondary: secondary,
      onSecondary: isDark ? Colors.black : Colors.white,
      secondaryContainer: isDark
          ? Color.lerp(background, secondary, 0.2)!
          : _lighten(secondary, 0.85),
      onSecondaryContainer: isDark ? secondary : _darken(secondary, 0.5),
      tertiary: accent,
      onTertiary: isDark ? Colors.black : Colors.white,
      tertiaryContainer: isDark
          ? Color.lerp(background, accent, 0.2)!
          : _lighten(accent, 0.85),
      onTertiaryContainer: isDark ? accent : _darken(accent, 0.5),
      error: const Color(0xFFFF6B6B),
      onError: isDark ? Colors.black : Colors.white,
      errorContainer:
          isDark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
      onErrorContainer:
          isDark ? const Color(0xFFFFDAD6) : const Color(0xFF410002),
      surface: bgColor,
      onSurface: onSurfColor,
      surfaceContainerHighest: surfColor,
      onSurfaceVariant: onSurfVariantColor,
      outline: onSurfVariantColor,
      outlineVariant: surfVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? bgColor : onSurfColor,
      onInverseSurface: isDark ? onSurfColor : bgColor,
      inversePrimary: isDark ? _lighten(primary, 0.7) : primary,
    );

    final extension = StoryScoreThemeExtension(
      goldAccent: accent,
      auroraTeal: secondary,
      softViolet: primary,
      auroraGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [secondary, primary, accent],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surfColor, surfVariant],
      ),
      playerColors: const {
        'aurora_teal': Color(0xFF2EC4B6),
        'soft_violet': Color(0xFF7B68EE),
        'gold': Color(0xFFD4A742),
        'coral': Color(0xFFFF6B6B),
        'emerald': Color(0xFF2DD4BF),
        'ocean_blue': Color(0xFF3B82F6),
        'sunset_orange': Color(0xFFFB923C),
        'rose_pink': Color(0xFFF472B6),
        'lime_green': Color(0xFFA3E635),
        'slate_blue': Color(0xFF64748B),
        'amber': Color(0xFFF59E0B),
        'plum': Color(0xFFA855F7),
      },
    );

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
        elevation: isDark ? 0 : 0.5,
        scrolledUnderElevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black26,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide.none
              : BorderSide(
                  color: onSurfVariantColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
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

  /// Lighten a color by mixing it with white.
  static Color _lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  /// Darken a color by mixing it with black.
  static Color _darken(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount)!;
  }
}

/// The four premium color palettes available in the Supporter Pack.
abstract final class PremiumThemes {
  /// Ocean Depths: deep blues, seafoam, silver.
  static const oceanDepths = PremiumThemePalette(
    id: 'ocean_depths',
    name: 'Ocean Depths',
    primary: Color(0xFF0A3D62),
    secondary: Color(0xFF3AAFA9),
    accent: Color(0xFFB0C4DE),
    background: Color(0xFF0B1929),
    surface: Color(0xFF112240),
    onSurface: Color(0xFFE0E8F0),
    onSurfaceVariant: Color(0xFF8DA4BF),
  );

  /// Ember: warm reds, oranges, amber.
  static const ember = PremiumThemePalette(
    id: 'ember',
    name: 'Ember',
    primary: Color(0xFFC0392B),
    secondary: Color(0xFFE67E22),
    accent: Color(0xFFF1C40F),
    background: Color(0xFF1A0E0A),
    surface: Color(0xFF2D1810),
    onSurface: Color(0xFFF5E6DC),
    onSurfaceVariant: Color(0xFFBFA08E),
  );

  /// Frost: ice blues, silvers, whites.
  static const frost = PremiumThemePalette(
    id: 'frost',
    name: 'Frost',
    primary: Color(0xFF5DADE2),
    secondary: Color(0xFF85C1E9),
    accent: Color(0xFFD6EAF8),
    background: Color(0xFF0C1A28),
    surface: Color(0xFF152638),
    onSurface: Color(0xFFECF0F1),
    onSurfaceVariant: Color(0xFFAABBCC),
  );

  /// Enchanted Forest: deep greens, golds, earthy tones.
  static const enchantedForest = PremiumThemePalette(
    id: 'enchanted_forest',
    name: 'Enchanted Forest',
    primary: Color(0xFF1E8449),
    secondary: Color(0xFF27AE60),
    accent: Color(0xFFD4A742),
    background: Color(0xFF0D1A0F),
    surface: Color(0xFF1A2E1C),
    onSurface: Color(0xFFE8F0E4),
    onSurfaceVariant: Color(0xFF9AB89E),
  );

  /// All premium palettes for iteration.
  static const List<PremiumThemePalette> all = [
    oceanDepths,
    ember,
    frost,
    enchantedForest,
  ];

  /// Returns the [PremiumThemePalette] matching the given [id],
  /// or `null` if no match is found.
  static PremiumThemePalette? byId(String id) {
    for (final palette in all) {
      if (palette.id == id) return palette;
    }
    return null;
  }

  /// Set of theme IDs that require the Supporter Pack.
  static const Set<String> premiumThemeIds = {
    'ocean_depths',
    'ember',
    'frost',
    'enchanted_forest',
  };

  /// Returns `true` if the given [themeId] requires the Supporter Pack.
  static bool isPremium(String themeId) => premiumThemeIds.contains(themeId);
}
