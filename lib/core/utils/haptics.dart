import 'package:flutter/services.dart';

/// Lightweight wrapper around [HapticFeedback] for consistent tactile
/// feedback throughout the app.
class Haptics {
  const Haptics._();

  /// Subtle tick — vote selection, color picks, toggle changes.
  static void selection() => HapticFeedback.selectionClick();

  /// Gentle bump — undo actions, minor confirmations.
  static void light() => HapticFeedback.lightImpact();

  /// Noticeable thud — round scored, export completed.
  static void medium() => HapticFeedback.mediumImpact();

  /// Strong pulse — game over / winner reveal.
  static void heavy() => HapticFeedback.heavyImpact();
}
