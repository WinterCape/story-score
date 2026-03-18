import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/settings/app_settings.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/features/settings/widgets/theme_picker.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final isSupporter = ref.watch(isSupporterProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(color: ColorTokens.parchment),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ColorTokens.goldAccent,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          children: [
            // Appearance section
            _SectionHeader(title: l10n.appearance),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(
                l10n.theme,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                _themeModeLabel(context, settings.themeMode),
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
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
                l10n.colorTheme,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorTokens.mutedText,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: const ThemePicker(),
            ),
            const SizedBox(height: SpacingTokens.sm),

            const Divider(),

            // Language section
            _SectionHeader(title: l10n.language),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(
                l10n.language,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              trailing: DropdownButton<String?>(
                value: settings.locale,
                underline: const SizedBox.shrink(),
                onChanged: (locale) {
                  ref.read(appSettingsProvider.notifier).setLocale(locale);
                },
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.system),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'en',
                    child: Text(l10n.english),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'ro',
                    child: Text(l10n.romanian),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Gameplay section
            _SectionHeader(title: l10n.gameplay),
            SwitchListTile(
              secondary: const Icon(Icons.vibration_outlined),
              title: Text(
                l10n.hapticFeedback,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.hapticFeedbackDescription,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              value: settings.hapticsEnabled,
              activeTrackColor: ColorTokens.goldAccent,
              onChanged: (v) {
                ref.read(appSettingsProvider.notifier).setHapticsEnabled(v);
              },
            ),
            SwitchListTile(
              secondary: Icon(
                Icons.volume_up_outlined,
                color: isSupporter ? null : Theme.of(context).disabledColor,
              ),
              title: Row(
                children: [
                  Text(
                    l10n.soundEffects,
                    style: const TextStyle(color: ColorTokens.parchment),
                  ),
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
                    ? l10n.soundEffectsDescription
                    : l10n.supporterPackFeature,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              value: settings.soundEffectsEnabled && isSupporter,
              activeTrackColor: ColorTokens.goldAccent,
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
              title: Text(
                l10n.reduceMotion,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.reduceMotionDescription,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              value: settings.reducedMotionOverride,
              activeTrackColor: ColorTokens.goldAccent,
              onChanged: (v) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setReducedMotionOverride(v);
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.note_outlined),
              title: Text(
                l10n.roundNotes,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.roundNotesDescription,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              value: settings.showRoundNotes,
              activeTrackColor: ColorTokens.goldAccent,
              onChanged: (v) {
                ref.read(appSettingsProvider.notifier).setShowRoundNotes(v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(
                l10n.defaultTargetMode,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                _targetTypeLabel(context, settings.defaultTargetMode),
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              trailing: SegmentedButton<TargetType>(
                segments: [
                  ButtonSegment(
                    value: TargetType.score,
                    label: Text(l10n.score),
                  ),
                  ButtonSegment(
                    value: TargetType.freeplay,
                    label: Text(l10n.free),
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
              title: Text(
                l10n.playerSortOrder,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                _sortOrderLabel(context, settings.preferredSortOrder),
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
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
                    .map(
                      (o) => DropdownMenuItem(
                        value: o,
                        child: Text(_sortOrderLabel(context, o)),
                      ),
                    )
                    .toList(),
              ),
            ),

            const Divider(),

            // Presets section
            _SectionHeader(title: l10n.playerPresets),
            ListTile(
              leading: Icon(
                ref.watch(isSupporterProvider)
                    ? Icons.group_outlined
                    : Icons.lock_outline_rounded,
              ),
              title: Text(
                l10n.playerPresets,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.saveAndManageGroups,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/presets'),
            ),

            const Divider(),

            // Premium section
            _SectionHeader(title: l10n.support),
            ListTile(
              leading: const Icon(Icons.star_outline_rounded),
              title: Text(
                l10n.supporterPack,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.premiumThemesAndExtras,
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/premium'),
            ),

            const Divider(),

            // About section
            _SectionHeader(title: l10n.about),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(
                l10n.appTitle,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              subtitle: Text(
                l10n.version('1.0.0'),
                style: const TextStyle(color: ColorTokens.mutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      ThemeMode.system => l10n.system,
      ThemeMode.light => l10n.light,
      ThemeMode.dark => l10n.dark,
    };
  }

  String _targetTypeLabel(BuildContext context, TargetType type) {
    final l10n = context.l10n;
    return switch (type) {
      TargetType.score => l10n.scoreTarget,
      TargetType.rounds => l10n.roundLimit,
      TargetType.freeplay => l10n.freePlay,
    };
  }

  String _sortOrderLabel(BuildContext context, PlayerSortOrder order) {
    final l10n = context.l10n;
    return switch (order) {
      PlayerSortOrder.seat => l10n.seatOrder,
      PlayerSortOrder.scoreDesc => l10n.scoreHighToLow,
      PlayerSortOrder.scoreAsc => l10n.scoreLowToHigh,
      PlayerSortOrder.name => l10n.name,
    };
  }
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
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ColorTokens.goldAccent,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
