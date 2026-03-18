import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/player_presets.dart';
import '../tables/preset_players.dart';

part 'preset_dao.g.dart';

@DriftAccessor(tables: [PlayerPresets, PresetPlayers])
class PresetDao extends DatabaseAccessor<AppDatabase> with _$PresetDaoMixin {
  PresetDao(super.db);

  static const maxPresets = 20;
  static const minPlayersPerPreset = 3;
  static const maxPlayersPerPreset = 10;

  /// Watches all presets ordered by most recently updated.
  Stream<List<PlayerPreset>> watchAllPresets() {
    return (select(
      playerPresets,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  /// Watches players for a specific preset, ordered by seat order.
  Stream<List<PresetPlayer>> watchPlayersForPreset(String presetId) {
    return (select(presetPlayers)
          ..where((t) => t.presetId.equals(presetId))
          ..orderBy([(t) => OrderingTerm.asc(t.seatOrder)]))
        .watch();
  }

  /// Gets favorites deduplicated by normalized name, max 10.
  Future<List<PresetPlayer>> getFavorites() async {
    final all = await (select(
      presetPlayers,
    )..where((t) => t.isFavorite.equals(true))).get();
    // Deduplicate by normalized name (case-insensitive, trimmed)
    final seen = <String>{};
    final deduped = <PresetPlayer>[];
    for (final p in all) {
      final key = p.name.trim().toLowerCase();
      if (seen.add(key) && deduped.length < 10) {
        deduped.add(p);
      }
    }
    return deduped;
  }

  /// Returns the total number of presets.
  Future<int> getPresetCount() async {
    final count = countAll();
    final query = selectOnly(playerPresets)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Creates a preset with its players in a transaction.
  /// Enforces max [maxPresets] presets and
  /// [minPlayersPerPreset]-[maxPlayersPerPreset] players per preset.
  Future<void> createPreset({
    required String id,
    required String name,
    required List<PresetPlayersCompanion> players,
  }) async {
    final count = await getPresetCount();
    if (count >= maxPresets) {
      throw StateError('Maximum $maxPresets presets reached');
    }
    if (players.length < minPlayersPerPreset ||
        players.length > maxPlayersPerPreset) {
      throw ArgumentError(
        'Preset must have $minPlayersPerPreset-$maxPlayersPerPreset players',
      );
    }
    return transaction(() async {
      await into(
        playerPresets,
      ).insert(PlayerPresetsCompanion.insert(id: id, name: name));
      for (final player in players) {
        await into(presetPlayers).insert(player);
      }
    });
  }

  /// Deletes a preset and all its players.
  Future<void> deletePreset(String id) {
    return transaction(() async {
      await (delete(presetPlayers)..where((t) => t.presetId.equals(id))).go();
      await (delete(playerPresets)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Renames a preset.
  Future<void> updatePresetName(String id, String name) {
    return (update(playerPresets)..where((t) => t.id.equals(id))).write(
      PlayerPresetsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks a preset as recently used.
  Future<void> markUsed(String id) {
    return (update(playerPresets)..where((t) => t.id.equals(id))).write(
      PlayerPresetsCompanion(
        lastUsedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggles the favorite flag on a preset player.
  Future<void> toggleFavorite(String playerId, bool isFav) {
    return (update(presetPlayers)..where((t) => t.id.equals(playerId))).write(
      PresetPlayersCompanion(isFavorite: Value(isFav)),
    );
  }
}
