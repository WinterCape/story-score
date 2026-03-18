import 'dart:ui' show Brightness;

/// Centralized asset paths for all design assets used throughout the app.
abstract final class AppAssets {
  // Illustrations
  static const onboarding1 = 'assets/images/illustrations/onboarding_1.png';
  static const onboarding2 = 'assets/images/illustrations/onboarding_2.png';
  static const onboarding3 = 'assets/images/illustrations/onboarding_3.png';
  static const emptyNoGames = 'assets/images/illustrations/empty_no_games.png';
  static const emptyNoStats = 'assets/images/illustrations/empty_no_stats.png';
  static const emptyNoPresets =
      'assets/images/illustrations/empty_no_presets.png';
  static const premiumHero = 'assets/images/illustrations/premium_hero.png';
  static const supporterBadge =
      'assets/images/illustrations/supporter_badge.png';

  // Decorative
  static const dividerOrnate = 'assets/images/decorative/divider_ornate.png';
  static const cardFrame = 'assets/images/decorative/card_frame.png';
  static const cardFrameSmall =
      'assets/images/decorative/card_frame_small.png';
  static const crownBadge = 'assets/images/decorative/crown_badge.png';
  static const trophyBadge = 'assets/images/decorative/trophy_badge.png';
  static const cornerFlourish =
      'assets/images/decorative/corner_flourish.png';
  static const lockBadge = 'assets/images/decorative/lock_badge.png';
  static String sparkle(int n) => 'assets/images/decorative/sparkle_$n.png';

  // States
  static const stateActive = 'assets/images/states/state_active.png';
  static const statePaused = 'assets/images/states/state_paused.png';
  static const stateCompleted = 'assets/images/states/state_completed.png';
  static const clueGood = 'assets/images/states/clue_good.png';
  static const clueBad = 'assets/images/states/clue_bad.png';

  // Premium
  static const premiumThemes = 'assets/images/premium/premium_themes.png';
  static const premiumCelebrations =
      'assets/images/premium/premium_celebrations.png';
  static const premiumPresets = 'assets/images/premium/premium_presets.png';
  static const premiumStats = 'assets/images/premium/premium_stats.png';
  static const premiumSupport = 'assets/images/premium/premium_support.png';

  // Textures
  static const bgTextureDark = 'assets/images/textures/bg_texture_dark.png';
  static const bgTextureLight = 'assets/images/textures/bg_texture_light.png';

  // Splash
  static const splashBackground = 'assets/images/splash_background.png';

  // Custom icons (use dark/light based on theme)
  static String icon(String name, Brightness brightness) =>
      'assets/images/icons/${brightness == Brightness.dark ? 'dark' : 'light'}/ic_$name.png';
}
