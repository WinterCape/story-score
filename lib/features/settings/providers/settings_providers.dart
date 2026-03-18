import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/settings/app_settings.dart';
import 'package:story_score/data/settings/app_settings_repository.dart';

/// Provides the [AppSettingsRepository] backed by SharedPreferences.
final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  // SharedPreferences instance is overridden in main.dart after
  // initialization, so this throws if accessed before override.
  throw UnimplementedError(
    'appSettingsRepositoryProvider must be overridden with a '
    'SharedPreferences instance at startup.',
  );
});

/// Async notifier that loads, caches, and updates [AppSettings].
final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
      AppSettingsNotifier.new,
    );

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    return repo.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setThemeMode(mode);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setHapticsEnabled(enabled);
    state = AsyncData(state.requireValue.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setReducedMotionOverride(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setReducedMotionOverride(enabled);
    state = AsyncData(
      state.requireValue.copyWith(reducedMotionOverride: enabled),
    );
  }

  Future<void> setDefaultTargetMode(TargetType type) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setDefaultTargetMode(type);
    state = AsyncData(state.requireValue.copyWith(defaultTargetMode: type));
  }

  Future<void> setShowRoundNotes(bool show) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setShowRoundNotes(show);
    state = AsyncData(state.requireValue.copyWith(showRoundNotes: show));
  }

  Future<void> setPreferredSortOrder(PlayerSortOrder order) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setPreferredSortOrder(order);
    state = AsyncData(state.requireValue.copyWith(preferredSortOrder: order));
  }

  Future<void> setSelectedTheme(String themeId) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setSelectedTheme(themeId);
    state = AsyncData(state.requireValue.copyWith(selectedTheme: themeId));
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setSoundEffectsEnabled(enabled);
    state = AsyncData(
      state.requireValue.copyWith(soundEffectsEnabled: enabled),
    );
  }

  Future<void> updateAll(AppSettings settings) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.save(settings);
    state = AsyncData(settings);
  }
}

/// Derived provider that exposes only the current [ThemeMode].
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).value?.themeMode ?? ThemeMode.system;
});

/// Derived provider that exposes the selected theme identifier.
final selectedThemeProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).value?.selectedTheme ?? 'celestial';
});
