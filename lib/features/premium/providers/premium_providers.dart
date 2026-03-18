import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';

/// Product identifier for the one-time supporter pack purchase.
const kSupporterPackProductId = 'storyscore_supporter';

/// Watches the supporter-pack [PurchaseEntitlement] row from the database.
///
/// Returns `null` when no purchase record exists.
final purchaseEntitlementProvider = StreamProvider<PurchaseEntitlement?>((ref) {
  final purchaseDao = ref.watch(purchaseDaoProvider);
  return purchaseDao.watchEntitlement(kSupporterPackProductId);
});

/// Derived convenience provider: `true` when the supporter pack is active.
final isSupporterProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(purchaseEntitlementProvider).value;
  return entitlement?.isActive ?? false;
});

/// Triggers the supporter-pack purchase flow.
///
/// In debug mode this simulates a purchase by writing directly to the local
/// database. Will be replaced with RevenueCat integration for production.
/// Returns a user-facing message describing the outcome.
final purchaseSupporterPackProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  // Simulate purchase by writing to local DB
  final dao = ref.read(purchaseDaoProvider);
  await dao.upsertEntitlement(
    PurchaseEntitlementsCompanion.insert(
      productId: 'storyscore_supporter',
      entitlementType: 'supporter_pack',
      isActive: const Value(true),
      sourceStore: const Value('debug'),
      purchasedAt: Value(DateTime.now()),
    ),
  );
  return 'Supporter Pack activated! (Debug mode)';
});

/// Triggers the restore-purchases flow.
///
/// In debug mode this checks the local DB for an existing entitlement.
/// Will be replaced with RevenueCat restore flow for production.
/// Returns a user-facing message describing the outcome.
final restorePurchasesProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final dao = ref.read(purchaseDaoProvider);
  final stream = dao.watchEntitlement(kSupporterPackProductId);
  final entitlement = await stream.first;
  if (entitlement != null && entitlement.isActive) {
    return 'Supporter Pack is already active!';
  }
  return 'No previous purchase found. (Debug mode)';
});

/// Clears the supporter-pack purchase for testing purposes.
///
/// Sets the entitlement to inactive so the user can toggle back to the
/// free state during development.
final clearPurchaseProvider = FutureProvider.autoDispose<String>((ref) async {
  final dao = ref.read(purchaseDaoProvider);
  await dao.upsertEntitlement(
    PurchaseEntitlementsCompanion.insert(
      productId: 'storyscore_supporter',
      entitlementType: 'supporter_pack',
      isActive: const Value(false),
    ),
  );
  return 'Purchase cleared (Debug mode)';
});
