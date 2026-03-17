import 'package:flutter/material.dart';

/// Predefined player colors — 12 distinct options for up to 10 players.
/// Each has good contrast in both light and dark themes.
abstract final class PlayerColors {
  static const Map<String, Color> all = {
    'aurora_teal': Color(0xFF2EC4B6),
    'soft_violet': Color(0xFF7B68EE),
    'gold': Color(0xFFD4A742),
    'coral': Color(0xFFFF6B6B),
    'emerald': Color(0xFF2ECC71),
    'ocean_blue': Color(0xFF3498DB),
    'sunset_orange': Color(0xFFE67E22),
    'rose_pink': Color(0xFFE91E8C),
    'lime_green': Color(0xFF8BC34A),
    'slate_blue': Color(0xFF5C6BC0),
    'amber': Color(0xFFFFC107),
    'plum': Color(0xFF9C27B0),
  };

  static const List<String> orderedKeys = [
    'aurora_teal',
    'soft_violet',
    'gold',
    'coral',
    'emerald',
    'ocean_blue',
    'sunset_orange',
    'rose_pink',
    'lime_green',
    'slate_blue',
    'amber',
    'plum',
  ];

  static Color colorFor(String key) => all[key] ?? all.values.first;

  /// Returns the next unused color key given already-used keys.
  static String nextAvailable(Set<String> usedKeys) {
    for (final key in orderedKeys) {
      if (!usedKeys.contains(key)) return key;
    }
    return orderedKeys.first;
  }
}
