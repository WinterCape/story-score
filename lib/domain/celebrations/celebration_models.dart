// Pure Dart celebration models.
//
// Zero Flutter imports. These describe which effects the UI layer
// should play, without containing any rendering logic.
import 'package:story_score/domain/stats/milestone_detector.dart';

/// Visual and audio effects that can be played during celebrations.
enum CelebrationEffect {
  /// Full-screen confetti rain particle effect.
  confettiRain,

  /// Burst of sparkles around the winner.
  sparkleBurst,

  /// Animated glow border on the winner's score card.
  winnerGlow,

  /// Animated toast banner showing a milestone achievement.
  milestoneToast,

  /// Fanfare sound for winner reveal.
  celebrationSound,

  /// Short chime for milestone achievements.
  milestoneChime,
}

/// Theme-specific particle visuals for confetti and sparkle effects.
enum ParticleTheme {
  /// Gold and white star-shaped particles falling.
  celestialStars,

  /// Blue circle particles rising like bubbles.
  oceanBubbles,

  /// Orange and red small dots floating upward.
  emberSparks,

  /// White hexagonal particles falling slowly.
  frostSnowflakes,

  /// Green and amber leaf shapes drifting down.
  forestLeaves,
}

/// The result of the celebration engine describing which effects to play.
class CelebrationResult {
  /// The visual and audio effects to trigger.
  final List<CelebrationEffect> effects;

  /// The particle theme for confetti/sparkle effects.
  final ParticleTheme particleTheme;

  /// Milestones detected in this round, if any.
  final List<MilestoneResult> milestones;

  const CelebrationResult({
    required this.effects,
    required this.particleTheme,
    required this.milestones,
  });

  /// Whether any effects should be played.
  bool get hasEffects => effects.isNotEmpty;

  /// Whether any milestones were detected.
  bool get hasMilestones => milestones.isNotEmpty;
}
