import 'package:flutter/material.dart';

/// Animation duration and curve constants for StoryScore.
abstract final class MotionTokens {
  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// Micro interactions (button press feedback, checkbox toggle).
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Standard transitions (card expand, bottom-sheet slide).
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// Emphasis transitions (page transitions, large layout shifts).
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// Dramatic / celebratory animations (confetti, score milestone).
  static const Duration durationEmphasis = Duration(milliseconds: 800);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------

  /// Default ease-in-out for most transitions.
  static const Curve curveStandard = Curves.easeInOut;

  /// Deceleration curve — elements entering the screen.
  static const Curve curveDecelerate = Curves.easeOut;

  /// Acceleration curve — elements leaving the screen.
  static const Curve curveAccelerate = Curves.easeIn;

  /// Emphasized ease for larger or more dramatic motion.
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  /// Bounce effect for playful feedback (e.g. score increment).
  static const Curve curveBounce = Curves.elasticOut;

  /// Spring-like overshoot for snappy interactions.
  static const Curve curveSpring = Curves.easeOutBack;
}
