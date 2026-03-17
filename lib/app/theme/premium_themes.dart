import 'package:flutter/material.dart';

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
}
