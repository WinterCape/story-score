// Pure Dart celebration engine.
//
// Determines which celebration effects to play based on game events,
// supporter status, theme selection, and accessibility settings.
// Zero Flutter imports, zero side effects.
import 'package:story_score/domain/stats/milestone_detector.dart';

import 'celebration_models.dart';

/// Computes which celebration effects to play.
///
/// All methods are static and pure — no side effects.
abstract final class CelebrationEngine {
  /// Computes effects for a winner reveal event.
  ///
  /// [isSupporter] gates premium effects (confetti, sparkle, glow, sound).
  /// [selectedTheme] determines particle visuals.
  /// [isReducedMotion] suppresses particle effects but keeps sound.
  /// [milestones] are always included regardless of supporter status.
  static CelebrationResult computeWinnerEffects({
    required bool isSupporter,
    required String selectedTheme,
    required bool isReducedMotion,
    List<MilestoneResult> milestones = const [],
  }) {
    final effects = <CelebrationEffect>[];

    if (isSupporter) {
      if (!isReducedMotion) {
        effects.add(CelebrationEffect.confettiRain);
        effects.add(CelebrationEffect.sparkleBurst);
        effects.add(CelebrationEffect.winnerGlow);
      }
      effects.add(CelebrationEffect.celebrationSound);
    }

    // Milestones are always shown (premium celebration effects are gated,
    // but the toast itself is free)
    if (milestones.isNotEmpty) {
      effects.add(CelebrationEffect.milestoneToast);
      if (isSupporter) {
        effects.add(CelebrationEffect.milestoneChime);
      }
    }

    return CelebrationResult(
      effects: effects,
      particleTheme: _themeFromName(selectedTheme),
      milestones: milestones,
    );
  }

  /// Computes effects for a milestone event (mid-game, not winner reveal).
  ///
  /// Milestones toasts are shown to all users. Sound is supporter-only.
  static CelebrationResult computeMilestoneEffects({
    required bool isSupporter,
    required String selectedTheme,
    required bool isReducedMotion,
    required List<MilestoneResult> milestones,
  }) {
    if (milestones.isEmpty) {
      return CelebrationResult(
        effects: const [],
        particleTheme: _themeFromName(selectedTheme),
        milestones: const [],
      );
    }

    final effects = <CelebrationEffect>[CelebrationEffect.milestoneToast];

    if (isSupporter) {
      effects.add(CelebrationEffect.milestoneChime);
    }

    return CelebrationResult(
      effects: effects,
      particleTheme: _themeFromName(selectedTheme),
      milestones: milestones,
    );
  }

  /// Maps a theme name string to a [ParticleTheme].
  static ParticleTheme _themeFromName(String themeName) {
    return switch (themeName.toLowerCase()) {
      'ocean' => ParticleTheme.oceanBubbles,
      'ember' => ParticleTheme.emberSparks,
      'frost' => ParticleTheme.frostSnowflakes,
      'forest' => ParticleTheme.forestLeaves,
      _ => ParticleTheme.celestialStars, // default/celestial
    };
  }
}
