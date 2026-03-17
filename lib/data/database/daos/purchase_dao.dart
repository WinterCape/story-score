import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/purchase_entitlements.dart';

part 'purchase_dao.g.dart';

@DriftAccessor(tables: [PurchaseEntitlements])
class PurchaseDao extends DatabaseAccessor<AppDatabase>
    with _$PurchaseDaoMixin {
  PurchaseDao(super.db);

  /// Watches a single entitlement by [productId].
  Stream<PurchaseEntitlement?> watchEntitlement(String productId) {
    return (select(purchaseEntitlements)
          ..where((e) => e.productId.equals(productId)))
        .watchSingleOrNull();
  }

  /// Inserts or updates an entitlement row.
  Future<void> upsertEntitlement(
      PurchaseEntitlementsCompanion entitlement) async {
    await into(purchaseEntitlements).insertOnConflictUpdate(entitlement);
  }
}
