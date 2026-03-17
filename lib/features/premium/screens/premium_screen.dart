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
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
            ),
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
                  _PurchaseSection(ref: ref, ext: ext),

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
          child: Icon(
            Icons.star_rounded,
            size: 44,
            color: ext.goldAccent,
          ),
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

class _PurchaseSection extends StatelessWidget {
  const _PurchaseSection({required this.ref, required this.ext});

  final WidgetRef ref;
  final StoryScoreThemeExtension ext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Price tag
        Text(
          '\$3.99 \u2014 one-time purchase',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
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
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusMd),
              ),
            ),
            icon: const Icon(Icons.star_rounded, size: 20),
            label: const Text(
              'Get Supporter Pack \u2014 \$3.99',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () => _handlePurchase(context, ref),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),

        // Restore purchases
        TextButton(
          onPressed: () => _handleRestore(context, ref),
          child: Text(
            'Restore Purchases',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    // Invalidate to trigger the future again.
    ref.invalidate(purchaseSupporterPackProvider);
    final result = await ref.read(purchaseSupporterPackProvider.future);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    ref.invalidate(restorePurchasesProvider);
    final result = await ref.read(restorePurchasesProvider.future);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
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
        border: Border.all(
          color: ext.auroraTeal.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_rounded,
            color: ext.auroraTeal,
            size: 28,
          ),
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
