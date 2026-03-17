import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Custom [ThemeExtension] carrying StoryScore-specific design tokens that
/// don't map directly to the Material [ColorScheme].
@immutable
class StoryScoreThemeExtension
    extends ThemeExtension<StoryScoreThemeExtension> {
  const StoryScoreThemeExtension({
    required this.goldAccent,
    required this.auroraTeal,
    required this.softViolet,
    required this.auroraGradient,
    required this.cardGradient,
    required this.playerColors,
  });

  /// Gold accent used for highlights, star ratings, premium badges.
  final Color goldAccent;

  /// Aurora teal used for positive actions & success states.
  final Color auroraTeal;

  /// Soft violet used for secondary emphasis & decorative elements.
  final Color softViolet;

  /// Multi-stop gradient inspired by the northern lights / aurora borealis.
  final LinearGradient auroraGradient;

  /// Subtle gradient applied to elevated card surfaces.
  final LinearGradient cardGradient;

  /// The 12 distinct player-assignment colors keyed by name.
  final Map<String, Color> playerColors;

  // ---------------------------------------------------------------------------
  // Pre-built instances for dark and light themes
  // ---------------------------------------------------------------------------

  static const StoryScoreThemeExtension dark = StoryScoreThemeExtension(
    goldAccent: ColorTokens.goldAccent,
    auroraTeal: ColorTokens.auroraTeal,
    softViolet: ColorTokens.softViolet,
    auroraGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.auroraTeal,
        ColorTokens.softViolet,
        ColorTokens.goldAccent,
      ],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.darkSurface,
        ColorTokens.darkSurfaceVariant,
      ],
    ),
    playerColors: ColorTokens.playerColorsByName,
  );

  static const StoryScoreThemeExtension light = StoryScoreThemeExtension(
    goldAccent: ColorTokens.lightGoldAccent,
    auroraTeal: ColorTokens.auroraTeal,
    softViolet: ColorTokens.lightPrimary,
    auroraGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.auroraTeal,
        ColorTokens.lightPrimary,
        ColorTokens.lightGoldAccent,
      ],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.lightSurface,
        ColorTokens.lightSurfaceVariant,
      ],
    ),
    playerColors: ColorTokens.playerColorsByName,
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension overrides
  // ---------------------------------------------------------------------------

  @override
  StoryScoreThemeExtension copyWith({
    Color? goldAccent,
    Color? auroraTeal,
    Color? softViolet,
    LinearGradient? auroraGradient,
    LinearGradient? cardGradient,
    Map<String, Color>? playerColors,
  }) {
    return StoryScoreThemeExtension(
      goldAccent: goldAccent ?? this.goldAccent,
      auroraTeal: auroraTeal ?? this.auroraTeal,
      softViolet: softViolet ?? this.softViolet,
      auroraGradient: auroraGradient ?? this.auroraGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      playerColors: playerColors ?? this.playerColors,
    );
  }

  @override
  StoryScoreThemeExtension lerp(
    covariant StoryScoreThemeExtension? other,
    double t,
  ) {
    if (other is! StoryScoreThemeExtension) return this;
    return StoryScoreThemeExtension(
      goldAccent: Color.lerp(goldAccent, other.goldAccent, t)!,
      auroraTeal: Color.lerp(auroraTeal, other.auroraTeal, t)!,
      softViolet: Color.lerp(softViolet, other.softViolet, t)!,
      auroraGradient:
          LinearGradient.lerp(auroraGradient, other.auroraGradient, t)!,
      cardGradient:
          LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      // Colors are discrete — snap at the midpoint.
      playerColors: t < 0.5 ? playerColors : other.playerColors,
    );
  }
}

/// Convenience extension on [ThemeData] for quick access.
extension StoryScoreThemeExtensionAccess on ThemeData {
  StoryScoreThemeExtension get storyScore =>
      extension<StoryScoreThemeExtension>()!;
}
