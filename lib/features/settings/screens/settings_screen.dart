import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/settings/app_settings.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/features/settings/widgets/theme_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final isSupporter = ref.watch(isSupporterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          children: [
            // Appearance section
            _SectionHeader(title: 'Appearance'),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text(_themeModeLabel(settings.themeMode)),
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_brightness_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (modes) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setThemeMode(modes.first);
                },
                showSelectedIcon: false,
              ),
            ),

            // Theme color picker
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.sm,
              ),
              child: Text(
                'Color Theme',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
              ),
              child: const ThemePicker(),
            ),
            const SizedBox(height: SpacingTokens.sm),

            const Divider(),

            // Gameplay section
            _SectionHeader(title: 'Gameplay'),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_outlined),
              title: const Text('Haptic Feedback'),
              subtitle: const Text('Vibrate on score events'),
              value: settings.hapticsEnabled,
              onChanged: (v) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setHapticsEnabled(v);
              },
            ),
            SwitchListTile(
              secondary: Icon(
                Icons.volume_up_outlined,
                color: isSupporter ? null : Theme.of(context).disabledColor,
              ),
              title: Row(
                children: [
                  const Text('Sound Effects'),
                  if (!isSupporter) ...[
                    const SizedBox(width: SpacingTokens.xs),
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Theme.of(context).disabledColor,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                isSupporter
                    ? 'Play sounds for celebrations'
                    : 'Supporter Pack feature',
              ),
              value: settings.soundEffectsEnabled && isSupporter,
              onChanged: isSupporter
                  ? (v) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setSoundEffectsEnabled(v);
                    }
                  : null,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.slow_motion_video_outlined),
              title: const Text('Reduce Motion'),
              subtitle: const Text('Minimize animations'),
              value: settings.reducedMotionOverride,
              onChanged: (v) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setReducedMotionOverride(v);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.note_outlined),
              title: const Text('Show Round Notes'),
              subtitle: const Text('Allow clue notes per round'),
              value: settings.showRoundNotes,
              onChanged: (v) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setShowRoundNotes(v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Default Target Mode'),
              subtitle:
                  Text(_targetTypeLabel(settings.defaultTargetMode)),
              trailing: SegmentedButton<TargetType>(
                segments: const [
                  ButtonSegment(
                    value: TargetType.score,
                    label: Text('Score'),
                  ),
                  ButtonSegment(
                    value: TargetType.freeplay,
                    label: Text('Free'),
                  ),
                ],
                selected: {settings.defaultTargetMode},
                onSelectionChanged: (types) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setDefaultTargetMode(types.first);
                },
                showSelectedIcon: false,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sort_outlined),
              title: const Text('Player Sort Order'),
              subtitle:
                  Text(_sortOrderLabel(settings.preferredSortOrder)),
              trailing: DropdownButton<PlayerSortOrder>(
                value: settings.preferredSortOrder,
                underline: const SizedBox.shrink(),
                onChanged: (order) {
                  if (order != null) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setPreferredSortOrder(order);
                  }
                },
                items: PlayerSortOrder.values
                    .map((o) => DropdownMenuItem(
                          value: o,
                          child: Text(_sortOrderLabel(o)),
                        ))
                    .toList(),
              ),
            ),

            const Divider(),

            // Presets section
            _SectionHeader(title: 'Player Presets'),
            ListTile(
              leading: Icon(
                ref.watch(isSupporterProvider)
                    ? Icons.group_outlined
                    : Icons.lock_outline_rounded,
              ),
              title: const Text('Player Presets'),
              subtitle: const Text('Save and manage player groups'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/settings/presets'),
            ),

            const Divider(),

            // Premium section
            _SectionHeader(title: 'Support'),
            ListTile(
              leading: const Icon(Icons.star_outline_rounded),
              title: const Text('Supporter Pack'),
              subtitle: const Text('Premium themes & extras'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/settings/premium'),
            ),

            const Divider(),

            // About section
            _SectionHeader(title: 'About'),
            const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('StoryScore'),
              subtitle: Text('Version 1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  String _targetTypeLabel(TargetType type) => switch (type) {
        TargetType.score => 'Score Target',
        TargetType.rounds => 'Round Limit',
        TargetType.freeplay => 'Free Play',
      };

  String _sortOrderLabel(PlayerSortOrder order) => switch (order) {
        PlayerSortOrder.seat => 'Seat Order',
        PlayerSortOrder.scoreDesc => 'Score (High to Low)',
        PlayerSortOrder.scoreAsc => 'Score (Low to High)',
        PlayerSortOrder.name => 'Name',
      };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
