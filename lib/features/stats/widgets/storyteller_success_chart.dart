import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Donut-style pie chart showing storyteller success ratio.
///
/// Gold segment for good clues, coral segment for bad clues.
class StorytellerSuccessChart extends StatelessWidget {
  const StorytellerSuccessChart({
    super.key,
    required this.goodClueCount,
    required this.badClueCount,
    this.size = 140,
  });

  final int goodClueCount;
  final int badClueCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final total = goodClueCount + badClueCount;

    if (total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            'No data',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final successRate = (goodClueCount / total * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.3,
              sections: [
                PieChartSectionData(
                  value: goodClueCount.toDouble(),
                  color: storyTheme.goldAccent,
                  radius: size * 0.18,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: badClueCount.toDouble(),
                  color: storyTheme.dustyRose,
                  radius: size * 0.18,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$successRate%',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'success',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Legend row for the storyteller success chart.
class StorytellerSuccessLegend extends StatelessWidget {
  const StorytellerSuccessLegend({
    super.key,
    required this.goodClueCount,
    required this.badClueCount,
  });

  final int goodClueCount;
  final int badClueCount;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final textTheme = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: storyTheme.goldAccent),
        const SizedBox(width: SpacingTokens.xs),
        Text('Good ($goodClueCount)', style: textTheme.bodySmall),
        const SizedBox(width: SpacingTokens.md),
        _LegendDot(color: storyTheme.dustyRose),
        const SizedBox(width: SpacingTokens.xs),
        Text('Bad ($badClueCount)', style: textTheme.bodySmall),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
