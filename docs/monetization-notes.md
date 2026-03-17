# StoryScore Monetization Notes

## Chosen Model

**Free + Supporter Pack (one-time IAP, $3.99 USD)**

The core game experience is fully free with no ads and no usage limits. The Supporter Pack is a single non-consumable purchase that unlocks premium features and supports development.

## Free vs. Premium Feature Matrix

| Feature | Free | Supporter Pack |
|---|---|---|
| Unlimited games and players | Yes | Yes |
| Automatic scoring | Yes | Yes |
| Round history + vote breakdown | Yes | Yes |
| Live leaderboard | Yes | Yes |
| Undo / edit rounds | Yes | Yes |
| Dark theme | Yes | Yes |
| Light theme | Yes | Yes |
| Game export (JSON) | -- | Yes |
| Game sharing | -- | Yes |
| Additional theme palettes | -- | Yes |
| Custom player avatars | -- | Yes |
| Session statistics / insights | -- | Yes |
| Priority feature requests | -- | Yes |

## Pricing Rationale

- **$3.99** is the sweet spot for utility apps in the Games category -- high enough to feel like a real product, low enough to be an impulse buy.
- One-time purchase (no subscription) reduces friction and aligns with the app's offline, privacy-first ethos.
- No ads, ever. Ads conflict with the premium feel and disrupt gameplay flow.
- The free tier is fully functional for scoring -- premium features are genuine extras, not artificial gates.

## RevenueCat Setup

StoryScore uses `purchases_flutter` (RevenueCat SDK) for IAP management.

### Integration Steps

1. **Create RevenueCat project** at https://app.revenuecat.com
2. **Configure platforms**:
   - iOS: Add App Store Connect shared secret and bundle ID
   - Android: Upload Google Play service account JSON key
3. **Create entitlements**:
   - Entitlement ID: `supporter_pack`
4. **Create products**:
   - iOS product ID: `com.yourorg.storyscore.supporter_pack`
   - Android product ID: `supporter_pack`
5. **Create offering**:
   - Offering ID: `default`
   - Attach both platform products
6. **Configure in-app**:
   ```dart
   await Purchases.configure(
     PurchasesConfiguration('<revenuecat-api-key>')
       ..appUserID = null  // Anonymous, no accounts
   );
   ```
7. **Check entitlement**:
   ```dart
   final info = await Purchases.getCustomerInfo();
   final isPremium = info.entitlements.active.containsKey('supporter_pack');
   ```

### Local Persistence

Purchase status is cached locally in the `PurchaseEntitlements` table (Drift) so entitlement checks work offline. Sync with RevenueCat on app launch when network is available.

### Restore Purchases

Implement a "Restore Purchases" button on the Premium screen and in Settings. Required by App Store guidelines.

```dart
await Purchases.restorePurchases();
```

## Store Compliance Notes

### Apple App Store
- [ ] IAP product created as "Non-Consumable" in App Store Connect
- [ ] Product approved and "Ready to Submit" status
- [ ] "Restore Purchases" button visible on purchase screen
- [ ] No external purchase links or references to pricing on other platforms
- [ ] Review notes explain how to test IAP (provide sandbox test account or note that the IAP is optional)

### Google Play
- [ ] IAP product created as "One-time product" in Play Console
- [ ] Product set to "Active" status
- [ ] Licensing testers added for QA (they can purchase for free)
- [ ] No references to iOS pricing or App Store

### Both Platforms
- [ ] Price is set in each store's pricing UI (not hardcoded in the app)
- [ ] Display price fetched from RevenueCat/store at runtime
- [ ] Graceful fallback if store is unavailable (show "unavailable" state, don't crash)
- [ ] Purchase errors handled with user-friendly messages

## IAP Product Configuration

### App Store Connect

| Field | Value |
|---|---|
| Reference Name | Supporter Pack |
| Product ID | `com.yourorg.storyscore.supporter_pack` |
| Type | Non-Consumable |
| Price | Tier 4 ($3.99 USD) |
| Display Name | Supporter Pack |
| Description | Unlock export, extra themes, custom avatars, and session insights. Support development of StoryScore. |
| Review Screenshot | Screenshot of Premium screen showing features |

### Google Play Console

| Field | Value |
|---|---|
| Product ID | `supporter_pack` |
| Name | Supporter Pack |
| Description | Unlock export, extra themes, custom avatars, and session insights. Support development of StoryScore. |
| Default Price | $3.99 USD |
| Status | Active |

## Revenue Expectations

This is a niche utility app. Realistic expectations:
- Primary goal: Cover developer program fees and hosting costs
- Secondary goal: Fund ongoing development
- The Supporter Pack is positioned as a "tip jar with benefits" rather than a hard paywall
