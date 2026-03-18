import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/domain/celebrations/celebration_models.dart';
import 'package:story_score/domain/stats/milestone_detector.dart';
import 'package:story_score/features/celebrations/widgets/confetti_overlay.dart';
import 'package:story_score/features/celebrations/widgets/milestone_toast.dart';

/// Orchestrates visual and audio celebration effects.
///
/// Reads a [CelebrationResult] from the domain engine and triggers
/// the appropriate overlay entries, sounds, and haptics.
class CelebrationController {
  CelebrationController({
    required this.overlayState,
    required this.isReducedMotion,
    required this.isSoundEnabled,
  });

  /// The overlay state to insert confetti and toast entries into.
  final OverlayState overlayState;

  /// Whether the user prefers reduced motion.
  final bool isReducedMotion;

  /// Whether sound effects are enabled (requires supporter status).
  final bool isSoundEnabled;

  OverlayEntry? _confettiEntry;
  MilestoneToastQueue? _toastQueue;
  AudioPlayer? _audioPlayer;

  /// Plays the effects described by [result].
  void play(CelebrationResult result) {
    if (!result.hasEffects) return;

    // Haptic feedback for any celebration
    Haptics.heavy();

    // Confetti overlay — skipped if reduced motion
    if (!isReducedMotion &&
        result.effects.contains(CelebrationEffect.confettiRain)) {
      _showConfetti(result.particleTheme);
    }

    // Milestone toasts — always shown, adapts internally to reduced motion
    if (result.effects.contains(CelebrationEffect.milestoneToast) &&
        result.hasMilestones) {
      _showMilestoneToasts(result.milestones);
    }

    // Audio — not affected by reduced motion
    if (isSoundEnabled) {
      if (result.effects.contains(CelebrationEffect.celebrationSound)) {
        _playSound('assets/sounds/celebration.mp3');
      } else if (result.effects.contains(CelebrationEffect.milestoneChime)) {
        _playSound('assets/sounds/chime.mp3');
      }
    }
  }

  void _showConfetti(ParticleTheme theme) {
    _confettiEntry?.remove();

    _confettiEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: ConfettiOverlay(
          particleTheme: theme,
          onComplete: () {
            _confettiEntry?.remove();
            _confettiEntry = null;
          },
        ),
      ),
    );

    overlayState.insert(_confettiEntry!);
  }

  void _showMilestoneToasts(List<MilestoneResult> milestones) {
    _toastQueue?.dispose();
    _toastQueue = MilestoneToastQueue(
      overlayState: overlayState,
      reducedMotion: isReducedMotion,
    );
    _toastQueue!.showMilestones(milestones);
  }

  Future<void> _playSound(String assetPath) async {
    try {
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.play(AssetSource(assetPath));
    } catch (_) {
      // Audio playback failures are non-critical; silently ignore.
    }
  }

  /// Cleans up any active overlays and audio resources.
  void dispose() {
    _confettiEntry?.remove();
    _confettiEntry = null;
    _toastQueue?.dispose();
    _toastQueue = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }
}
