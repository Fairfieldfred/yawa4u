import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';
import 'template_selection_screen.dart';

/// Mesocycle list screen - organized by Draft/Current/Completed
class MesocycleListScreen extends ConsumerStatefulWidget {
  const MesocycleListScreen({super.key});

  @override
  ConsumerState<MesocycleListScreen> createState() =>
      _MesocycleListScreenState();
}

class _MesocycleListScreenState extends ConsumerState<MesocycleListScreen> {
  @override
  Widget build(BuildContext context) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesocycles'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(isDarkModeProvider)
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          // New mesocycle button
          TextButton.icon(
            onPressed: () => context.push('/plan-mesocycle'),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: mesocyclesAsync.when(
        data: (mesocycles) {
          if (mesocycles.isEmpty) {
            return _buildEmptyState(context);
          }

          // Separate mesocycles by status
          final draftMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.draft)
              .toList();
          final currentMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.current)
              .toList();
          final completedMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Draft Mesocycles Section
              if (draftMesocycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Draft Mesocycle'),
                const SizedBox(height: 12),
                ...draftMesocycles.map(
                  (mesocycle) =>
                      _buildMesocycleCard(context, mesocycle, isDraft: true),
                ),
                const SizedBox(height: 24),
              ],

              // Current Mesocycle Section
              if (currentMesocycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Current Mesocycle'),
                const SizedBox(height: 12),
                ...currentMesocycles.map(
                  (mesocycle) =>
                      _buildMesocycleCard(context, mesocycle, isCurrent: true),
                ),
                const SizedBox(height: 24),
              ],

              // Completed Mesocycles Section
              if (completedMesocycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Completed Mesocycles'),
                const SizedBox(height: 12),
                ...completedMesocycles.map(
                  (mesocycle) => _buildMesocycleCard(context, mesocycle),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading mesocycles: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMesocycleCard(
    BuildContext context,
    Mesocycle mesocycle, {
    bool isDraft = false,
    bool isCurrent = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/mesocycles/${mesocycle.id}/workouts'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and more menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mesocycle.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'CURRENT',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) =>
                            _handleMenuAction(value, mesocycle),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'note',
                            child: Row(
                              children: [
                                Icon(Icons.note_add_outlined),
                                SizedBox(width: 12),
                                Text('Write a new note'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 12),
                                Text('Rename the mesocycle'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                Icon(Icons.copy_outlined),
                                SizedBox(width: 12),
                                Text('Copy the Mesocycle'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'summary',
                            child: Row(
                              children: [
                                Icon(Icons.summarize_outlined),
                                SizedBox(width: 12),
                                Text('Summary'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'template',
                            child: Row(
                              children: [
                                Icon(Icons.save_outlined),
                                SizedBox(width: 12),
                                Text('Save as a Template'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Delete meso',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.weeksTotal} weeks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.daysPerWeek} days/week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mesocycles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first mesocycle to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/plan-mesocycle'),
            icon: const Icon(Icons.add),
            label: const Text('Create New'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TemplateSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Start from Template'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(String action, Mesocycle mesocycle) async {
    switch (action) {
      case 'note':
        // TODO: Implement write note functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Write note - Coming soon')),
        );
        break;
      case 'rename':
        await _showRenameMesocycleModal(mesocycle);
        break;
      case 'copy':
        // TODO: Implement copy functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copy mesocycle - Coming soon')),
        );
        break;
      case 'summary':
        // TODO: Implement summary functionality
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Summary - Coming soon')));
        break;
      case 'template':
        // TODO: Implement save as template functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save as template - Coming soon')),
        );
        break;
      case 'delete':
        await _deleteMesocycle(mesocycle);
        break;
    }
  }

  Future<void> _showRenameMesocycleModal(Mesocycle mesocycle) async {
    final TextEditingController nameController = TextEditingController(
      text: mesocycle.name,
    );

    try {
      final newName = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      'Rename',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Mesocycle name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final trimmedName = nameController.text.trim();
                          if (trimmedName.isNotEmpty) {
                            Navigator.pop(context, trimmedName);
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('SAVE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (newName != null && newName != mesocycle.name && mounted) {
        try {
          final repository = ref.read(mesocycleRepositoryProvider);
          final updatedMesocycle = mesocycle.copyWith(name: newName);
          await repository.update(updatedMesocycle);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Renamed to "$newName"'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error renaming mesocycle: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } finally {
      // Dispose after a microtask to ensure dialog is fully closed
      Future.microtask(() => nameController.dispose());
    }
  }

  Future<void> _deleteMesocycle(Mesocycle mesocycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft Mesocycle'),
        content: Text(
          'Are you sure you want to delete "${mesocycle.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(mesocycleRepositoryProvider);
        await repository.delete(mesocycle.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${mesocycle.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting mesocycle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
