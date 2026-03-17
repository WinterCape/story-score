import 'package:drift/drift.dart';

import 'game_sessions.dart';
import 'players.dart';

class Rounds extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(GameSessions, #id)();
  IntColumn get roundNumber => integer()();
  TextColumn get storytellerPlayerId => text().references(Players, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get editedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
