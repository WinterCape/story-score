import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/export_schema.dart';

/// Builds an [ExportedSession] from the database for a given [sessionId].
///
/// Reads the session, players, rounds (with votes and score changes) from the
/// DAOs and assembles them into the export schema.
Future<ExportedSession> buildExportedSession({
  required String sessionId,
  required SessionDao sessionDao,
  required RoundDao roundDao,
  required String appVersion,
}) async {
  // 1. Load session
  final session = await sessionDao.watchSession(sessionId).first;

  if (session == null) {
    throw StateError('Session $sessionId not found');
  }

  // 2. Load players
  final players = await sessionDao.watchPlayersForSession(sessionId).first;

  // 3. Load rounds
  final rounds = await roundDao.watchRoundsForSession(sessionId).first;

  // 4. For each round, load votes and score changes via watchRoundWithDetails
  final exportedRounds = <ExportedRound>[];
  for (final round in rounds) {
    final details = await roundDao.watchRoundWithDetails(round.id).first;

    if (details == null) continue;

    exportedRounds.add(
      ExportedRound(
        id: round.id,
        roundNumber: round.roundNumber,
        storytellerPlayerId: round.storytellerPlayerId,
        note: round.note,
        createdAt: round.createdAt,
        votes: details.votes
            .map(
              (v) => ExportedVote(
                voterPlayerId: v.voterPlayerId,
                votedForPlayerId: v.votedForPlayerId,
              ),
            )
            .toList(),
        scoreChanges: details.scoreChanges
            .map(
              (sc) => ExportedScoreChange(
                playerId: sc.playerId,
                delta: sc.delta,
                reasonCode: sc.reasonCode,
                reasonLabel: sc.reasonLabel,
              ),
            )
            .toList(),
      ),
    );
  }

  // 5. Map target type enum to string
  final targetTypeStr = switch (session.targetType) {
    TargetType.score => 'score',
    TargetType.rounds => 'rounds',
    TargetType.freeplay => 'freeplay',
  };

  // 6. Map game status enum to string
  final statusStr = switch (session.status) {
    GameStatus.active => 'active',
    GameStatus.paused => 'paused',
    GameStatus.completed => 'completed',
  };

  return ExportedSession(
    appVersion: appVersion,
    exportedAt: DateTime.now(),
    session: ExportedGameSession(
      id: session.id,
      title: session.title,
      status: statusStr,
      targetType: targetTypeStr,
      targetScore: session.targetScore,
      roundCount: session.roundCount,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    ),
    players: players
        .map(
          (p) => ExportedPlayer(
            id: p.id,
            name: p.name,
            seatOrder: p.seatOrder,
            colorKey: p.colorKey,
            avatarStyle: p.avatarStyle,
            currentScore: p.currentScore,
          ),
        )
        .toList(),
    rounds: exportedRounds,
  );
}
