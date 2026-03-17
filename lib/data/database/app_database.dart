import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/purchase_dao.dart';
import 'daos/round_dao.dart';
import 'daos/session_dao.dart';
import 'tables/game_sessions.dart';
import 'tables/players.dart';
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
  ],
  daos: [SessionDao, RoundDao, PurchaseDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'story_score_v1');
  }
}
