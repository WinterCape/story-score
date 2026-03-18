import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:story_score/app/router/app_router.dart';
import 'package:story_score/app/theme/premium_themes.dart';
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
    final selectedTheme = ref.watch(selectedThemeProvider);

    // Resolve theme data based on selected theme
    final ThemeData lightTheme;
    final ThemeData darkTheme;

    final palette = PremiumThemes.byId(selectedTheme);
    if (palette != null) {
      lightTheme = palette.toLightTheme();
      darkTheme = palette.toDarkTheme();
    } else {
      // Default Celestial/Aurora theme
      lightTheme = StoryScoreTheme.lightTheme;
      darkTheme = StoryScoreTheme.darkTheme;
    }

    return MaterialApp.router(
      title: 'StoryScore',
      debugShowCheckedModeBanner: false,

      // -- Theme --
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // -- Routing --
      routerConfig: router,

      // -- Localization --
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }
}
