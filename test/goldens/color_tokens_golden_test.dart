import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/core/constants/player_colors.dart';

import 'golden_test_helpers.dart';

void main() {
  group('Color tokens golden tests', () {
    testWidgets('all 12 player colors rendered as a grid', (tester) async {
      await tester.pumpWidget(
        wrapInTheme(
          SizedBox(
            width: 300,
            height: 200,
            child: _PlayerColorGrid(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_PlayerColorGrid),
        matchesGoldenFile('goldens/player_colors_grid.png'),
      );
    });

    testWidgets('all 12 player colors – dark theme', (tester) async {
      await tester.pumpWidget(
        wrapInTheme(
          SizedBox(
            width: 300,
            height: 200,
            child: _PlayerColorGrid(),
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(_PlayerColorGrid),
        matchesGoldenFile('goldens/player_colors_grid_dark.png'),
      );
    });
  });
}

/// A simple grid that renders each of the 12 player colors as labeled circles.
class _PlayerColorGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = PlayerColors.all.entries.toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: entries.map((entry) {
        final label = entry.key.replaceAll('_', '\n');
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.value,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
