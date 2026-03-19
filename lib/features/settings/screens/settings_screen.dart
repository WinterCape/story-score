import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/app/theme/theme_extensions.dart';
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

    final storyTheme = Theme.of(context).extension<StoryScoreThemeExtension>()!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: storyTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: settingsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.error}: $e')),
            data: (settings) => ListView(
              padding: EdgeInsets.symmetric(
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
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                          color:
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context).colorScheme.primary,
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
                    SizedBox(width: SpacingTokens.md),
                    Text(
                      l10n.settings,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SpacingTokens.lg),

                // ── APPEARANCE ──
                _SectionHeader(l10n.appearance),
                SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: l10n.theme,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _themeModeLabel(context, settings.themeMode),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.expand_more_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: () => _showThemeModePicker(context, ref, settings.themeMode),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.colorTheme,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            settings.selectedTheme.isEmpty
                                ? l10n.storybookGold
                                : _capitalizeFirst(settings.selectedTheme),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.expand_more_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: () => _showColorThemePicker(context, ref, settings.selectedTheme),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.language,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _localeLabel(context, settings.locale),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.expand_more_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap: () => _showLanguagePicker(context, ref, settings.locale),
                    ),
                  ],
                ),

                SizedBox(height: SpacingTokens.lg),

                // ── GAMEPLAY ──
                _SectionHeader(l10n.gameplay),
                SizedBox(height: SpacingTokens.sm),
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

                SizedBox(height: SpacingTokens.lg),

                // ── DATA ──
                _SectionHeader(l10n.dataSection),
                SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: l10n.playerPresets,
                      trailing: Text(
                        l10n.nSaved(3),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => context.push('/settings/presets'),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.exportImport,
                      trailing: Text(
                        l10n.manageData,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to export/import
                      },
                    ),
                  ],
                ),

                SizedBox(height: SpacingTokens.lg),

                // ── PREMIUM ──
                _SectionHeader(l10n.premiumSection),
                SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    InkWell(
                      onTap: () => context.push('/settings/premium'),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.md,
                        ),
                        child: Row(
                          children: [
                            Text(
                              l10n.supporterPack,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: SpacingTokens.sm),
                            Image.asset(
                              AppAssets.supporterBadge,
                              width: 20,
                            ),
                            Spacer(),
                            Text(
                              l10n.unlockMoreMagic,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SpacingTokens.lg),

                // ── ABOUT ──
                _SectionHeader(l10n.about),
                SizedBox(height: SpacingTokens.sm),
                _SettingsCard(
                  children: [
                    _SettingsRow(
                      title: l10n.version('1.0.0'),
                      trailing: SizedBox.shrink(),
                    ),
                    const _SettingsDivider(),
                    _SettingsRow(
                      title: l10n.privacyAndSupport,
                      trailing: Text(
                        l10n.viewLinks,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to privacy/support
                      },
                    ),
                  ],
                ),

                SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _themeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      ThemeMode.system => l10n.systemTheme,
      ThemeMode.light => l10n.lightTheme,
      ThemeMode.dark => l10n.darkTheme,
    };
  }

  void _showThemeModePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  context.l10n.chooseTheme,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                _ThemeModeOption(
                  icon: Icons.phone_android_rounded,
                  label: context.l10n.systemTheme,
                  description: context.l10n.followDeviceSettings,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.system);
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 8),
                _ThemeModeOption(
                  icon: Icons.light_mode_rounded,
                  label: context.l10n.lightTheme,
                  description: context.l10n.warmParchmentTheme,
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.light);
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 8),
                _ThemeModeOption(
                  icon: Icons.dark_mode_rounded,
                  label: context.l10n.darkTheme,
                  description: context.l10n.enchantedNightTheme,
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.dark);
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColorThemePicker(
    BuildContext context,
    WidgetRef ref,
    String currentTheme,
  ) {
    final l10n = context.l10n;
    final themes = [
      ('', l10n.storybookGold, l10n.storybookGoldDescription),
      ('ocean', l10n.oceanDepths, l10n.oceanDepthsDescription),
      ('ember', l10n.emberTheme, l10n.emberThemeDescription),
      ('frost', l10n.frostTheme, l10n.frostThemeDescription),
      ('forest', l10n.enchantedForest, l10n.enchantedForestDescription),
    ];

    final isSupporter = ref.read(isSupporterProvider);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  l10n.colorThemeHeader,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                ...themes.map((t) {
                  final (id, label, desc) = t;
                  final isPremium = id.isNotEmpty;
                  final isLocked = isPremium && !isSupporter;
                  final isSelected = currentTheme == id || (currentTheme.isEmpty && id.isEmpty);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _ThemeModeOption(
                      icon: isLocked ? Icons.lock_rounded : Icons.palette_rounded,
                      label: isLocked ? '$label 🔒' : label,
                      description: isLocked ? 'Supporter Pack feature' : desc,
                      isSelected: isSelected,
                      onTap: () {
                        if (isLocked) {
                          Navigator.pop(sheetContext);
                          context.push('/settings/premium');
                        } else {
                          ref.read(appSettingsProvider.notifier).setSelectedTheme(id);
                          Navigator.pop(sheetContext);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String? currentLocale,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  context.l10n.languageHeader,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                _ThemeModeOption(
                  icon: Icons.phone_android_rounded,
                  label: context.l10n.systemTheme,
                  description: context.l10n.followDeviceLanguage,
                  isSelected: currentLocale == null,
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setLocale(null);
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 8),
                _ThemeModeOption(
                  icon: Icons.language_rounded,
                  label: context.l10n.english,
                  description: context.l10n.english,
                  isSelected: currentLocale == 'en',
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setLocale('en');
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 8),
                _ThemeModeOption(
                  icon: Icons.language_rounded,
                  label: 'Română',
                  description: context.l10n.romanian,
                  isSelected: currentLocale == 'ro',
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setLocale('ro');
                    Navigator.pop(sheetContext);
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _localeLabel(BuildContext context, String? locale) {
    final l10n = context.l10n;
    return switch (locale) {
      null => l10n.systemTheme,
      'en' => l10n.english,
      'ro' => l10n.romanian,
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
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Spacer(),
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
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Spacer(),
          Switch(
            value: value,
            activeTrackColor: Theme.of(context).colorScheme.primary,
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
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
    );
  }
}

/// A selectable theme mode option for the bottom sheet picker.
class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
