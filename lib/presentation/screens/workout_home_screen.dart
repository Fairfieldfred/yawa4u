import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';

/// Workout home screen - shows current/upcoming workouts
class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  bool _showWeekSelector = false;
  int? _selectedWeek;
  int? _selectedDay;

  void _toggleWeekSelector() {
    setState(() {
      _showWeekSelector = !_showWeekSelector;
    });
  }

  void _selectDay(int week, int day) {
    setState(() {
      _showWeekSelector = false;
      _selectedWeek = week;
      _selectedDay = day;
    });
  }

  Future<void> _updateSetWeight(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final weight = double.tryParse(value);
    if (weight == null && value.isNotEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(weight: weight);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(reps: value);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _toggleSetLog(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  @override
  Widget build(BuildContext context) {
    final currentMesocycle = ref.watch(currentMesocycleProvider);

    // Debug logging
    debugPrint('=== WorkoutHomeScreen Debug ===');
    debugPrint('Current mesocycle: ${currentMesocycle?.name}');
    debugPrint('Start date: ${currentMesocycle?.startDate}');
    debugPrint('Status: ${currentMesocycle?.status}');

    // If there's a current mesocycle, show today's workout
    if (currentMesocycle != null && currentMesocycle.startDate != null) {
      // Get workouts from the workout repository instead of embedded workouts
      final allWorkouts = ref.watch(
        workoutsByMesocycleProvider(currentMesocycle.id),
      );

      debugPrint('Total workouts from repository: ${allWorkouts.length}');
      for (var workout in allWorkouts.take(5)) {
        debugPrint(
          '  Week ${workout.weekNumber} Day ${workout.dayNumber}: ${workout.exercises.length} exercises (ID: ${workout.id})',
        );
        for (var ex in workout.exercises) {
          debugPrint('    - ${ex.name}');
        }
      }

      final currentWeek = currentMesocycle.getCurrentWeek();
      debugPrint('Current week: $currentWeek');

      if (currentWeek == null) {
        // Mesocycle hasn't started yet or has ended
        return _buildEmptyState(
          context,
          'Mesocycle Not Active',
          'The mesocycle is scheduled for a future date or has ended',
        );
      }

      // Use selected week/day if available, otherwise calculate current day
      final displayWeek = _selectedWeek ?? currentWeek;
      final displayDay =
          _selectedDay ??
          (() {
            final daysSinceStart = DateTime.now()
                .difference(currentMesocycle.startDate!)
                .inDays;
            final daysSinceWeekStart = daysSinceStart % 7;
            return (daysSinceWeekStart + 1).clamp(
              1,
              currentMesocycle.daysPerWeek,
            );
          })();

      debugPrint('Display week: $displayWeek, Display day: $displayDay');

      // Get all workouts for the display week and day
      final todaysWorkouts = allWorkouts
          .where(
            (w) => w.weekNumber == displayWeek && w.dayNumber == displayDay,
          )
          .toList();

      debugPrint(
        'Found ${todaysWorkouts.length} workouts for W$displayWeek D$displayDay',
      );

      if (todaysWorkouts.isNotEmpty) {
        // Show selected day's workouts
        return _buildTodaysWorkoutView(
          context,
          ref,
          currentMesocycle,
          todaysWorkouts,
          displayWeek,
          displayDay,
          currentWeek: currentWeek,
        );
      }

      // No workout found for selected day
      return _buildEmptyState(
        context,
        'No Workout Scheduled',
        'No workout found for Week $displayWeek, Day $displayDay',
      );
    }

    // If no current mesocycle, show empty state
    return _buildEmptyState(
      context,
      'No Active Mesocycle',
      'Create and start a mesocycle to begin',
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysWorkoutView(
    BuildContext context,
    WidgetRef ref,
    dynamic mesocycle,
    List<Workout> workouts,
    int displayWeek,
    int displayDay, {
    required int currentWeek,
  }) {
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final dayName = displayDay >= 1 && displayDay <= dayNames.length
        ? dayNames[displayDay - 1]
        : 'DAY $displayDay';

    // Collect all exercises from all workouts for today
    final allExercises = <dynamic>[];
    for (var workout in workouts) {
      allExercises.addAll(workout.exercises);
    }

    debugPrint(
      'Building workout view with ${allExercises.length} total exercises from ${workouts.length} workouts',
    );
    for (var i = 0; i < allExercises.length; i++) {
      debugPrint('  Exercise $i: ${allExercises[i].name}');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mesocycle.name.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'WEEK $displayWeek DAY $displayDay $dayName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _toggleWeekSelector,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Exercise list
          allExercises.isEmpty
              ? const Center(
                  child: Text(
                    'No exercises',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80, top: 24),
                  itemCount: allExercises.length,
                  separatorBuilder: (context, index) {
                    // Check if next exercise is same muscle group
                    final currentMuscleGroup = allExercises[index].muscleGroup;
                    final nextMuscleGroup = index + 1 < allExercises.length
                        ? allExercises[index + 1].muscleGroup
                        : null;
                    final isSameMuscleGroup =
                        currentMuscleGroup == nextMuscleGroup;

                    // Thin grey divider for same muscle group, black spacer for different
                    return isSameMuscleGroup
                        ? Container(height: 1, color: const Color(0xFF3A3A3C))
                        : const SizedBox(height: 32);
                  },
                  itemBuilder: (context, index) {
                    final exercise = allExercises[index];
                    final showMuscleGroupBadge =
                        index == 0 ||
                        allExercises[index - 1].muscleGroup !=
                            exercise.muscleGroup;
                    return _buildExerciseCard(
                      context,
                      exercise,
                      showMuscleGroupBadge: showMuscleGroupBadge,
                    );
                  },
                ),

          // Week selector overlay (shown on top when toggled)
          if (_showWeekSelector)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _WeekSelectorDropdown(
                mesocycle: mesocycle,
                currentWeek: currentWeek,
                currentDay: displayDay,
                onDaySelected: _selectDay,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    dynamic exercise, {
    required bool showMuscleGroupBadge,
  }) {
    final muscleGroup = exercise.muscleGroup as MuscleGroup;
    final equipmentType = exercise.equipmentType as EquipmentType?;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Exercise card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipmentType?.displayName.toUpperCase() ??
                                'UNKNOWN',
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
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
                        child: const Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 0),
                    // Overflow menu button
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF8E8E93),
                        size: 24,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
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
                        const SizedBox(
                          width: 24,
                        ), // Spacer for overflow menu alignment
                        Expanded(
                          child: Text(
                            'WEIGHT',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'REPS',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'LOG',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                          child: IconButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ),

                        // Weight Input
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Center(
                              child: TextFormField(
                                initialValue: set.weight?.toString() ?? '',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'lbs',
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    bottom: 12,
                                  ), // Center vertically
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (value) {
                                  _updateSetWeight(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    value,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Reps Input
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Center(
                              child: TextFormField(
                                initialValue: set.reps,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'RIR',
                                  hintStyle: TextStyle(color: Colors.white24),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(bottom: 12),
                                ),
                                onChanged: (value) {
                                  _updateSetReps(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    value,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Log Checkbox
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: set.isLogged
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: set.isLogged
                                    ? Colors.green
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                _toggleSetLog(
                                  exercise.workoutId,
                                  exercise.id,
                                  index,
                                );
                              },
                              child: set.isLogged
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                            ),
                          ),
                        ),
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
                    style: const TextStyle(
                      color: Colors.white,
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
}

/// Dropdown for selecting week and day (appears below AppBar)
class _WeekSelectorDropdown extends StatefulWidget {
  final dynamic mesocycle;
  final int currentWeek;
  final int currentDay;
  final Function(int week, int day) onDaySelected;

  const _WeekSelectorDropdown({
    required this.mesocycle,
    required this.currentWeek,
    required this.currentDay,
    required this.onDaySelected,
  });

  @override
  State<_WeekSelectorDropdown> createState() => _WeekSelectorDropdownState();
}

class _WeekSelectorDropdownState extends State<_WeekSelectorDropdown> {
  late int _selectedWeek;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.currentWeek;
    _selectedDay = widget.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final availableDays = dayNames.take(widget.mesocycle.daysPerWeek).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 450),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with +/- buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WEEKS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _selectedWeek > 1
                          ? () {
                              setState(() {
                                _selectedWeek--;
                              });
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _selectedWeek < widget.mesocycle.weeksTotal
                          ? () {
                              setState(() {
                                _selectedWeek++;
                              });
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2E),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Week grid with responsive layout
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.mesocycle.weeksTotal, (
                  weekIndex,
                ) {
                  final weekNumber = weekIndex + 1;
                  return Expanded(
                    child: _buildWeekColumn(
                      weekNumber,
                      availableDays,
                      widget.mesocycle.deloadWeek == weekNumber,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekColumn(
    int weekNumber,
    List<String> dayNames,
    bool isDeload,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Week header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDeload ? 'DL' : '$weekNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_calculateRIR(weekNumber)} RIR',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Day buttons - limit to available workout days only
          ...List.generate(dayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentWeek = weekNumber == widget.currentWeek;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                weekNumber == _selectedWeek && dayNumber == _selectedDay;
            final isCompleted =
                weekNumber < widget.currentWeek ||
                (isCurrentWeek && dayNumber < widget.currentDay);

            return GestureDetector(
              onTap: () {
                widget.onDaySelected(weekNumber, dayNumber);
              },
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : (isCurrentWeek && isCurrentDay)
                      ? Colors.red
                      : const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.orange, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNames[dayIndex],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _calculateRIR(int weekNumber) {
    final totalWeeks = widget.mesocycle.weeksTotal;
    final deloadWeek = widget.mesocycle.deloadWeek;

    if (weekNumber == deloadWeek) {
      return 8;
    }

    if (weekNumber <= totalWeeks ~/ 3) {
      return 3;
    } else if (weekNumber <= (totalWeeks * 2) ~/ 3) {
      return 2;
    } else if (weekNumber < deloadWeek) {
      return 1;
    } else {
      return 0;
    }
  }
}

/// Old modal widget - kept for reference but not used
class _WeekSelectorModal extends StatefulWidget {
  final dynamic mesocycle;
  final int currentWeek;
  final int currentDay;

  const _WeekSelectorModal({
    required this.mesocycle,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  State<_WeekSelectorModal> createState() => _WeekSelectorModalState();
}

class _WeekSelectorModalState extends State<_WeekSelectorModal> {
  late int _selectedWeek;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.currentWeek;
    _selectedDay = widget.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final availableDays = dayNames.take(widget.mesocycle.daysPerWeek).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
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
                const SizedBox(width: 40),
                Text(
                  'WEEKS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Week selector buttons (+ and -)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _selectedWeek > 1
                      ? () {
                          setState(() {
                            _selectedWeek--;
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _selectedWeek < widget.mesocycle.weeksTotal
                      ? () {
                          setState(() {
                            _selectedWeek++;
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          // Week grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.mesocycle.weeksTotal, (
                  weekIndex,
                ) {
                  final weekNumber = weekIndex + 1;
                  return _buildWeekColumn(
                    weekNumber,
                    availableDays,
                    widget.mesocycle.deloadWeek == weekNumber,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekColumn(
    int weekNumber,
    List<String> dayNames,
    bool isDeload,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Week header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                Text(
                  '$weekNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isDeload)
                  Text(
                    'DL',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  '${_calculateRIR(weekNumber)} RIR',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Day buttons
          ...List.generate(dayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentWeek = weekNumber == widget.currentWeek;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                weekNumber == _selectedWeek && dayNumber == _selectedDay;
            final isCompleted =
                weekNumber < widget.currentWeek ||
                (isCurrentWeek && dayNumber < widget.currentDay);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWeek = weekNumber;
                  _selectedDay = dayNumber;
                });
                // TODO: Navigate to selected workout
                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : (isCurrentWeek && isCurrentDay)
                      ? Colors.red
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNames[dayIndex],
                  style: TextStyle(
                    color: isCompleted || (isCurrentWeek && isCurrentDay)
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),

          // Extra days for weeks with fewer workout days
          if (dayNames.length < 7)
            ...List.generate(7 - dayNames.length, (index) {
              final extraDayIndex = dayNames.length + index;
              final extraDayNames = [
                'Sun',
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
              ];
              return Container(
                width: 80,
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  extraDayNames[extraDayIndex],
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  int _calculateRIR(int weekNumber) {
    // Calculate RIR based on week number and deload week
    final totalWeeks = widget.mesocycle.weeksTotal;
    final deloadWeek = widget.mesocycle.deloadWeek;

    if (weekNumber == deloadWeek) {
      return 8; // Deload week has high RIR
    }

    // Progressive overload: start at 3 RIR and decrease
    if (weekNumber <= totalWeeks ~/ 3) {
      return 3;
    } else if (weekNumber <= (totalWeeks * 2) ~/ 3) {
      return 2;
    } else if (weekNumber < deloadWeek) {
      return 1;
    } else {
      return 0;
    }
  }
}
