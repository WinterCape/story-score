import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameSetupScreen extends ConsumerWidget {
  const GameSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: Center(
        child: Text(
          'Game Setup',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
