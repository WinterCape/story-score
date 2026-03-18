import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/app/theme/theme_extensions.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/premium/widgets/feature_preview_list.dart';

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
      body: CustomScrollView(
        slivers: [
          // ---- App bar ----
          SliverAppBar(
            pinned: true,
            title: const Text('Supporter Pack'),
            centerTitle: true,
          ),

          // ---- Body ----
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: SpacingTokens.lg),

                // ---- Hero header ----
                _HeroHeader(ext: ext, isSupporter: isSupporter),

                const SizedBox(height: SpacingTokens.xxl),

                // ---- Feature list ----
                Text(
                  "What's included",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                const FeaturePreviewList(),

                const SizedBox(height: SpacingTokens.xxl),

                // ---- Purchase / status section ----
                if (isSupporter)
                  _AlreadySupporterBanner(ext: ext)
                else
                  const _PurchaseSection(),

                // ---- Debug clear button (when supporter, debug only) ----
                if (isSupporter && kDebugMode) ...[
                  const SizedBox(height: SpacingTokens.md),
                  const _DebugClearButton(),
                ],

                const SizedBox(height: SpacingTokens.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero header with star icon and description
// ---------------------------------------------------------------------------

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.ext, required this.isSupporter});

  final StoryScoreThemeExtension ext;
  final bool isSupporter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Star icon with gradient background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ext.goldAccent.withValues(alpha: 0.25),
                ext.softViolet.withValues(alpha: 0.20),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star_rounded, size: 44, color: ext.goldAccent),
        ),
        const SizedBox(height: SpacingTokens.lg),

        Text(
          isSupporter ? 'Thank you for your support!' : 'Supporter Pack',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.sm),

        Text(
          isSupporter
              ? 'You have unlocked all supporter features. '
                    'Your generosity helps keep StoryScore growing.'
              : 'A one-time purchase to unlock premium features '
                    'and support the development of StoryScore.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
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
  static const _fallbackPrice = r'$1.99';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.storyScore;

    final priceAsync = ref.watch(supporterPackPriceProvider);
    final priceString = priceAsync.when(
      data: (price) => price ?? _fallbackPrice,
      loading: () => null, // null signals "still loading"
      error: (_, _) => _fallbackPrice,
    );

    final priceLabel = priceString != null
        ? '$priceString \u2014 one-time purchase'
        : null;
    final buttonLabel = priceString != null
        ? 'Get Supporter Pack \u2014 $priceString'
        : null;

    return Column(
      children: [
        // Price tag (or loading indicator)
        if (priceLabel != null)
          Text(
            priceLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          )
        else
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: SpacingTokens.md),

        // Purchase button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ext.goldAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              ),
            ),
            icon: _isPurchasing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.star_rounded, size: 20),
            label: Text(
              buttonLabel ?? 'Loading\u2026',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: (_isPurchasing || priceString == null)
                ? null
                : () => _handlePurchase(context, ref),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),

        // Restore purchases
        _isRestoring
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => _handleRestore(context, ref),
                child: Text(
                  'Restore Purchases',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
      // Invalidate the entitlement provider so isSupporterProvider updates
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
        color: ext.auroraTeal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: ext.auroraTeal.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: ext.auroraTeal, size: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Supporter Pack Active',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ext.auroraTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All premium features are unlocked.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
// Debug clear button — allows toggling back to free state during development
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
        label: const Text('Clear Purchase (Debug)'),
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
