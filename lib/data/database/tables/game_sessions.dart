import 'package:drift/drift.dart';

enum GameStatus { active, paused, completed }

enum TargetType { score, rounds, freeplay }

class GameSessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get status => intEnum<GameStatus>()();
  IntColumn get targetType => intEnum<TargetType>()();
  IntColumn get targetScore => integer().nullable()();
  BoolColumn get continuePastTargetEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get currentStorytellerSeat =>
      integer().withDefault(const Constant(0))();
  IntColumn get roundCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
