import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Reusable stat tile with an icon on the left, label, large value,
/// and optional subtitle.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final colors = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? storyTheme.goldAccent).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? storyTheme.goldAccent,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    value,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
