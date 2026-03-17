import 'package:drift/drift.dart';

import 'players.dart';
import 'rounds.dart';

class Votes extends Table {
  TextColumn get id => text()();
  TextColumn get roundId => text().references(Rounds, #id)();
  TextColumn get voterPlayerId => text().references(Players, #id)();
  TextColumn get votedForPlayerId => text().references(Players, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
