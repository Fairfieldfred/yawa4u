import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';

/// Workout list screen - Edit draft mesocycle design
class WorkoutListScreen extends ConsumerStatefulWidget {
  final String mesocycleId;

  const WorkoutListScreen({super.key, required this.mesocycleId});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  int _selectedDayIndex = 0;

  final List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    return mesocyclesAsync.when(
      data: (mesocycles) {
        final mesocycle = mesocycles.firstWhere(
          (m) => m.id == widget.mesocycleId,
          orElse: () => mesocycles.first,
        );

        final workouts = ref.watch(
          workoutsByMesocycleProvider(widget.mesocycleId),
        );

        // Get workouts for the selected day
        final dayWorkouts =
            workouts.where((w) => w.dayNumber == _selectedDayIndex + 1).toList()
              ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            title: Text(mesocycle.name),
            actions: [Icon(Icons.chevron_right)],
          ),
          body: Column(
            children: [
              // Day selector
              _buildDaySelector(mesocycle),

              // Exercise list
              Expanded(
                child: dayWorkouts.isEmpty
                    ? _buildEmptyState(context, mesocycle)
                    : _buildExerciseList(context, dayWorkouts),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showMuscleGroupSelector(context, mesocycle),
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: const Text('Add Exercise'),
            icon: const Icon(Icons.add),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildDaySelector(Mesocycle mesocycle) {
    // Show only the number of days per week the user selected
    final availableDays = _dayNames.take(mesocycle.daysPerWeek).toList();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                availableDays[index],
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

  Widget _buildExerciseList(BuildContext context, List<Workout> dayWorkouts) {
    if (dayWorkouts.isEmpty) {
      return _buildEmptyState(context, null);
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

    // Separate workouts by category
    final upperPushWorkouts = <Workout>[];
    final upperPullWorkouts = <Workout>[];
    final legsWorkouts = <Workout>[];
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
              (mg) => mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.chest,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Upper pull section
        if (upperPullWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Upper pull'),
          ...upperPullWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) => mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.back,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
            );
          }),
          const SizedBox(height: 24),
        ],

        // Legs section
        if (legsWorkouts.isNotEmpty) ...[
          _buildCategoryHeader('Legs'),
          ...legsWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) => mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.quads,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
            );
          }),
        ],

        // Other workouts (if any)
        if (otherWorkouts.isNotEmpty) ...[
          const SizedBox(height: 24),
          ...otherWorkouts.map((workout) {
            final muscleGroup = MuscleGroup.values.firstWhere(
              (mg) => mg.displayName.toLowerCase() == workout.label?.toLowerCase(),
              orElse: () => MuscleGroup.chest,
            );
            return _buildMuscleGroupSection(
              muscleGroup,
              workout.exercises,
              workout.id,
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
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Muscle group header
          Padding(
            padding: const EdgeInsets.all(16),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () {
                    // Navigate to exercise selection for this muscle group
                    GoRouter.of(context).push(
                      '/mesocycles/${widget.mesocycleId}/workouts/$workoutId/choose-exercise?muscleGroup=${muscleGroup.name}',
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Exercise list or "Choose an exercise" placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                if (exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.only(bottom: 8),
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
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

  Color _getMuscleGroupColor(MuscleGroup muscleGroup) {
    // Upper push = pink/magenta
    if ([
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ].contains(muscleGroup)) {
      return Colors.pink;
    }
    // Upper pull = blue/cyan
    if ([MuscleGroup.back, MuscleGroup.biceps].contains(muscleGroup)) {
      return Colors.cyan;
    }
    // Legs = green/teal
    return Colors.teal;
  }

  Widget _buildEmptyState(BuildContext context, Mesocycle? mesocycle) {
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
              onPressed: () => _showMuscleGroupSelector(context, mesocycle),
              icon: const Icon(Icons.add),
              label: const Text('Add First Workout'),
            ),
          ],
        ],
      ),
    );
  }

  void _showMuscleGroupSelector(BuildContext context, Mesocycle mesocycle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MuscleGroupSelectorModal(
        mesocycleId: mesocycle.id,
        dayNumber: _selectedDayIndex + 1,
        onMuscleGroupsSelected: (muscleGroups) {
          // Create workouts for selected muscle groups
          for (final muscleGroup in muscleGroups) {
            // Create a workout for this day and muscle group
            final newWorkout = Workout(
              id: const Uuid().v4(),
              mesocycleId: mesocycle.id,
              weekNumber: 1, // Default to week 1
              dayNumber: _selectedDayIndex + 1,
              dayName: _dayNames[_selectedDayIndex],
              label: muscleGroup.displayName,
              status: WorkoutStatus.incomplete,
            );

            ref.read(workoutRepositoryProvider).create(newWorkout);
          }

          GoRouter.of(context).pop();
        },
      ),
    );
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
                  child: const Text('CANCEL'),
                ),
                Text(
                  'Choose muscle groups',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategorySection('Upper push', [
                  MuscleGroup.chest,
                  MuscleGroup.triceps,
                  MuscleGroup.shoulders,
                ], Colors.pink),

                const SizedBox(height: 24),

                _buildCategorySection('Upper pull', [
                  MuscleGroup.back,
                  MuscleGroup.biceps,
                ], Colors.cyan),

                const SizedBox(height: 24),

                _buildCategorySection('Legs', [
                  MuscleGroup.quads,
                  MuscleGroup.glutes,
                  MuscleGroup.hamstrings,
                  MuscleGroup.calves,
                ], Colors.teal),
              ],
            ),
          ),

          // Bottom button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedMuscleGroups.isEmpty
                      ? null
                      : () => widget.onMuscleGroupsSelected(
                          _selectedMuscleGroups.toList(),
                        ),
                  child: Text(
                    'ADD MUSCLE GROUPS',
                    style: TextStyle(
                      color: _selectedMuscleGroups.isEmpty
                          ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<MuscleGroup> muscleGroups,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...muscleGroups.map((muscleGroup) {
          final isSelected = _selectedMuscleGroups.contains(muscleGroup);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: color, width: 2) : null,
            ),
            child: ListTile(
              leading: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              title: Text(muscleGroup.displayName),
              trailing: IconButton(
                icon: Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected ? color : null,
                ),
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMuscleGroups.remove(muscleGroup);
                    } else {
                      _selectedMuscleGroups.add(muscleGroup);
                    }
                  });
                },
              ),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMuscleGroups.remove(muscleGroup);
                  } else {
                    _selectedMuscleGroups.add(muscleGroup);
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }
}
