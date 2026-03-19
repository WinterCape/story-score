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
    required this.backgroundGradient,
    required this.primaryAccent,
    required this.primaryText,
    required this.secondaryText,
    required this.cardColor,
    required this.cardVariant,
    required this.surfaceColor,
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

  /// Full-screen background gradient (dark: ink→plum→violet, light: linen→parchment).
  final LinearGradient backgroundGradient;

  /// Primary accent color (dark: gold, light: burgundy).
  final Color primaryAccent;

  /// Primary text color (dark: parchment, light: warm brown).
  final Color primaryText;

  /// Secondary / muted text color (dark: lavender mist, light: faded brown).
  final Color secondaryText;

  /// Card background color.
  final Color cardColor;

  /// Card variant / elevated card color.
  final Color cardVariant;

  /// Surface color (slightly elevated from background).
  final Color surfaceColor;

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
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ColorTokens.darkBackground,
        ColorTokens.darkSurface,
        ColorTokens.darkCard,
      ],
    ),
    primaryAccent: ColorTokens.goldAccent,
    primaryText: ColorTokens.parchment,
    secondaryText: ColorTokens.mutedText,
    cardColor: ColorTokens.darkCard,
    cardVariant: ColorTokens.darkCardVariant,
    surfaceColor: ColorTokens.darkSurface,
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
    backgroundGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        ColorTokens.lightBackground,
        ColorTokens.lightSurface,
      ],
    ),
    primaryAccent: ColorTokens.lightPrimary,
    primaryText: ColorTokens.lightOnSurface,
    secondaryText: ColorTokens.lightOnSurfaceVariant,
    cardColor: ColorTokens.lightCard,
    cardVariant: ColorTokens.lightSurface,
    surfaceColor: ColorTokens.lightSurface,
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
    LinearGradient? backgroundGradient,
    Color? primaryAccent,
    Color? primaryText,
    Color? secondaryText,
    Color? cardColor,
    Color? cardVariant,
    Color? surfaceColor,
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
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      cardColor: cardColor ?? this.cardColor,
      cardVariant: cardVariant ?? this.cardVariant,
      surfaceColor: surfaceColor ?? this.surfaceColor,
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
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      cardVariant: Color.lerp(cardVariant, other.cardVariant, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
    );
  }
}

/// Convenience extension on [ThemeData] for quick access.
extension StoryScoreThemeExtensionAccess on ThemeData {
  StoryScoreThemeExtension get storyScore =>
      extension<StoryScoreThemeExtension>()!;
}
