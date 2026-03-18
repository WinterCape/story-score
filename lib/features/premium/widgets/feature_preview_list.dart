import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';

/// A single feature item in the supporter-pack feature list.
@immutable
class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Displays the list of features included in the Supporter Pack.
class FeaturePreviewList extends StatelessWidget {
  const FeaturePreviewList({super.key});

  static const _features = [
    _FeatureItem(
      icon: Icons.palette_outlined,
      title: '4 Premium Color Themes',
      description: 'Ocean Depths, Ember, Frost, and Enchanted Forest palettes.',
    ),
    _FeatureItem(
      icon: Icons.auto_awesome_outlined,
      title: 'Premium Celebration Effects',
      description: 'Delightful animations when players hit milestones.',
    ),
    _FeatureItem(
      icon: Icons.group_outlined,
      title: 'Player Presets & Saved Groups',
      description: 'Save your regular player groups for quick game setup.',
    ),
    _FeatureItem(
      icon: Icons.insights_outlined,
      title: 'Advanced Score Statistics',
      description: 'Deeper insights into scores, streaks, and trends.',
    ),
    _FeatureItem(
      icon: Icons.favorite_outline,
      title: 'Support Independent Development',
      description: 'Help keep StoryScore ad-free and actively maintained.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final checkColor = isDark ? ColorTokens.auroraTeal : ColorTokens.auroraTeal;

    return Column(
      children: [
        for (int i = 0; i < _features.length; i++) ...[
          _FeatureTile(feature: _features[i], checkColor: checkColor),
          if (i < _features.length - 1)
            const SizedBox(height: SpacingTokens.sm),
        ],
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.checkColor});

  final _FeatureItem feature;
  final Color checkColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: checkColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            ),
            child: Icon(feature.icon, size: 18, color: checkColor),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Icon(Icons.check_circle, size: 20, color: checkColor),
        ],
      ),
    );
  }
}
