import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/features/game_edit/providers/game_edit_providers.dart';
import 'package:story_score/features/game_setup/widgets/color_picker_chips.dart';
import 'package:story_score/features/game_setup/widgets/player_tile.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

class GameEditScreen extends ConsumerStatefulWidget {
  const GameEditScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<GameEditScreen> createState() => _GameEditScreenState();
}

class _GameEditScreenState extends ConsumerState<GameEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetScoreController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _targetScoreController = TextEditingController();

    // Load session data on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(gameEditProvider.notifier).loadSession(widget.sessionId);
      final state = ref.read(gameEditProvider);
      _titleController.text = state.title;
      _targetScoreController.text = state.targetScore.toString();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(gameEditProvider.notifier).save();
      Haptics.selection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.changesSaved)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddPlayerSheet() {
    final editState = ref.read(gameEditProvider);
    if (editState.isPlayerLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.maxPlayersReached)),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _AddPlayerSheet(
        usedColorKeys: editState.usedColorKeys,
        onConfirm: (name, colorKey, avatarStyle) {
          Haptics.selection();
          ref.read(gameEditProvider.notifier).addPlayer(
                name: name,
                colorKey: colorKey,
                avatarStyle: avatarStyle,
              );
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.playerAdded)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameEditProvider);
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    if (!state.isLoaded) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: storyTheme.backgroundGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editGame,
          style: TextStyle(color: storyTheme.primaryText),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: storyTheme.primaryAccent,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: storyTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isTablet ? 600 : double.infinity,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                      vertical: SpacingTokens.md,
                    ),
                    children: [
                      // ── Title field ──
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
                            ref.read(gameEditProvider.notifier).setTitle(v),
                      ),

                      const SizedBox(height: SpacingTokens.lg),

                      // ── Target type selector ──
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
                              .read(gameEditProvider.notifier)
                              .setTargetType(s.first),
                          showSelectedIcon: false,
                        ),
                      ),

                      // ── Target score input (conditional) ──
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
                            _StepperButton(
                              icon: Icons.remove_rounded,
                              onPressed: state.targetScore > 10
                                  ? () {
                                      final newVal = state.targetScore - 5;
                                      ref
                                          .read(gameEditProvider.notifier)
                                          .setTargetScore(newVal);
                                      _targetScoreController.text =
                                          newVal.clamp(10, 200).toString();
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
                                    final clamped = parsed.clamp(1, 200);
                                    ref
                                        .read(gameEditProvider.notifier)
                                        .setTargetScore(clamped);
                                    if (parsed != clamped) {
                                      _targetScoreController.text =
                                          clamped.toString();
                                      _targetScoreController.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(
                                          offset: _targetScoreController
                                              .text.length,
                                        ),
                                      );
                                    }
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
                                          .read(gameEditProvider.notifier)
                                          .setTargetScore(newVal);
                                      _targetScoreController.text =
                                          newVal.clamp(10, 200).toString();
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.md),
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
                                  .read(gameEditProvider.notifier)
                                  .setContinuePastTarget(v),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: SpacingTokens.xl),

                      // ── Players section ──
                      Row(
                        children: [
                          Text(
                            l10n.players.toUpperCase(),
                            style: textTheme.labelLarge?.copyWith(
                              color: storyTheme.primaryAccent,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${state.players.length}/10',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),

                      // Player list
                      ...state.players.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: GestureDetector(
                            onTap: () => _showEditPlayerSheet(index, player),
                            child: PlayerTile(
                              name: player.name,
                              colorKey: player.colorKey,
                              seatNumber: player.seatOrder + 1,
                              onRemove: () =>
                                  _showEditPlayerSheet(index, player),
                            ),
                          ),
                        );
                      }),

                      // Add player button
                      if (!state.isPlayerLimitReached)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: SpacingTokens.sm,
                          ),
                          child: OutlinedButton.icon(
                            onPressed: _showAddPlayerSheet,
                            icon: const Icon(Icons.person_add_rounded),
                            label: Text(l10n.addPlayer),
                            style: OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size(double.infinity, 48),
                            ),
                          ),
                        ),

                      const SizedBox(height: SpacingTokens.xxl),
                    ],
                  ),
                ),

                // ── Save button ──
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.saveChanges),
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

  void _showEditPlayerSheet(int index, EditablePlayer player) {
    final nameController = TextEditingController(text: player.name);
    var selectedColorKey = player.colorKey;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final storyTheme = context.storyTheme;
            final editState = ref.read(gameEditProvider);
            final usedKeys = editState.usedColorKeys
                .difference({player.colorKey});

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Text(
                        context.l10n.playerName.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: storyTheme.primaryAccent,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        maxLength: 30,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: context.l10n.playerName,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      Text(
                        context.l10n.selectColor.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: storyTheme.primaryAccent,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      ColorPickerChips(
                        selectedKey: selectedColorKey,
                        usedKeys: usedKeys,
                        onSelected: (key) {
                          setSheetState(() => selectedColorKey = key);
                        },
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          ref
                              .read(gameEditProvider.notifier)
                              .updatePlayerName(index, name);
                          ref
                              .read(gameEditProvider.notifier)
                              .updatePlayerColor(index, selectedColorKey);
                          Navigator.of(sheetContext).pop();
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(context.l10n.saveChanges),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// Add player bottom sheet (reused pattern from game_setup)
// =============================================================================

class _AddPlayerSheet extends StatefulWidget {
  const _AddPlayerSheet({
    required this.usedColorKeys,
    required this.onConfirm,
  });

  final Set<String> usedColorKeys;
  final void Function(String name, String colorKey, String avatarStyle)
      onConfirm;

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _nameController = TextEditingController();
  late String _selectedColorKey;

  @override
  void initState() {
    super.initState();
    _selectedColorKey = PlayerColors.orderedKeys.firstWhere(
      (key) => !widget.usedColorKeys.contains(key),
      orElse: () => PlayerColors.orderedKeys.first,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                l10n.playerName.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: storyTheme.primaryAccent,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: l10n.playerName,
                  counterText: '',
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                l10n.selectColor.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: storyTheme.primaryAccent,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              ColorPickerChips(
                selectedKey: _selectedColorKey,
                usedKeys: widget.usedColorKeys,
                onSelected: (key) {
                  setState(() => _selectedColorKey = key);
                },
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  widget.onConfirm(name, _selectedColorKey, 'initials');
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l10n.addPlayer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Stepper button (reused pattern from game_setup)
// =============================================================================

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          disabledBackgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
