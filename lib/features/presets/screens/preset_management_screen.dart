import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/presets/providers/preset_providers.dart';
import 'package:story_score/features/presets/widgets/preset_list_tile.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Screen listing all saved player presets with CRUD operations.
///
/// Premium-gated: shows a locked state with CTA when the user is not a
/// supporter.
class PresetManagementScreen extends ConsumerWidget {
  const PresetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSupporter = ref.watch(isSupporterProvider);
    final presetsAsync = ref.watch(presetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Presets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: isSupporter
          ? _buildUnlockedBody(context, ref, presetsAsync)
          : _buildLockedBody(context),
      floatingActionButton: isSupporter
          ? FloatingActionButton(
              onPressed: () => _showCreatePresetDialog(context, ref),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildLockedBody(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text('Player Presets', style: textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Save your favorite player groups for quick game setup. '
              'Unlock with the Supporter Pack.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xl),
            FilledButton.icon(
              onPressed: () => context.go('/settings/premium'),
              icon: const Icon(Icons.star_rounded),
              label: const Text('Unlock Supporter Pack'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PlayerPreset>> presetsAsync,
  ) {
    return presetsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (presets) {
        if (presets.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(SpacingTokens.md),
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final preset = presets[index];
            return _PresetTileWithPlayers(
              preset: preset,
              onTap: () => _showEditPresetDialog(context, ref, preset),
              onDelete: () => _deletePreset(context, ref, preset),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text('No presets yet', style: textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Create a preset to quickly start games with your usual group.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePresetDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Preset'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Preset name',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    nameController.dispose();

    if (name == null || name.isEmpty) return;

    // Create an empty preset with placeholder players (min 3)
    // Users will edit and add real players
    final dao = ref.read(presetDaoProvider);
    try {
      final presetId = IdGenerator.newId();
      final defaultPlayers = List.generate(3, (i) {
        final colorKey = PlayerColors.orderedKeys[i];
        return PresetPlayersCompanion.insert(
          id: IdGenerator.newId(),
          presetId: presetId,
          name: 'Player ${i + 1}',
          colorKey: colorKey,
          seatOrder: i,
        );
      });
      await dao.createPreset(id: presetId, name: name, players: defaultPlayers);
      Haptics.selection();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create preset: $e')));
      }
    }
  }

  Future<void> _showEditPresetDialog(
    BuildContext context,
    WidgetRef ref,
    PlayerPreset preset,
  ) async {
    final nameController = TextEditingController(text: preset.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Preset'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Preset name',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();

    if (newName == null || newName.isEmpty || newName == preset.name) return;

    final dao = ref.read(presetDaoProvider);
    await dao.updatePresetName(preset.id, newName);
  }

  Future<void> _deletePreset(
    BuildContext context,
    WidgetRef ref,
    PlayerPreset preset,
  ) async {
    final dao = ref.read(presetDaoProvider);
    await dao.deletePreset(preset.id);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${preset.name}"')));
    }
  }
}

/// Wraps a [PresetListTile] and loads its players via the stream provider.
class _PresetTileWithPlayers extends ConsumerWidget {
  const _PresetTileWithPlayers({
    required this.preset,
    required this.onTap,
    required this.onDelete,
  });

  final PlayerPreset preset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(presetPlayersProvider(preset.id));

    return playersAsync.when(
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ListTile(title: Text('Error: $e')),
      data: (players) => PresetListTile(
        preset: preset,
        players: players,
        onTap: onTap,
        onDelete: onDelete,
      ),
    );
  }
}
