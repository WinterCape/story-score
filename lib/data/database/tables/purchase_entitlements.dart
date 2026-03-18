import 'package:drift/drift.dart';

class PurchaseEntitlements extends Table {
  TextColumn get productId => text()();
  TextColumn get entitlementType => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  TextColumn get sourceStore => text().nullable()();
  DateTimeColumn get purchasedAt => dateTime().nullable()();
  DateTimeColumn get restoredAt => dateTime().nullable()();
  DateTimeColumn get lastValidatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {productId};
}
