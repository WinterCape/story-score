import 'package:drift/drift.dart';

import 'game_sessions.dart';

class Players extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(GameSessions, #id)();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  IntColumn get seatOrder => integer()();
  TextColumn get colorKey => text()();
  TextColumn get avatarStyle =>
      text().withDefault(const Constant('initials'))();
  IntColumn get currentScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
