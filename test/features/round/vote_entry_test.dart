import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_score/features/round/providers/round_providers.dart';

void main() {
  late ProviderContainer container;
  late VoteEntryNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(voteEntryProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('VoteEntryNotifier', () {
    test('init with 3 voter IDs sets all votes to null', () {
      notifier.init(['A', 'B', 'C']);

      final state = container.read(voteEntryProvider);
      expect(state.voterIds, ['A', 'B', 'C']);
      expect(state.votes, {'A': null, 'B': null, 'C': null});
    });

    test('setVote sets the correct vote', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');

      final state = container.read(voteEntryProvider);
      expect(state.votes['A'], 'X');
      expect(state.votes['B'], isNull);
      expect(state.votes['C'], isNull);
    });

    test('clearVote clears a vote', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');
      notifier.clearVote('A');

      final state = container.read(voteEntryProvider);
      expect(state.votes['A'], isNull);
    });

    test('allVotesCast returns false when some votes missing', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');
      notifier.setVote('B', 'Y');

      final state = container.read(voteEntryProvider);
      expect(state.allVotesCast, isFalse);
    });

    test('allVotesCast returns true when all votes set', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');
      notifier.setVote('B', 'Y');
      notifier.setVote('C', 'Z');

      final state = container.read(voteEntryProvider);
      expect(state.allVotesCast, isTrue);
    });

    test('completedVotes returns only non-null entries', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');
      notifier.setVote('C', 'Z');

      final state = container.read(voteEntryProvider);
      expect(state.completedVotes, {'A': 'X', 'C': 'Z'});
      expect(state.completedVotes.containsKey('B'), isFalse);
    });

    test('clearAll resets everything', () {
      notifier.init(['A', 'B', 'C']);
      notifier.setVote('A', 'X');
      notifier.setVote('B', 'Y');
      notifier.setVote('C', 'Z');
      notifier.clearAll();

      final state = container.read(voteEntryProvider);
      expect(state.voterIds, ['A', 'B', 'C']);
      expect(state.votes, {'A': null, 'B': null, 'C': null});
      expect(state.allVotesCast, isFalse);
    });
  });
}
