import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoundDetailScreen extends ConsumerWidget {
  const RoundDetailScreen({
    super.key,
    required this.sessionId,
    required this.roundId,
  });

  final String sessionId;
  final String roundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Round Detail')),
      body: Center(
        child: Text(
          'Round Detail\nSession: $sessionId\nRound: $roundId',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
