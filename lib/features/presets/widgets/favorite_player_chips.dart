import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Horizontal scrollable row of [ActionChip] widgets showing favorited player
/// names with their color dots.
///
/// Tapping a chip fires [onSelect] with the player's name, color key, and
/// avatar style so the caller can auto-fill a form or add a player.
class FavoritePlayerChips extends StatelessWidget {
  const FavoritePlayerChips({
    super.key,
    required this.favorites,
    required this.onSelect,
    this.excludeNames = const {},
  });

  final List<PresetPlayer> favorites;
  final void Function(String name, String colorKey, String avatarStyle)
      onSelect;

  /// Names already added — these chips will be disabled.
  final Set<String> excludeNames;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorites',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.xs),
            itemBuilder: (context, index) {
              final fav = favorites[index];
              final isExcluded = excludeNames
                  .contains(fav.name.trim().toLowerCase());

              return Semantics(
                label: 'Add ${fav.name} from favorites',
                button: true,
                child: ActionChip(
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: PlayerColors.colorFor(fav.colorKey),
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: Text(fav.name),
                  onPressed: isExcluded
                      ? null
                      : () => onSelect(
                            fav.name,
                            fav.colorKey,
                            fav.avatarStyle,
                          ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
