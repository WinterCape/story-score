import 'package:story_score/data/export/export_schema.dart';

/// Converts session data to export formats (JSON, CSV).
class SessionExporter {
  const SessionExporter();

  /// Convert to formatted JSON string.
  String toJson(ExportedSession session) => session.toJsonString();

  /// Convert to CSV format for spreadsheet use.
  String toCsv(ExportedSession session) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Round,Storyteller,Player,Score Change,Reason,Running Total');

    // Build player ID → name lookup
    final playerNames = <String, String>{};
    for (final p in session.players) {
      playerNames[p.id] = p.name;
    }

    // Track running totals
    final runningTotals = <String, int>{};
    for (final p in session.players) {
      runningTotals[p.id] = 0;
    }

    // Output each round's score changes
    for (final round in session.rounds) {
      final storytellerName =
          playerNames[round.storytellerPlayerId] ?? 'Unknown';

      for (final sc in round.scoreChanges) {
        final playerName = playerNames[sc.playerId] ?? 'Unknown';
        runningTotals[sc.playerId] =
            (runningTotals[sc.playerId] ?? 0) + sc.delta;

        final deltaStr = sc.delta >= 0 ? '+${sc.delta}' : '${sc.delta}';
        buffer.writeln(
          '${round.roundNumber},'
          '$storytellerName,'
          '$playerName,'
          '$deltaStr,'
          '${sc.reasonLabel},'
          '${runningTotals[sc.playerId]}',
        );
      }
    }

    return buffer.toString();
  }
}
