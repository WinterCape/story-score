import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A card showing a preset's name, player count, and color dot preview.
///
/// Supports swipe-to-delete via [Dismissible] and tapping to edit.
class PresetListTile extends StatelessWidget {
  const PresetListTile({
    super.key,
    required this.preset,
    required this.players,
    required this.onTap,
    required this.onDelete,
  });

  final PlayerPreset preset;
  final List<PresetPlayer> players;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Dismissible(
      key: ValueKey('preset_${preset.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.lg),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onError,
        ),
      ),
      child: Semantics(
        label: '${preset.name}, ${players.length} players',
        button: true,
        child: Card(
          margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  // Preset info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          '${players.length} players',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Color dot preview
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: players.take(6).map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: PlayerColors.colorFor(p.colorKey),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (players.length > 6)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '+${players.length - 6}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  const SizedBox(width: SpacingTokens.sm),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
