import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Bar chart showing how often a player scores 0, 2, 3, or 4+ in a round.
///
/// Takes a [Map<int, int>] where keys are score values (0, 2, 3, 4)
/// and values are the number of rounds with that score.
/// The key 4 represents "4 or more".
class ScoreDistributionChart extends StatelessWidget {
  const ScoreDistributionChart({
    super.key,
    required this.distribution,
    this.playerColor,
    this.height = 180,
  });

  /// Score value -> count of rounds. Keys: 0, 2, 3, 4 (4 means 4+).
  final Map<int, int> distribution;
  final Color? playerColor;
  final double height;

  static const _scoreLabels = {0: '0', 2: '2', 3: '3', 4: '4+'};
  static const _orderedKeys = [0, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final colors = context.colorScheme;
    final barColor = playerColor ?? storyTheme.auroraTeal;

    final maxCount = distribution.values.fold(0,
        (max, count) => count > max ? count : max);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(
          right: SpacingTokens.md,
          top: SpacingTokens.sm,
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCount > 0 ? (maxCount * 1.2).ceilToDouble() : 5,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    colors.surfaceContainerHighest.withValues(alpha: 0.95),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final scoreKey = _orderedKeys[group.x];
                  final label = _scoreLabels[scoreKey] ?? '$scoreKey';
                  return BarTooltipItem(
                    'Score $label: ${rod.toY.toInt()} rounds',
                    TextStyle(color: colors.onSurface, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= _orderedKeys.length) {
                      return const SizedBox.shrink();
                    }
                    final scoreKey = _orderedKeys[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _scoreLabels[scoreKey] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: storyTheme.goldAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value != value.roundToDouble()) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colors.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 0.5,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _orderedKeys.asMap().entries.map((e) {
              final index = e.key;
              final scoreKey = e.value;
              final count = distribution[scoreKey] ?? 0;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: count.toDouble(),
                    color: barColor,
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
