// Pure Dart data models for the stats system.
//
// Zero Flutter imports. These models are consumed by [StatsCalculator]
// and surfaced through providers to the UI layer.

/// Normalizes a player name for comparison and deduplication.
///
/// Trims whitespace and lowercases. Two names that normalize to the
/// same string are considered the same player across games.
String normalizeName(String name) => name.trim().toLowerCase();

/// A player's final score in a completed game.
class PlayerScore {
  final String name;
  final String normalizedName;
  final int finalScore;
  final bool isWinner;

  const PlayerScore({
    required this.name,
    required this.normalizedName,
    required this.finalScore,
    required this.isWinner,
  });
}

/// Data for a single round within a game session.
class RoundData {
  /// 1-based round number.
  final int roundNumber;

  /// The player ID who was storyteller this round.
  final String storytellerId;

  /// Maps voter player ID to the player ID they voted for.
  final Map<String, String> votes;

  /// Maps player ID to their score delta this round.
  final Map<String, int> scoreDeltas;

  /// Whether the storyteller gave a good clue (some but not all guessed).
  final bool hasGoodClue;

  const RoundData({
    required this.roundNumber,
    required this.storytellerId,
    required this.votes,
    required this.scoreDeltas,
    required this.hasGoodClue,
  });
}

/// All the data for a completed game session.
class CompletedGameData {
  final String sessionId;
  final List<PlayerScore> players;
  final List<RoundData> rounds;
  final DateTime createdAt;

  const CompletedGameData({
    required this.sessionId,
    required this.players,
    required this.rounds,
    required this.createdAt,
  });
}

/// Stats computed from a single game session.
class SessionStats {
  /// The round with the highest total score delta across all players.
  final int bestRound;

  /// The round with the lowest total score delta across all players.
  final int worstRound;

  /// Fraction of non-storyteller votes that correctly identified the
  /// storyteller's card (0.0 to 1.0).
  final double guessAccuracy;

  /// Total fooled-bonus points earned across all rounds.
  final int totalBonusPoints;

  /// Fraction of storyteller rounds that resulted in a good clue (0.0 to 1.0).
  final double storytellerSuccessRate;

  /// The name of the player with the highest score.
  final String mvpName;

  /// The score of the MVP.
  final int mvpScore;

  const SessionStats({
    required this.bestRound,
    required this.worstRound,
    required this.guessAccuracy,
    required this.totalBonusPoints,
    required this.storytellerSuccessRate,
    required this.mvpName,
    required this.mvpScore,
  });
}

/// All-time stats for a single player across multiple games.
class PlayerAllTimeStats {
  final String normalizedName;
  final int gamesPlayed;
  final int wins;
  final double winRate;
  final double avgScore;
  final int bestGameScore;
  final int totalPoints;
  final int currentWinStreak;
  final int longestWinStreak;
  final int gamesSinceLastWin;

  const PlayerAllTimeStats({
    required this.normalizedName,
    required this.gamesPlayed,
    required this.wins,
    required this.winRate,
    required this.avgScore,
    required this.bestGameScore,
    required this.totalPoints,
    required this.currentWinStreak,
    required this.longestWinStreak,
    required this.gamesSinceLastWin,
  });
}

/// Head-to-head record between two players.
class HeadToHeadRecord {
  final String playerA;
  final String playerB;
  final int winsA;
  final int winsB;
  final int ties;
  final int sharedGames;

  const HeadToHeadRecord({
    required this.playerA,
    required this.playerB,
    required this.winsA,
    required this.winsB,
    required this.ties,
    required this.sharedGames,
  });
}

/// A player's entry on the all-time leaderboard.
class LeaderboardEntry implements Comparable<LeaderboardEntry> {
  final String normalizedName;
  final String displayName;
  final int wins;
  final double winRate;
  final int gamesPlayed;
  final int totalPoints;

  const LeaderboardEntry({
    required this.normalizedName,
    required this.displayName,
    required this.wins,
    required this.winRate,
    required this.gamesPlayed,
    required this.totalPoints,
  });

  /// Sorts by win rate descending, then by total points descending.
  @override
  int compareTo(LeaderboardEntry other) {
    final byWinRate = other.winRate.compareTo(winRate);
    if (byWinRate != 0) return byWinRate;
    return other.totalPoints.compareTo(totalPoints);
  }
}
