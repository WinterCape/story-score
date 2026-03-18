import 'package:flutter/foundation.dart' show visibleForTesting;

import 'score_reason.dart';

/// The votes and player configuration for a single round.
///
/// [storytellerPlayerId] is the player who gave the clue this round.
/// [allPlayerIds] contains every player in the game (including the storyteller).
/// [votes] maps each non-storyteller's ID to the player ID whose card they voted for.
class RoundInput {
  final String storytellerPlayerId;
  final List<String> allPlayerIds;
  final Map<String, String> votes;

  const RoundInput._({
    required this.storytellerPlayerId,
    required this.allPlayerIds,
    required this.votes,
  });

  /// Creates a [RoundInput] without validation. Only for testing [ScoringEngine.validateInput].
  @visibleForTesting
  const RoundInput.unvalidated({
    required this.storytellerPlayerId,
    required this.allPlayerIds,
    required this.votes,
  });

  /// Creates a [RoundInput] after validating the data.
  ///
  /// Throws [ArgumentError] if validation fails. Use [ScoringEngine.validateInput]
  /// to check for errors without throwing.
  factory RoundInput({
    required String storytellerPlayerId,
    required List<String> allPlayerIds,
    required Map<String, String> votes,
  }) {
    final input = RoundInput._(
      storytellerPlayerId: storytellerPlayerId,
      allPlayerIds: allPlayerIds,
      votes: votes,
    );
    final errors = const ScoringEngine().validateInput(input);
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('; '));
    }
    return input;
  }
}

/// A single point award for one player in a round.
class ScoreEntry {
  final String playerId;
  final int delta;
  final ScoreReason reason;

  const ScoreEntry({
    required this.playerId,
    required this.delta,
    required this.reason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          playerId == other.playerId &&
          delta == other.delta &&
          reason == other.reason;

  @override
  int get hashCode => Object.hash(playerId, delta, reason);

  @override
  String toString() => 'ScoreEntry($playerId, +$delta, ${reason.name})';
}

/// The complete scoring result for a round.
class RoundResult {
  final List<ScoreEntry> scoreEntries;
  final ClueOutcome clueOutcome;

  const RoundResult({required this.scoreEntries, required this.clueOutcome});

  /// Returns the total points earned by [playerId] in this round.
  int totalDeltaFor(String playerId) {
    return scoreEntries
        .where((e) => e.playerId == playerId)
        .fold(0, (sum, e) => sum + e.delta);
  }
}

/// Pure, stateless scoring engine for storytelling card game rounds.
///
/// Implements the standard scoring rules:
/// - **Perfect fail** (all or none vote for storyteller): storyteller 0, everyone else +2.
/// - **Good clue** (some vote for storyteller): storyteller +3, each correct guesser +3.
/// - **Always**: each non-storyteller gets +1 per vote their card received.
class ScoringEngine {
  const ScoringEngine();

  /// Computes scores for a single round.
  ///
  /// The [input] must pass validation (enforced by [RoundInput]'s factory constructor).
  RoundResult computeRound(RoundInput input) {
    final storyteller = input.storytellerPlayerId;
    final nonStorytellers = input.allPlayerIds
        .where((id) => id != storyteller)
        .toList();

    // Count votes for the storyteller's card.
    final votesForStoryteller = input.votes.values
        .where((v) => v == storyteller)
        .length;

    final isPerfectFail =
        votesForStoryteller == 0 ||
        votesForStoryteller == nonStorytellers.length;

    final entries = <ScoreEntry>[];

    if (isPerfectFail) {
      // Storyteller gets 0; every non-storyteller gets +2.
      for (final player in nonStorytellers) {
        entries.add(
          ScoreEntry(
            playerId: player,
            delta: 2,
            reason: ScoreReason.allGuessedBonus,
          ),
        );
      }
    } else {
      // Storyteller gets +3.
      entries.add(
        ScoreEntry(
          playerId: storyteller,
          delta: 3,
          reason: ScoreReason.storytellerGoodClue,
        ),
      );

      // Each correct guesser gets +3.
      for (final entry in input.votes.entries) {
        if (entry.value == storyteller) {
          entries.add(
            ScoreEntry(
              playerId: entry.key,
              delta: 3,
              reason: ScoreReason.correctGuess,
            ),
          );
        }
      }
    }

    // Fooled bonus: each non-storyteller gets +1 per vote their card received.
    // The storyteller does NOT get bonus for votes on the storyteller's card.
    for (final player in nonStorytellers) {
      final votesReceived = input.votes.values.where((v) => v == player).length;
      if (votesReceived > 0) {
        entries.add(
          ScoreEntry(
            playerId: player,
            delta: votesReceived,
            reason: ScoreReason.fooledBonus,
          ),
        );
      }
    }

    return RoundResult(
      scoreEntries: entries,
      clueOutcome: isPerfectFail
          ? ClueOutcome.perfectFail
          : ClueOutcome.goodClue,
    );
  }

  /// Validates a [RoundInput] and returns a list of error messages.
  ///
  /// Returns an empty list if the input is valid.
  List<String> validateInput(RoundInput input) {
    final errors = <String>[];
    final allIds = input.allPlayerIds.toSet();

    // Storyteller must be in allPlayerIds.
    if (!allIds.contains(input.storytellerPlayerId)) {
      errors.add(
        'Storyteller "${input.storytellerPlayerId}" is not in allPlayerIds',
      );
    }

    // Storyteller cannot be a voter.
    if (input.votes.containsKey(input.storytellerPlayerId)) {
      errors.add('Storyteller cannot vote');
    }

    // Every voter and vote target must be in allPlayerIds.
    for (final entry in input.votes.entries) {
      if (!allIds.contains(entry.key)) {
        errors.add('Voter "${entry.key}" is not in allPlayerIds');
      }
      if (!allIds.contains(entry.value)) {
        errors.add(
          'Vote target "${entry.value}" from voter "${entry.key}" is not in allPlayerIds',
        );
      }
      // No self-votes.
      if (entry.key == entry.value) {
        errors.add('Player "${entry.key}" cannot vote for themselves');
      }
    }

    // All non-storytellers must vote exactly once.
    final expectedVoters = allIds
        .where((id) => id != input.storytellerPlayerId)
        .toSet();
    final actualVoters = input.votes.keys.toSet();
    final missingVoters = expectedVoters.difference(actualVoters);
    final extraVoters = actualVoters.difference(expectedVoters);

    for (final missing in missingVoters) {
      errors.add('Player "$missing" did not vote');
    }
    for (final extra in extraVoters) {
      if (extra != input.storytellerPlayerId) {
        errors.add('Voter "$extra" is not a valid non-storyteller');
      }
    }

    return errors;
  }
}
