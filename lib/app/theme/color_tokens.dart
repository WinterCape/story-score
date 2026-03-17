import 'package:flutter/material.dart';

/// All color constants for the StoryScore dark and light palettes,
/// plus the 12 distinct player-assignment colors.
abstract final class ColorTokens {
  // ---------------------------------------------------------------------------
  // Dark palette
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF1A1025);
  static const Color darkSurface = Color(0xFF241735);
  static const Color darkSurfaceVariant = Color(0xFF2D2040);
  static const Color midnightBlue = Color(0xFF0D1B2A);
  static const Color goldAccent = Color(0xFFD4A742);
  static const Color goldAccentLight = Color(0xFFE8C876);
  static const Color auroraTeal = Color(0xFF2EC4B6);
  static const Color softViolet = Color(0xFF7B68EE);
  static const Color auroraGreen = Color(0xFF4ADE80);
  static const Color coralAccent = Color(0xFFFF6B6B);
  static const Color darkOnSurface = Color(0xFFE8E0F0);
  static const Color darkOnSurfaceVariant = Color(0xFFB8A8CC);

  // ---------------------------------------------------------------------------
  // Light palette
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFFDF8F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0E8F5);
  static const Color lightPrimary = Color(0xFF5B3E96);
  static const Color lightGoldAccent = Color(0xFFB8912E);
  static const Color lightOnSurface = Color(0xFF1A1025);
  static const Color lightOnSurfaceVariant = Color(0xFF5A4A6E);

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
