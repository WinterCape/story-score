import 'package:flutter/material.dart';

import 'package:story_score/data/database/tables/game_sessions.dart';

/// Sort order preference for the player list on the scoreboard.
enum PlayerSortOrder { seat, scoreDesc, scoreAsc, name }

/// Immutable settings model persisted via SharedPreferences.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.hapticsEnabled = true,
    this.reducedMotionOverride = false,
    this.defaultTargetMode = TargetType.score,
    this.showRoundNotes = true,
    this.preferredSortOrder = PlayerSortOrder.seat,
    this.selectedTheme = 'celestial',
    this.soundEffectsEnabled = false,
    this.locale,
  });

  final ThemeMode themeMode;
  final bool hapticsEnabled;
  final bool reducedMotionOverride;
  final TargetType defaultTargetMode;
  final bool showRoundNotes;
  final PlayerSortOrder preferredSortOrder;

  /// The selected color theme identifier (e.g. 'celestial', 'ocean_depths').
  final String selectedTheme;

  /// Whether sound effects are enabled for celebrations.
  /// Requires supporter status to take effect.
  final bool soundEffectsEnabled;

  /// The user-selected locale code (e.g. 'en', 'ro'), or null to follow
  /// the system locale.
  final String? locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? hapticsEnabled,
    bool? reducedMotionOverride,
    TargetType? defaultTargetMode,
    bool? showRoundNotes,
    PlayerSortOrder? preferredSortOrder,
    String? selectedTheme,
    bool? soundEffectsEnabled,
    String? Function()? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotionOverride:
          reducedMotionOverride ?? this.reducedMotionOverride,
      defaultTargetMode: defaultTargetMode ?? this.defaultTargetMode,
      showRoundNotes: showRoundNotes ?? this.showRoundNotes,
      preferredSortOrder: preferredSortOrder ?? this.preferredSortOrder,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      locale: locale != null ? locale() : this.locale,
    );
  }
}
