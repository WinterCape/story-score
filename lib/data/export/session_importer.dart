import 'dart:convert';

import 'package:story_score/data/export/export_schema.dart';

/// Import validation result.
class ImportResult {
  final ExportedSession? session;
  final List<String> errors;
  final List<String> warnings;

  const ImportResult({
    this.session,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => errors.isEmpty && session != null;
}

/// Validates and parses imported session JSON.
class SessionImporter {
  const SessionImporter();

  /// Parse and validate a JSON string into an ExportedSession.
  ImportResult fromJson(String jsonString) {
    final errors = <String>[];
    final warnings = <String>[];

    // Parse JSON
    Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return ImportResult(errors: ['Invalid JSON format: $e']);
    }

    // Check schema version
    final version = json['schemaVersion'] as int?;
    if (version == null) {
      errors.add('Missing schemaVersion field');
      return ImportResult(errors: errors);
    }
    if (version != 1) {
      errors.add('Unsupported schema version: $version (expected 1)');
      return ImportResult(errors: errors);
    }

    // Parse session
    ExportedSession session;
    try {
      session = ExportedSession.fromJson(json);
    } catch (e) {
      errors.add('Failed to parse session data: $e');
      return ImportResult(errors: errors);
    }

    // Validate players
    if (session.players.isEmpty) {
      errors.add('Session must have at least one player');
    }
    if (session.players.length < 3) {
      errors.add('Session must have at least 3 players');
    }
    if (session.players.length > 10) {
      errors.add('Session cannot have more than 10 players');
    }

    // Build player ID set for referential integrity checks
    final playerIds = session.players.map((p) => p.id).toSet();

    // Check for duplicate player IDs
    if (playerIds.length != session.players.length) {
      errors.add('Duplicate player IDs found');
    }

    // Validate rounds
    for (final round in session.rounds) {
      // Storyteller must be a valid player
      if (!playerIds.contains(round.storytellerPlayerId)) {
        errors.add(
          'Round ${round.roundNumber}: storyteller ID '
          '${round.storytellerPlayerId} not found in players',
        );
      }

      // Validate votes
      for (final vote in round.votes) {
        if (!playerIds.contains(vote.voterPlayerId)) {
          errors.add(
            'Round ${round.roundNumber}: voter ID '
            '${vote.voterPlayerId} not found in players',
          );
        }
        if (!playerIds.contains(vote.votedForPlayerId)) {
          errors.add(
            'Round ${round.roundNumber}: voted-for ID '
            '${vote.votedForPlayerId} not found in players',
          );
        }
        if (vote.voterPlayerId == vote.votedForPlayerId) {
          warnings.add(
            'Round ${round.roundNumber}: player voted for themselves',
          );
        }
        if (vote.voterPlayerId == round.storytellerPlayerId) {
          warnings.add(
            'Round ${round.roundNumber}: storyteller appears as voter',
          );
        }
      }

      // Validate score changes reference valid players
      for (final sc in round.scoreChanges) {
        if (!playerIds.contains(sc.playerId)) {
          errors.add(
            'Round ${round.roundNumber}: score change player ID '
            '${sc.playerId} not found in players',
          );
        }
      }
    }

    if (errors.isNotEmpty) {
      return ImportResult(errors: errors, warnings: warnings);
    }

    return ImportResult(session: session, errors: errors, warnings: warnings);
  }
}
