import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';

/// Product identifier for the one-time supporter pack purchase.
const kSupporterPackProductId = 'supporter_pack';

/// Watches the supporter-pack [PurchaseEntitlement] row from the database.
///
/// Returns `null` when no purchase record exists.
final purchaseEntitlementProvider =
    StreamProvider<PurchaseEntitlement?>((ref) {
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
/// Currently a placeholder that will be replaced with RevenueCat integration.
/// Returns a user-facing message describing the outcome.
final purchaseSupporterPackProvider =
    FutureProvider.autoDispose<String>((ref) async {
  // TODO: Replace with RevenueCat purchase flow.
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Coming soon \u2014 purchase will be available on the App Store / Play Store';
});

/// Triggers the restore-purchases flow.
///
/// Currently a placeholder that will be replaced with RevenueCat integration.
/// Returns a user-facing message describing the outcome.
final restorePurchasesProvider =
    FutureProvider.autoDispose<String>((ref) async {
  // TODO: Replace with RevenueCat restore flow.
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return 'Coming soon \u2014 purchase will be available on the App Store / Play Store';
});
