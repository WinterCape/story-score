import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Center(
        child: Text(
          'Premium',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
