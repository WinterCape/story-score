// Detects player milestones during a game session.
//
// Pure Dart, zero Flutter imports. Milestones are determined from
// the full history of rounds in the session plus the latest round.
import 'stats_models.dart';

/// Milestones that can be detected during gameplay.
enum Milestone {
  /// First time a player correctly guesses the storyteller's card.
  firstCorrectGuess,

  /// Player has 3 correct guesses in a row.
  onFire,

  /// Storyteller has 3 good clues in a row.
  masterStoryteller,

  /// Player received 3+ bonus votes (fooled 3+ opponents) in a single round.
  trickster,
}

/// A milestone detected for a specific player.
class MilestoneResult {
  final Milestone milestone;
  final String playerId;
  final String playerName;

  const MilestoneResult({
    required this.milestone,
    required this.playerId,
    required this.playerName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MilestoneResult &&
          runtimeType == other.runtimeType &&
          milestone == other.milestone &&
          playerId == other.playerId;

  @override
  int get hashCode => Object.hash(milestone, playerId);

  @override
  String toString() =>
      'MilestoneResult(${milestone.name}, $playerId, $playerName)';
}

/// Detects milestones based on session round history.
///
/// Stateless: all detection is based on the provided round data.
abstract final class MilestoneDetector {
  /// Detects milestones triggered by [latestRound].
  ///
  /// [sessionRounds] should include all rounds in the session up to
  /// and including [latestRound].
  /// [playerNames] maps player ID to display name.
  static List<MilestoneResult> detectMilestones({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required Map<String, String> playerNames,
  }) {
    final results = <MilestoneResult>[];

    // Detect first correct guess
    _detectFirstCorrectGuess(
      sessionRounds: sessionRounds,
      latestRound: latestRound,
      playerNames: playerNames,
      results: results,
    );

    // Detect on fire (3 correct guesses in a row)
    _detectOnFire(
      sessionRounds: sessionRounds,
      latestRound: latestRound,
      playerNames: playerNames,
      results: results,
    );

    // Detect master storyteller (3 good clues in a row)
    _detectMasterStoryteller(
      sessionRounds: sessionRounds,
      latestRound: latestRound,
      playerNames: playerNames,
      results: results,
    );

    // Detect trickster (3+ bonus votes in single round)
    _detectTrickster(
      latestRound: latestRound,
      playerNames: playerNames,
      results: results,
    );

    return results;
  }

  /// First correct guess: triggered the first time a player votes for the
  /// storyteller correctly in the entire session.
  static void _detectFirstCorrectGuess({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required Map<String, String> playerNames,
    required List<MilestoneResult> results,
  }) {
    // Find players who guessed correctly in the latest round
    final correctGuessersThisRound = <String>{};
    for (final entry in latestRound.votes.entries) {
      if (entry.value == latestRound.storytellerId) {
        correctGuessersThisRound.add(entry.key);
      }
    }

    if (correctGuessersThisRound.isEmpty) return;

    // Find players who guessed correctly in any PREVIOUS round
    final previousCorrectGuessers = <String>{};
    for (final round in sessionRounds) {
      if (round.roundNumber >= latestRound.roundNumber) continue;
      for (final entry in round.votes.entries) {
        if (entry.value == round.storytellerId) {
          previousCorrectGuessers.add(entry.key);
        }
      }
    }

    // Milestone: first correct guess ever in this session
    for (final playerId in correctGuessersThisRound) {
      if (!previousCorrectGuessers.contains(playerId)) {
        results.add(
          MilestoneResult(
            milestone: Milestone.firstCorrectGuess,
            playerId: playerId,
            playerName: playerNames[playerId] ?? playerId,
          ),
        );
      }
    }
  }

  /// On Fire: player has 3 consecutive correct guesses ending with this round.
  static void _detectOnFire({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required Map<String, String> playerNames,
    required List<MilestoneResult> results,
  }) {
    // Check each player who guessed correctly this round
    for (final entry in latestRound.votes.entries) {
      if (entry.value != latestRound.storytellerId) continue;

      final playerId = entry.key;
      int streak = 0;

      // Count consecutive correct guesses backwards from latest round
      final sortedRounds = List.of(sessionRounds)
        ..sort((a, b) => b.roundNumber.compareTo(a.roundNumber));

      for (final round in sortedRounds) {
        // Skip rounds where this player was the storyteller (can't vote)
        if (round.storytellerId == playerId) continue;

        final vote = round.votes[playerId];
        if (vote == round.storytellerId) {
          streak++;
        } else {
          break;
        }
      }

      if (streak >= 3) {
        results.add(
          MilestoneResult(
            milestone: Milestone.onFire,
            playerId: playerId,
            playerName: playerNames[playerId] ?? playerId,
          ),
        );
      }
    }
  }

  /// Master Storyteller: the storyteller has 3 consecutive good clues.
  static void _detectMasterStoryteller({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required Map<String, String> playerNames,
    required List<MilestoneResult> results,
  }) {
    if (!latestRound.hasGoodClue) return;

    final storytellerId = latestRound.storytellerId;
    int streak = 0;

    // Count consecutive good clues backwards from latest round,
    // only considering rounds where this player was storyteller
    final sortedRounds = List.of(sessionRounds)
      ..sort((a, b) => b.roundNumber.compareTo(a.roundNumber));

    for (final round in sortedRounds) {
      if (round.storytellerId != storytellerId) continue;

      if (round.hasGoodClue) {
        streak++;
      } else {
        break;
      }
    }

    if (streak >= 3) {
      results.add(
        MilestoneResult(
          milestone: Milestone.masterStoryteller,
          playerId: storytellerId,
          playerName: playerNames[storytellerId] ?? storytellerId,
        ),
      );
    }
  }

  /// Trickster: a non-storyteller received 3+ votes on their card in a
  /// single round (fooled 3+ opponents).
  static void _detectTrickster({
    required RoundData latestRound,
    required Map<String, String> playerNames,
    required List<MilestoneResult> results,
  }) {
    // Count votes received by each non-storyteller
    final votesReceived = <String, int>{};
    for (final votedFor in latestRound.votes.values) {
      if (votedFor == latestRound.storytellerId) continue;
      votesReceived[votedFor] = (votesReceived[votedFor] ?? 0) + 1;
    }

    for (final entry in votesReceived.entries) {
      if (entry.value >= 3) {
        results.add(
          MilestoneResult(
            milestone: Milestone.trickster,
            playerId: entry.key,
            playerName: playerNames[entry.key] ?? entry.key,
          ),
        );
      }
    }
  }
}
