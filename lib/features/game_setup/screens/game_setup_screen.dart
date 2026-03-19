import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/app/theme/theme_extensions.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/features/game_setup/providers/game_setup_providers.dart';
import 'package:story_score/features/game_setup/widgets/color_picker_chips.dart';
import 'package:story_score/features/game_setup/widgets/player_tile.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/presets/providers/preset_providers.dart';
import 'package:story_score/features/presets/widgets/favorite_player_chips.dart';
import 'package:story_score/features/presets/widgets/preset_list_tile.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  final _titleController = TextEditingController();
  final _targetScoreController = TextEditingController(text: '30');
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Actions
  // --------------------------------------------------------------------------

  Future<void> _startGame() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final dao = ref.read(sessionDaoProvider);
      final sessionId = await ref
          .read(gameSetupProvider.notifier)
          .createGame(dao);

      if (mounted) {
        context.go('/game/$sessionId/scoreboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToCreateGame('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _showSavePresetDialog() async {
    final state = ref.read(gameSetupProvider);
    if (state.players.length < 3) return;

    final l10n = context.l10n;
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveAsPreset),
        content: TextField(
          controller: nameController,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.presetName,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    nameController.dispose();

    if (name == null || name.isEmpty) return;

    try {
      final dao = ref.read(presetDaoProvider);
      await savePreset(
        dao: dao,
        name: name,
        players: state.players
            .map(
              (p) => (
                name: p.name,
                colorKey: p.colorKey,
                avatarStyle: p.avatarStyle,
                seatOrder: p.seatOrder,
              ),
            )
            .toList(),
      );
      Haptics.selection();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.savedPreset(name))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedToSavePreset('$e'))));
      }
    }
  }

  void _showLoadPresetSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _LoadPresetSheet(
        onPresetSelected: (preset, players) {
          Navigator.of(sheetContext).pop();
          _loadPreset(players);
        },
      ),
    );
  }

  void _loadPreset(List<PresetPlayer> players) {
    final notifier = ref.read(gameSetupProvider.notifier);
    // Clear existing players and add from preset
    final currentState = ref.read(gameSetupProvider);
    for (var i = currentState.players.length - 1; i >= 0; i--) {
      notifier.removePlayer(i);
    }
    for (final p in players) {
      notifier.addPlayer(
        name: p.name,
        colorKey: p.colorKey,
        avatarStyle: p.avatarStyle,
      );
    }
    Haptics.selection();
  }

  void _showAddPlayerSheet() {
    final setupState = ref.read(gameSetupProvider);
    if (setupState.isPlayerLimitReached) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _AddPlayerSheet(
        usedColorKeys: setupState.usedColorKeys,
        onConfirm: (name, colorKey, avatarStyle) {
          Haptics.selection();
          ref
              .read(gameSetupProvider.notifier)
              .addPlayer(
                name: name,
                colorKey: colorKey,
                avatarStyle: avatarStyle,
              );
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Build
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameSetupProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.newGame,
          style: TextStyle(color: storyTheme.primaryText),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: storyTheme.primaryAccent,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (state.players.length >= 3 && ref.watch(isSupporterProvider))
            IconButton(
              icon: const CustomIcon('save_preset', size: 20),
              tooltip: l10n.saveAsPreset,
              onPressed: () => _showSavePresetDialog(),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: storyTheme.backgroundGradient,
        ),
        child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 600 : double.infinity,
          ),
          child: Column(
            children: [
              // Scrollable form content.
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg,
                    vertical: SpacingTokens.md,
                  ),
                  children: [
                    // ── Title field ──────────────────────────────────────────
                    Text(
                      l10n.gameTitle.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        color: storyTheme.primaryAccent,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: l10n.gameTitleHint),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) =>
                          ref.read(gameSetupProvider.notifier).setTitle(v),
                    ),

                    const SizedBox(height: SpacingTokens.lg),

                    // ── Target type selector ─────────────────────────────────
                    Text(
                      l10n.winCondition.toUpperCase(),
                      style: textTheme.labelLarge?.copyWith(
                        color: storyTheme.primaryAccent,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TargetType>(
                        segments: [
                          ButtonSegment(
                            value: TargetType.score,
                            label: Text(l10n.scoreTarget),
                            icon: const CustomIcon('target', size: 18),
                          ),
                          ButtonSegment(
                            value: TargetType.freeplay,
                            label: Text(l10n.infinite),
                            icon: const CustomIcon('infinite', size: 18),
                          ),
                        ],
                        selected: {state.targetType},
                        onSelectionChanged: (s) => ref
                            .read(gameSetupProvider.notifier)
                            .setTargetType(s.first),
                        showSelectedIcon: false,
                      ),
                    ),

                    // ── Target score input (conditional) ─────────────────────
                    if (state.targetType == TargetType.score) ...[
                      const SizedBox(height: SpacingTokens.md),
                      Row(
                        children: [
                          Text(
                            l10n.targetScore,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          // Stepper controls.
                          _StepperButton(
                            icon: Icons.remove_rounded,
                            onPressed: state.targetScore > 10
                                ? () {
                                    final newVal = state.targetScore - 5;
                                    ref
                                        .read(gameSetupProvider.notifier)
                                        .setTargetScore(newVal);
                                    _targetScoreController.text = newVal
                                        .clamp(10, 200)
                                        .toString();
                                  }
                                : null,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          SizedBox(
                            width: 64,
                            child: TextFormField(
                              controller: _targetScoreController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: textTheme.titleMedium,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: SpacingTokens.sm,
                                ),
                              ),
                              onChanged: (v) {
                                final parsed = int.tryParse(v);
                                if (parsed != null) {
                                  ref
                                      .read(gameSetupProvider.notifier)
                                      .setTargetScore(parsed);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _StepperButton(
                            icon: Icons.add_rounded,
                            onPressed: state.targetScore < 200
                                ? () {
                                    final newVal = state.targetScore + 5;
                                    ref
                                        .read(gameSetupProvider.notifier)
                                        .setTargetScore(newVal);
                                    _targetScoreController.text = newVal
                                        .clamp(10, 200)
                                        .toString();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),

                      // Continue past target toggle.
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.continuePastTarget,
                                  style: textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.continuePastTargetDescription,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: state.continuePastTarget,
                            onChanged: (v) => ref
                                .read(gameSetupProvider.notifier)
                                .setContinuePastTarget(v),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: SpacingTokens.xl),

                    // ── Load Preset button (premium-gated) ──────────────────
                    if (ref.watch(isSupporterProvider))
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: SpacingTokens.md,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => _showLoadPresetSheet(),
                          icon: const CustomIcon('load_preset', size: 20),
                          label: Text(l10n.loadPreset),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      ),

                    // ── Players section ──────────────────────────────────────
                    Row(
                      children: [
                        Text(
                          l10n.players.toUpperCase(),
                          style: textTheme.titleLarge?.copyWith(
                            color: storyTheme.primaryAccent,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              SpacingTokens.radiusSm,
                            ),
                          ),
                          child: Text(
                            l10n.playerCountLabel(state.players.length),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (state.players.length < 3)
                          Text(
                            l10n.minPlayersRequired,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.sm),

                    // Player list (non-scrollable inside the parent ListView).
                    if (state.players.isNotEmpty)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Material(
                              color: Colors.transparent,
                              elevation: 4,
                              borderRadius: BorderRadius.circular(
                                SpacingTokens.radiusMd,
                              ),
                              child: child,
                            ),
                            child: child,
                          );
                        },
                        itemCount: state.players.length,
                        onReorder: (oldIndex, newIndex) => ref
                            .read(gameSetupProvider.notifier)
                            .reorderPlayers(oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          final player = state.players[index];
                          return ReorderableDragStartListener(
                            key: ValueKey('player_$index'),
                            index: index,
                            child: PlayerTile(
                              name: player.name,
                              colorKey: player.colorKey,
                              seatNumber: player.seatOrder,
                              avatarStyle: player.avatarStyle,
                              onRemove: () => ref
                                  .read(gameSetupProvider.notifier)
                                  .removePlayer(index),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: SpacingTokens.sm),

                    // Add player button — gold outlined.
                    OutlinedButton.icon(
                      onPressed: state.isPlayerLimitReached
                          ? null
                          : _showAddPlayerSheet,
                      icon: const CustomIcon('add_player', size: 20),
                      label: Text(l10n.addPlayer),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: storyTheme.primaryAccent,
                        side: BorderSide(
                          color: state.isPlayerLimitReached
                              ? colorScheme.outline.withValues(alpha: 0.3)
                              : storyTheme.primaryAccent,
                        ),
                      ),
                    ),

                    // Favorite player chips (premium-gated).
                    if (ref.watch(isSupporterProvider))
                      _FavoriteChipsSection(
                        usedColorKeys: state.usedColorKeys,
                        existingNames: state.players
                            .map((p) => p.name.trim().toLowerCase())
                            .toSet(),
                        onSelect: (name, colorKey, avatarStyle) {
                          Haptics.selection();
                          ref
                              .read(gameSetupProvider.notifier)
                              .addPlayer(
                                name: name,
                                colorKey: colorKey,
                                avatarStyle: avatarStyle,
                              );
                        },
                      ),

                    // Bottom padding for scroll clearance.
                    const SizedBox(height: SpacingTokens.xxl),
                  ],
                ),
              ),

              // ── Start Game button (pinned at bottom) ───────────────────────
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    SpacingTokens.sm,
                    SpacingTokens.lg,
                    SpacingTokens.md,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: state.canStart && !_isCreating
                          ? storyTheme.accentGradient
                          : LinearGradient(
                              colors: [
                                storyTheme.burgundy.withValues(alpha: 0.3),
                                storyTheme.goldAccent.withValues(alpha: 0.3),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(
                        SpacingTokens.radiusMd,
                      ),
                    ),
                    child: FilledButton(
                      onPressed: state.canStart && !_isCreating
                          ? _startGame
                          : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: Colors.white54,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white54,
                              ),
                            )
                          : Text(l10n.startGame),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// =============================================================================
// Internal helper: stepper button
// =============================================================================

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurface,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.4),
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// =============================================================================
// Add Player Bottom Sheet
// =============================================================================

class _AddPlayerSheet extends ConsumerStatefulWidget {
  const _AddPlayerSheet({required this.usedColorKeys, required this.onConfirm});

  final Set<String> usedColorKeys;
  final void Function(String name, String colorKey, String avatarStyle)
  onConfirm;

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet> {
  final _nameController = TextEditingController();
  late String _selectedColorKey;
  String _avatarStyle = 'initials';

  // ── Free emoji packs ──────────────────────────────────────────────
  static const _freeEmoji = [
    // Animals
    '🐱', '🐶', '🐻', '🦊', '🐼', '🐨', '🐸', '🐙',
    '🦋', '🐬', '🦄', '🐉', '🐺', '🦁', '🐧', '🦉',
    // Objects & symbols
    '⭐', '👑', '🔥', '❤️', '🌙', '☀️', '✨', '🔮',
    '🪄', '⚡', '🌈', '🎲', '🍀', '🌻', '👻', '🎭',
    // People & roles
    '🧙', '🧝', '🧚', '🦸', '🥷', '👸', '🤴', '🧑\u200d🎨',
  ];

  // ── Premium emoji packs (supporter only) ────────────────────────
  static const _premiumFamousPeople = [
    '🎩',
    '🕵️',
    '🧛',
    '🧟',
    '🤖',
    '👽',
    '🧜',
    '🦹',
    '🫅',
    '💂',
    '🧑\u200d🚀',
    '🧑\u200d🔬',
    '🧑\u200d🍳',
    '🧑\u200d✈️',
    '🧑\u200d🎤',
    '🧑\u200d🏫',
  ];

  static const _premiumMythical = [
    '🐲',
    '🦅',
    '🦇',
    '🕊️',
    '🐍',
    '🦂',
    '🦚',
    '🦩',
    '🐋',
    '🦈',
    '🐊',
    '🐅',
    '🦏',
    '🐘',
    '🦬',
    '🐎',
  ];

  static const _premiumFood = [
    '🍕',
    '🍔',
    '🌮',
    '🍣',
    '🧁',
    '🍩',
    '🍪',
    '🎂',
    '🍉',
    '🍑',
    '🍒',
    '🥑',
    '🌶️',
    '🍄',
    '☕',
    '🧋',
  ];

  @override
  void initState() {
    super.initState();
    _selectedColorKey = PlayerColors.nextAvailable(widget.usedColorKeys);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  bool get _isEmojiMode => _avatarStyle != 'initials';

  List<String> get _emojiOptions => [
    ..._freeEmoji,
    if (ref.read(isSupporterProvider)) ...[
      ..._premiumFamousPeople,
      ..._premiumMythical,
      ..._premiumFood,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpacingTokens.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            Text(l10n.addPlayer, style: textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.lg),

            // Name field.
            TextFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: 30,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: l10n.playerName,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Color picker.
            Text(
              l10n.chooseColor,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            ColorPickerChips(
              selectedKey: _selectedColorKey,
              usedKeys: widget.usedColorKeys,
              onSelected: (key) => setState(() => _selectedColorKey = key),
            ),

            const SizedBox(height: SpacingTokens.lg),

            // Avatar style section.
            Text(
              l10n.avatarStyle,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.initials),
                    icon: const Icon(Icons.text_fields_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.emoji),
                    icon: const Icon(Icons.emoji_emotions_rounded, size: 18),
                  ),
                ],
                selected: {_isEmojiMode},
                onSelectionChanged: (s) {
                  setState(() {
                    if (s.first) {
                      // Switch to emoji — pick first one as default
                      _avatarStyle = _emojiOptions.first;
                    } else {
                      _avatarStyle = 'initials';
                    }
                  });
                },
                showSelectedIcon: false,
              ),
            ),

            // Emoji grid (shown only when emoji mode is active).
            if (_isEmojiMode) ...[
              const SizedBox(height: SpacingTokens.sm),
              _buildEmojiGrid(
                'Free',
                _freeEmoji,
                storyTheme,
                colorScheme,
                false,
              ),
              if (ref.watch(isSupporterProvider)) ...[
                const SizedBox(height: SpacingTokens.sm),
                _buildEmojiGrid(
                  '👥 People Pack',
                  _premiumFamousPeople,
                  storyTheme,
                  colorScheme,
                  false,
                ),
                const SizedBox(height: SpacingTokens.sm),
                _buildEmojiGrid(
                  '🐲 Mythical Pack',
                  _premiumMythical,
                  storyTheme,
                  colorScheme,
                  false,
                ),
                const SizedBox(height: SpacingTokens.sm),
                _buildEmojiGrid(
                  '🍕 Food Pack',
                  _premiumFood,
                  storyTheme,
                  colorScheme,
                  false,
                ),
              ] else ...[
                const SizedBox(height: SpacingTokens.md),
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                    border: Border.all(
                      color: storyTheme.goldAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: storyTheme.goldAccent,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.bonusEmojiPacks,
                          style: textTheme.labelMedium?.copyWith(
                            color: storyTheme.goldAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: SpacingTokens.lg),

            // Confirm button.
            FilledButton(
              onPressed: _isValid
                  ? () => widget.onConfirm(
                      _nameController.text.trim(),
                      _selectedColorKey,
                      _avatarStyle,
                    )
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: storyTheme.teal,
                foregroundColor: Colors.black,
                disabledBackgroundColor: storyTheme.teal.withValues(
                  alpha: 0.3,
                ),
                disabledForegroundColor: Colors.black45,
              ),
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiGrid(
    String label,
    List<String> emojis,
    StoryScoreThemeExtension storyTheme,
    ColorScheme colorScheme,
    bool isLocked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != 'Free')
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Wrap(
          spacing: SpacingTokens.xs,
          runSpacing: SpacingTokens.xs,
          children: emojis.map((emoji) {
            final isSelected = _avatarStyle == emoji;
            return GestureDetector(
              onTap: isLocked
                  ? null
                  : () => setState(() => _avatarStyle = emoji),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? storyTheme.teal.withValues(alpha: 0.2)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  border: Border.all(
                    color: isSelected
                        ? storyTheme.teal
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 20,
                    color: isLocked ? Colors.grey : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// =============================================================================
// Load Preset Bottom Sheet
// =============================================================================

class _LoadPresetSheet extends ConsumerWidget {
  const _LoadPresetSheet({required this.onPresetSelected});

  final void Function(PlayerPreset preset, List<PresetPlayer> players)
  onPresetSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: SpacingTokens.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(l10n.loadPreset, style: textTheme.titleLarge),
          const SizedBox(height: SpacingTokens.md),
          presetsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('${l10n.error}: $e'),
            data: (presets) {
              if (presets.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Center(
                    child: Text(
                      l10n.noPresetsYet,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return _LoadPresetTile(
                      preset: preset,
                      onTap: (players) => onPresetSelected(preset, players),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadPresetTile extends ConsumerWidget {
  const _LoadPresetTile({required this.preset, required this.onTap});

  final PlayerPreset preset;
  final void Function(List<PresetPlayer> players) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(presetPlayersProvider(preset.id));

    return playersAsync.when(
      loading: () => const SizedBox(height: 56),
      error: (e, _) => ListTile(title: Text('${context.l10n.error}: $e')),
      data: (players) => PresetListTile(
        preset: preset,
        players: players,
        onTap: () => onTap(players),
        onDelete: () {}, // no delete in load sheet
      ),
    );
  }
}

// =============================================================================
// Favorite Chips Section (loads favorites from provider)
// =============================================================================

class _FavoriteChipsSection extends ConsumerWidget {
  const _FavoriteChipsSection({
    required this.usedColorKeys,
    required this.existingNames,
    required this.onSelect,
  });

  final Set<String> usedColorKeys;
  final Set<String> existingNames;
  final void Function(String name, String colorKey, String avatarStyle)
  onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritePlayersProvider);

    return favoritesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (favorites) {
        if (favorites.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: SpacingTokens.md),
          child: FavoritePlayerChips(
            favorites: favorites,
            excludeNames: existingNames,
            onSelect: onSelect,
          ),
        );
      },
    );
  }
}
