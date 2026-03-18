import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Custom [ThemeExtension] carrying StoryScore-specific design tokens that
/// don't map directly to the Material [ColorScheme].
@immutable
class StoryScoreThemeExtension
    extends ThemeExtension<StoryScoreThemeExtension> {
  const StoryScoreThemeExtension({
    required this.goldAccent,
    required this.teal,
    required this.violet,
    required this.burgundy,
    required this.dustyRose,
    required this.parchment,
    required this.accentGradient,
    required this.cardGradient,
    required this.playerColors,
  });

  /// Gold accent used for highlights, star ratings, premium badges.
  final Color goldAccent;

  /// Teal used for positive actions & success states.
  final Color teal;

  /// Violet used for secondary emphasis & decorative elements.
  final Color violet;

  /// Burgundy / deep wine used for primary actions & branding.
  final Color burgundy;

  /// Dusty rose / vivid rose for softer accent elements.
  final Color dustyRose;

  /// Parchment / warm cream for primary text on dark surfaces.
  final Color parchment;

  /// Accent gradient from burgundy to gold.
  final LinearGradient accentGradient;

  /// Subtle gradient applied to elevated card surfaces.
  final LinearGradient cardGradient;

  /// The 12 distinct player-assignment colors keyed by name.
  final Map<String, Color> playerColors;

  // ---------------------------------------------------------------------------
  // Pre-built instances for dark and light themes
  // ---------------------------------------------------------------------------

  static const StoryScoreThemeExtension dark = StoryScoreThemeExtension(
    goldAccent: ColorTokens.goldAccent,
    teal: ColorTokens.teal,
    violet: ColorTokens.violet,
    burgundy: ColorTokens.burgundy,
    dustyRose: ColorTokens.dustyRose,
    parchment: ColorTokens.parchment,
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.burgundy,
        ColorTokens.goldAccent,
      ],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
    ),
    playerColors: ColorTokens.playerColorsByName,
  );

  static const StoryScoreThemeExtension light = StoryScoreThemeExtension(
    goldAccent: ColorTokens.goldAccent,
    teal: ColorTokens.teal,
    violet: ColorTokens.violet,
    burgundy: ColorTokens.lightPrimary,
    dustyRose: ColorTokens.dustyRose,
    parchment: ColorTokens.lightSurface,
    accentGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        ColorTokens.lightPrimary,
        ColorTokens.goldAccent,
      ],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorTokens.lightCard, ColorTokens.lightSurface],
    ),
    playerColors: ColorTokens.playerColorsByName,
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension overrides
  // ---------------------------------------------------------------------------

  @override
  StoryScoreThemeExtension copyWith({
    Color? goldAccent,
    Color? teal,
    Color? violet,
    Color? burgundy,
    Color? dustyRose,
    Color? parchment,
    LinearGradient? accentGradient,
    LinearGradient? cardGradient,
    Map<String, Color>? playerColors,
  }) {
    return StoryScoreThemeExtension(
      goldAccent: goldAccent ?? this.goldAccent,
      teal: teal ?? this.teal,
      violet: violet ?? this.violet,
      burgundy: burgundy ?? this.burgundy,
      dustyRose: dustyRose ?? this.dustyRose,
      parchment: parchment ?? this.parchment,
      accentGradient: accentGradient ?? this.accentGradient,
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
      teal: Color.lerp(teal, other.teal, t)!,
      violet: Color.lerp(violet, other.violet, t)!,
      burgundy: Color.lerp(burgundy, other.burgundy, t)!,
      dustyRose: Color.lerp(dustyRose, other.dustyRose, t)!,
      parchment: Color.lerp(parchment, other.parchment, t)!,
      accentGradient: LinearGradient.lerp(
        accentGradient,
        other.accentGradient,
        t,
      )!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
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
