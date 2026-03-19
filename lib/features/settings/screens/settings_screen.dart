import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final isSupporter = ref.watch(isSupporterProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.darkCard,
            ],
          ),
        ),
        child: SafeArea(
          child: settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.error}: $e')),
            data: (settings) => ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.lg,
                vertical: SpacingTokens.md,
              ),
              children: [
                // ── Header: back circle + "Settings" title ──
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorTokens.darkCard,
                        border: Border.all(
                          color:
                              ColorTokens.goldAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: ColorTokens.goldAccent,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Text(
                      l10n.settings,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ColorTokens.parchment,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.lg),

                // ── APPEARANCE ──
                const _SectionHeader('APPEARANCE'),
                const SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: l10n.theme,
                      trailing: Text(
                        _themeModeLabel(context, settings.themeMode),
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Cycle theme mode
                        final next = switch (settings.themeMode) {
                          ThemeMode.dark => ThemeMode.light,
                          ThemeMode.light => ThemeMode.system,
                          ThemeMode.system => ThemeMode.dark,
                        };
                        ref
                            .read(appSettingsProvider.notifier)
                            .setThemeMode(next);
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.colorTheme,
                      trailing: Text(
                        settings.selectedTheme.isEmpty
                            ? 'Storybook Gold'
                            : _capitalizeFirst(settings.selectedTheme),
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Could navigate to theme picker
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.language,
                      trailing: Text(
                        _localeLabel(settings.locale),
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Cycle locale
                        final next = switch (settings.locale) {
                          null => 'en',
                          'en' => 'ro',
                          _ => null,
                        };
                        ref
                            .read(appSettingsProvider.notifier)
                            .setLocale(next);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.lg),

                // ── GAMEPLAY ──
                const _SectionHeader('GAMEPLAY'),
                const SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsToggleRow(
                      title: l10n.hapticFeedback,
                      value: settings.hapticsEnabled,
                      onChanged: (v) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setHapticsEnabled(v);
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsToggleRow(
                      title: l10n.soundEffects,
                      value: settings.soundEffectsEnabled && isSupporter,
                      onChanged: isSupporter
                          ? (v) {
                              ref
                                  .read(appSettingsProvider.notifier)
                                  .setSoundEffectsEnabled(v);
                            }
                          : null,
                    ),
                    const _SettingsDivider(),
                    _SettingsToggleRow(
                      title: l10n.reduceMotion,
                      value: settings.reducedMotionOverride,
                      onChanged: (v) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setReducedMotionOverride(v);
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsToggleRow(
                      title: l10n.roundNotes,
                      value: settings.showRoundNotes,
                      onChanged: (v) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setShowRoundNotes(v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.lg),

                // ── DATA ──
                const _SectionHeader('DATA'),
                const SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: l10n.playerPresets,
                      trailing: Text(
                        '3 saved',
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => context.push('/settings/presets'),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: 'Export / Import',
                      trailing: const Text(
                        'Manage data',
                        style: TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to export/import
                      },
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.lg),

                // ── PREMIUM ──
                const _SectionHeader('PREMIUM'),
                const SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    InkWell(
                      onTap: () => context.push('/settings/premium'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.md,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Supporter Pack',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ColorTokens.parchment,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Image.asset(
                              AppAssets.supporterBadge,
                              width: 20,
                            ),
                            const Spacer(),
                            const Text(
                              'Unlock more magic',
                              style: TextStyle(
                                color: ColorTokens.mutedText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.lg),

                // ── ABOUT ──
                const _SectionHeader('ABOUT'),
                const SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: 'Version',
                      trailing: const Text(
                        '1.0.0',
                        style: TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: 'Privacy & Support',
                      trailing: const Text(
                        'View links',
                        style: TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to privacy/support
                      },
                    ),
                  ],
                ),

                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _themeModeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark / Light',
    };
  }

  static String _localeLabel(String? locale) {
    return switch (locale) {
      null => 'System',
      'en' => 'English',
      'ro' => 'Romanian',
      _ => locale,
    };
  }

  static String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

// =============================================================================
// Section header (gold uppercase)
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: ColorTokens.goldAccent,
      ),
    );
  }
}

// =============================================================================
// Settings card (grouped container)
// =============================================================================

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorTokens.goldAccent.withValues(alpha: 0.15),
        ),
      ),
      child: Column(children: children),
    );
  }
}

// =============================================================================
// Settings row (label + trailing widget)
// =============================================================================

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ColorTokens.parchment,
              ),
            ),
            const Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Settings toggle row
// =============================================================================

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorTokens.parchment,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            activeTrackColor: ColorTokens.goldAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Divider inside settings card
// =============================================================================

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: SpacingTokens.md,
      endIndent: SpacingTokens.md,
      color: ColorTokens.mutedText.withValues(alpha: 0.15),
    );
  }
}
