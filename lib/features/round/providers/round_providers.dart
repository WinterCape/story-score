import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for vote entry during a round.
class VoteEntryState {
  const VoteEntryState({required this.voterIds, required this.votes});

  /// IDs of all non-storyteller players (the voters).
  final List<String> voterIds;

  /// Map of voterId -> votedForPlayerId (null if not yet voted).
  final Map<String, String?> votes;

  /// Whether every voter has cast a vote.
  bool get allVotesCast =>
      voterIds.isNotEmpty && voterIds.every((id) => votes[id] != null);

  /// Returns a complete votes map (only non-null entries) for submission.
  Map<String, String> get completedVotes => {
    for (final entry in votes.entries)
      if (entry.value != null) entry.key: entry.value!,
  };

  VoteEntryState copyWith({
    List<String>? voterIds,
    Map<String, String?>? votes,
  }) {
    return VoteEntryState(
      voterIds: voterIds ?? this.voterIds,
      votes: votes ?? this.votes,
    );
  }
}

/// Notifier managing vote entry state for a round.
class VoteEntryNotifier extends Notifier<VoteEntryState> {
  @override
  VoteEntryState build() {
    return const VoteEntryState(voterIds: [], votes: {});
  }

  /// Initialize with non-storyteller player IDs.
  void init(List<String> nonStorytellerIds) {
    state = VoteEntryState(
      voterIds: nonStorytellerIds,
      votes: {for (final id in nonStorytellerIds) id: null},
    );
  }

  /// Set a vote for a specific voter.
  void setVote(String voterId, String votedForId) {
    final newVotes = Map<String, String?>.from(state.votes);
    newVotes[voterId] = votedForId;
    state = state.copyWith(votes: newVotes);
  }

  /// Clear a voter's selection.
  void clearVote(String voterId) {
    final newVotes = Map<String, String?>.from(state.votes);
    newVotes[voterId] = null;
    state = state.copyWith(votes: newVotes);
  }

  /// Reset all votes.
  void clearAll() {
    state = state.copyWith(votes: {for (final id in state.voterIds) id: null});
  }
}

/// Provider for the vote entry notifier.
final voteEntryProvider = NotifierProvider<VoteEntryNotifier, VoteEntryState>(
  VoteEntryNotifier.new,
);
