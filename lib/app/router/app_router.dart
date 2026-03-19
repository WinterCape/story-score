import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/features/endgame/screens/endgame_screen.dart';
import 'package:story_score/features/game_edit/screens/game_edit_screen.dart';
import 'package:story_score/features/game_setup/screens/game_setup_screen.dart';
import 'package:story_score/features/history/screens/history_screen.dart';
import 'package:story_score/features/home/screens/home_screen.dart';
import 'package:story_score/features/onboarding/screens/onboarding_flow.dart';
import 'package:story_score/features/splash/screens/splash_screen.dart';
import 'package:story_score/features/premium/screens/premium_screen.dart';
import 'package:story_score/features/presets/screens/preset_management_screen.dart';
import 'package:story_score/features/round/screens/round_detail_screen.dart';
import 'package:story_score/features/round/screens/round_screen.dart';
import 'package:story_score/features/scoreboard/screens/scoreboard_screen.dart';
import 'package:story_score/features/settings/screens/settings_screen.dart';
import 'package:story_score/features/stats/screens/stats_screen.dart';

// ── Router provider ──────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // ── Home ──────────────────────────────────────────────────────────────
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlow(),
      ),

      // ── Settings ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          GoRoute(
            path: 'presets',
            builder: (context, state) => const PresetManagementScreen(),
          ),
        ],
      ),

      // ── Stats ──────────────────────────────────────────────────────────────
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),

      // ── Game setup ────────────────────────────────────────────────────────
      GoRoute(
        path: '/game/new',
        builder: (context, state) => const GameSetupScreen(),
      ),

      // ── In-game screens (flat routes, no shell) ───────────────────────────
      GoRoute(
        path: '/game/:sessionId/scoreboard',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ScoreboardScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/game/:sessionId/round',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return RoundScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/game/:sessionId/round/:roundId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          final roundId = state.pathParameters['roundId']!;
          return RoundDetailScreen(sessionId: sessionId, roundId: roundId);
        },
      ),
      GoRoute(
        path: '/game/:sessionId/edit',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return GameEditScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/game/:sessionId/history',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return HistoryScreen(sessionId: sessionId);
        },
      ),

      // ── End game ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/game/:sessionId/endgame',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return EndgameScreen(sessionId: sessionId);
        },
      ),

      // ── Archive (read-only view of a past game) ───────────────────────────
      GoRoute(
        path: '/archive/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ScoreboardScreen(sessionId: sessionId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            const Text('This page does not exist.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

