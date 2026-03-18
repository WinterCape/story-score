import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/purchases/revenuecat_service.dart';

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
///
/// Reads from the local DB cache so it works offline.
final isSupporterProvider = Provider<bool>((ref) {
  final entitlement = ref.watch(purchaseEntitlementProvider).value;
  return entitlement?.isActive ?? false;
});

/// Fetches the supporter pack price string from the store via RevenueCat.
///
/// Returns the localized price (e.g. "\$3.99", "\u20AC3,49") or `null` when
/// the store is unreachable.
final supporterPackPriceProvider = FutureProvider<String?>((ref) async {
  return RevenueCatService.getSupporterPackPrice();
});

/// Syncs the RevenueCat entitlement status with the local DB cache.
///
/// Call once on app start (or whenever the app returns to foreground) to
/// ensure the local cache reflects the latest server-side state.
final syncEntitlementProvider = FutureProvider<void>((ref) async {
  final isActive = await RevenueCatService.isSupporter();
  final dao = ref.read(purchaseDaoProvider);
  await dao.upsertEntitlement(
    PurchaseEntitlementsCompanion.insert(
      productId: kSupporterPackProductId,
      entitlementType: 'supporter_pack',
      isActive: Value(isActive),
      sourceStore: const Value('revenuecat'),
      purchasedAt: isActive ? Value(DateTime.now()) : const Value.absent(),
    ),
  );
});

/// Triggers the supporter-pack purchase flow via RevenueCat.
///
/// On success, also writes to the local DB cache so the entitlement is
/// available offline immediately.
/// Returns a user-facing message describing the outcome.
final purchaseSupporterPackProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final result = await RevenueCatService.purchaseSupporterPack();

  if (result.success) {
    // Write to local DB cache
    final dao = ref.read(purchaseDaoProvider);
    await dao.upsertEntitlement(
      PurchaseEntitlementsCompanion.insert(
        productId: kSupporterPackProductId,
        entitlementType: 'supporter_pack',
        isActive: const Value(true),
        sourceStore: const Value('revenuecat'),
        purchasedAt: Value(DateTime.now()),
      ),
    );
  }

  return result.message;
});

/// Triggers the restore-purchases flow via RevenueCat.
///
/// On success, also writes to the local DB cache so the entitlement is
/// available offline immediately.
/// Returns a user-facing message describing the outcome.
final restorePurchasesProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final result = await RevenueCatService.restorePurchases();

  if (result.restored) {
    // Write to local DB cache
    final dao = ref.read(purchaseDaoProvider);
    await dao.upsertEntitlement(
      PurchaseEntitlementsCompanion.insert(
        productId: kSupporterPackProductId,
        entitlementType: 'supporter_pack',
        isActive: const Value(true),
        sourceStore: const Value('revenuecat'),
        purchasedAt: Value(DateTime.now()),
      ),
    );
  }

  return result.message;
});

/// Clears the supporter-pack purchase for testing purposes.
///
/// Only available in debug builds. Sets the entitlement to inactive so the
/// user can toggle back to the free state during development.
final clearPurchaseProvider = FutureProvider.autoDispose<String>((ref) async {
  if (!kDebugMode) {
    return 'Clear is only available in debug builds.';
  }

  final dao = ref.read(purchaseDaoProvider);
  await dao.upsertEntitlement(
    PurchaseEntitlementsCompanion.insert(
      productId: kSupporterPackProductId,
      entitlementType: 'supporter_pack',
      isActive: const Value(false),
    ),
  );
  return 'Purchase cleared (Debug mode)';
});
