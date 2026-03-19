import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
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
    final storyTheme = context.storyTheme;
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isTablet ? 600 : double.infinity,
              ),
              child: Column(
                children: [
                  // Scrollable form content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.lg,
                        vertical: SpacingTokens.md,
                      ),
                      children: [
                        // ── Header row: back circle + "New Game" + save preset ──
                        Row(
                          children: [
                            // Back button in circle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorTokens.darkCard,
                                border: Border.all(
                                  color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: ColorTokens.goldAccent,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => context.pop(),
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            Text(
                              l10n.newGame,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: ColorTokens.parchment,
                              ),
                            ),
                            const Spacer(),
                            if (state.players.length >= 3 &&
                                ref.watch(isSupporterProvider))
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorTokens.darkCard,
                                  border: Border.all(
                                    color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const CustomIcon('save_preset', size: 18),
                                  padding: EdgeInsets.zero,
                                  tooltip: l10n.saveAsPreset,
                                  onPressed: () => _showSavePresetDialog(),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: SpacingTokens.lg),

                        // ── GAME TITLE section ──
                        const _SectionLabel('GAME TITLE'),
                        const SizedBox(height: SpacingTokens.sm),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: l10n.gameTitleHint,
                            filled: true,
                            fillColor: ColorTokens.darkCard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                          onChanged: (v) =>
                              ref.read(gameSetupProvider.notifier).setTitle(v),
                        ),

                        const SizedBox(height: SpacingTokens.lg),

                        // ── Score Target / Infinite toggle pills ──
                        Row(
                          children: [
                            // Score Target pill
                            _TogglePill(
                              label: l10n.scoreTarget,
                              isSelected: state.targetType == TargetType.score,
                              onTap: () => ref
                                  .read(gameSetupProvider.notifier)
                                  .setTargetType(TargetType.score),
                              gradient: storyTheme.accentGradient,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            // Infinite pill
                            _TogglePill(
                              label: l10n.infinite,
                              isSelected:
                                  state.targetType == TargetType.freeplay,
                              onTap: () => ref
                                  .read(gameSetupProvider.notifier)
                                  .setTargetType(TargetType.freeplay),
                              gradient: storyTheme.accentGradient,
                            ),
                          ],
                        ),

                        // ── Target score stepper (conditional) ──
                        if (state.targetType == TargetType.score) ...[
                          const SizedBox(height: SpacingTokens.lg),
                          const _SectionLabel('TARGET SCORE'),
                          const SizedBox(height: SpacingTokens.sm),
                          Row(
                            children: [
                              // Stepper: - / number / +
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
                                width: 56,
                                child: TextFormField(
                                  controller: _targetScoreController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: ColorTokens.parchment,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorTokens.darkCard,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: SpacingTokens.sm,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
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
                              const Spacer(),
                              // Load Preset button
                              if (ref.watch(isSupporterProvider))
                                OutlinedButton.icon(
                                  onPressed: () => _showLoadPresetSheet(),
                                  icon: const CustomIcon('load_preset', size: 18),
                                  label: Text(l10n.loadPreset),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ColorTokens.parchment,
                                    side: BorderSide(
                                      color: ColorTokens.parchment
                                          .withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: SpacingTokens.md,
                                      vertical: SpacingTokens.sm,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],

                        const SizedBox(height: SpacingTokens.xl),

                        // ── PLAYERS section ──
                        const _SectionLabel('PLAYERS'),
                        const SizedBox(height: SpacingTokens.sm),

                        // Player list
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
                                  borderRadius: BorderRadius.circular(14),
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

                        // Add Player button: outlined purple with sparkle icon
                        OutlinedButton.icon(
                          onPressed: state.isPlayerLimitReached
                              ? null
                              : _showAddPlayerSheet,
                          icon: const CustomIcon('add_player', size: 20),
                          label: Text(l10n.addPlayer),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            foregroundColor: ColorTokens.parchment,
                            side: BorderSide(
                              color: state.isPlayerLimitReached
                                  ? ColorTokens.mutedText.withValues(alpha: 0.3)
                                  : ColorTokens.violet.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                        // Favorite player chips (premium-gated)
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

                        const SizedBox(height: SpacingTokens.xxl),
                      ],
                    ),
                  ),

                  // ── Start Game button (pinned at bottom) ──
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SpacingTokens.lg,
                        SpacingTokens.sm,
                        SpacingTokens.lg,
                        SpacingTokens.md,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: state.canStart && !_isCreating
                                ? storyTheme.accentGradient
                                : LinearGradient(
                                    colors: [
                                      ColorTokens.burgundy.withValues(alpha: 0.3),
                                      ColorTokens.goldAccent.withValues(alpha: 0.3),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: FilledButton(
                            onPressed: state.canStart && !_isCreating
                                ? _startGame
                                : null,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.white54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                : Text(
                                    l10n.startGame,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Section label (gold uppercase)
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
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
// Toggle pill for Score Target / Infinite
// =============================================================================

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm + 2,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? null
              : Border.all(
                  color: ColorTokens.parchment.withValues(alpha: 0.3),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : ColorTokens.parchment,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Stepper button
// =============================================================================

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: ColorTokens.darkCard,
          foregroundColor: ColorTokens.goldAccent,
          disabledBackgroundColor:
              ColorTokens.darkCard.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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

  // ── Free emoji packs ──
  static const _freeEmoji = [
    '🐱', '🐶', '🐻', '🦊', '🐼', '🐨', '🐸', '🐙',
    '🦋', '🐬', '🦄', '🐉', '🐺', '🦁', '🐧', '🦉',
    '⭐', '👑', '🔥', '❤️', '🌙', '☀️', '✨', '🔮',
    '🪄', '⚡', '🌈', '🎲', '🍀', '🌻', '👻', '🎭',
    '🧙', '🧝', '🧚', '🦸', '🥷', '👸', '🤴', '🧑\u200d🎨',
  ];

  // ── Premium emoji packs ──
  static const _premiumFamousPeople = [
    '🎩', '🕵️', '🧛', '🧟', '🤖', '👽', '🧜', '🦹',
    '🫅', '💂', '🧑\u200d🚀', '🧑\u200d🔬', '🧑\u200d🍳', '🧑\u200d✈️', '🧑\u200d🎤', '🧑\u200d🏫',
  ];

  static const _premiumMythical = [
    '🐲', '🦅', '🦇', '🕊️', '🐍', '🦂', '🦚', '🦩',
    '🐋', '🦈', '🐊', '🐅', '🦏', '🐘', '🦬', '🐎',
  ];

  static const _premiumFood = [
    '🍕', '🍔', '🌮', '🍣', '🧁', '🍩', '🍪', '🎂',
    '🍉', '🍑', '🍒', '🥑', '🌶️', '🍄', '☕', '🧋',
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
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: ColorTokens.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorTokens.mutedText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // "Add Player" title
              const Text(
                'Add Player',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: ColorTokens.parchment,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // Favorites section
              if (ref.watch(isSupporterProvider))
                _FavoriteChipsInSheet(
                  usedColorKeys: widget.usedColorKeys,
                  onSelect: (name, colorKey, avatarStyle) {
                    widget.onConfirm(name, colorKey, avatarStyle);
                  },
                ),

              // "NAME" section header
              const _SectionLabel('NAME'),
              const SizedBox(height: SpacingTokens.sm),

              // Name input
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l10n.playerName,
                  counterText: '',
                  filled: true,
                  fillColor: ColorTokens.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: ColorTokens.violet.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: ColorTokens.violet.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorTokens.goldAccent,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // "CHOOSE COLOR" section header
              const _SectionLabel('CHOOSE COLOR'),
              const SizedBox(height: SpacingTokens.sm),
              ColorPickerChips(
                selectedKey: _selectedColorKey,
                usedKeys: widget.usedColorKeys,
                onSelected: (key) => setState(() => _selectedColorKey = key),
              ),

              const SizedBox(height: SpacingTokens.lg),

              // "AVATAR STYLE" section header
              const _SectionLabel('AVATAR STYLE'),
              const SizedBox(height: SpacingTokens.sm),

              // Initials / Emoji toggle pills
              Row(
                children: [
                  _TogglePill(
                    label: l10n.initials,
                    isSelected: !_isEmojiMode,
                    onTap: () => setState(() => _avatarStyle = 'initials'),
                    gradient: storyTheme.accentGradient,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  _TogglePill(
                    label: l10n.emoji,
                    isSelected: _isEmojiMode,
                    onTap: () {
                      if (!_isEmojiMode) {
                        setState(
                            () => _avatarStyle = _emojiOptions.first);
                      }
                    },
                    gradient: storyTheme.accentGradient,
                  ),
                ],
              ),

              // Emoji grid
              if (_isEmojiMode) ...[
                const SizedBox(height: SpacingTokens.sm),
                _buildEmojiGrid(_freeEmoji, false),
                if (ref.watch(isSupporterProvider)) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  _buildEmojiGrid(_premiumFamousPeople, false),
                  const SizedBox(height: SpacingTokens.sm),
                  _buildEmojiGrid(_premiumMythical, false),
                  const SizedBox(height: SpacingTokens.sm),
                  _buildEmojiGrid(_premiumFood, false),
                ] else ...[
                  const SizedBox(height: SpacingTokens.md),
                  Container(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    decoration: BoxDecoration(
                      color: ColorTokens.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ColorTokens.goldAccent.withValues(alpha: 0.3),
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
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
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

              // "Add" gradient button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _isValid
                        ? storyTheme.accentGradient
                        : LinearGradient(
                            colors: [
                              ColorTokens.burgundy.withValues(alpha: 0.3),
                              ColorTokens.goldAccent.withValues(alpha: 0.3),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FilledButton(
                    onPressed: _isValid
                        ? () => widget.onConfirm(
                              _nameController.text.trim(),
                              _selectedColorKey,
                              _avatarStyle,
                            )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.white54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.add,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiGrid(List<String> emojis, bool isLocked) {
    return Wrap(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? ColorTokens.goldAccent.withValues(alpha: 0.2)
                  : ColorTokens.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? ColorTokens.goldAccent
                    : ColorTokens.darkCardVariant,
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
    );
  }
}

// =============================================================================
// Favorite chips within the add player sheet
// =============================================================================

class _FavoriteChipsInSheet extends ConsumerWidget {
  const _FavoriteChipsInSheet({
    required this.usedColorKeys,
    required this.onSelect,
  });

  final Set<String> usedColorKeys;
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel('FAVORITES'),
            const SizedBox(height: SpacingTokens.sm),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              children: favorites.map((fav) {
                return OutlinedButton(
                  onPressed: () =>
                      onSelect(fav.name, fav.colorKey, fav.avatarStyle),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorTokens.parchment,
                    side: BorderSide(
                      color: ColorTokens.parchment.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                  ),
                  child: Text(fav.name),
                );
              }).toList(),
            ),
            const SizedBox(height: SpacingTokens.lg),
          ],
        );
      },
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
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: ColorTokens.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorTokens.mutedText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              l10n.loadPreset,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ColorTokens.parchment,
              ),
            ),
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
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
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
                        onTap: (players) =>
                            onPresetSelected(preset, players),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
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
        onDelete: () {},
      ),
    );
  }
}

// =============================================================================
// Favorite Chips Section (main screen)
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
