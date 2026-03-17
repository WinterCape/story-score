import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/app/app.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/settings/app_settings_repository.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appSettingsRepositoryProvider.overrideWithValue(
          AppSettingsRepository(prefs),
        ),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const StoryScoreApp(),
    ),
  );
}
