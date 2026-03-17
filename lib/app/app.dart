import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:story_score/app/router/app_router.dart';
import 'package:story_score/app/theme/story_score_theme.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';

/// Root widget for StoryScore.
///
/// Expects to be wrapped in a [ProviderScope] (done in main.dart).
class StoryScoreApp extends ConsumerWidget {
  const StoryScoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'StoryScore',
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────────
      theme: StoryScoreTheme.lightTheme,
      darkTheme: StoryScoreTheme.darkTheme,
      themeMode: themeMode,

      // ── Routing ───────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localization ──────────────────────────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
    );
  }
}
