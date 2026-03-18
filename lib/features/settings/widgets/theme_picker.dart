import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/premium_themes.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';

/// Displays a grid of theme swatches, including the default Celestial/Aurora
/// theme and the four premium themes. Premium themes show a lock icon when the
/// Supporter Pack is not active.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final isSupporter = ref.watch(isSupporterProvider);

    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.sm,
      children: [
        // Default Celestial theme (always free)
        _ThemeSwatch(
          themeId: 'celestial',
          name: 'Celestial',
          colors: const [
            ColorTokens.softViolet,
            ColorTokens.auroraTeal,
            ColorTokens.goldAccent,
          ],
          isSelected: selectedTheme == 'celestial',
          isPremium: false,
          isSupporter: isSupporter,
          onTap: () =>
              _selectTheme(context, ref, 'celestial', false, isSupporter),
        ),
        // Premium themes
        for (final palette in PremiumThemes.all)
          _ThemeSwatch(
            themeId: palette.id,
            name: palette.name,
            colors: [palette.primary, palette.secondary, palette.accent],
            isSelected: selectedTheme == palette.id,
            isPremium: true,
            isSupporter: isSupporter,
            onTap: () =>
                _selectTheme(context, ref, palette.id, true, isSupporter),
          ),
      ],
    );
  }

  void _selectTheme(
    BuildContext context,
    WidgetRef ref,
    String themeId,
    bool isPremium,
    bool isSupporter,
  ) {
    if (isPremium && !isSupporter) {
      _showPremiumDialog(context);
      return;
    }
    ref.read(appSettingsProvider.notifier).setSelectedTheme(themeId);
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Premium Theme'),
        content: const Text(
          'This theme requires the Supporter Pack. '
          'Unlock all premium themes with a one-time purchase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/settings/premium');
            },
            child: const Text('Get Supporter Pack'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual theme swatch
// ---------------------------------------------------------------------------

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.themeId,
    required this.name,
    required this.colors,
    required this.isSelected,
    required this.isPremium,
    required this.isSupporter,
    required this.onTap,
  });

  final String themeId;
  final String name;
  final List<Color> colors;
  final bool isSelected;
  final bool isPremium;
  final bool isSupporter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showLock = isPremium && !isSupporter;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm,
          horizontal: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color circles row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < colors.length; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
            // Theme name + lock
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLock) ...[
                  Icon(
                    Icons.lock_outline,
                    size: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(
                    name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Selected check
            if (isSelected) ...[
              const SizedBox(height: 2),
              Icon(
                Icons.check_circle,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
