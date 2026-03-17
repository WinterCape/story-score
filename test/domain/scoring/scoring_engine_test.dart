import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/domain/scoring/score_reason.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';

void main() {
  const engine = ScoringEngine();

  // ───────────────────────────────────────────────────────────────────
  // Helper to build a RoundInput without the factory's validation,
  // so we can test the validator directly.
  // ───────────────────────────────────────────────────────────────────
  RoundInput validInput({
    required String storyteller,
    required List<String> players,
    required Map<String, String> votes,
  }) {
    return RoundInput(
      storytellerPlayerId: storyteller,
      allPlayerIds: players,
      votes: votes,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 3 players
  // ─────────────────────────────────────────────────────────────
  group('3 players', () {
    const players = ['S', 'A', 'B'];

    test('good clue — 1 of 2 guesses correctly', () {
      // A votes for S (correct), B votes for A (wrong).
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'A'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // Storyteller: +3 (good clue)
      expect(result.totalDeltaFor('S'), 3);
      // A: +3 (correct guess) + 1 (fooled B) = 4
      expect(result.totalDeltaFor('A'), 4);
      // B: 0 (wrong guess, no one voted for B's card)
      expect(result.totalDeltaFor('B'), 0);

      // Verify specific entries
      expect(
        result.scoreEntries,
        containsAll([
          const ScoreEntry(playerId: 'S', delta: 3, reason: ScoreReason.storytellerGoodClue),
          const ScoreEntry(playerId: 'A', delta: 3, reason: ScoreReason.correctGuess),
          const ScoreEntry(playerId: 'A', delta: 1, reason: ScoreReason.fooledBonus),
        ]),
      );
    });

    test('perfect fail — all guess correctly (both vote for storyteller)', () {
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'S'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.perfectFail);

      // Storyteller: 0
      expect(result.totalDeltaFor('S'), 0);
      // A: +2 (allGuessedBonus)
      expect(result.totalDeltaFor('A'), 2);
      // B: +2 (allGuessedBonus)
      expect(result.totalDeltaFor('B'), 2);
    });

    test('perfect fail — none guess correctly', () {
      // A votes for B, B votes for A.
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'B', 'B': 'A'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.perfectFail);

      // Storyteller: 0
      expect(result.totalDeltaFor('S'), 0);
      // A: +2 (allGuessedBonus) + 1 (fooled B) = 3
      expect(result.totalDeltaFor('A'), 3);
      // B: +2 (allGuessedBonus) + 1 (fooled A) = 3
      expect(result.totalDeltaFor('B'), 3);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 4 players
  // ─────────────────────────────────────────────────────────────
  group('4 players', () {
    const players = ['S', 'A', 'B', 'C'];

    test('good clue with fooled bonus', () {
      // A votes S (correct), B votes A (wrong), C votes A (wrong).
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'A', 'C': 'A'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // S: +3 (good clue)
      expect(result.totalDeltaFor('S'), 3);
      // A: +3 (correct) + 2 (fooled B and C) = 5
      expect(result.totalDeltaFor('A'), 5);
      // B: 0
      expect(result.totalDeltaFor('B'), 0);
      // C: 0
      expect(result.totalDeltaFor('C'), 0);
    });

    test('all guess correctly — perfect fail', () {
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'S', 'C': 'S'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.perfectFail);

      expect(result.totalDeltaFor('S'), 0);
      expect(result.totalDeltaFor('A'), 2);
      expect(result.totalDeltaFor('B'), 2);
      expect(result.totalDeltaFor('C'), 2);
    });

    test('none guess correctly — perfect fail with fooled bonuses', () {
      // A→B, B→C, C→A. Nobody votes for S.
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'B', 'B': 'C', 'C': 'A'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.perfectFail);

      expect(result.totalDeltaFor('S'), 0);
      // Each non-storyteller: +2 (bonus) + 1 (fooled one person) = 3
      expect(result.totalDeltaFor('A'), 3);
      expect(result.totalDeltaFor('B'), 3);
      expect(result.totalDeltaFor('C'), 3);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 6 players
  // ─────────────────────────────────────────────────────────────
  group('6 players', () {
    const players = ['S', 'A', 'B', 'C', 'D', 'E'];

    test('mixed guesses with multiple fooled bonuses', () {
      // A→S (correct), B→S (correct), C→A (wrong), D→A (wrong), E→C (wrong).
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'S', 'C': 'A', 'D': 'A', 'E': 'C'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // S: +3 (good clue)
      expect(result.totalDeltaFor('S'), 3);
      // A: +3 (correct) + 2 (fooled C and D) = 5
      expect(result.totalDeltaFor('A'), 5);
      // B: +3 (correct) + 0 = 3
      expect(result.totalDeltaFor('B'), 3);
      // C: 0 + 1 (fooled E) = 1
      expect(result.totalDeltaFor('C'), 1);
      // D: 0
      expect(result.totalDeltaFor('D'), 0);
      // E: 0
      expect(result.totalDeltaFor('E'), 0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 8 players
  // ─────────────────────────────────────────────────────────────
  group('8 players', () {
    const players = ['S', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'];

    test('large game verification', () {
      // P1→S, P2→S, P3→P1, P4→P1, P5→P3, P6→P3, P7→P2
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {
          'P1': 'S',
          'P2': 'S',
          'P3': 'P1',
          'P4': 'P1',
          'P5': 'P3',
          'P6': 'P3',
          'P7': 'P2',
        },
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // S: +3
      expect(result.totalDeltaFor('S'), 3);
      // P1: +3 (correct) + 2 (fooled P3, P4) = 5
      expect(result.totalDeltaFor('P1'), 5);
      // P2: +3 (correct) + 1 (fooled P7) = 4
      expect(result.totalDeltaFor('P2'), 4);
      // P3: 0 + 2 (fooled P5, P6) = 2
      expect(result.totalDeltaFor('P3'), 2);
      // P4: 0
      expect(result.totalDeltaFor('P4'), 0);
      // P5: 0
      expect(result.totalDeltaFor('P5'), 0);
      // P6: 0
      expect(result.totalDeltaFor('P6'), 0);
      // P7: 0
      expect(result.totalDeltaFor('P7'), 0);

      // Verify total points distributed:
      // S(3) + P1(5) + P2(4) + P3(2) = 14
      final totalPoints = players.fold(0, (sum, p) => sum + result.totalDeltaFor(p));
      expect(totalPoints, 14);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 10 players (maximum)
  // ─────────────────────────────────────────────────────────────
  group('10 players', () {
    const players = ['S', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'P8', 'P9'];

    test('maximum player count — good clue scenario', () {
      // 4 guess correctly, 5 guess wrong with varied fooled targets.
      // P1→S, P2→S, P3→S, P4→S, P5→P1, P6→P1, P7→P2, P8→P5, P9→P5
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {
          'P1': 'S',
          'P2': 'S',
          'P3': 'S',
          'P4': 'S',
          'P5': 'P1',
          'P6': 'P1',
          'P7': 'P2',
          'P8': 'P5',
          'P9': 'P5',
        },
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // S: +3
      expect(result.totalDeltaFor('S'), 3);
      // P1: +3 (correct) + 2 (fooled P5, P6) = 5
      expect(result.totalDeltaFor('P1'), 5);
      // P2: +3 (correct) + 1 (fooled P7) = 4
      expect(result.totalDeltaFor('P2'), 4);
      // P3: +3 (correct) = 3
      expect(result.totalDeltaFor('P3'), 3);
      // P4: +3 (correct) = 3
      expect(result.totalDeltaFor('P4'), 3);
      // P5: 0 + 2 (fooled P8, P9) = 2
      expect(result.totalDeltaFor('P5'), 2);
      // P6: 0
      expect(result.totalDeltaFor('P6'), 0);
      // P7: 0
      expect(result.totalDeltaFor('P7'), 0);
      // P8: 0
      expect(result.totalDeltaFor('P8'), 0);
      // P9: 0
      expect(result.totalDeltaFor('P9'), 0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Edge cases
  // ─────────────────────────────────────────────────────────────
  group('edge cases', () {
    test('storyteller gets 0 bonus even if storyteller card receives votes', () {
      // In a good clue scenario, some vote for storyteller.
      // The storyteller should NOT get a fooledBonus for those votes.
      const players = ['S', 'A', 'B', 'C'];
      // A→S (correct), B→S (correct), C→A (wrong).
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'S', 'C': 'A'},
      );
      final result = engine.computeRound(input);

      // S should only have the +3 storytellerGoodClue, NOT any fooledBonus.
      final storytellerEntries =
          result.scoreEntries.where((e) => e.playerId == 'S').toList();
      expect(storytellerEntries.length, 1);
      expect(storytellerEntries.first.reason, ScoreReason.storytellerGoodClue);
      expect(storytellerEntries.first.delta, 3);
      expect(result.totalDeltaFor('S'), 3);

      // Verify no fooledBonus entry exists for the storyteller.
      final storytellerFooledEntries = result.scoreEntries
          .where((e) => e.playerId == 'S' && e.reason == ScoreReason.fooledBonus);
      expect(storytellerFooledEntries, isEmpty);
    });

    test('correct guesser also gets fooled bonus from other voters', () {
      // A votes for storyteller (correct) AND other players vote for A's card.
      const players = ['S', 'A', 'B', 'C', 'D'];
      // A→S (correct), B→A (wrong), C→A (wrong), D→B (wrong).
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'A', 'C': 'A', 'D': 'B'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.goodClue);

      // A: +3 (correct guess) + 2 (fooled B and C) = 5
      expect(result.totalDeltaFor('A'), 5);

      final aEntries = result.scoreEntries.where((e) => e.playerId == 'A').toList();
      expect(aEntries.length, 2);
      expect(
        aEntries,
        containsAll([
          const ScoreEntry(playerId: 'A', delta: 3, reason: ScoreReason.correctGuess),
          const ScoreEntry(playerId: 'A', delta: 2, reason: ScoreReason.fooledBonus),
        ]),
      );
    });

    test('perfect fail — all voters vote for storyteller in 4-player game', () {
      const players = ['S', 'A', 'B', 'C'];
      final input = validInput(
        storyteller: 'S',
        players: players,
        votes: {'A': 'S', 'B': 'S', 'C': 'S'},
      );
      final result = engine.computeRound(input);

      expect(result.clueOutcome, ClueOutcome.perfectFail);
      expect(result.totalDeltaFor('S'), 0);

      // No fooledBonus entries at all (all voted for storyteller).
      final fooledEntries =
          result.scoreEntries.where((e) => e.reason == ScoreReason.fooledBonus);
      expect(fooledEntries, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────
  group('validation', () {
    test('storyteller in votes → error', () {
      expect(
        () => RoundInput(
          storytellerPlayerId: 'S',
          allPlayerIds: ['S', 'A', 'B'],
          votes: {'S': 'A', 'A': 'B', 'B': 'A'},
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Storyteller cannot vote'),
        )),
      );
    });

    test('self-vote → error', () {
      expect(
        () => RoundInput(
          storytellerPlayerId: 'S',
          allPlayerIds: ['S', 'A', 'B'],
          votes: {'A': 'A', 'B': 'S'},
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('cannot vote for themselves'),
        )),
      );
    });

    test('missing voter → error', () {
      expect(
        () => RoundInput(
          storytellerPlayerId: 'S',
          allPlayerIds: ['S', 'A', 'B'],
          votes: {'A': 'S'},
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('did not vote'),
        )),
      );
    });

    test('unknown player ID in voter → error', () {
      expect(
        () => RoundInput(
          storytellerPlayerId: 'S',
          allPlayerIds: ['S', 'A', 'B'],
          votes: {'A': 'S', 'B': 'S', 'X': 'S'},
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('not in allPlayerIds'),
        )),
      );
    });

    test('unknown player ID in vote target → error', () {
      expect(
        () => RoundInput(
          storytellerPlayerId: 'S',
          allPlayerIds: ['S', 'A', 'B'],
          votes: {'A': 'Z', 'B': 'S'},
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('not in allPlayerIds'),
        )),
      );
    });

    test('validateInput returns all errors without throwing', () {
      // Construct input bypassing the factory to test validateInput directly.
      // We use a raw instance via the private constructor workaround:
      // Just call validateInput with a manually crafted scenario.
      final errors = engine.validateInput(RoundInput.unvalidated(
        storytellerPlayerId: 'S',
        allPlayerIds: ['S', 'A', 'B'],
        votes: {'S': 'A', 'A': 'A'},
      ));

      expect(errors, isNotEmpty);
      // Should report: storyteller voting, self-vote by A, missing voter B.
      expect(errors.any((e) => e.contains('Storyteller cannot vote')), isTrue);
      expect(errors.any((e) => e.contains('cannot vote for themselves')), isTrue);
      expect(errors.any((e) => e.contains('did not vote')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // Determinism
  // ─────────────────────────────────────────────────────────────
  group('determinism', () {
    test('same input 100 times → same output', () {
      final input = validInput(
        storyteller: 'S',
        players: ['S', 'A', 'B', 'C', 'D'],
        votes: {'A': 'S', 'B': 'C', 'C': 'A', 'D': 'S'},
      );

      final firstResult = engine.computeRound(input);
      final firstEntries = firstResult.scoreEntries.toList();
      final firstOutcome = firstResult.clueOutcome;

      for (var i = 1; i < 100; i++) {
        final result = engine.computeRound(input);
        expect(result.clueOutcome, firstOutcome);
        expect(result.scoreEntries.length, firstEntries.length);
        for (var j = 0; j < firstEntries.length; j++) {
          expect(result.scoreEntries[j], firstEntries[j]);
        }
        // Also verify total deltas match.
        for (final player in ['S', 'A', 'B', 'C', 'D']) {
          expect(result.totalDeltaFor(player), firstResult.totalDeltaFor(player));
        }
      }
    });
  });

  // ─────────────────────────────────────────────────────────────
  // ScoreReason label extension
  // ─────────────────────────────────────────────────────────────
  group('ScoreReason labels', () {
    test('all reasons have non-empty labels', () {
      for (final reason in ScoreReason.values) {
        expect(reason.label, isNotEmpty);
      }
    });

    test('labels return expected strings', () {
      expect(ScoreReason.storytellerGoodClue.label, 'Good clue');
      expect(ScoreReason.correctGuess.label, 'Correct guess');
      expect(ScoreReason.fooledBonus.label, 'Fooled opponent');
      expect(ScoreReason.allGuessedBonus.label, 'Bad clue bonus');
    });
  });
}
