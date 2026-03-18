import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/settings/app_settings.dart';

/// Reads and writes [AppSettings] to SharedPreferences.
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  // ── Key constants ────────────────────────────────────────────────────────

  static const _keyThemeMode = 'settings.themeMode';
  static const _keyHapticsEnabled = 'settings.hapticsEnabled';
  static const _keyReducedMotion = 'settings.reducedMotionOverride';
  static const _keyDefaultTargetMode = 'settings.defaultTargetMode';
  static const _keyShowRoundNotes = 'settings.showRoundNotes';
  static const _keyPreferredSortOrder = 'settings.preferredSortOrder';
  static const _keySelectedTheme = 'settings.selectedTheme';
  static const _keySoundEffectsEnabled = 'settings.soundEffectsEnabled';

  // ── Read ─────────────────────────────────────────────────────────────────

  AppSettings load() {
    return AppSettings(
      themeMode: _loadThemeMode(),
      hapticsEnabled: _prefs.getBool(_keyHapticsEnabled) ?? true,
      reducedMotionOverride: _prefs.getBool(_keyReducedMotion) ?? false,
      defaultTargetMode: _loadTargetType(),
      showRoundNotes: _prefs.getBool(_keyShowRoundNotes) ?? true,
      preferredSortOrder: _loadSortOrder(),
      selectedTheme: _prefs.getString(_keySelectedTheme) ?? 'celestial',
      soundEffectsEnabled: _prefs.getBool(_keySoundEffectsEnabled) ?? false,
    );
  }

  // ── Write (full) ─────────────────────────────────────────────────────────

  Future<void> save(AppSettings settings) async {
    await Future.wait([
      setThemeMode(settings.themeMode),
      setHapticsEnabled(settings.hapticsEnabled),
      setReducedMotionOverride(settings.reducedMotionOverride),
      setDefaultTargetMode(settings.defaultTargetMode),
      setShowRoundNotes(settings.showRoundNotes),
      setPreferredSortOrder(settings.preferredSortOrder),
      setSelectedTheme(settings.selectedTheme),
      setSoundEffectsEnabled(settings.soundEffectsEnabled),
    ]);
  }

  // ── Individual setters ───────────────────────────────────────────────────

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool(_keyHapticsEnabled, enabled);
  }

  Future<void> setReducedMotionOverride(bool enabled) async {
    await _prefs.setBool(_keyReducedMotion, enabled);
  }

  Future<void> setDefaultTargetMode(TargetType type) async {
    await _prefs.setInt(_keyDefaultTargetMode, type.index);
  }

  Future<void> setShowRoundNotes(bool show) async {
    await _prefs.setBool(_keyShowRoundNotes, show);
  }

  Future<void> setPreferredSortOrder(PlayerSortOrder order) async {
    await _prefs.setInt(_keyPreferredSortOrder, order.index);
  }

  Future<void> setSelectedTheme(String themeId) async {
    await _prefs.setString(_keySelectedTheme, themeId);
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    await _prefs.setBool(_keySoundEffectsEnabled, enabled);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  ThemeMode _loadThemeMode() {
    final index = _prefs.getInt(_keyThemeMode);
    if (index == null || index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  TargetType _loadTargetType() {
    final index = _prefs.getInt(_keyDefaultTargetMode);
    if (index == null || index < 0 || index >= TargetType.values.length) {
      return TargetType.score;
    }
    return TargetType.values[index];
  }

  PlayerSortOrder _loadSortOrder() {
    final index = _prefs.getInt(_keyPreferredSortOrder);
    if (index == null ||
        index < 0 ||
        index >= PlayerSortOrder.values.length) {
      return PlayerSortOrder.seat;
    }
    return PlayerSortOrder.values[index];
  }
}
