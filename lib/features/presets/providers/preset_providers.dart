import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:story_score/app/providers.dart';
import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/preset_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

/// Provides the [PresetDao].
final presetDaoProvider = Provider<PresetDao>((ref) {
  return ref.watch(appDatabaseProvider).presetDao;
});

/// Watches all presets ordered by most recently updated.
final presetsProvider = StreamProvider<List<PlayerPreset>>((ref) {
  return ref.watch(presetDaoProvider).watchAllPresets();
});

/// Watches players for a specific preset.
final presetPlayersProvider =
    StreamProvider.family<List<PresetPlayer>, String>((ref, presetId) {
  return ref.watch(presetDaoProvider).watchPlayersForPreset(presetId);
});

/// Fetches favorite players (deduplicated, max 10).
final favoritePlayersProvider = FutureProvider<List<PresetPlayer>>((ref) {
  return ref.watch(presetDaoProvider).getFavorites();
});

/// Returns the current number of saved presets.
final presetCountProvider = FutureProvider<int>((ref) {
  return ref.watch(presetDaoProvider).getPresetCount();
});

/// Saves a new preset with the given name and player list.
/// Returns the new preset ID.
Future<String> savePreset({
  required PresetDao dao,
  required String name,
  required List<({String name, String colorKey, String avatarStyle, int seatOrder})>
      players,
}) async {
  final presetId = IdGenerator.newId();
  final companions = players
      .map(
        (p) => PresetPlayersCompanion.insert(
          id: IdGenerator.newId(),
          presetId: presetId,
          name: p.name,
          colorKey: p.colorKey,
          avatarStyle: Value(p.avatarStyle),
          seatOrder: p.seatOrder,
        ),
      )
      .toList();

  await dao.createPreset(id: presetId, name: name, players: companions);
  return presetId;
}

/// Quick Start: creates a game from a preset with default 30 target score.
/// Returns the new session ID.
Future<String> quickStart({
  required PresetDao presetDao,
  required SessionDao sessionDao,
  required String presetId,
}) async {
  final players = await presetDao.watchPlayersForPreset(presetId).first;
  if (players.length < 3) {
    throw StateError('Preset has fewer than 3 players');
  }

  final sessionId = IdGenerator.newId();
  await sessionDao.createSession(
    GameSessionsCompanion.insert(
      id: sessionId,
      status: GameStatus.active,
      targetType: TargetType.score,
      targetScore: const Value(30),
    ),
    players
        .map(
          (p) => PlayersCompanion.insert(
            id: IdGenerator.newId(),
            sessionId: sessionId,
            name: p.name,
            seatOrder: p.seatOrder,
            colorKey: p.colorKey,
            avatarStyle: Value(p.avatarStyle),
          ),
        )
        .toList(),
  );

  await presetDao.markUsed(presetId);
  return sessionId;
}
