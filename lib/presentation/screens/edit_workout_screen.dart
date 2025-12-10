import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/utils/template_exporter.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/dialogs/exercise_info_dialog.dart';
import 'add_exercise_screen.dart';
import 'workout/edit_workout_controller.dart';

/// Edit workout screen - Edit draft mesocycle design
class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String mesocycleId;

  const EditWorkoutScreen({super.key, required this.mesocycleId});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  int _selectedDayIndex = 0;
  int _selectedWeek = 1;

  @override
  Widget build(BuildContext context) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);
    final controller = ref.watch(
      editWorkoutControllerProvider(widget.mesocycleId),
    );

    return mesocyclesAsync.when(
      data: (mesocycles) {
        final mesocycle = mesocycles.firstWhere(
          (m) => m.id == widget.mesocycleId,
          orElse: () => mesocycles.first,
        );

        final workouts = ref.watch(
          workoutsByMesocycleProvider(widget.mesocycleId),
        );

        // Get workouts for the selected week and day
        final dayWorkouts = workouts
            .where(
              (w) =>
                  w.weekNumber == _selectedWeek &&
                  w.dayNumber == _selectedDayIndex + 1,
            )
            .toList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            title: Text(mesocycle.name),
            actions: [
              // Export template button (Debug only)
              if (kDebugMode)
                IconButton(
                  icon: const Icon(Icons.save_alt),
                  onPressed: () =>
                      _exportTemplate(context, mesocycle, workouts),
                  tooltip: 'Export Template (Debug)',
                ),
              // Start mesocycle button (if draft)
              if (mesocycle.status == MesocycleStatus.draft)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () =>
                      _startMesocycle(context, controller, mesocycle),
                  tooltip: 'Start mesocycle',
                ),
            ],
          ),
          body: Column(
            children: [
              // Week selector
              _buildWeekSelector(mesocycle, controller),

              // Day selector
              _buildDaySelector(mesocycle, workouts, controller),

              // Exercise list
              Expanded(
                child: dayWorkouts.isEmpty
                    ? _buildEmptyState(context, mesocycle, controller)
                    : _buildExerciseList(context, dayWorkouts, controller),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _showMuscleGroupSelector(context, mesocycle, controller),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: const Text('Add Exercise'),
            icon: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildWeekSelector(
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) {
    final allWorkouts = ref.watch(
      workoutsByMesocycleProvider(widget.mesocycleId),
    );
    final week1HasWorkouts = allWorkouts.any((w) => w.weekNumber == 1);

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
            'Week',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          // Remove week button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: mesocycle.weeksTotal > 2
                ? () => _showRemoveWeekDialog(mesocycle, controller)
                : null,
            tooltip: 'Remove Week',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add week button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => _addWeek(mesocycle, controller),
            tooltip: 'Add Week',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(mesocycle.weeksTotal, (index) {
                  final weekNumber = index + 1;
                  final isSelected = weekNumber == _selectedWeek;
                  final isDeloadWeek = weekNumber == mesocycle.weeksTotal;

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(
                        isDeloadWeek ? 'DL' : '$weekNumber',
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
                          setState(() => _selectedWeek = weekNumber);
                        }
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Mirror week 1 button (only show when not on week 1 and week 1 has workouts)
          if (_selectedWeek > 1 && week1HasWorkouts)
            IconButton(
              icon: const Icon(Icons.content_copy, size: 20),
              onPressed: () =>
                  _mirrorWeek1ToSelectedWeek(mesocycle, controller),
              tooltip: 'Mirror Week 1',
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

  Future<void> _addWeek(
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) async {
    try {
      await controller.addWeek(mesocycle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Week ${mesocycle.weeksTotal} added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding week: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRemoveWeekDialog(
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) async {
    final lastNonDeloadWeek = mesocycle.weeksTotal - 1;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Week'),
        content: Text(
          'Which week would you like to remove?\n\n'
          '• Week $lastNonDeloadWeek (last training week)\n'
          '• Deload week',
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove Week $lastNonDeloadWeek'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final removeDeload = result == 'deload';
        await controller.removeWeek(mesocycle, removeDeload: removeDeload);

        // Adjust selected week if it no longer exists
        if (_selectedWeek > mesocycle.weeksTotal - 1) {
          setState(() => _selectedWeek = mesocycle.weeksTotal - 1);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removeDeload
                    ? 'Deload week removed'
                    : 'Week $lastNonDeloadWeek removed',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing week: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildDaySelector(
    Mesocycle mesocycle,
    List<Workout> workouts,
    EditWorkoutController controller,
  ) {
    // Build day labels as D1, D2, D3, etc.
    final dayLabels = <String>[];
    for (int dayNum = 1; dayNum <= mesocycle.daysPerWeek; dayNum++) {
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
            onPressed: mesocycle.daysPerWeek > 1
                ? () => _removeDay(mesocycle, controller)
                : null,
            tooltip: 'Remove Day',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add day button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: mesocycle.daysPerWeek < 7
                ? () => _addDay(mesocycle, controller)
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
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) async {
    try {
      await controller.addDay(mesocycle);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day ${mesocycle.daysPerWeek + 1} added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding day: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeDay(
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) async {
    final dayToRemove = mesocycle.daysPerWeek;

    // Check if there are any workouts on this day
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));
    final hasWorkoutsOnDay = allWorkouts.any((w) => w.dayNumber == dayToRemove);

    if (hasWorkoutsOnDay) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Day'),
          content: Text(
            'Day $dayToRemove has exercises assigned. '
            'Removing it will delete all exercises on this day across all weeks.\n\n'
            'Are you sure you want to remove Day $dayToRemove?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await controller.removeDay(mesocycle);

      // Adjust selected day if it no longer exists
      if (_selectedDayIndex >= mesocycle.daysPerWeek - 1) {
        setState(() => _selectedDayIndex = mesocycle.daysPerWeek - 2);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Day $dayToRemove removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing day: $e'),
            backgroundColor: Colors.red,
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
                        const PopupMenuItem<String>(
                          value: 'delete',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Delete exercise',
                                style: TextStyle(color: Colors.red),
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
                              const PopupMenuItem<String>(
                                value: 'delete',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Delete set',
                                      style: TextStyle(color: Colors.red),
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
                                          ? Colors.red
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
                                          ? Colors.red
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
                                          ? Colors.red
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
                                          ? Colors.red
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
                                          ? Colors.red
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
                                  borderRadius: BorderRadius.circular(4),
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
                                      hintText: 'reps',
                                      hintStyle: Theme.of(
                                        context,
                                      ).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
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
          Positioned(
            top: -20,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: muscleGroup.color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    muscleGroup.displayName.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade700
                          : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          mesocycleId: widget.mesocycleId,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
    Mesocycle? mesocycle,
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
          Text('No Workouts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'This mesocycle has no workouts yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (mesocycle != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  _showMuscleGroupSelector(context, mesocycle, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add First Workout'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _mirrorWeek1ToSelectedWeek(
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mirror Week 1'),
        content: Text(
          'Copy all workouts from Week 1 to Week $_selectedWeek? This will replace any existing workouts for Week $_selectedWeek.',
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
        await controller.mirrorWeek1ToSelectedWeek(mesocycle, _selectedWeek);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Week 1 mirrored to Week $_selectedWeek'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error mirroring week: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _startMesocycle(
    BuildContext context,
    EditWorkoutController controller,
    Mesocycle mesocycle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Mesocycle'),
        content: Text(
          'Start "${mesocycle.name}"? This will set it as your current mesocycle.',
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
        await controller.startMesocycle(mesocycle);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mesocycle started!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showMuscleGroupSelector(
    BuildContext context,
    Mesocycle mesocycle,
    EditWorkoutController controller,
  ) {
    // Get workouts for the current day
    final workouts = ref.read(workoutsByMesocycleProvider(widget.mesocycleId));
    final dayWorkouts = workouts
        .where(
          (w) =>
              w.weekNumber == _selectedWeek &&
              w.dayNumber == _selectedDayIndex + 1,
        )
        .toList();

    // Create a map of existing muscle groups to their workouts
    final muscleGroupWorkouts = <MuscleGroup, Workout>{};
    for (final workout in dayWorkouts) {
      if (workout.exercises.isNotEmpty) {
        final muscleGroup = workout.exercises.first.muscleGroup;
        if (!muscleGroupWorkouts.containsKey(muscleGroup)) {
          muscleGroupWorkouts[muscleGroup] = workout;
        }
      }
    }

    // Show all muscle groups
    final allMuscleGroups = MuscleGroup.values.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Muscle Group',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allMuscleGroups.length,
                  itemBuilder: (listContext, index) {
                    final muscleGroup = allMuscleGroups[index];
                    final existingWorkout = muscleGroupWorkouts[muscleGroup];

                    return ListTile(
                      title: Text(muscleGroup.displayName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        Navigator.pop(sheetContext);

                        // If workout exists for this muscle group, use it
                        if (existingWorkout != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddExerciseScreen(
                                mesocycleId: existingWorkout.mesocycleId,
                                workoutId: existingWorkout.id,
                                initialMuscleGroup: muscleGroup,
                              ),
                            ),
                          );
                        } else {
                          // Create a new workout for this muscle group
                          final newWorkout = Workout(
                            id: const Uuid().v4(),
                            mesocycleId: mesocycle.id,
                            weekNumber: _selectedWeek,
                            dayNumber: _selectedDayIndex + 1,
                            label: muscleGroup.displayName,
                            exercises: [],
                          );

                          // Save the new workout directly to repository
                          await ref
                              .read(workoutRepositoryProvider)
                              .create(newWorkout);

                          // Navigate to add exercise screen
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddExerciseScreen(
                                  mesocycleId: newWorkout.mesocycleId,
                                  workoutId: newWorkout.id,
                                  initialMuscleGroup: muscleGroup,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportTemplate(
    BuildContext context,
    Mesocycle mesocycle,
    List<Workout> workouts,
  ) async {
    try {
      // Create a copy of the mesocycle with the latest workouts
      final mesocycleToExport = mesocycle.copyWith(workouts: workouts);
      await TemplateExporter.exportToClipboard(mesocycleToExport);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template JSON copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
