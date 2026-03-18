// Pure Dart stats calculator for game statistics.
//
// Zero Flutter imports. All methods are deterministic:
// same inputs produce same outputs.
import 'stats_models.dart';

/// Computes various statistics from game data.
///
/// All methods are static and pure — no side effects, no persistence.
abstract final class StatsCalculator {
  /// Computes session-level stats from a list of players and rounds.
  ///
  /// Requires at least one round. Players must include final scores.
  static SessionStats computeSessionStats({
    required List<PlayerScore> players,
    required List<RoundData> rounds,
  }) {
    if (rounds.isEmpty) {
      return SessionStats(
        bestRound: 0,
        worstRound: 0,
        guessAccuracy: 0.0,
        totalBonusPoints: 0,
        storytellerSuccessRate: 0.0,
        mvpName: players.isNotEmpty ? players.first.name : '',
        mvpScore: players.isNotEmpty ? players.first.finalScore : 0,
      );
    }

    // Best and worst rounds by total points scored
    int bestRound = rounds.first.roundNumber;
    int worstRound = rounds.first.roundNumber;
    int bestTotal = _roundTotal(rounds.first);
    int worstTotal = bestTotal;

    for (final round in rounds) {
      final total = _roundTotal(round);
      if (total > bestTotal) {
        bestTotal = total;
        bestRound = round.roundNumber;
      }
      if (total < worstTotal) {
        worstTotal = total;
        worstRound = round.roundNumber;
      }
    }

    // Guess accuracy: correct guesses / total non-storyteller votes
    int correctGuesses = 0;
    int totalVotes = 0;
    for (final round in rounds) {
      for (final entry in round.votes.entries) {
        totalVotes++;
        if (entry.value == round.storytellerId) {
          correctGuesses++;
        }
      }
    }
    final guessAccuracy = totalVotes > 0 ? correctGuesses / totalVotes : 0.0;

    // Total bonus points (fooled bonus = non-storyteller, non-correct-guess deltas
    // beyond the base awards). We approximate by summing all deltas that come from
    // votes received by non-storytellers (the fooled bonus).
    // Since we only have scoreDeltas map, we compute bonus as total points minus
    // base awards. Simpler: sum all score deltas across all rounds for all players.
    // The "bonus" here means fooled-bonus points specifically.
    // We compute it as: for each round, for each non-storyteller player,
    // any points beyond the base 2 (perfect fail) or 3 (correct guess) are bonus.
    // Actually, the plan says "totalBonusPoints" which likely means total fooled bonus.
    // We'll compute it from the scoreDeltas — points that aren't from storyteller good
    // clue, correct guess, or all-guessed bonus are bonus points.
    // Simplification: we know from the scoring engine that bonus points = fooled bonus.
    // In a good-clue round: storyteller gets 3, correct guessers get 3, bonus = remaining.
    // In a perfect-fail round: everyone gets 2, bonus = remaining above 2 per player.
    // Since we have scoreDeltas per player per round, we compute total bonus as:
    int totalBonusPoints = 0;
    for (final round in rounds) {
      if (round.hasGoodClue) {
        // Good clue: storyteller gets 3, correct guessers get 3, rest is bonus
        for (final entry in round.scoreDeltas.entries) {
          final playerId = entry.key;
          final delta = entry.value;
          if (playerId == round.storytellerId) {
            // Storyteller base = 3, any extra is bonus (shouldn't happen)
            totalBonusPoints += (delta > 3 ? delta - 3 : 0);
          } else {
            // Non-storyteller: check if they guessed correctly
            final votedFor = round.votes[playerId];
            final guessedCorrectly = votedFor == round.storytellerId;
            final basePts = guessedCorrectly ? 3 : 0;
            totalBonusPoints += (delta > basePts ? delta - basePts : 0);
          }
        }
      } else {
        // Perfect fail: all non-storytellers get 2, rest is bonus
        for (final entry in round.scoreDeltas.entries) {
          final playerId = entry.key;
          final delta = entry.value;
          if (playerId != round.storytellerId) {
            totalBonusPoints += (delta > 2 ? delta - 2 : 0);
          }
        }
      }
    }

    // Storyteller success rate
    final goodClueCount = rounds.where((r) => r.hasGoodClue).length;
    final storytellerSuccessRate = rounds.isNotEmpty
        ? goodClueCount / rounds.length
        : 0.0;

    // MVP
    final mvp = players.reduce((a, b) => a.finalScore >= b.finalScore ? a : b);

    return SessionStats(
      bestRound: bestRound,
      worstRound: worstRound,
      guessAccuracy: guessAccuracy,
      totalBonusPoints: totalBonusPoints,
      storytellerSuccessRate: storytellerSuccessRate,
      mvpName: mvp.name,
      mvpScore: mvp.finalScore,
    );
  }

  /// Computes all-time stats for a single player across all completed games.
  ///
  /// Games are expected to be ordered chronologically (oldest first).
  static PlayerAllTimeStats computePlayerAllTimeStats({
    required String normalizedName,
    required List<CompletedGameData> allGames,
  }) {
    // Filter to games this player participated in
    final playerGames = allGames
        .where(
          (game) => game.players.any((p) => p.normalizedName == normalizedName),
        )
        .toList();

    if (playerGames.isEmpty) {
      return PlayerAllTimeStats(
        normalizedName: normalizedName,
        gamesPlayed: 0,
        wins: 0,
        winRate: 0.0,
        avgScore: 0.0,
        bestGameScore: 0,
        totalPoints: 0,
        currentWinStreak: 0,
        longestWinStreak: 0,
        gamesSinceLastWin: 0,
      );
    }

    int wins = 0;
    int totalPoints = 0;
    int bestGameScore = 0;
    int currentWinStreak = 0;
    int longestWinStreak = 0;
    int gamesSinceLastWin = 0;
    bool lastWinFound = false;

    // Process games chronologically for streak tracking
    final streaks = <bool>[]; // true = win, false = loss/tie
    for (final game in playerGames) {
      final player = game.players.firstWhere(
        (p) => p.normalizedName == normalizedName,
      );
      totalPoints += player.finalScore;
      if (player.finalScore > bestGameScore) {
        bestGameScore = player.finalScore;
      }
      streaks.add(player.isWinner);
      if (player.isWinner) {
        wins++;
      }
    }

    // Current win streak (from most recent game backwards)
    for (int i = streaks.length - 1; i >= 0; i--) {
      if (streaks[i]) {
        currentWinStreak++;
      } else {
        break;
      }
    }

    // Longest win streak
    int tempStreak = 0;
    for (final won in streaks) {
      if (won) {
        tempStreak++;
        if (tempStreak > longestWinStreak) {
          longestWinStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    // Games since last win
    for (int i = streaks.length - 1; i >= 0; i--) {
      if (streaks[i]) {
        lastWinFound = true;
        break;
      }
      gamesSinceLastWin++;
    }
    if (!lastWinFound) {
      gamesSinceLastWin = playerGames.length;
    }

    final gamesPlayed = playerGames.length;
    final winRate = gamesPlayed > 0 ? wins / gamesPlayed : 0.0;
    final avgScore = gamesPlayed > 0 ? totalPoints / gamesPlayed : 0.0;

    return PlayerAllTimeStats(
      normalizedName: normalizedName,
      gamesPlayed: gamesPlayed,
      wins: wins,
      winRate: winRate,
      avgScore: avgScore,
      bestGameScore: bestGameScore,
      totalPoints: totalPoints,
      currentWinStreak: currentWinStreak,
      longestWinStreak: longestWinStreak,
      gamesSinceLastWin: gamesSinceLastWin,
    );
  }

  /// Computes head-to-head record between two players.
  ///
  /// Only considers games where both players participated.
  static HeadToHeadRecord computeHeadToHead({
    required String playerA,
    required String playerB,
    required List<CompletedGameData> sharedGames,
  }) {
    final normalizedA = normalizeName(playerA);
    final normalizedB = normalizeName(playerB);

    int winsA = 0;
    int winsB = 0;
    int ties = 0;
    int sharedCount = 0;

    for (final game in sharedGames) {
      final pA = game.players
          .where((p) => p.normalizedName == normalizedA)
          .toList();
      final pB = game.players
          .where((p) => p.normalizedName == normalizedB)
          .toList();

      if (pA.isEmpty || pB.isEmpty) continue;
      sharedCount++;

      final scoreA = pA.first.finalScore;
      final scoreB = pB.first.finalScore;

      if (scoreA > scoreB) {
        winsA++;
      } else if (scoreB > scoreA) {
        winsB++;
      } else {
        ties++;
      }
    }

    return HeadToHeadRecord(
      playerA: playerA,
      playerB: playerB,
      winsA: winsA,
      winsB: winsB,
      ties: ties,
      sharedGames: sharedCount,
    );
  }

  /// Computes the all-time leaderboard.
  ///
  /// Only includes players with at least [minGames] completed games.
  /// Results are sorted by win rate descending, then total points descending.
  static List<LeaderboardEntry> computeLeaderboard({
    required List<CompletedGameData> allGames,
    int minGames = 3,
  }) {
    // Collect stats per normalized name
    final playerMap = <String, _LeaderboardAccumulator>{};

    for (final game in allGames) {
      for (final player in game.players) {
        final acc = playerMap.putIfAbsent(
          player.normalizedName,
          () => _LeaderboardAccumulator(
            normalizedName: player.normalizedName,
            displayName: player.name,
          ),
        );
        acc.gamesPlayed++;
        acc.totalPoints += player.finalScore;
        if (player.isWinner) {
          acc.wins++;
        }
        // Keep the most recent display name
        acc.displayName = player.name;
      }
    }

    // Filter by min games and build entries
    final entries = playerMap.values
        .where((acc) => acc.gamesPlayed >= minGames)
        .map(
          (acc) => LeaderboardEntry(
            normalizedName: acc.normalizedName,
            displayName: acc.displayName,
            wins: acc.wins,
            winRate: acc.gamesPlayed > 0 ? acc.wins / acc.gamesPlayed : 0.0,
            gamesPlayed: acc.gamesPlayed,
            totalPoints: acc.totalPoints,
          ),
        )
        .toList();

    entries.sort();
    return entries;
  }

  static int _roundTotal(RoundData round) {
    return round.scoreDeltas.values.fold(0, (sum, d) => sum + d);
  }
}

class _LeaderboardAccumulator {
  final String normalizedName;
  String displayName;
  int gamesPlayed = 0;
  int wins = 0;
  int totalPoints = 0;

  _LeaderboardAccumulator({
    required this.normalizedName,
    required this.displayName,
  });
}
