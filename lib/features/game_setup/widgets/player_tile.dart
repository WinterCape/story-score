import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A single player row in the reorderable list.
///
/// Shows a colored dot, the player's name, their seat number, and a
/// remove button. Designed to sit inside a [ReorderableListView].
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.colorKey,
    required this.seatNumber,
    required this.onRemove,
    this.avatarStyle = 'initials',
  });

  final String name;
  final String colorKey;
  final int seatNumber;
  final VoidCallback onRemove;
  final String avatarStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final color = PlayerColors.colorFor(colorKey);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: SpacingTokens.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            // Drag handle.
            Icon(
              Icons.drag_handle_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: SpacingTokens.sm),

            // Color dot / emoji avatar.
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: avatarStyle != 'initials' && avatarStyle.isNotEmpty
                  ? Text(avatarStyle,
                      style: const TextStyle(fontSize: 14))
                  : null,
            ),
            const SizedBox(width: SpacingTokens.md),

            // Name.
            Expanded(
              child: Text(
                name,
                style: textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Seat badge.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusSm),
              ),
              child: Text(
                '#${seatNumber + 1}',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),

            // Remove button.
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: colorScheme.error,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove player',
            ),
          ],
        ),
      ),
    );
  }
}
