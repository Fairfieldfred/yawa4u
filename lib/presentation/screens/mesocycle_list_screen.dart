import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/template_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/mesocycle_summary_dialog.dart';
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
            padding: const EdgeInsets.all(0.0),
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
                const SizedBox(height: 20),
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

  /// Check if ALL days in ALL weeks have at least one exercise
  bool _hasExercisesForAllDays(Mesocycle mesocycle) {
    final workouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

    // Check EVERY week in the mesocycle
    for (int week = 1; week <= mesocycle.weeksTotal; week++) {
      final weekWorkouts = workouts.where((w) => w.weekNumber == week).toList();

      // Check EVERY day in this week
      for (int day = 1; day <= mesocycle.daysPerWeek; day++) {
        // Find workouts for this specific day in this specific week
        final dayWorkouts = weekWorkouts.where((w) => w.dayNumber == day);

        // Check if at least one workout has exercises
        final hasExercises = dayWorkouts.any((w) => w.exercises.isNotEmpty);

        if (!hasExercises) {
          return false; // This day in this week has no exercises
        }
      }
    }

    return true; // ALL days in ALL weeks have at least one exercise
  }

  Widget _buildMesocycleCard(
    BuildContext context,
    Mesocycle mesocycle, {
    bool isDraft = false,
    bool isCurrent = false,
  }) {
    // Check if mesocycle is ready to be saved as template
    final canSaveAsTemplate = _hasExercisesForAllDays(mesocycle);

    // Determine if this is a completed mesocycle (for read-only navigation)
    final isCompleted = mesocycle.status == MesocycleStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            // Navigate to read-only view for completed mesocycles
            context.push('/mesocycles/${mesocycle.id}/view');
          } else if (isCurrent) {
            // Switch to workout tab (same as tapping Workout in bottomNav)
            ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.workout);
          } else {
            // Navigate to editable workout screen for draft mesocycles
            context.push('/mesocycles/${mesocycle.id}/workouts');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                        )
                      else if (mesocycle.status == MesocycleStatus.completed &&
                          mesocycle.endDate != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatDate(mesocycle.endDate!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          ],
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
                          PopupMenuItem(
                            value: 'template',
                            enabled: canSaveAsTemplate,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.save_outlined,
                                  color: canSaveAsTemplate ? null : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Save as a Template',
                                  style: TextStyle(
                                    color: canSaveAsTemplate
                                        ? null
                                        : Colors.grey,
                                  ),
                                ),
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
        await showDialog(
          context: context,
          builder: (context) => MesocycleSummaryDialog(mesocycle: mesocycle),
        );
        break;
      case 'template':
        await _saveAsTemplate(mesocycle);
        break;
      case 'delete':
        await _deleteMesocycle(mesocycle);
        break;
    }
  }

  Future<void> _saveAsTemplate(Mesocycle mesocycle) async {
    final result = await showDialog<({String name, String description})>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SaveTemplateDialog(initialName: mesocycle.name),
    );

    if (result != null && mounted) {
      try {
        // Load the full mesocycle with workouts
        final workouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));
        final fullMesocycle = mesocycle.copyWith(workouts: workouts);

        final repository = ref.read(templateRepositoryProvider);
        await repository.saveAsTemplate(
          fullMesocycle,
          result.name,
          result.description,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${result.name}" saved!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh templates provider
          ref.invalidate(availableTemplatesProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showRenameMesocycleModal(Mesocycle mesocycle) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RenameMesocycleDialog(initialName: mesocycle.name),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// Stateful dialog widget for renaming mesocycle
class _RenameMesocycleDialog extends StatefulWidget {
  final String initialName;

  const _RenameMesocycleDialog({required this.initialName});

  @override
  State<_RenameMesocycleDialog> createState() => _RenameMesocycleDialogState();
}

class _RenameMesocycleDialogState extends State<_RenameMesocycleDialog> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: () => Navigator.of(context).pop(),
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
                        Navigator.of(context).pop(trimmedName);
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
    );
  }
}

// Stateful dialog widget to properly manage TextEditingController lifecycle
class _SaveTemplateDialog extends StatefulWidget {
  final String initialName;

  const _SaveTemplateDialog({required this.initialName});

  @override
  State<_SaveTemplateDialog> createState() => _SaveTemplateDialogState();
}

class _SaveTemplateDialogState extends State<_SaveTemplateDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  'Save as Template',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Template Name',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g., "Upper Lower Split"',
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
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., "Great for building strength and size"',
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
                    onPressed: () => Navigator.of(context).pop(),
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
                      final trimmedDescription = descriptionController.text
                          .trim();
                      if (trimmedName.isNotEmpty &&
                          trimmedDescription.isNotEmpty) {
                        Navigator.of(context).pop((
                          name: trimmedName,
                          description: trimmedDescription,
                        ));
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
    );
  }
}
