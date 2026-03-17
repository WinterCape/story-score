import 'package:flutter/material.dart';
import 'package:story_score/app/theme/theme_extensions.dart';

/// Convenience extensions on BuildContext for accessing theme data.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  StoryScoreThemeExtension get storyTheme =>
      theme.extension<StoryScoreThemeExtension>()!;
}

/// Convenience extensions for media queries.
extension MediaQueryX on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  bool get reduceMotion => mediaQuery.disableAnimations;
}
