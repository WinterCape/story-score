import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/app/theme/theme_extensions.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Full-featured Supporter Pack purchase screen.
///
/// Shows a warm, non-aggressive presentation of the one-time supporter
/// pack with feature list, purchase button, and restore option.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ext = theme.storyScore;
    final isSupporter = ref.watch(isSupporterProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.darkCard,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: Column(
              children: [
                const SizedBox(height: SpacingTokens.lg),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: ColorTokens.goldAccent,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: SpacingTokens.md),

                // Hero illustration with sparkles
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkles around hero
                    Positioned(
                      top: 10,
                      left: 30,
                      child: Opacity(
                        opacity: 0.3,
                        child: Image.asset(AppAssets.sparkle(1), width: 16),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 40,
                      child: Opacity(
                        opacity: 0.25,
                        child: Image.asset(AppAssets.sparkle(2), width: 14),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 50,
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.asset(AppAssets.sparkle(3), width: 12),
                      ),
                    ),
                    // Hero image
                    if (isSupporter)
                      Image.asset(AppAssets.supporterBadge, width: 80)
                    else
                      Image.asset(AppAssets.premiumHero, width: 200),
                  ],
                ),
                const SizedBox(height: SpacingTokens.lg),

                // "Supporter Pack" large parchment title
                Text(
                  isSupporter
                      ? context.l10n.thankYouForSupport
                      : context.l10n.supporterPack,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ColorTokens.parchment,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (!isSupporter) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  // Price as muted text
                  _PriceLabel(),
                ],

                const SizedBox(height: SpacingTokens.xxl),

                // Feature list: 5 items
                const _FeatureList(),

                const SizedBox(height: SpacingTokens.xxl),

                // Purchase / status section
                if (isSupporter)
                  _AlreadySupporterBanner(ext: ext)
                else
                  const _PurchaseSection(),

                // Debug clear button (when supporter, debug only)
                if (isSupporter && kDebugMode) ...[
                  const SizedBox(height: SpacingTokens.md),
                  const _DebugClearButton(),
                ],

                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Price label
// ---------------------------------------------------------------------------

class _PriceLabel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceAsync = ref.watch(supporterPackPriceProvider);
    final priceString = priceAsync.when(
      data: (price) => price,
      loading: () => null,
      error: (_, _) => r'$4.99',
    );

    if (priceString == null) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: ColorTokens.mutedText,
        ),
      );
    }

    return Text(
      context.l10n.oneTimePurchase(priceString),
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ColorTokens.mutedText,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature list matching mockup: icon circle + bold title + muted subtitle
// ---------------------------------------------------------------------------

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _items = [
    (
      icon: Icons.palette_outlined,
      title: 'Exclusive themes',
      subtitle: 'More magic for your table',
    ),
    (
      icon: Icons.auto_awesome_outlined,
      title: 'Round celebrations',
      subtitle: 'More magic for your table',
    ),
    (
      icon: Icons.group_outlined,
      title: 'Unlimited presets',
      subtitle: 'More magic for your table',
    ),
    (
      icon: Icons.insights_outlined,
      title: 'Deep stats',
      subtitle: 'More magic for your table',
    ),
    (
      icon: Icons.favorite_outline,
      title: 'Support the app',
      subtitle: 'More magic for your table',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _items.length; i++) ...[
          _FeatureRow(
            icon: _items[i].icon,
            title: _items[i].title,
            subtitle: _items[i].subtitle,
          ),
          if (i < _items.length - 1) const SizedBox(height: SpacingTokens.md),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon in a circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorTokens.darkCard,
            border: Border.all(
              color: ColorTokens.goldAccent.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: ColorTokens.goldAccent),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColorTokens.parchment,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: ColorTokens.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Purchase button + restore link
// ---------------------------------------------------------------------------

class _PurchaseSection extends ConsumerStatefulWidget {
  const _PurchaseSection();

  @override
  ConsumerState<_PurchaseSection> createState() => _PurchaseSectionState();
}

class _PurchaseSectionState extends ConsumerState<_PurchaseSection> {
  bool _isPurchasing = false;
  bool _isRestoring = false;

  /// Fallback price shown when the store is unreachable.
  static const _fallbackPrice = r'$4.99';

  @override
  Widget build(BuildContext context) {
    final priceAsync = ref.watch(supporterPackPriceProvider);
    final priceString = priceAsync.when(
      data: (price) => price ?? _fallbackPrice,
      loading: () => null,
      error: (_, _) => _fallbackPrice,
    );

    final l10n = context.l10n;
    final buttonLabel = priceString != null
        ? l10n.getSupporterPack(priceString)
        : null;

    return Column(
      children: [
        // Full-width "Get Supporter Pack" gradient button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColorTokens.burgundy, ColorTokens.goldAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: (_isPurchasing || priceString == null)
                  ? null
                  : () => _handlePurchase(context, ref),
              child: _isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      buttonLabel ?? l10n.loading,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),

        // "Restore Purchases" text button
        _isRestoring
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => _handleRestore(context, ref),
                child: Text(
                  l10n.restorePurchases,
                  style: const TextStyle(color: ColorTokens.mutedText),
                ),
              ),
      ],
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    setState(() => _isPurchasing = true);
    try {
      ref.invalidate(purchaseSupporterPackProvider);
      final result = await ref.read(purchaseSupporterPackProvider.future);
      ref.invalidate(purchaseEntitlementProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    setState(() => _isRestoring = true);
    try {
      ref.invalidate(restorePurchasesProvider);
      final result = await ref.read(restorePurchasesProvider.future);
      ref.invalidate(purchaseEntitlementProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }
}

// ---------------------------------------------------------------------------
// Already-purchased banner
// ---------------------------------------------------------------------------

class _AlreadySupporterBanner extends StatelessWidget {
  const _AlreadySupporterBanner({required this.ext});

  final StoryScoreThemeExtension ext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: ext.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.teal.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Image.asset(AppAssets.supporterBadge, width: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.supporterPackActive,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ext.teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.allPremiumUnlocked,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Debug clear button
// ---------------------------------------------------------------------------

class _DebugClearButton extends ConsumerWidget {
  const _DebugClearButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(
            color: theme.colorScheme.error.withValues(alpha: 0.5),
          ),
        ),
        icon: const Icon(Icons.bug_report_outlined, size: 18),
        label: Text(context.l10n.clearPurchaseDebug),
        onPressed: () => _handleClear(context, ref),
      ),
    );
  }

  Future<void> _handleClear(BuildContext context, WidgetRef ref) async {
    ref.invalidate(clearPurchaseProvider);
    final result = await ref.read(clearPurchaseProvider.future);
    ref.invalidate(purchaseEntitlementProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }
}
