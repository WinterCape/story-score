import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/data/export/export_schema.dart';
import 'package:story_score/data/export/session_exporter.dart';
import 'package:story_score/data/export/session_importer.dart';

/// Creates a valid ExportedSession for testing.
ExportedSession _validSession({
  int schemaVersion = 1,
  int playerCount = 4,
  List<ExportedRound>? rounds,
}) {
  final now = DateTime(2025, 1, 15, 10, 30);
  final players = List.generate(
    playerCount,
    (i) => ExportedPlayer(
      id: 'p$i',
      name: 'Player $i',
      seatOrder: i,
      colorKey: 'color$i',
      currentScore: i * 3,
    ),
  );

  return ExportedSession(
    schemaVersion: schemaVersion,
    appVersion: '1.0.0',
    exportedAt: now,
    session: ExportedGameSession(
      id: 'session-1',
      title: 'Test Game',
      status: 'completed',
      targetType: 'rounds',
      targetScore: 30,
      roundCount: 2,
      createdAt: now.subtract(const Duration(hours: 1)),
      updatedAt: now,
    ),
    players: players,
    rounds: rounds ??
        [
          ExportedRound(
            id: 'r1',
            roundNumber: 1,
            storytellerPlayerId: 'p0',
            createdAt: now,
            votes: [
              const ExportedVote(
                  voterPlayerId: 'p1', votedForPlayerId: 'p0'),
              const ExportedVote(
                  voterPlayerId: 'p2', votedForPlayerId: 'p1'),
              const ExportedVote(
                  voterPlayerId: 'p3', votedForPlayerId: 'p0'),
            ],
            scoreChanges: [
              const ExportedScoreChange(
                playerId: 'p0',
                delta: 3,
                reasonCode: 'storytellerGoodClue',
                reasonLabel: 'Good clue',
              ),
              const ExportedScoreChange(
                playerId: 'p1',
                delta: 4,
                reasonCode: 'correctGuess',
                reasonLabel: 'Correct guess',
              ),
            ],
          ),
        ],
  );
}

void main() {
  group('ExportedSession toJson/fromJson round-trip', () {
    test('preserves all fields', () {
      final original = _validSession();
      final json = original.toJson();
      final restored = ExportedSession.fromJson(json);

      expect(restored.schemaVersion, original.schemaVersion);
      expect(restored.appVersion, original.appVersion);
      expect(restored.exportedAt, original.exportedAt);
      expect(restored.session.id, original.session.id);
      expect(restored.session.title, original.session.title);
      expect(restored.session.status, original.session.status);
      expect(restored.session.targetType, original.session.targetType);
      expect(restored.session.targetScore, original.session.targetScore);
      expect(restored.session.roundCount, original.session.roundCount);
      expect(restored.players.length, original.players.length);
      expect(restored.rounds.length, original.rounds.length);

      for (var i = 0; i < original.players.length; i++) {
        expect(restored.players[i].id, original.players[i].id);
        expect(restored.players[i].name, original.players[i].name);
        expect(restored.players[i].seatOrder, original.players[i].seatOrder);
        expect(restored.players[i].colorKey, original.players[i].colorKey);
        expect(
            restored.players[i].currentScore, original.players[i].currentScore);
      }

      final restoredRound = restored.rounds.first;
      final originalRound = original.rounds.first;
      expect(restoredRound.id, originalRound.id);
      expect(restoredRound.roundNumber, originalRound.roundNumber);
      expect(restoredRound.storytellerPlayerId,
          originalRound.storytellerPlayerId);
      expect(restoredRound.votes.length, originalRound.votes.length);
      expect(restoredRound.scoreChanges.length,
          originalRound.scoreChanges.length);
    });
  });

  group('SessionImporter', () {
    const importer = SessionImporter();

    test('rejects invalid schemaVersion', () {
      final session = _validSession(schemaVersion: 2);
      final jsonStr = const JsonEncoder().convert(session.toJson()
        ..['schemaVersion'] = 2);

      final result = importer.fromJson(jsonStr);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Unsupported schema')),
          isTrue);
    });

    test('rejects too few players (<3)', () {
      final session = _validSession(playerCount: 2);
      final jsonStr = session.toJsonString();

      final result = importer.fromJson(jsonStr);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('at least 3')), isTrue);
    });

    test('rejects too many players (>10)', () {
      final session = _validSession(playerCount: 11);
      final jsonStr = session.toJsonString();

      final result = importer.fromJson(jsonStr);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('more than 10')), isTrue);
    });

    test('detects missing player references in rounds', () {
      final session = _validSession(
        rounds: [
          ExportedRound(
            id: 'r1',
            roundNumber: 1,
            storytellerPlayerId: 'unknown-player',
            createdAt: DateTime(2025),
            votes: const [],
            scoreChanges: const [],
          ),
        ],
      );
      final jsonStr = session.toJsonString();

      final result = importer.fromJson(jsonStr);
      expect(result.isValid, isFalse);
      expect(
          result.errors
              .any((e) => e.contains('not found in players')),
          isTrue);
    });

    test('detects self-votes as warning', () {
      final session = _validSession(
        rounds: [
          ExportedRound(
            id: 'r1',
            roundNumber: 1,
            storytellerPlayerId: 'p0',
            createdAt: DateTime(2025),
            votes: const [
              ExportedVote(voterPlayerId: 'p1', votedForPlayerId: 'p1'),
            ],
            scoreChanges: const [],
          ),
        ],
      );
      final jsonStr = session.toJsonString();

      final result = importer.fromJson(jsonStr);
      expect(
          result.warnings.any((w) => w.contains('voted for themselves')),
          isTrue);
    });

    test('valid session passes import validation', () {
      final session = _validSession();
      final jsonStr = session.toJsonString();

      final result = importer.fromJson(jsonStr);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.session, isNotNull);
    });
  });

  group('SessionExporter', () {
    test('toCsv produces valid CSV with correct headers', () {
      const exporter = SessionExporter();
      final session = _validSession();
      final csv = exporter.toCsv(session);

      final lines = csv.trim().split('\n');
      expect(lines.first,
          'Round,Storyteller,Player,Score Change,Reason,Running Total');

      // Should have header + score change rows
      expect(lines.length, greaterThan(1));

      // Verify data rows contain expected content
      final dataLine = lines[1];
      final fields = dataLine.split(',');
      expect(fields.length, 6);
      expect(fields[0], '1'); // round number
    });
  });
}
