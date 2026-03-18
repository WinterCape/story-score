import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/domain/celebrations/celebration_engine.dart';
import 'package:story_score/domain/celebrations/celebration_models.dart';
import 'package:story_score/domain/stats/milestone_detector.dart';

void main() {
  group('computeWinnerEffects', () {
    test('supporter + winner reveal produces confetti, sparkle, glow, sound', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: false,
      );

      expect(result.effects, contains(CelebrationEffect.confettiRain));
      expect(result.effects, contains(CelebrationEffect.sparkleBurst));
      expect(result.effects, contains(CelebrationEffect.winnerGlow));
      expect(result.effects, contains(CelebrationEffect.celebrationSound));
    });

    test('free user + winner reveal produces no premium effects', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: false,
        selectedTheme: 'celestial',
        isReducedMotion: false,
      );

      expect(result.effects, isNot(contains(CelebrationEffect.confettiRain)));
      expect(result.effects, isNot(contains(CelebrationEffect.sparkleBurst)));
      expect(result.effects, isNot(contains(CelebrationEffect.winnerGlow)));
      expect(result.effects, isNot(contains(CelebrationEffect.celebrationSound)));
    });

    test('supporter + milestone produces toast and chime', () {
      final milestones = [
        const MilestoneResult(
          milestone: Milestone.onFire,
          playerId: 'alice',
          playerName: 'Alice',
        ),
      ];

      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: false,
        milestones: milestones,
      );

      expect(result.effects, contains(CelebrationEffect.milestoneToast));
      expect(result.effects, contains(CelebrationEffect.milestoneChime));
      expect(result.milestones, equals(milestones));
    });

    test('free user + milestone produces toast but no chime', () {
      final milestones = [
        const MilestoneResult(
          milestone: Milestone.firstCorrectGuess,
          playerId: 'bob',
          playerName: 'Bob',
        ),
      ];

      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: false,
        selectedTheme: 'celestial',
        isReducedMotion: false,
        milestones: milestones,
      );

      expect(result.effects, contains(CelebrationEffect.milestoneToast));
      expect(result.effects, isNot(contains(CelebrationEffect.milestoneChime)));
    });

    test('reduced motion suppresses particle effects but keeps sound', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: true,
      );

      expect(result.effects, isNot(contains(CelebrationEffect.confettiRain)));
      expect(result.effects, isNot(contains(CelebrationEffect.sparkleBurst)));
      expect(result.effects, isNot(contains(CelebrationEffect.winnerGlow)));
      expect(result.effects, contains(CelebrationEffect.celebrationSound));
    });

    test('reduced motion + milestone still includes toast and chime', () {
      final milestones = [
        const MilestoneResult(
          milestone: Milestone.masterStoryteller,
          playerId: 'carol',
          playerName: 'Carol',
        ),
      ];

      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: true,
        milestones: milestones,
      );

      expect(result.effects, contains(CelebrationEffect.milestoneToast));
      expect(result.effects, contains(CelebrationEffect.milestoneChime));
      expect(result.effects, contains(CelebrationEffect.celebrationSound));
    });
  });

  group('theme-specific particles', () {
    test('ocean theme selects oceanBubbles', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'ocean',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.oceanBubbles));
    });

    test('ember theme selects emberSparks', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'ember',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.emberSparks));
    });

    test('frost theme selects frostSnowflakes', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'frost',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.frostSnowflakes));
    });

    test('forest theme selects forestLeaves', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'forest',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.forestLeaves));
    });

    test('celestial theme selects celestialStars', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.celestialStars));
    });

    test('unknown theme defaults to celestialStars', () {
      final result = CelebrationEngine.computeWinnerEffects(
        isSupporter: true,
        selectedTheme: 'unknown_theme',
        isReducedMotion: false,
      );
      expect(result.particleTheme, equals(ParticleTheme.celestialStars));
    });
  });

  group('computeMilestoneEffects', () {
    test('empty milestones produces no effects', () {
      final result = CelebrationEngine.computeMilestoneEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: false,
        milestones: [],
      );

      expect(result.effects, isEmpty);
      expect(result.milestones, isEmpty);
      expect(result.hasEffects, isFalse);
      expect(result.hasMilestones, isFalse);
    });

    test('multiple milestones are all included in result', () {
      final milestones = [
        const MilestoneResult(
          milestone: Milestone.onFire,
          playerId: 'alice',
          playerName: 'Alice',
        ),
        const MilestoneResult(
          milestone: Milestone.trickster,
          playerId: 'bob',
          playerName: 'Bob',
        ),
      ];

      final result = CelebrationEngine.computeMilestoneEffects(
        isSupporter: true,
        selectedTheme: 'celestial',
        isReducedMotion: false,
        milestones: milestones,
      );

      expect(result.milestones.length, equals(2));
      expect(result.hasMilestones, isTrue);
      expect(result.effects, contains(CelebrationEffect.milestoneToast));
      expect(result.effects, contains(CelebrationEffect.milestoneChime));
    });

    test('free user milestone produces toast but no chime', () {
      final milestones = [
        const MilestoneResult(
          milestone: Milestone.firstCorrectGuess,
          playerId: 'alice',
          playerName: 'Alice',
        ),
      ];

      final result = CelebrationEngine.computeMilestoneEffects(
        isSupporter: false,
        selectedTheme: 'celestial',
        isReducedMotion: false,
        milestones: milestones,
      );

      expect(result.effects, contains(CelebrationEffect.milestoneToast));
      expect(result.effects, isNot(contains(CelebrationEffect.milestoneChime)));
    });
  });
}
