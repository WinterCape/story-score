import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Centered empty-state placeholder with an icon, message, and optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final text = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              title,
              style: text.titleLarge?.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                subtitle!,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
