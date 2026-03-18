import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Compact card showing the head-to-head record between two players.
class HeadToHeadCard extends StatelessWidget {
  const HeadToHeadCard({
    super.key,
    required this.record,
  });

  final HeadToHeadRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            // Player A
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.playerA,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.winsA} wins',
                    style: textTheme.bodySmall?.copyWith(
                      color: record.winsA > record.winsB
                          ? ColorTokens.auroraGreen
                          : colors.onSurfaceVariant,
                      fontWeight: record.winsA > record.winsB
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            // Center record
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              child: Column(
                children: [
                  Text(
                    'vs',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.ties} ties',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${record.sharedGames} games',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Player B
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.playerB,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${record.winsB} wins',
                    style: textTheme.bodySmall?.copyWith(
                      color: record.winsB > record.winsA
                          ? ColorTokens.auroraGreen
                          : colors.onSurfaceVariant,
                      fontWeight: record.winsB > record.winsA
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
