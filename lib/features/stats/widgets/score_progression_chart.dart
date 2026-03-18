import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Line chart showing cumulative score progression per player across rounds.
///
/// Takes a [Map<String, List<int>>] where keys are player names and values
/// are cumulative scores per round (starting at 0 for round 0).
class ScoreProgressionChart extends StatelessWidget {
  const ScoreProgressionChart({
    super.key,
    required this.progression,
    this.height = 220,
  });

  /// Player name -> cumulative scores per round.
  final Map<String, List<int>> progression;
  final double height;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final colors = context.colorScheme;

    if (progression.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data available')),
      );
    }

    final playerNames = progression.keys.toList();
    final maxRounds = progression.values.fold(
      0,
      (max, scores) => scores.length > max ? scores.length : max,
    );
    final maxScore = progression.values
        .expand((s) => s)
        .fold(0, (max, score) => score > max ? score : max);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(
          right: SpacingTokens.md,
          top: SpacingTokens.sm,
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxScore > 0
                  ? (maxScore / 4).ceilToDouble().clamp(1, double.infinity)
                  : 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colors.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxRounds > 10 ? (maxRounds / 5).ceilToDouble() : 1,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'R${value.toInt()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: storyTheme.goldAccent,
                      ),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: storyTheme.goldAccent,
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
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (maxRounds - 1).toDouble().clamp(0, double.infinity),
            minY: 0,
            maxY: maxScore > 0 ? maxScore.toDouble() * 1.1 : 10,
            lineBarsData: playerNames.asMap().entries.map((entry) {
              final name = entry.value;
              final scores = progression[name]!;
              final color = _playerColor(name, entry.key);
              return LineChartBarData(
                spots: scores.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.toDouble());
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.2,
                color: color,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: scores.length <= 15,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 0,
                      ),
                ),
                belowBarData: BarAreaData(show: false),
              );
            }).toList(),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    colors.surfaceContainerHighest.withValues(alpha: 0.95),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final name = playerNames[spot.barIndex];
                    return LineTooltipItem(
                      '$name: ${spot.y.toInt()}',
                      TextStyle(
                        color: spot.bar.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _playerColor(String name, int index) {
    // Try to match by player color key naming; fall back to indexed
    final keys = PlayerColors.orderedKeys;
    if (index < keys.length) {
      return PlayerColors.colorFor(keys[index]);
    }
    return PlayerColors.all.values.elementAt(index % PlayerColors.all.length);
  }
}
