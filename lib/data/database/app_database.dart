import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/preset_dao.dart';
import 'daos/purchase_dao.dart';
import 'daos/round_dao.dart';
import 'daos/session_dao.dart';
import 'tables/game_sessions.dart';
import 'tables/player_presets.dart';
import 'tables/players.dart';
import 'tables/preset_players.dart';
import 'tables/purchase_entitlements.dart';
import 'tables/rounds.dart';
import 'tables/score_changes.dart';
import 'tables/votes.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    GameSessions,
    Players,
    Rounds,
    Votes,
    ScoreChanges,
    PurchaseEntitlements,
    PlayerPresets,
    PresetPlayers,
  ],
  daos: [SessionDao, RoundDao, PurchaseDao, PresetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(playerPresets);
        await m.createTable(presetPlayers);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'story_score_v1');
  }
}
