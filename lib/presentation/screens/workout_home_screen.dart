import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
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
    if (set.weight == null || set.reps.isEmpty) return;

    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _addSetBelow(
    String workoutId,
    String exerciseId,
    int currentSetIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Create new set
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    // Insert set after current index
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(currentSetIndex + 1, newSet);

    // Re-number sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _toggleSetSkip(
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
    if (setIndex >= exercise.sets.length) return;

    final currentSet = exercise.sets[setIndex];
    final updatedSet = currentSet.copyWith(isSkipped: !currentSet.isSkipped);
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _deleteSet(
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
    if (setIndex >= exercise.sets.length) return;

    // Remove set
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    // Re-number sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType type,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final updatedSet = exercise.sets[setIndex].copyWith(setType: type);
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _addNote(String workoutId, String exerciseId) async {
    // TODO: Implement note dialog
    debugPrint('Add note for exercise: $exerciseId');
  }

  Future<void> _moveExerciseDown(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final index = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (index == -1 || index >= workout.exercises.length - 1) return;

    final updatedExercises = List<Exercise>.from(workout.exercises);
    final exercise = updatedExercises.removeAt(index);
    updatedExercises.insert(index + 1, exercise);

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    // TODO: Implement replace exercise navigation
    debugPrint('Replace exercise: $exerciseId');
  }

  Future<void> _logJointPain(String workoutId, String exerciseId) async {
    // TODO: Implement joint pain dialog
    debugPrint('Log joint pain for exercise: $exerciseId');
  }

  Future<void> _addSetToExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets)..add(newSet);
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _skipExerciseSets(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Only skip unlogged sets
    final updatedSets = (exercise.sets)
        .map((s) => !s.isLogged ? s.copyWith(isSkipped: true) : s)
        .toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
  }

  bool _isWorkoutComplete(Workout workout) {
    // Check if all sets in all exercises are either logged or skipped
    for (final exercise in workout.exercises) {
      final sets = exercise.sets;
      for (final set in sets) {
        if (!set.isLogged && !set.isSkipped) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _finishWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await repository.update(updatedWorkout);
    }

    // Navigate to next workout using the first workout's info
    final firstWorkout = workouts.first;
    final mesocycle = ref.read(currentMesocycleProvider);
    if (mesocycle == null) return;

    // Find next workout
    int nextDay = firstWorkout.dayNumber + 1;
    int nextWeek = firstWorkout.weekNumber;

    // Check if we need to move to next week
    if (nextDay > mesocycle.daysPerWeek) {
      nextDay = 1;
      nextWeek++;
    }

    // Update selected day
    setState(() {
      _selectedWeek = nextWeek;
      _selectedDay = nextDay;
    });
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

          // FINISH WORKOUT button (appears when all sets are logged or skipped)
          if (workouts.isNotEmpty &&
              !workouts.every((w) => w.isCompleted) &&
              workouts.every((w) => _isWorkoutComplete(w)))
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: () => _finishWorkout(workouts),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'FINISH WORKOUT',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF8E8E93),
                        size: 24,
                      ),
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
                            _addNote(exercise.workoutId, exercise.id);
                            break;
                          case 'move_down':
                            _moveExerciseDown(exercise.workoutId, exercise.id);
                            break;
                          case 'replace':
                            _replaceExercise(exercise.workoutId, exercise.id);
                            break;
                          case 'joint_pain':
                            _logJointPain(exercise.workoutId, exercise.id);
                            break;
                          case 'add_set':
                            _addSetToExercise(exercise.workoutId, exercise.id);
                            break;
                          case 'skip_sets':
                            _skipExerciseSets(exercise.workoutId, exercise.id);
                            break;
                          case 'delete':
                            _deleteExercise(exercise.workoutId, exercise.id);
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
                        // Move down
                        const PopupMenuItem<String>(
                          value: 'move_down',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Move down',
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
                        // Joint pain
                        const PopupMenuItem<String>(
                          value: 'joint_pain',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.healing,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Joint pain',
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
                        // Skip sets
                        const PopupMenuItem<String>(
                          value: 'skip_sets',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.fast_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Skip sets',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Delete exercise
                        PopupMenuItem<String>(
                          value: 'delete',
                          enabled: !(exercise.sets as List<ExerciseSet>).any(
                            (s) => s.isLogged,
                          ),
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color:
                                    (exercise.sets as List<ExerciseSet>).any(
                                      (s) => s.isLogged,
                                    )
                                    ? Colors.grey
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete exercise',
                                style: TextStyle(
                                  color:
                                      (exercise.sets as List<ExerciseSet>).any(
                                        (s) => s.isLogged,
                                      )
                                      ? Colors.grey
                                      : Colors.red,
                                ),
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
                  final isLoggable = set.weight != null && set.reps.isNotEmpty;
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
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 20,
                            ),
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
                                case 'add_below':
                                  _addSetBelow(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                  );
                                  break;
                                case 'skip':
                                  _toggleSetSkip(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                  );
                                  break;
                                case 'delete':
                                  _deleteSet(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                  );
                                  break;
                                case 'regular':
                                  _updateSetType(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    SetType.regular,
                                  );
                                  break;
                                case 'myorep':
                                  _updateSetType(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    SetType.myorep,
                                  );
                                  break;
                                case 'myorep_match':
                                  _updateSetType(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    SetType.myorepMatch,
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
                              const PopupMenuItem<String>(
                                value: 'add_below',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Add set below',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // Skip set
                              PopupMenuItem<String>(
                                value: 'skip',
                                height: 40,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.fast_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      set.isSkipped ? 'Unskip set' : 'Skip set',
                                      style: const TextStyle(
                                        color: Colors.white,
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
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Regular',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '(straight, down, ascending)',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
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
                                    const Text(
                                      'Myorep',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
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
                                    const Text(
                                      'Myorep match',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                key: ValueKey('weight_${set.id}'),
                                initialValue: set.isLogged
                                    ? (set.weight?.toString() ?? '')
                                    : '',
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
                                key: ValueKey('reps_${set.id}'),
                                initialValue: set.isLogged ? set.reps : '',
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
                                  : (isLoggable
                                        ? const Color(0xFF1C1C1E)
                                        : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: set.isLogged
                                    ? Colors.green
                                    : (isLoggable
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.white.withValues(
                                              alpha: 0.05,
                                            )),
                              ),
                            ),
                            child: InkWell(
                              onTap: isLoggable
                                  ? () {
                                      _toggleSetLog(
                                        exercise.workoutId,
                                        exercise.id,
                                        index,
                                      );
                                    }
                                  : null,
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
    final deloadWeek = widget.mesocycle.deloadWeek;

    // Deload week has 8 RIR
    if (weekNumber == deloadWeek) {
      return 8;
    }

    // Calculate weeks until deload
    final weeksUntilDeload = deloadWeek - weekNumber;

    // Week before deload = 0 RIR
    // 2 weeks before = 1 RIR
    // 3 weeks before = 2 RIR, etc.
    if (weeksUntilDeload == 1) {
      return 0;
    } else if (weeksUntilDeload > 1) {
      return weeksUntilDeload - 1;
    } else {
      // After deload week
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
    final deloadWeek = widget.mesocycle.deloadWeek;

    // Deload week has 8 RIR
    if (weekNumber == deloadWeek) {
      return 8;
    }

    // Calculate weeks until deload
    final weeksUntilDeload = deloadWeek - weekNumber;

    // Week before deload = 0 RIR
    // 2 weeks before = 1 RIR
    // 3 weeks before = 2 RIR, etc.
    if (weeksUntilDeload == 1) {
      return 0;
    } else if (weeksUntilDeload > 1) {
      return weeksUntilDeload - 1;
    } else {
      // After deload week
      return 0;
    }
  }
}
