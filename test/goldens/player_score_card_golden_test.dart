import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/scoreboard/widgets/player_score_card.dart';

import 'golden_test_helpers.dart';

void main() {
  Player makePlayer({
    String name = 'Alice',
    String colorKey = 'aurora_teal',
    int score = 42,
  }) {
    return Player(
      id: 'p1',
      sessionId: 's1',
      name: name,
      seatOrder: 0,
      colorKey: colorKey,
      avatarStyle: 'initials',
      currentScore: score,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('PlayerScoreCard golden tests', () {
    testWidgets('light theme - regular player', (tester) async {
      await tester.pumpWidget(
        wrapInTheme(
          SizedBox(
            width: 200,
            height: 140,
            child: PlayerScoreCard(
              player: makePlayer(),
              isStoryteller: false,
              rank: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PlayerScoreCard),
        matchesGoldenFile('goldens/player_score_card_light.png'),
      );
    });

    testWidgets('dark theme - regular player', (tester) async {
      await tester.pumpWidget(
        wrapInTheme(
          SizedBox(
            width: 200,
            height: 140,
            child: PlayerScoreCard(
              player: makePlayer(),
              isStoryteller: false,
              rank: 2,
            ),
          ),
          isDark: true,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PlayerScoreCard),
        matchesGoldenFile('goldens/player_score_card_dark.png'),
      );
    });
  });
}
