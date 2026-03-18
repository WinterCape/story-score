import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Horizontal bar chart showing win rates for leaderboard entries.
class WinRateBarChart extends StatelessWidget {
  const WinRateBarChart({
    super.key,
    required this.entries,
    this.height,
  });

  final List<LeaderboardEntry> entries;

  /// If null, height is computed from entry count.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final colors = context.colorScheme;

    if (entries.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No leaderboard data')),
      );
    }

    final chartHeight = height ?? (entries.length * 44.0).clamp(120, 400);

    return SizedBox(
      height: chartHeight,
      child: Padding(
        padding: const EdgeInsets.only(right: SpacingTokens.md),
        child: RotatedBox(
          quarterTurns: 1,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      colors.surfaceContainerHighest.withValues(alpha: 0.95),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entry = entries[group.x];
                    return BarTooltipItem(
                      '${entry.displayName}\n${(entry.winRate * 100).toStringAsFixed(0)}% '
                      '(${entry.wins}W / ${entry.gamesPlayed}G)',
                      TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 80,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      return RotatedBox(
                        quarterTurns: -1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            entries[index].displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 25,
                    getTitlesWidget: (value, meta) => RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: storyTheme.goldAccent,
                        ),
                      ),
                    ),
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
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: entries.asMap().entries.map((e) {
                final index = e.key;
                final entry = e.value;
                final color = _colorForIndex(index);
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (entry.winRate * 100).clamp(0, 100),
                      color: color,
                      width: 18,
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
      ),
    );
  }

  Color _colorForIndex(int index) {
    final keys = PlayerColors.orderedKeys;
    if (index < keys.length) {
      return PlayerColors.colorFor(keys[index]);
    }
    return PlayerColors.all.values.elementAt(index % PlayerColors.all.length);
  }
}
