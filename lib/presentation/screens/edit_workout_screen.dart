import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/theme/skins/skins.dart';
import '../../core/utils/template_exporter.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/dialogs/add_exercise_dialog.dart';
import '../widgets/dialogs/exercise_info_dialog.dart';
import '../widgets/dialogs/workout_dialogs.dart';
import '../widgets/muscle_group_badge.dart';
import 'add_exercise_screen.dart';
import 'workout/edit_workout_controller.dart';

/// Edit workout screen - Edit draft trainingCycle design
class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String trainingCycleId;

  const EditWorkoutScreen({super.key, required this.trainingCycleId});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  int _selectedDayIndex = 0;
  int _selectedPeriod = 1;

  @override
  Widget build(BuildContext context) {
    final trainingCyclesAsync = ref.watch(trainingCyclesProvider);
    final controller = ref.watch(
      editWorkoutControllerProvider(widget.trainingCycleId),
    );

    return trainingCyclesAsync.when(
      data: (trainingCycles) {
        final trainingCycle = trainingCycles.firstWhere(
          (m) => m.id == widget.trainingCycleId,
          orElse: () => trainingCycles.first,
        );

        final workouts = ref.watch(
          workoutsByTrainingCycleProvider(widget.trainingCycleId),
        );

        // Get workouts for the selected period and day
        final dayWorkouts = workouts
            .where(
              (w) =>
                  w.periodNumber == _selectedPeriod &&
                  w.dayNumber == _selectedDayIndex + 1,
            )
            .toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
              title: Text(trainingCycle.name),
              actions: [
                // Export template button (Debug only)
                if (kDebugMode)
                  IconButton(
                    icon: const Icon(Icons.save_alt),
                    onPressed: () =>
                        _exportTemplate(context, trainingCycle, workouts),
                    tooltip: 'Export Template (Debug)',
                  ),
                // Start trainingCycle button (if draft)
                if (trainingCycle.status == TrainingCycleStatus.draft)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _startTrainingCycle(
                        context,
                        controller,
                        trainingCycle,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: context.successColor,
                              size: 24,
                            ),
                            Text(
                              'Start',
                              style: TextStyle(
                                color: context.successColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Period selector
                _buildPeriodSelector(trainingCycle, controller),

                // Day selector
                _buildDaySelector(trainingCycle, workouts, controller),

                // Exercise list
                Expanded(
                  child: dayWorkouts.isEmpty
                      ? _buildEmptyState(context, trainingCycle, controller)
                      : _buildExerciseList(context, dayWorkouts, controller),
                ),
              ],
            ),
            floatingActionButton: dayWorkouts.isEmpty
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _showMuscleGroupSelector(
                      context,
                      trainingCycle,
                      controller,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    label: const Text('Add Exercise'),
                    icon: const Icon(Icons.add),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildPeriodSelector(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) {
    final allWorkouts = ref.watch(
      workoutsByTrainingCycleProvider(widget.trainingCycleId),
    );
    final period1HasWorkouts = allWorkouts.any((w) => w.periodNumber == 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Period',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          // Remove period button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: trainingCycle.periodsTotal > 2
                ? () => _showRemovePeriodDialog(trainingCycle, controller)
                : null,
            tooltip: 'Remove Period',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add period button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => _addPeriod(trainingCycle, controller),
            tooltip: 'Add Period',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(trainingCycle.periodsTotal, (index) {
                  final periodNumber = index + 1;
                  final isSelected = periodNumber == _selectedPeriod;
                  final isRecoveryPeriod =
                      periodNumber == trainingCycle.recoveryPeriod;

                  final chip = ChoiceChip(
                    label: Text(
                      isRecoveryPeriod
                          ? trainingCycle.recoveryPeriodType.abbreviation
                          : '$periodNumber',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPeriod = periodNumber);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: isRecoveryPeriod
                        ? GestureDetector(
                            onLongPress: () => _showRecoveryTypeSelector(
                              trainingCycle,
                              controller,
                            ),
                            child: chip,
                          )
                        : chip,
                  );
                }),
              ),
            ),
          ),
          // Mirror period 1 button (only show when not on period 1 and period 1 has workouts)
          if (_selectedPeriod > 1 && period1HasWorkouts)
            IconButton(
              icon: const Icon(Icons.content_copy, size: 20),
              onPressed: () =>
                  _mirrorPeriod1ToSelectedPeriod(trainingCycle, controller),
              tooltip: 'Mirror Period 1',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addPeriod(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    try {
      await controller.addPeriod(trainingCycle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Period ${trainingCycle.periodsTotal} added'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding period: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _showRemovePeriodDialog(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final lastNonRecoveryPeriod = trainingCycle.periodsTotal - 1;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Period'),
        content: Text(
          'Which period would you like to remove?\n\n'
          '• Period $lastNonRecoveryPeriod (last training period)\n'
          '• Recovery period',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'deload'),
            child: const Text('Remove Deload'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'training'),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text('Remove Period $lastNonRecoveryPeriod'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final removeRecovery = result == 'deload';
        await controller.removePeriod(
          trainingCycle,
          removeRecovery: removeRecovery,
        );

        // Adjust selected period if it no longer exists
        if (_selectedPeriod > trainingCycle.periodsTotal - 1) {
          setState(() => _selectedPeriod = trainingCycle.periodsTotal - 1);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removeRecovery
                    ? 'Recovery period removed'
                    : 'Period $lastNonRecoveryPeriod removed',
              ),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing period: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _showRecoveryTypeSelector(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final result = await showDialog<RecoveryPeriodType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recovery Period Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecoveryPeriodType.values.map((type) {
            final isSelected = type == trainingCycle.recoveryPeriodType;
            return ListTile(
              title: Text(type.displayName),
              subtitle: Text(type.description),
              leading: Radio<RecoveryPeriodType>(
                value: type,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (type == trainingCycle.recoveryPeriodType) {
                    return Theme.of(context).colorScheme.primary;
                  }
                  return null;
                }),
              ),
              trailing: Text(
                type.abbreviation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              onTap: () => Navigator.pop(context, type),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null &&
        result != trainingCycle.recoveryPeriodType &&
        mounted) {
      try {
        await controller.updateRecoveryPeriodType(trainingCycle, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recovery period changed to ${result.displayName}'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating recovery type: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Widget _buildDaySelector(
    TrainingCycle trainingCycle,
    List<Workout> workouts,
    EditWorkoutController controller,
  ) {
    // Build day labels as D1, D2, D3, etc.
    final dayLabels = <String>[];
    for (int dayNum = 1; dayNum <= trainingCycle.daysPerPeriod; dayNum++) {
      dayLabels.add('D$dayNum');
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            'Day',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          // Remove day button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: trainingCycle.daysPerPeriod > 1
                ? () => _removeDay(trainingCycle, controller)
                : null,
            tooltip: 'Remove Day',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add day button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed:
                trainingCycle.daysPerPeriod < AppConstants.maxDaysPerPeriod
                ? () => _addDay(trainingCycle, controller)
                : null,
            tooltip: 'Add Day',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dayLabels.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      dayLabels[index],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDayIndex = index);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDay(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    try {
      await controller.addDay(trainingCycle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${trainingCycle.daysPerPeriod + 1} added'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding day: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _removeDay(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final dayToRemove = trainingCycle.daysPerPeriod;

    // Check if there are any workouts on this day
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );
    final hasWorkoutsOnDay = allWorkouts.any((w) => w.dayNumber == dayToRemove);

    if (hasWorkoutsOnDay) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Day'),
          content: Text(
            'Day $dayToRemove has exercises assigned. '
            'Removing it will delete all exercises on this day across all periods.\n\n'
            'Are you sure you want to remove Day $dayToRemove?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: context.errorColor,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await controller.removeDay(trainingCycle);

      // Adjust selected day if it no longer exists
      if (_selectedDayIndex >= trainingCycle.daysPerPeriod - 1) {
        setState(() => _selectedDayIndex = trainingCycle.daysPerPeriod - 2);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day $dayToRemove removed'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing day: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildExerciseList(
    BuildContext context,
    List<Workout> dayWorkouts,
    EditWorkoutController controller,
  ) {
    if (dayWorkouts.isEmpty) {
      return _buildEmptyState(context, null, controller);
    }

    // Collect all exercises from all workouts for this day
    final allExercises = <Exercise>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }

    if (allExercises.isEmpty) {
      return _buildEmptyState(context, null, controller);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 24),
      itemCount: allExercises.length,
      separatorBuilder: (context, index) {
        // Check if next exercise is same muscle group
        final currentMuscleGroup = allExercises[index].muscleGroup;
        final nextMuscleGroup = index + 1 < allExercises.length
            ? allExercises[index + 1].muscleGroup
            : null;
        final isSameMuscleGroup = currentMuscleGroup == nextMuscleGroup;

        // Thin grey divider for same muscle group, black spacer for different
        return isSameMuscleGroup
            ? Container(height: 1, color: const Color(0xFF3A3A3C))
            : const SizedBox(height: 32);
      },
      itemBuilder: (context, index) {
        final exercise = allExercises[index];
        final showMuscleGroupBadge =
            index == 0 ||
            allExercises[index - 1].muscleGroup != exercise.muscleGroup;

        return _buildExerciseCard(
          context,
          exercise,
          controller,
          showMuscleGroupBadge: showMuscleGroupBadge,
        );
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    EditWorkoutController controller, {
    required bool showMuscleGroupBadge,
  }) {
    final muscleGroup = exercise.muscleGroup;
    final equipmentType = exercise.equipmentType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Exercise card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipmentType.displayName.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Info button
                    IconButton(
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8E8E93),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () =>
                          showExerciseInfoDialog(context, exercise),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 0),
                    // Overflow menu button
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        size: 24,
                      ),
                      offset: const Offset(-180, 40),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 250),
                      color: const Color(0xFF2C2C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'note':
                            _newExerciseNote(exercise);
                            break;
                          case 'replace':
                            _replaceExercise(exercise);
                            break;
                          case 'add_set':
                            _addSetToExercise(exercise, controller);
                            break;
                          case 'delete':
                            _deleteExercise(exercise, controller);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        // Header
                        const PopupMenuItem<String>(
                          enabled: false,
                          height: 32,
                          child: Text(
                            'EXERCISE',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // New note
                        const PopupMenuItem<String>(
                          value: 'note',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'New note',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Replace
                        const PopupMenuItem<String>(
                          value: 'replace',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Replace',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Add set
                        const PopupMenuItem<String>(
                          value: 'add_set',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Add set',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Delete exercise
                        PopupMenuItem<String>(
                          value: 'delete',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: context.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete exercise',
                                style: TextStyle(color: context.errorColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Column headers
                if (exercise.sets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 24), // Spacer for set menu
                        Expanded(
                          child: Text(
                            'SET',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'REPS',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(width: 40), // Spacer for actions
                      ],
                    ),
                  ),

                // Sets list
                ...List.generate(exercise.sets.length, (index) {
                  final set = exercise.sets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Set menu (3 dots)
                        SizedBox(
                          width: 24,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            offset: const Offset(0, 40),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 250),
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'add_below':
                                  _addSetBelow(exercise, index, controller);
                                  break;
                                case 'delete':
                                  _deleteSet(exercise, index, controller);
                                  break;
                                case 'regular':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.regular,
                                    controller,
                                  );
                                  break;
                                case 'myorep':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.myorep,
                                    controller,
                                  );
                                  break;
                                case 'myorep_match':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.myorepMatch,
                                    controller,
                                  );
                                  break;
                                case 'max_reps':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.maxReps,
                                    controller,
                                  );
                                  break;
                                case 'end_with_partials':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.endWithPartials,
                                    controller,
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              // SET Header
                              const PopupMenuItem<String>(
                                enabled: false,
                                height: 32,
                                child: Text(
                                  'SET',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Add set below
                              PopupMenuItem<String>(
                                value: 'add_below',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Add set below',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Delete set
                              PopupMenuItem<String>(
                                value: 'delete',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: context.errorColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Delete set',
                                      style: TextStyle(
                                        color: context.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              // SET TYPE Header
                              const PopupMenuItem<String>(
                                enabled: false,
                                height: 32,
                                child: Text(
                                  'SET TYPE',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Regular
                              PopupMenuItem<String>(
                                value: 'regular',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      set.setType == SetType.regular
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: set.setType == SetType.regular
                                          ? context.selectedIndicatorColor
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Regular',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Myorep
                              PopupMenuItem<String>(
                                value: 'myorep',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      set.setType == SetType.myorep
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: set.setType == SetType.myorep
                                          ? context.selectedIndicatorColor
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Myorep',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Myorep match
                              PopupMenuItem<String>(
                                value: 'myorep_match',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      set.setType == SetType.myorepMatch
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: set.setType == SetType.myorepMatch
                                          ? context.selectedIndicatorColor
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Myorep match',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Max reps
                              PopupMenuItem<String>(
                                value: 'max_reps',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      set.setType == SetType.maxReps
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: set.setType == SetType.maxReps
                                          ? context.selectedIndicatorColor
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Max reps',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // End with partials
                              PopupMenuItem<String>(
                                value: 'end_with_partials',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      set.setType == SetType.endWithPartials
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color:
                                          set.setType == SetType.endWithPartials
                                          ? context.selectedIndicatorColor
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'End with partials',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Set number display
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${set.setNumber}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Reps Input
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor,
                                  borderRadius: BorderRadius.circular(
                                    context.inputBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    key: ValueKey('reps_${set.id}'),
                                    initialValue: set.reps,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      filled: false,
                                      hintText: 'reps',
                                      hintStyle: Theme.of(
                                        context,
                                      ).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _updateSetReps(
                                        exercise,
                                        index,
                                        value,
                                        controller,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Badge for non-regular set types
                              if (_getSetTypeBadge(set.setType) != null)
                                Positioned(
                                  top: 2,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      _getSetTypeBadge(set.setType)!,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Placeholder for alignment (no LOG checkbox in edit mode)
                        const SizedBox(width: 40),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Muscle group badge - overlays the card
        if (showMuscleGroupBadge)
          MuscleGroupBadge.compact(muscleGroup: muscleGroup),
      ],
    );
  }

  String? _getSetTypeBadge(SetType setType) {
    switch (setType) {
      case SetType.myorep:
        return 'MYO';
      case SetType.myorepMatch:
        return 'M-M';
      case SetType.maxReps:
        return 'MAX';
      case SetType.endWithPartials:
        return 'EWP';
      default:
        return null;
    }
  }

  // Exercise action methods
  void _replaceExercise(Exercise exercise) {
    // Navigate to add exercise screen with replace mode
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          trainingCycleId: widget.trainingCycleId,
          workoutId: exercise.workoutId,
          initialMuscleGroup: exercise.muscleGroup,
          replaceExerciseId: exercise.id,
        ),
      ),
    );
  }

  Future<void> _addSetToExercise(
    Exercise exercise,
    EditWorkoutController controller,
  ) async {
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    await controller.addSetToExercise(exercise.workoutId, exercise.id, newSet);
  }

  Future<void> _deleteExercise(
    Exercise exercise,
    EditWorkoutController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteExercise(exercise.workoutId, exercise.id);
    }
  }

  // Set action methods
  Future<void> _addSetBelow(
    Exercise exercise,
    int currentSetIndex,
    EditWorkoutController controller,
  ) async {
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    await controller.insertSetAtIndex(
      exercise.workoutId,
      exercise.id,
      currentSetIndex + 1,
      newSet,
    );
  }

  Future<void> _deleteSet(
    Exercise exercise,
    int setIndex,
    EditWorkoutController controller,
  ) async {
    await controller.removeSetFromExercise(
      exercise.workoutId,
      exercise.id,
      setIndex,
    );
  }

  Future<void> _updateSetType(
    Exercise exercise,
    int setIndex,
    SetType type,
    EditWorkoutController controller,
  ) async {
    await controller.updateSetType(
      exercise.workoutId,
      exercise.id,
      setIndex,
      type,
    );
  }

  Future<void> _updateSetReps(
    Exercise exercise,
    int setIndex,
    String value,
    EditWorkoutController controller,
  ) async {
    await controller.updateSetReps(
      exercise.workoutId,
      exercise.id,
      setIndex,
      value,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    TrainingCycle? trainingCycle,
    EditWorkoutController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises scheduled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (trainingCycle != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  _showMuscleGroupSelector(context, trainingCycle, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _mirrorPeriod1ToSelectedPeriod(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mirror Period 1'),
        content: Text(
          'Copy all workouts from Period 1 to Period $_selectedPeriod? This will replace any existing workouts for Period $_selectedPeriod.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mirror'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await controller.mirrorPeriod1ToSelectedPeriod(
          trainingCycle,
          _selectedPeriod,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Period 1 mirrored to Period $_selectedPeriod'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error mirroring period: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _startTrainingCycle(
    BuildContext context,
    EditWorkoutController controller,
    TrainingCycle trainingCycle,
  ) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start $cycleTerm'),
        content: Text(
          'Start "${trainingCycle.name}"? This will set it as your current $cycleTerm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await controller.startTrainingCycle(trainingCycle);

        if (context.mounted) {
          // Navigate to workout tab on home screen
          ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.workout);
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showMuscleGroupSelector(
    BuildContext context,
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) {
    // Get workouts for the current day
    final workouts = ref.read(
      workoutsByTrainingCycleProvider(widget.trainingCycleId),
    );
    final dayWorkouts = workouts
        .where(
          (w) =>
              w.periodNumber == _selectedPeriod &&
              w.dayNumber == _selectedDayIndex + 1,
        )
        .toList();

    showAddExerciseDialog(
      context: context,
      ref: ref,
      workouts: dayWorkouts,
      trainingCycleId: trainingCycle.id,
      periodNumber: _selectedPeriod,
      dayNumber: _selectedDayIndex + 1,
    );
  }

  Future<void> _newExerciseNote(Exercise exercise) async {
    // Get the workout containing this exercise
    final workout = ref.read(workoutProvider(exercise.workoutId));
    if (workout == null) return;

    final currentNote = exercise.notes;

    final result = await showDialog<ExerciseNoteResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoteDialog(
        initialNote: currentNote,
        noteType: NoteType.exercise,
        initialPinned: exercise.isNotePinned,
      ),
    );

    if (result != null && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final updatedExercise = exercise.copyWith(
          notes: result.note.isEmpty ? null : result.note,
          isNotePinned: result.isPinned,
        );
        final updatedExercises = workout.exercises
            .map((e) => e.id == exercise.id ? updatedExercise : e)
            .toList();
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);
        await repository.update(updatedWorkout);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note saved'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportTemplate(
    BuildContext context,
    TrainingCycle trainingCycle,
    List<Workout> workouts,
  ) async {
    try {
      // Create a copy of the trainingCycle with the latest workouts
      final trainingCycleToExport = trainingCycle.copyWith(workouts: workouts);
      await TemplateExporter.exportToClipboard(trainingCycleToExport);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template JSON copied to clipboard!'),
            backgroundColor: context.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting template: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }
}
