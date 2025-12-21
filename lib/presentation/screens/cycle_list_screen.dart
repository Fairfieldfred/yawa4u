import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/template_exporter.dart';
import '../../data/models/training_cycle.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/template_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/cycle_summary_dialog.dart';
import '../widgets/dialogs/workout_dialogs.dart';
import 'template_selection_screen.dart';

/// TrainingCycle list screen - organized by Draft/Current/Completed
class CycleListScreen extends ConsumerStatefulWidget {
  const CycleListScreen({super.key});

  @override
  ConsumerState<CycleListScreen> createState() => _CycleListScreenState();
}

class _CycleListScreenState extends ConsumerState<CycleListScreen> {
  @override
  Widget build(BuildContext context) {
    final trainingCyclesAsync = ref.watch(trainingCyclesProvider);
    final cycleTerm = ref.watch(trainingCycleTermProvider);
    final cycleTermPlural = ref.watch(trainingCycleTermPluralProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(cycleTermPlural),
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
          // New trainingCycle button
          TextButton.icon(
            onPressed: () => context.push('/plan-trainingCycle'),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: trainingCyclesAsync.when(
        data: (trainingCycles) {
          if (trainingCycles.isEmpty) {
            return _buildEmptyState(context);
          }

          // Separate trainingCycles by status
          final draftTrainingCycles = trainingCycles
              .where((m) => m.status == TrainingCycleStatus.draft)
              .toList();
          final currentTrainingCycles = trainingCycles
              .where((m) => m.status == TrainingCycleStatus.current)
              .toList();
          final completedTrainingCycles = trainingCycles
              .where((m) => m.status == TrainingCycleStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(0.0),
            children: [
              // Draft TrainingCycles Section
              if (draftTrainingCycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Draft $cycleTerm'),
                const SizedBox(height: 12),
                ...draftTrainingCycles.map(
                  (trainingCycle) => _buildTrainingCycleCard(
                    context,
                    trainingCycle,
                    isDraft: true,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Current TrainingCycle Section
              if (currentTrainingCycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Current $cycleTerm'),
                const SizedBox(height: 12),
                ...currentTrainingCycles.map(
                  (trainingCycle) => _buildTrainingCycleCard(
                    context,
                    trainingCycle,
                    isCurrent: true,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Completed TrainingCycles Section
              if (completedTrainingCycles.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  completedTrainingCycles.length == 1
                      ? 'Completed $cycleTerm'
                      : 'Completed $cycleTermPlural',
                ),
                const SizedBox(height: 12),
                ...completedTrainingCycles.map(
                  (trainingCycle) =>
                      _buildTrainingCycleCard(context, trainingCycle),
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
              Text('Error loading trainingCycles: $error'),
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
  bool _hasExercisesForAllDays(TrainingCycle trainingCycle) {
    final workouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    // Check EVERY week in the trainingCycle
    for (int week = 1; week <= trainingCycle.weeksTotal; week++) {
      final weekWorkouts = workouts.where((w) => w.weekNumber == week).toList();

      // Check EVERY day in this week
      for (int day = 1; day <= trainingCycle.daysPerWeek; day++) {
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

  Widget _buildTrainingCycleCard(
    BuildContext context,
    TrainingCycle trainingCycle, {
    bool isDraft = false,
    bool isCurrent = false,
  }) {
    // Check if trainingCycle is ready to be saved as template
    final canSaveAsTemplate = _hasExercisesForAllDays(trainingCycle);

    // Determine if this is a completed trainingCycle (for read-only navigation)
    final isCompleted = trainingCycle.status == TrainingCycleStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isCompleted) {
            // Navigate to read-only view for completed trainingCycles
            context.push('/trainingCycles/${trainingCycle.id}/view');
          } else if (isCurrent) {
            // Switch to workout tab (same as tapping Workout in bottomNav)
            ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.workout);
          } else {
            // Navigate to editable workout screen for draft trainingCycles
            context.push('/trainingCycles/${trainingCycle.id}/workouts');
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
                      trainingCycle.name,
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
                      else if (trainingCycle.status ==
                              TrainingCycleStatus.completed &&
                          trainingCycle.endDate != null)
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
                                _formatDate(trainingCycle.endDate!),
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
                            _handleMenuAction(value, trainingCycle),
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
                          PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined),
                                const SizedBox(width: 12),
                                Text(
                                  'Rename the ${ref.watch(trainingCycleTermProvider)}',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                const Icon(Icons.copy_outlined),
                                const SizedBox(width: 12),
                                Text(
                                  'Copy the ${ref.watch(trainingCycleTermProvider)}',
                                ),
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
                          // Export option (Debug mode only)
                          if (kDebugMode)
                            const PopupMenuItem(
                              value: 'export',
                              child: Row(
                                children: [
                                  Icon(Icons.save_alt),
                                  SizedBox(width: 12),
                                  Text('Export (Debug)'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete ${ref.watch(trainingCycleTermProvider)}',
                                  style: const TextStyle(color: Colors.red),
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
                    '${trainingCycle.weeksTotal} weeks',
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
                    '${trainingCycle.daysPerWeek} days/week',
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
            'No TrainingCycles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first trainingCycle to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/plan-trainingCycle'),
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

  Future<void> _handleMenuAction(
    String action,
    TrainingCycle trainingCycle,
  ) async {
    switch (action) {
      case 'note':
        await _writeTrainingCycleNote(trainingCycle);
        break;
      case 'rename':
        await _showRenameTrainingCycleModal(trainingCycle);
        break;
      case 'copy':
        // TODO: Implement copy functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copy trainingCycle - Coming soon')),
        );
        break;
      case 'summary':
        await showDialog(
          context: context,
          builder: (context) =>
              CycleSummaryDialog(trainingCycle: trainingCycle),
        );
        break;
      case 'template':
        await _saveAsTemplate(trainingCycle);
        break;
      case 'export':
        await _exportTemplate(trainingCycle);
        break;
      case 'delete':
        await _deleteTrainingCycle(trainingCycle);
        break;
    }
  }

  Future<void> _writeTrainingCycleNote(TrainingCycle trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentNote = trainingCycle.notes;

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: currentNote,
        noteType: NoteType.trainingCycle,
        customTitle: '$cycleTerm Note',
        customHint: 'Enter note for this $cycleTerm...',
      ),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(
          notes: newNote.isEmpty ? null : newNote,
        );
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note saved'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveAsTemplate(TrainingCycle trainingCycle) async {
    final result = await showDialog<({String name, String description})>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _SaveTemplateDialog(initialName: trainingCycle.name),
    );

    if (result != null && mounted) {
      try {
        // Load the full trainingCycle with workouts
        final workouts = ref.read(
          workoutsByTrainingCycleProvider(trainingCycle.id),
        );
        final fullTrainingCycle = trainingCycle.copyWith(workouts: workouts);

        final repository = ref.read(templateRepositoryProvider);
        await repository.saveAsTemplate(
          fullTrainingCycle,
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

  /// Export trainingCycle as JSON template to clipboard (Debug mode only)
  Future<void> _exportTemplate(TrainingCycle trainingCycle) async {
    try {
      // Load the full trainingCycle with workouts
      final workouts = ref.read(
        workoutsByTrainingCycleProvider(trainingCycle.id),
      );
      final trainingCycleToExport = trainingCycle.copyWith(workouts: workouts);
      await TemplateExporter.exportToClipboard(trainingCycleToExport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template JSON copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRenameTrainingCycleModal(
    TrainingCycle trainingCycle,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _RenameTrainingCycleDialog(initialName: trainingCycle.name),
    );

    if (newName != null && newName != trainingCycle.name && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(name: newName);
        await repository.update(updatedTrainingCycle);

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
              content: Text('Error renaming trainingCycle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTrainingCycle(TrainingCycle trainingCycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft TrainingCycle'),
        content: Text(
          'Are you sure you want to delete "${trainingCycle.name}"? This action cannot be undone.',
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
        final repository = ref.read(trainingCycleRepositoryProvider);
        await repository.delete(trainingCycle.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${trainingCycle.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting trainingCycle: $e'),
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

// Stateful dialog widget for renaming trainingCycle
class _RenameTrainingCycleDialog extends StatefulWidget {
  final String initialName;

  const _RenameTrainingCycleDialog({required this.initialName});

  @override
  State<_RenameTrainingCycleDialog> createState() =>
      _RenameTrainingCycleDialogState();
}

class _RenameTrainingCycleDialogState
    extends State<_RenameTrainingCycleDialog> {
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
                hintText: 'TrainingCycle name',
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
  String? nameError;
  String? descriptionError;

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

  void _validateAndSave() {
    setState(() {
      nameError = null;
      descriptionError = null;
    });

    final trimmedName = nameController.text.trim();
    final trimmedDescription = descriptionController.text.trim();

    bool isValid = true;

    if (trimmedName.isEmpty) {
      setState(() {
        nameError = 'Please enter a template name';
      });
      isValid = false;
    }

    if (trimmedDescription.isEmpty) {
      setState(() {
        descriptionError = 'Please enter a description';
      });
      isValid = false;
    }

    if (isValid) {
      Navigator.of(
        context,
      ).pop((name: trimmedName, description: trimmedDescription));
    }
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
                errorText: nameError,
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
                errorText: descriptionError,
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
                    onPressed: _validateAndSave,
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
