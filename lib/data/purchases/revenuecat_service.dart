import 'package:purchases_flutter/purchases_flutter.dart';

/// Configuration constants for RevenueCat integration.
abstract final class RevenueCatConfig {
  // Replace with real key from RevenueCat dashboard
  static const googleApiKey = 'YOUR_REVENUECAT_GOOGLE_API_KEY';
  // static const appleApiKey = 'YOUR_REVENUECAT_APPLE_API_KEY'; // Add later for iOS

  static const entitlementId = 'supporter';
  static const supporterPackageId =
      r'$rc_lifetime'; // RevenueCat lifetime package
}

/// Thin wrapper around the RevenueCat (purchases_flutter) SDK.
///
/// All methods are static so the service is stateless; the SDK itself
/// holds session state internally.
class RevenueCatService {
  /// Initialize RevenueCat SDK. Call once at app start.
  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug); // Remove in production
    final configuration = PurchasesConfiguration(RevenueCatConfig.googleApiKey);
    await Purchases.configure(configuration);
  }

  /// Check if user has active supporter entitlement.
  static Future<bool> isSupporter() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo
              .entitlements
              .all[RevenueCatConfig.entitlementId]
              ?.isActive ??
          false;
    } catch (_) {
      return false; // Fall back to local cache on error
    }
  }

  /// Get the current offering (contains price info).
  static Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (_) {
      return null;
    }
  }

  /// Purchase the supporter pack. Returns true on success.
  static Future<({bool success, String message})>
  purchaseSupporterPack() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package =
          offerings.current?.lifetime ??
          offerings.current?.availablePackages.firstOrNull;
      if (package == null) {
        return (
          success: false,
          message: 'Product not available. Please try again later.',
        );
      }
      final result = await Purchases.purchase(PurchaseParams.package(package));
      final isActive =
          result
              .customerInfo
              .entitlements
              .all[RevenueCatConfig.entitlementId]
              ?.isActive ??
          false;
      if (isActive) {
        return (success: true, message: 'Thank you! Supporter Pack activated.');
      }
      return (
        success: false,
        message: 'Purchase could not be verified. Please try restoring.',
      );
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return (success: false, message: 'Purchase cancelled.');
      }
      return (success: false, message: 'Purchase failed. Please try again.');
    } catch (_) {
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Restore previous purchases.
  static Future<({bool restored, String message})> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive =
          customerInfo
              .entitlements
              .all[RevenueCatConfig.entitlementId]
              ?.isActive ??
          false;
      if (isActive) {
        return (
          restored: true,
          message: 'Supporter Pack restored successfully!',
        );
      }
      return (restored: false, message: 'No previous purchase found.');
    } catch (_) {
      return (
        restored: false,
        message: 'Could not restore purchases. Please try again.',
      );
    }
  }

  /// Get formatted price string from the store (e.g., "\$1.99", "\u20AC1.99").
  static Future<String?> getSupporterPackPrice() async {
    try {
      final offerings = await Purchases.getOfferings();
      final package =
          offerings.current?.lifetime ??
          offerings.current?.availablePackages.firstOrNull;
      return package?.storeProduct.priceString;
    } catch (_) {
      return null;
    }
  }
}
