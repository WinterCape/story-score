import 'package:flutter/material.dart';

/// All color constants for the StoryScore dark and light palettes,
/// plus the 12 distinct player-assignment colors.
abstract final class ColorTokens {
  // ---------------------------------------------------------------------------
  // Dark palette — "Warm Storybook — Rich & Dramatic"
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0F0A1A); // Ink night
  static const Color darkSurface = Color(0xFF1E1233); // Rich plum
  static const Color darkCard = Color(0xFF2E1A4A); // Velvet violet
  static const Color darkCardVariant = Color(0xFF3A2060); // Deep amethyst
  static const Color goldAccent = Color(0xFFE8A020); // Rich amber
  static const Color burgundy = Color(0xFFA01845); // Deep wine
  static const Color dustyRose = Color(0xFFD4758A); // Vivid rose
  static const Color parchment = Color(0xFFF5E0B8); // Warm cream (primary text on dark)
  static const Color mutedText = Color(0xFFB89AAA); // Lavender mist (secondary text)
  static const Color teal = Color(0xFF1A8585); // Emerald pool
  static const Color violet = Color(0xFF7B50C8); // Royal violet
  static const Color coral = Color(0xFFE8785E); // Warm coral

  // ---------------------------------------------------------------------------
  // Light palette
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFFBF0DD); // Warm linen
  static const Color lightSurface = Color(0xFFF5E0B8); // Parchment
  static const Color lightCard = Color(0xFFFFFFFF); // White
  static const Color lightPrimary = Color(0xFFA01845); // Deep wine
  static const Color lightOnSurface = Color(0xFF6B3A1A); // Warm brown
  static const Color lightOnSurfaceVariant = Color(0xFF8B6A5A); // Faded brown
  static const Color lightCardBorder = Color(0xFFE8D0A0); // Tan

  // ---------------------------------------------------------------------------
  // Player colors – 12 distinct hues for player assignment
  // ---------------------------------------------------------------------------
  static const Color playerAuroraTeal = Color(0xFF2EC4B6);
  static const Color playerSoftViolet = Color(0xFF7B68EE);
  static const Color playerGold = Color(0xFFD4A742);
  static const Color playerCoral = Color(0xFFFF6B6B);
  static const Color playerEmerald = Color(0xFF2DD4BF);
  static const Color playerOceanBlue = Color(0xFF3B82F6);
  static const Color playerSunsetOrange = Color(0xFFFB923C);
  static const Color playerRosePink = Color(0xFFF472B6);
  static const Color playerLimeGreen = Color(0xFFA3E635);
  static const Color playerSlateBlue = Color(0xFF64748B);
  static const Color playerAmber = Color(0xFFF59E0B);
  static const Color playerPlum = Color(0xFFA855F7);

  /// Ordered list of all player colors for indexed access.
  static const List<Color> playerColors = [
    playerAuroraTeal,
    playerSoftViolet,
    playerGold,
    playerCoral,
    playerEmerald,
    playerOceanBlue,
    playerSunsetOrange,
    playerRosePink,
    playerLimeGreen,
    playerSlateBlue,
    playerAmber,
    playerPlum,
  ];

  /// Player color names keyed by their color value for display purposes.
  static const Map<String, Color> playerColorsByName = {
    'aurora_teal': playerAuroraTeal,
    'soft_violet': playerSoftViolet,
    'gold': playerGold,
    'coral': playerCoral,
    'emerald': playerEmerald,
    'ocean_blue': playerOceanBlue,
    'sunset_orange': playerSunsetOrange,
    'rose_pink': playerRosePink,
    'lime_green': playerLimeGreen,
    'slate_blue': playerSlateBlue,
    'amber': playerAmber,
    'plum': playerPlum,
  };
}
