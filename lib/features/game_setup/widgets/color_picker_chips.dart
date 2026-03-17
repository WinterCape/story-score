import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A grid of 12 color swatches for player color selection.
///
/// Already-used colors are shown dimmed with a lock icon and cannot be tapped.
class ColorPickerChips extends StatelessWidget {
  const ColorPickerChips({
    super.key,
    required this.selectedKey,
    required this.usedKeys,
    required this.onSelected,
  });

  /// Currently selected color key.
  final String selectedKey;

  /// Color keys already assigned to other players.
  final Set<String> usedKeys;

  /// Called when the user taps an available color.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Wrap(
      spacing: SpacingTokens.sm,
      runSpacing: SpacingTokens.sm,
      children: PlayerColors.orderedKeys.map((key) {
        final color = PlayerColors.colorFor(key);
        final isSelected = key == selectedKey;
        final isUsed = usedKeys.contains(key) && !isSelected;

        return GestureDetector(
          onTap: isUsed ? null : () => onSelected(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUsed ? color.withValues(alpha: 0.3) : color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isUsed
                ? Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  )
                : isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: Colors.white,
                      )
                    : null,
          ),
        );
      }).toList(),
    );
  }
}
