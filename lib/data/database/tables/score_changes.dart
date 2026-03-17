import 'package:drift/drift.dart';

import 'players.dart';
import 'rounds.dart';

class ScoreChanges extends Table {
  TextColumn get id => text()();
  TextColumn get roundId => text().references(Rounds, #id)();
  TextColumn get playerId => text().references(Players, #id)();
  IntColumn get delta => integer()();
  TextColumn get reasonCode => text()();
  TextColumn get reasonLabel => text()();

  @override
  Set<Column> get primaryKey => {id};
}
