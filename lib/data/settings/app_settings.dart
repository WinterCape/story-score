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
  });

  final ThemeMode themeMode;
  final bool hapticsEnabled;
  final bool reducedMotionOverride;
  final TargetType defaultTargetMode;
  final bool showRoundNotes;
  final PlayerSortOrder preferredSortOrder;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? hapticsEnabled,
    bool? reducedMotionOverride,
    TargetType? defaultTargetMode,
    bool? showRoundNotes,
    PlayerSortOrder? preferredSortOrder,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotionOverride:
          reducedMotionOverride ?? this.reducedMotionOverride,
      defaultTargetMode: defaultTargetMode ?? this.defaultTargetMode,
      showRoundNotes: showRoundNotes ?? this.showRoundNotes,
      preferredSortOrder: preferredSortOrder ?? this.preferredSortOrder,
    );
  }
}
