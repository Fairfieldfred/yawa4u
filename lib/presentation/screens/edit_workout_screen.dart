import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/template_exporter.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
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

  final List<String> _dayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

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
              _buildDaySelector(mesocycle, workouts),

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

  Widget _buildDaySelector(Mesocycle mesocycle, List<Workout> workouts) {
    // Build day labels from workouts or use default names
    final dayLabels = <String>[];
    for (int dayNum = 1; dayNum <= mesocycle.daysPerWeek; dayNum++) {
      // Find a workout for this day to get the custom label
      final workoutForDay = workouts.cast<Workout?>().firstWhere(
        (w) => w!.dayNumber == dayNum,
        orElse: () => null,
      );
      if (workoutForDay != null && workoutForDay.dayName != null) {
        dayLabels.add(workoutForDay.dayName!);
      } else {
        // Fall back to default day names
        dayLabels.add(_dayNames[dayNum - 1]);
      }
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    List<Workout> dayWorkouts,
    EditWorkoutController controller,
  ) {
    if (dayWorkouts.isEmpty) {
      return _buildEmptyState(context, null, controller);
    }

    // Group workouts by category based on their muscle group label
    final upperPush = <MuscleGroup>[
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ];
    final upperPull = <MuscleGroup>[MuscleGroup.back, MuscleGroup.biceps];
    final legs = <MuscleGroup>[
      MuscleGroup.quads,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.calves,
    ];
    final coreAndAccessories = <MuscleGroup>[
      MuscleGroup.traps,
      MuscleGroup.forearms,
      MuscleGroup.abs,
    ];

    // Separate workouts by category
    final upperPushWorkouts = <Workout>[];
    final upperPullWorkouts = <Workout>[];
    final legsWorkouts = <Workout>[];
    final coreAndAccessoriesWorkouts = <Workout>[];
    final otherWorkouts = <Workout>[];

    for (final workout in dayWorkouts) {
      final muscleGroup = MuscleGroup.values.firstWhere(
        (mg) => mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
        orElse: () => MuscleGroup.chest,
      );

      if (upperPush.contains(muscleGroup)) {
        upperPushWorkouts.add(workout);
      } else if (upperPull.contains(muscleGroup)) {
        upperPullWorkouts.add(workout);
      } else if (legs.contains(muscleGroup)) {
        legsWorkouts.add(workout);
      } else if (coreAndAccessories.contains(muscleGroup)) {
        coreAndAccessoriesWorkouts.add(workout);
      } else {
        otherWorkouts.add(workout);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Upper push section
        if (upperPushWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Upper push'),
          ...upperPushWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) =>
                  mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.chest,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
              controller,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Upper pull section
        if (upperPullWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Upper pull'),
          ...upperPullWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) =>
                  mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.back,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
              controller,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Legs section
        if (legsWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Legs'),
          ...legsWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) =>
                  mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.quads,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
              controller,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Core & Accessories section
        if (coreAndAccessoriesWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Core & Accessories'),
          ...coreAndAccessoriesWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) =>
                  mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.abs,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
              controller,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Other workouts (if any)
        if (otherWorkouts.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...otherWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) =>
                  mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.chest,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
              controller,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        category,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMuscleGroupSection(
    MuscleGroup muscleGroup,
    List<Exercise> exercises,
    String workoutId,
    EditWorkoutController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle group header
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getMuscleGroupColor(muscleGroup),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  muscleGroup.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () =>
                      _deleteMuscleGroup(context, controller, workoutId),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete muscle group',
                ),
              ],
            ),
          ),

          // Exercise list or "Choose an exercise" placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Column(
              children: [
                if (exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigate to exercise selection for this muscle group
                        GoRouter.of(context).push(
                          '/mesocycles/${widget.mesocycleId}/workouts/$workoutId/choose-exercise?muscleGroup=${muscleGroup.name}',
                        );
                      },
                      child: Center(
                        child: Text(
                          'Choose an exercise',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ),
                    ),
                  )
                else
                  ...exercises.map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Navigate back to add_exercise screen with muscle group pre-filtered
                                GoRouter.of(context).push(
                                  '/mesocycles/${widget.mesocycleId}/workouts/$workoutId/choose-exercise?muscleGroup=${muscleGroup.name}',
                                );
                              },
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                minimumSize: const Size(0, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Set counter with +/- buttons
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16),
                                  onPressed: exercise.sets.length > 1
                                      ? () => _removeSet(
                                          controller,
                                          workoutId,
                                          exercise,
                                        )
                                      : null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  tooltip: 'Remove set',
                                ),
                                Container(
                                  width: 24,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${exercise.sets.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16),
                                  onPressed: () =>
                                      _addSet(controller, workoutId, exercise),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  tooltip: 'Add set',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSet(
    EditWorkoutController controller,
    String workoutId,
    Exercise exercise,
  ) async {
    final newSetNumber = exercise.sets.length + 1;
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: newSetNumber,
      reps: '', // Default empty to show hint
      setType: SetType.regular,
    );

    await controller.addSetToExercise(workoutId, exercise.id, newSet);
  }

  Future<void> _removeSet(
    EditWorkoutController controller,
    String workoutId,
    Exercise exercise,
  ) async {
    if (exercise.sets.isEmpty) return;

    // Remove the last set
    await controller.removeSetFromExercise(
      workoutId,
      exercise.id,
      exercise.sets.length - 1,
    );
  }

  Color _getMuscleGroupColor(MuscleGroup muscleGroup) {
    final colors = Theme.of(context).extension<MuscleGroupColors>();
    if (colors == null) return Colors.teal;

    // Upper push = pink/magenta
    if ([
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ].contains(muscleGroup)) {
      return colors.upperPush ?? Colors.pink;
    }
    // Upper pull = blue/cyan
    if ([MuscleGroup.back, MuscleGroup.biceps].contains(muscleGroup)) {
      return colors.upperPull ?? Colors.cyan;
    }
    // Core & Accessories = purple
    if ([
      MuscleGroup.traps,
      MuscleGroup.forearms,
      MuscleGroup.abs,
    ].contains(muscleGroup)) {
      return colors.coreAndAccessories ?? Colors.purple;
    }
    // Legs = green/teal
    return colors.legs ?? Colors.teal;
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

  Future<void> _deleteMuscleGroup(
    BuildContext context,
    EditWorkoutController controller,
    String workoutId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Muscle Group'),
        content: const Text(
          'Are you sure you want to delete this muscle group and all its exercises?',
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

    if (confirmed == true && context.mounted) {
      try {
        await controller.deleteMuscleGroup(workoutId);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Muscle group deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting muscle group: $e'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MuscleGroupSelectorModal(
        mesocycleId: mesocycle.id,
        dayNumber: _selectedDayIndex + 1,
        onMuscleGroupsSelected: (muscleGroups) {
          controller.createWorkoutsForMuscleGroups(
            muscleGroups: muscleGroups,
            weekNumber: _selectedWeek,
            dayNumber: _selectedDayIndex + 1,
          );
          GoRouter.of(context).pop();
        },
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

/// Modal for selecting muscle groups
class _MuscleGroupSelectorModal extends StatefulWidget {
  final String mesocycleId;
  final int dayNumber;
  final Function(List<MuscleGroup>) onMuscleGroupsSelected;

  const _MuscleGroupSelectorModal({
    required this.mesocycleId,
    required this.dayNumber,
    required this.onMuscleGroupsSelected,
  });

  @override
  State<_MuscleGroupSelectorModal> createState() =>
      __MuscleGroupSelectorModalState();
}

class __MuscleGroupSelectorModalState extends State<_MuscleGroupSelectorModal> {
  final Set<MuscleGroup> _selectedMuscleGroups = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                Text(
                  'Select Muscle Groups',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _selectedMuscleGroups.isEmpty
                      ? null
                      : () => widget.onMuscleGroupsSelected(
                          _selectedMuscleGroups.toList(),
                        ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: MuscleGroup.values.length,
              itemBuilder: (context, index) {
                final muscleGroup = MuscleGroup.values[index];
                final isSelected = _selectedMuscleGroups.contains(muscleGroup);

                return ListTile(
                  title: Text(muscleGroup.displayName),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedMuscleGroups.remove(muscleGroup);
                      } else {
                        _selectedMuscleGroups.add(muscleGroup);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
