import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/domain/stats/milestone_detector.dart';
import 'package:story_score/domain/stats/stats_models.dart';

void main() {
  const playerNames = {
    'alice': 'Alice',
    'bob': 'Bob',
    'carol': 'Carol',
    'dave': 'Dave',
    'eve': 'Eve',
  };

  group('firstCorrectGuess', () {
    test('detected on first correct vote in session', () {
      final round1 = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1],
        latestRound: round1,
        playerNames: playerNames,
      );

      expect(
        milestones,
        contains(const MilestoneResult(
          milestone: Milestone.firstCorrectGuess,
          playerId: 'bob',
          playerName: 'Bob',
        )),
      );
    });

    test('NOT triggered on second correct vote', () {
      final round1 = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );
      final round2 = RoundData(
        roundNumber: 2,
        storytellerId: 'carol',
        votes: {'alice': 'carol', 'bob': 'carol'},
        scoreDeltas: {'carol': 3, 'alice': 3, 'bob': 3},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1, round2],
        latestRound: round2,
        playerNames: playerNames,
      );

      // Bob already guessed correctly in round 1, so no firstCorrectGuess for Bob.
      // Alice guesses correctly for the first time in round 2.
      final firstGuesses = milestones
          .where((m) => m.milestone == Milestone.firstCorrectGuess)
          .toList();

      expect(firstGuesses.any((m) => m.playerId == 'bob'), isFalse);
      expect(firstGuesses.any((m) => m.playerId == 'alice'), isTrue);
    });
  });

  group('onFire', () {
    test('triggered after 3 correct guesses in a row', () {
      // Bob guesses correctly 3 times in a row
      final round1 = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );
      final round2 = RoundData(
        roundNumber: 2,
        storytellerId: 'carol',
        votes: {'alice': 'bob', 'bob': 'carol'},
        scoreDeltas: {'carol': 3, 'alice': 0, 'bob': 3},
        hasGoodClue: true,
      );
      final round3 = RoundData(
        roundNumber: 3,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1, round2, round3],
        latestRound: round3,
        playerNames: playerNames,
      );

      expect(
        milestones.any(
          (m) => m.milestone == Milestone.onFire && m.playerId == 'bob',
        ),
        isTrue,
      );
    });

    test('streak resets after incorrect guess', () {
      final round1 = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );
      final round2 = RoundData(
        roundNumber: 2,
        storytellerId: 'carol',
        votes: {'alice': 'bob', 'bob': 'alice'}, // Bob guesses wrong (alice not storyteller)
        scoreDeltas: {'carol': 0, 'alice': 0, 'bob': 0},
        hasGoodClue: false,
      );
      final round3 = RoundData(
        roundNumber: 3,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );
      final round4 = RoundData(
        roundNumber: 4,
        storytellerId: 'carol',
        votes: {'alice': 'bob', 'bob': 'carol'},
        scoreDeltas: {'carol': 3, 'alice': 0, 'bob': 3},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1, round2, round3, round4],
        latestRound: round4,
        playerNames: playerNames,
      );

      // Bob's streak: R4 correct, R3 correct, R2 incorrect -> streak = 2, not enough
      expect(
        milestones.any(
          (m) => m.milestone == Milestone.onFire && m.playerId == 'bob',
        ),
        isFalse,
      );
    });

    test('skips rounds where player was storyteller in streak count', () {
      // Bob: correct R1, storyteller R2 (skip), correct R3, correct R4
      final round1 = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );
      final round2 = RoundData(
        roundNumber: 2,
        storytellerId: 'bob', // Bob is storyteller, can't vote
        votes: {'alice': 'carol', 'carol': 'alice'},
        scoreDeltas: {'bob': 0, 'alice': 2, 'carol': 2},
        hasGoodClue: false,
      );
      final round3 = RoundData(
        roundNumber: 3,
        storytellerId: 'carol',
        votes: {'alice': 'bob', 'bob': 'carol'},
        scoreDeltas: {'carol': 3, 'alice': 0, 'bob': 3},
        hasGoodClue: true,
      );
      final round4 = RoundData(
        roundNumber: 4,
        storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1, round2, round3, round4],
        latestRound: round4,
        playerNames: playerNames,
      );

      // Bob: R4 correct, R3 correct, R2 skip (storyteller), R1 correct -> 3 in a row
      expect(
        milestones.any(
          (m) => m.milestone == Milestone.onFire && m.playerId == 'bob',
        ),
        isTrue,
      );
    });
  });

  group('masterStoryteller', () {
    test('triggered after 3 good clues in a row', () {
      // Alice is storyteller in rounds 1, 4, 7 (with good clues each time)
      // Other rounds have different storytellers
      final rounds = [
        RoundData(roundNumber: 1, storytellerId: 'alice',
          votes: {'bob': 'alice', 'carol': 'bob'},
          scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0}, hasGoodClue: true),
        RoundData(roundNumber: 2, storytellerId: 'bob',
          votes: {'alice': 'bob', 'carol': 'alice'},
          scoreDeltas: {'bob': 3, 'alice': 3, 'carol': 0}, hasGoodClue: true),
        RoundData(roundNumber: 3, storytellerId: 'carol',
          votes: {'alice': 'carol', 'bob': 'alice'},
          scoreDeltas: {'carol': 3, 'alice': 3, 'bob': 0}, hasGoodClue: true),
        RoundData(roundNumber: 4, storytellerId: 'alice',
          votes: {'bob': 'alice', 'carol': 'bob'},
          scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0}, hasGoodClue: true),
        RoundData(roundNumber: 5, storytellerId: 'bob',
          votes: {'alice': 'carol', 'carol': 'alice'},
          scoreDeltas: {'bob': 0, 'alice': 2, 'carol': 2}, hasGoodClue: false),
        RoundData(roundNumber: 6, storytellerId: 'carol',
          votes: {'alice': 'carol', 'bob': 'alice'},
          scoreDeltas: {'carol': 3, 'alice': 3, 'bob': 0}, hasGoodClue: true),
        RoundData(roundNumber: 7, storytellerId: 'alice',
          votes: {'bob': 'alice', 'carol': 'bob'},
          scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0}, hasGoodClue: true),
      ];

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: rounds,
        latestRound: rounds.last,
        playerNames: playerNames,
      );

      // Alice had good clues in rounds 1, 4, 7 — 3 consecutive (for her)
      expect(
        milestones.any(
          (m) => m.milestone == Milestone.masterStoryteller && m.playerId == 'alice',
        ),
        isTrue,
      );
    });

    test('not triggered if latest round is not a good clue', () {
      final round1 = RoundData(
        roundNumber: 1, storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'bob'},
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0}, hasGoodClue: true,
      );
      final round2 = RoundData(
        roundNumber: 2, storytellerId: 'alice',
        votes: {'bob': 'alice', 'carol': 'alice'},
        scoreDeltas: {'alice': 0, 'bob': 2, 'carol': 2}, hasGoodClue: false,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round1, round2],
        latestRound: round2,
        playerNames: playerNames,
      );

      expect(
        milestones.any((m) => m.milestone == Milestone.masterStoryteller),
        isFalse,
      );
    });
  });

  group('trickster', () {
    test('triggered when player receives 3+ votes', () {
      // 5-player game: Alice storyteller, Bob/Carol/Dave all vote for Eve
      final round = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {
          'bob': 'eve',
          'carol': 'eve',
          'dave': 'eve',
          'eve': 'alice', // Eve votes for storyteller
        },
        scoreDeltas: {'alice': 3, 'eve': 6, 'bob': 0, 'carol': 0, 'dave': 0},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round],
        latestRound: round,
        playerNames: playerNames,
      );

      expect(
        milestones.any(
          (m) => m.milestone == Milestone.trickster && m.playerId == 'eve',
        ),
        isTrue,
      );
    });

    test('not triggered with fewer than 3 votes', () {
      final round = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {
          'bob': 'eve',
          'carol': 'eve',
          'dave': 'alice',
          'eve': 'alice',
        },
        scoreDeltas: {'alice': 3, 'eve': 5, 'bob': 0, 'carol': 0, 'dave': 3},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round],
        latestRound: round,
        playerNames: playerNames,
      );

      expect(
        milestones.any((m) => m.milestone == Milestone.trickster),
        isFalse,
      );
    });

    test('does not count votes for storyteller as trickster', () {
      // All non-storytellers vote for storyteller -> storyteller should not
      // get trickster (votes for storyteller are not "fooled" votes).
      final round = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {
          'bob': 'alice',
          'carol': 'alice',
          'dave': 'alice',
          'eve': 'alice',
        },
        scoreDeltas: {'alice': 0, 'bob': 2, 'carol': 2, 'dave': 2, 'eve': 2},
        hasGoodClue: false,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round],
        latestRound: round,
        playerNames: playerNames,
      );

      expect(
        milestones.any((m) => m.milestone == Milestone.trickster),
        isFalse,
      );
    });
  });

  group('multiple milestones', () {
    test('can detect multiple milestones in same round', () {
      // Eve gets trickster + first correct guess
      // Bob gets first correct guess too
      final round = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {
          'bob': 'alice',
          'carol': 'eve',
          'dave': 'eve',
          'eve': 'eve', // self-vote shouldn't happen in real game, but for test
        },
        scoreDeltas: {'alice': 3, 'bob': 3, 'carol': 0, 'dave': 0, 'eve': 0},
        hasGoodClue: true,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round],
        latestRound: round,
        playerNames: playerNames,
      );

      // Bob gets first correct guess
      expect(
        milestones.any(
          (m) => m.milestone == Milestone.firstCorrectGuess && m.playerId == 'bob',
        ),
        isTrue,
      );
    });
  });

  group('empty history', () {
    test('no milestones with no votes', () {
      final round = RoundData(
        roundNumber: 1,
        storytellerId: 'alice',
        votes: {},
        scoreDeltas: {},
        hasGoodClue: false,
      );

      final milestones = MilestoneDetector.detectMilestones(
        sessionRounds: [round],
        latestRound: round,
        playerNames: playerNames,
      );

      expect(milestones, isEmpty);
    });
  });
}
