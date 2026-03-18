import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/domain/models/game_summary.dart';

GameSummary _summary(List<PlayerStanding> standings) {
  return GameSummary(
    sessionId: 'test-session',
    title: 'Test Game',
    roundCount: 5,
    standings: standings,
    startedAt: DateTime(2025, 1, 1),
    endedAt: DateTime(2025, 1, 1, 1),
  );
}

PlayerStanding _standing(String id, int score, {int rank = 1}) {
  return PlayerStanding(
    playerId: id,
    playerName: 'Player $id',
    colorKey: 'blue',
    score: score,
    rank: rank,
  );
}

void main() {
  group('GameSummary', () {
    test('winners returns single winner when scores differ', () {
      final summary = _summary([
        _standing('A', 30, rank: 1),
        _standing('B', 20, rank: 2),
        _standing('C', 10, rank: 3),
      ]);

      expect(summary.winners.length, 1);
      expect(summary.winners.first.playerId, 'A');
    });

    test('winners returns multiple when tied', () {
      final summary = _summary([
        _standing('A', 25, rank: 1),
        _standing('B', 25, rank: 1),
        _standing('C', 10, rank: 3),
      ]);

      expect(summary.winners.length, 2);
      expect(summary.winners.map((w) => w.playerId), containsAll(['A', 'B']));
    });

    test('hasTie is true for ties', () {
      final summary = _summary([
        _standing('A', 20, rank: 1),
        _standing('B', 20, rank: 1),
      ]);

      expect(summary.hasTie, isTrue);
    });

    test('hasTie is false when no tie', () {
      final summary = _summary([
        _standing('A', 30, rank: 1),
        _standing('B', 20, rank: 2),
      ]);

      expect(summary.hasTie, isFalse);
    });
  });
}
