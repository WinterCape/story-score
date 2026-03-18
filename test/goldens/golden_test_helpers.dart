import 'package:flutter/material.dart';
import 'package:story_score/app/theme/story_score_theme.dart';

/// Wraps [child] in a [MaterialApp] with the StoryScore theme applied.
///
/// Set [isDark] to `true` to use the dark theme variant.
/// The widget is centered inside a [Scaffold] body.
Widget wrapInTheme(Widget child, {bool isDark = false}) {
  return MaterialApp(
    theme: isDark ? StoryScoreTheme.darkTheme : StoryScoreTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}
