import 'package:drift/drift.dart';

import 'player_presets.dart';

class PresetPlayers extends Table {
  TextColumn get id => text()();
  TextColumn get presetId => text().references(PlayerPresets, #id)();
  TextColumn get name => text()();
  TextColumn get colorKey => text()();
  TextColumn get avatarStyle =>
      text().withDefault(const Constant('initials'))();
  IntColumn get seatOrder => integer()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
