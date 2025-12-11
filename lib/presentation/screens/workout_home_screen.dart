import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/workout.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/dialogs/exercise_info_dialog.dart';
import '../widgets/dialogs/workout_dialogs.dart';
import '../widgets/mesocycle_summary_dialog.dart';
import 'add_exercise_screen.dart';

/// Workout home screen - shows current/upcoming workouts
class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  // ---------------------------------------------------------------------------
  // Controller Access
  // ---------------------------------------------------------------------------

  WorkoutHomeController get _controller =>
      ref.read(workoutHomeControllerProvider.notifier);

  WorkoutHomeState get _homeState => ref.watch(workoutHomeControllerProvider);

  void _toggleWeekSelector() {
    _controller.toggleWeekSelector();
  }

  void _selectDay(int week, int day) {
    _controller.selectDay(week, day);
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
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);
    final noteController = TextEditingController(text: exercise.notes ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updatedExercise = exercise.copyWith(
        notes: result.isEmpty ? null : result,
      );
      final updatedExercises = workout.exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);
    }
  }

  Future<void> _moveExerciseDown(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise down called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get the current mesocycle to find all workouts for today
    final mesocycle = ref.read(currentMesocycleProvider);
    if (mesocycle == null) {
      debugPrint('No current mesocycle');
      return;
    }

    // Get all workouts for this mesocycle
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

    // Get current week and day
    final currentWeek = mesocycle.getCurrentWeek();
    if (currentWeek == null) {
      debugPrint('Could not determine current week');
      return;
    }

    // Use selected week/day if available, otherwise use current
    final displayWeek = _homeState.selectedWeek ?? currentWeek;
    final displayDay =
        _homeState.selectedDay ??
        (() {
          final daysSinceStart = DateTime.now()
              .difference(mesocycle.startDate!)
              .inDays;
          final daysSinceWeekStart = daysSinceStart % 7;
          return (daysSinceWeekStart + 1).clamp(1, 7);
        })();

    final todaysWorkouts = allWorkouts
        .where((w) => w.weekNumber == displayWeek && w.dayNumber == displayDay)
        .toList();

    // Collect all exercises from all workouts
    final allExercises = <Exercise>[];
    for (var workout in todaysWorkouts) {
      allExercises.addAll(workout.exercises);
    }

    debugPrint('Total exercises across all workouts: ${allExercises.length}');

    // Find the exercise's position in the complete list
    final globalIndex = allExercises.indexWhere((e) => e.id == exerciseId);
    if (globalIndex == -1) {
      debugPrint('Exercise not found in allExercises');
      return;
    }

    if (globalIndex >= allExercises.length - 1) {
      debugPrint('Exercise is already at the bottom');
      return;
    }

    // Get the exercise to move and the exercise to swap with
    final exerciseToMove = allExercises[globalIndex];
    final exerciseToSwapWith = allExercises[globalIndex + 1];

    debugPrint(
      'Moving "${exerciseToMove.name}" down, swapping with "${exerciseToSwapWith.name}"',
    );

    // Find which workouts contain these exercises
    Workout? workoutWithMovingExercise;
    Workout? workoutWithSwapExercise;

    for (var workout in todaysWorkouts) {
      if (workout.exercises.any((e) => e.id == exerciseToMove.id)) {
        workoutWithMovingExercise = workout;
      }
      if (workout.exercises.any((e) => e.id == exerciseToSwapWith.id)) {
        workoutWithSwapExercise = workout;
      }
    }

    if (workoutWithMovingExercise == null || workoutWithSwapExercise == null) {
      debugPrint('Could not find workouts containing the exercises');
      return;
    }

    if (workoutWithMovingExercise.id == workoutWithSwapExercise.id) {
      // Same workout - just swap positions
      final workout = workoutWithMovingExercise;
      final exercises = List<Exercise>.from(workout.exercises);
      final idx1 = exercises.indexWhere((e) => e.id == exerciseToMove.id);
      final idx2 = exercises.indexWhere((e) => e.id == exerciseToSwapWith.id);

      final temp = exercises[idx1];
      exercises[idx1] = exercises[idx2];
      exercises[idx2] = temp;

      final updatedWorkout = workout.copyWith(exercises: exercises);
      await repository.update(updatedWorkout);
      debugPrint('Swapped exercises within same workout');
    } else {
      // Different workouts - move exercise between workouts
      // Remove from first workout
      final exercises1 = workoutWithMovingExercise.exercises
          .where((e) => e.id != exerciseToMove.id)
          .toList();

      // Add to second workout (insert at the position before the swap exercise)
      final exercises2 = List<Exercise>.from(workoutWithSwapExercise.exercises);
      final insertIndex = exercises2.indexWhere(
        (e) => e.id == exerciseToSwapWith.id,
      );

      // Update the exercise's workoutId to match the new workout
      final movedExercise = exerciseToMove.copyWith(
        workoutId: workoutWithSwapExercise.id,
      );
      exercises2.insert(insertIndex, movedExercise);

      final updatedWorkout1 = workoutWithMovingExercise.copyWith(
        exercises: exercises1,
      );
      final updatedWorkout2 = workoutWithSwapExercise.copyWith(
        exercises: exercises2,
      );

      await repository.update(updatedWorkout1);
      await repository.update(updatedWorkout2);
      debugPrint(
        'Moved exercise from workout ${workoutWithMovingExercise.id} to ${workoutWithSwapExercise.id}',
      );
    }

    debugPrint('Exercise moved successfully');
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    // Get the workout and exercise
    final workout = ref.read(workoutProvider(workoutId));
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    // First delete the current exercise
    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await ref.read(workoutRepositoryProvider).update(updatedWorkout);

    // Navigate to add exercise screen with the same muscle group
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddExerciseScreen(
            mesocycleId: workout.mesocycleId,
            workoutId: workout.id,
            initialMuscleGroup: exercise.muscleGroup,
          ),
        ),
      );
    }
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

  /// Calculate target RIR for a given week based on mesocycle deload schedule
  int _calculateRIR(int weekNumber, dynamic mesocycle) {
    final deloadWeek = mesocycle.deloadWeek;

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

  Future<void> _finishWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    final mesocycle = ref.read(currentMesocycleProvider);

    if (mesocycle == null) return;

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await repository.update(updatedWorkout);
    }

    // Check if ALL workouts in the mesocycle are now completed
    // We need to verify that every week/day combination has at least one completed workout
    final allWorkouts = repository.getByMesocycleId(mesocycle.id);

    // Build a set of completed week/day combinations
    final completedDays = <String>{};
    for (final workout in allWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        completedDays.add('${workout.weekNumber}-${workout.dayNumber}');
      }
    }

    // Check if all expected week/day combinations are completed
    final totalWeeks = mesocycle.weeksTotal;
    final daysPerWeek = mesocycle.daysPerWeek;
    bool allCompleted = true;

    for (int week = 1; week <= totalWeeks; week++) {
      for (int day = 1; day <= daysPerWeek; day++) {
        if (!completedDays.contains('$week-$day')) {
          allCompleted = false;
          break;
        }
      }
      if (!allCompleted) break;
    }

    if (allCompleted) {
      // Complete the mesocycle
      await mesocycleRepository.update(mesocycle.complete());

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Mesocycle Completed!'),
            content: const Text(
              'Congratulations! You have finished all workouts in this mesocycle.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/'); // Go back to list screen
                },
                child: const Text('AWESOME'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Navigate to next workout using the first workout's info
    final firstWorkout = workouts.first;

    // Find next workout
    int nextDay = firstWorkout.dayNumber + 1;
    int nextWeek = firstWorkout.weekNumber;

    // Check if we need to move to next week
    if (nextDay > mesocycle.daysPerWeek) {
      nextDay = 1;
      nextWeek++;
    }

    // Update selected day via controller
    _controller.navigateToNextDay(nextWeek, nextDay);
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

      // Use selected week/day if available, otherwise find first incomplete workout
      int displayWeek;
      int displayDay;

      if (_homeState.selectedWeek != null && _homeState.selectedDay != null) {
        // User has manually selected a specific workout (or we locked it in)
        displayWeek = _homeState.selectedWeek!;
        displayDay = _homeState.selectedDay!;
      } else {
        // Find first incomplete workout
        final firstIncomplete = findFirstIncompleteWorkout(allWorkouts);
        if (firstIncomplete != null) {
          displayWeek = firstIncomplete.$1;
          displayDay = firstIncomplete.$2;
        } else {
          // All workouts complete, fall back to current week/day
          displayWeek = currentWeek;
          displayDay = (() {
            final daysSinceStart = DateTime.now()
                .difference(currentMesocycle.startDate!)
                .inDays;
            final daysSinceWeekStart = daysSinceStart % 7;
            return (daysSinceWeekStart + 1).clamp(
              1,
              currentMesocycle.daysPerWeek,
            );
          })();
        }

        // Lock in the selected day so we don't auto-navigate on rebuild
        // This ensures user stays on current day until they press "Finish Workout"
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selectDay(displayWeek, displayDay);
        });
      }

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
          allWorkouts: allWorkouts,
        );
      }

      // No workout found for selected day
      return _buildNoWorkoutForDay(
        context,
        ref,
        currentMesocycle,
        displayWeek,
        displayDay,
        currentWeek: currentWeek,
        allWorkouts: allWorkouts,
      );
    }

    // If no current mesocycle, show empty state
    return _buildEmptyState(
      context,
      'No Active Mesocycle',
      'Create and start a mesocycle to begin',
    );
  }

  /// Build empty state for a selected day that has no workout scheduled
  /// This includes the full AppBar with calendar navigation
  Widget _buildNoWorkoutForDay(
    BuildContext context,
    WidgetRef ref,
    dynamic mesocycle,
    int displayWeek,
    int displayDay, {
    required int currentWeek,
    required List<Workout> allWorkouts,
  }) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mesocycle.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'WEEK $displayWeek DAY $displayDay',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _toggleWeekSelector,
            ),
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
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Workout Scheduled',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No workout found for Week $displayWeek, Day $displayDay',
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
            // Week selector overlay
            if (_homeState.showWeekSelector) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _controller.hideWeekSelector();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CalendarDropdown(
                  mesocycle: mesocycle,
                  currentWeek: currentWeek,
                  currentDay: displayDay,
                  selectedWeek: displayWeek,
                  selectedDay: displayDay,
                  allWorkouts: allWorkouts,
                  onDaySelected: _selectDay,
                ),
              ),
            ],
          ],
        ),
      ),
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
    required List<Workout> allWorkouts,
  }) {
    // Calculate day name based on the mesocycle start date
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    String dayName;

    // Debug logging
    debugPrint('=== DAY NAME CALCULATION ===');
    debugPrint('Start date: ${mesocycle.startDate}');
    debugPrint('Start date weekday: ${mesocycle.startDate?.weekday}');
    debugPrint('Display week: $displayWeek, Display day: $displayDay');
    debugPrint('Days per week: ${mesocycle.daysPerWeek}');
    debugPrint(
      'Has custom dayName: ${workouts.isNotEmpty && workouts.first.dayName != null}',
    );
    if (workouts.isNotEmpty && workouts.first.dayName != null) {
      debugPrint('Custom dayName: ${workouts.first.dayName}');
    }

    if (workouts.isNotEmpty && workouts.first.dayName != null) {
      // Use custom day name from workout if available
      dayName = workouts.first.dayName!.substring(0, 3).toUpperCase();
      debugPrint('Using custom dayName: $dayName');
    } else if (mesocycle.startDate != null) {
      // Calculate based on start date
      // Get the day of week when mesocycle started (0 = Sunday, 6 = Saturday)
      final startDayOfWeek =
          mesocycle.startDate!.weekday % 7; // Convert Monday=1 to Sunday=0
      debugPrint('Start day of week (after conversion): $startDayOfWeek');

      // Calculate days elapsed since start
      final daysElapsed =
          ((displayWeek - 1) * mesocycle.daysPerWeek) + (displayDay - 1);
      debugPrint('Days elapsed: $daysElapsed');

      // Calculate actual day of week
      final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
      debugPrint('Actual day of week: $actualDayOfWeek');

      dayName = defaultDayNames[actualDayOfWeek];
      debugPrint('Calculated dayName: $dayName');
    } else {
      // Fallback to default if no start date
      dayName = displayDay >= 1 && displayDay <= defaultDayNames.length
          ? defaultDayNames[displayDay - 1]
          : 'DAY $displayDay';
      debugPrint('Using fallback dayName: $dayName');
    }

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mesocycle.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'WEEK $displayWeek DAY $displayDay $dayName',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _toggleWeekSelector,
            ),
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
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showWorkoutMenu(context, mesocycle, workouts),
              ),
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
                      final currentMuscleGroup =
                          allExercises[index].muscleGroup;
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

                      // Calculate target RIR for current week
                      final weekRir = _calculateRIR(displayWeek, mesocycle);

                      return _buildExerciseCard(
                        context,
                        exercise,
                        showMuscleGroupBadge: showMuscleGroupBadge,
                        targetRir: weekRir,
                      );
                    },
                  ),

            // Week selector overlay (shown on top when toggled)
            if (_homeState.showWeekSelector) ...[
              // Barrier to dismiss on tap outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _controller.hideWeekSelector();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              // The dropdown itself
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _CalendarDropdown(
                  mesocycle: mesocycle,
                  currentWeek: currentWeek,
                  currentDay: displayDay,
                  selectedWeek: displayWeek,
                  selectedDay: displayDay,
                  allWorkouts: allWorkouts,
                  onDaySelected: _selectDay,
                ),
              ),
            ],

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
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
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
      ),
    );
  }

  void _showWorkoutMenu(
    BuildContext context,
    dynamic mesocycle,
    List<Workout> workouts,
  ) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition + const Offset(-180, 40),
        buttonPosition + const Offset(-180, 40) + const Offset(250, 0),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: <PopupMenuEntry<void>>[
        // MESOCYCLE Section
        _buildMenuHeader('MESOCYCLE'),
        _buildMenuItem(
          icon: Icons.edit_note,
          text: 'View notes',
          onTap: () => _viewMesocycleNotes(mesocycle),
        ),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: 'Summary',
          onTap: () => _showMesocycleSummary(mesocycle),
        ),
        _buildMenuItem(
          icon: Icons.edit,
          text: 'Rename',
          onTap: () => _renameMesocycle(mesocycle),
        ),
        _buildMenuItem(
          icon: Icons.stop_circle_outlined,
          text: 'End meso',
          onTap: () => _endMesocycle(mesocycle),
        ),
        const PopupMenuDivider(height: 1),

        // WORKOUT Section
        _buildMenuHeader('WORKOUT'),
        _buildMenuItem(
          icon: Icons.edit,
          text: 'New note',
          onTap: () => _newWorkoutNote(workouts),
        ),
        _buildMenuItem(
          icon: Icons.label_outline,
          text: 'Relabel',
          onTap: () => _relabelWorkout(workouts),
        ),
        _buildMenuItem(
          icon: Icons.clear_all,
          text: 'Clear all day labels',
          onTap: () => _clearAllDayNames(mesocycle),
        ),
        _buildMenuItem(
          icon: Icons.add,
          text: 'Add exercise',
          onTap: () => _addExerciseToWorkout(workouts),
        ),
        _buildMenuItem(
          icon: Icons.monitor_weight_outlined,
          text: 'Bodyweight',
          onTap: () => _logBodyweight(),
        ),
        _buildMenuItem(
          icon: Icons.undo,
          text: 'Reset',
          onTap: () => _resetWorkout(workouts),
          enabled:
              !workouts.any((w) => w.status == WorkoutStatus.completed) &&
              workouts.any(
                (w) => w.exercises.any(
                  (e) => e.sets.any(
                    (s) =>
                        s.isLogged ||
                        (s.weight != null) ||
                        (s.reps.isNotEmpty && s.reps != '0'),
                  ),
                ),
              ),
        ),
        _buildMenuItem(
          icon: Icons.skip_next,
          text: 'Skip workout',
          onTap: () => _skipWorkout(workouts),
        ),
      ],
    );
  }

  PopupMenuItem<void> _buildMenuHeader(String title) {
    return PopupMenuItem<void>(
      enabled: false,
      height: 32,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  PopupMenuItem<void> _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return PopupMenuItem<void>(
      enabled: enabled,
      height: 48,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? Theme.of(context).iconTheme.color
                : Theme.of(context).disabledColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: enabled
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder actions
  void _viewMesocycleNotes(dynamic mesocycle) {
    debugPrint('View notes');
  }

  void _showMesocycleSummary(dynamic mesocycle) {
    showDialog(
      context: context,
      builder: (context) => MesocycleSummaryDialog(mesocycle: mesocycle),
    );
  }

  Future<void> _renameMesocycle(dynamic mesocycle) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameMesocycleDialog(initialName: mesocycle.name),
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

  Future<void> _endMesocycle(dynamic mesocycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Mesocycle'),
        content: Text(
          'Are you sure you want to end "${mesocycle.name}"? This will mark it as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('END MESOCYCLE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(mesocycleRepositoryProvider);
        final updatedMesocycle = mesocycle.copyWith(
          status: MesocycleStatus.completed,
          endDate: DateTime.now(),
        );
        await repository.update(updatedMesocycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${mesocycle.name}" completed'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ending mesocycle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _newWorkoutNote(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    // Use the first workout to store the note for the day
    final workout = workouts.first;
    final currentNote = workout.notes;

    final newNote = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorkoutNoteDialog(initialNote: currentNote),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final updatedWorkout = workout.copyWith(notes: newNote);
        await repository.update(updatedWorkout);

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

  Future<void> _relabelWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final workout = workouts.first;
    final currentLabel = workout.dayName ?? 'Day ${workout.dayNumber}';

    // Debug logging to understand what's being passed in
    debugPrint('=== RELABEL DEBUG ===');
    debugPrint('Workouts passed in: ${workouts.length}');
    for (var w in workouts) {
      debugPrint('  - Week ${w.weekNumber}, Day ${w.dayNumber}, ID: ${w.id}');
    }

    final result = await showDialog<({String label, bool applyToAll})>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RelabelDayDialog(initialLabel: currentLabel),
    );

    if (result != null && mounted) {
      debugPrint('Apply to all: ${result.applyToAll}');
      debugPrint('New label: ${result.label}');

      try {
        final repository = ref.read(workoutRepositoryProvider);

        if (result.applyToAll) {
          // Update all workouts with the same day number in this mesocycle
          final allWorkouts = ref.read(
            workoutsByMesocycleProvider(workout.mesocycleId),
          );
          final workoutsToUpdate = allWorkouts
              .where((w) => w.dayNumber == workout.dayNumber)
              .toList();

          debugPrint(
            'Updating ${workoutsToUpdate.length} workouts (apply to all)',
          );
          for (final w in workoutsToUpdate) {
            debugPrint(
              '  - Updating Week ${w.weekNumber}, Day ${w.dayNumber}, ID: ${w.id}',
            );
            final updatedWorkout = w.copyWith(dayName: result.label);
            await repository.update(updatedWorkout);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Updated label for all Day ${workout.dayNumber} workouts',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Update only the current workout(s) for this specific week and day
          // The workouts list passed in contains ALL workouts for this day across all weeks
          // We need to filter to only the current week
          final currentWeekNumber = workouts.first.weekNumber;
          final currentWeekWorkouts = workouts
              .where((w) => w.weekNumber == currentWeekNumber)
              .toList();

          debugPrint(
            'Updating ${currentWeekWorkouts.length} workouts (current week only)',
          );
          for (final w in currentWeekWorkouts) {
            debugPrint(
              '  - Updating Week ${w.weekNumber}, Day ${w.dayNumber}, ID: ${w.id}',
            );
            final updatedWorkout = w.copyWith(dayName: result.label);
            await repository.update(updatedWorkout);
          }

          // Verify the update by checking all workouts again
          debugPrint('=== VERIFICATION ===');
          final allWorkoutsAfter = ref.read(
            workoutsByMesocycleProvider(workout.mesocycleId),
          );

          // Show ALL workouts grouped by week
          debugPrint('All workouts in mesocycle after update:');
          for (int week = 1; week <= 5; week++) {
            final weekWorkouts = allWorkoutsAfter
                .where((w) => w.weekNumber == week)
                .toList();
            if (weekWorkouts.isNotEmpty) {
              debugPrint('  Week $week:');
              for (var w in weekWorkouts) {
                debugPrint(
                  '    - Day ${w.dayNumber}, dayName: "${w.dayName}", ID: ${w.id.substring(0, 8)}...',
                );
              }
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Label updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error updating label: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating label: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllDayNames(dynamic mesocycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Day Labels'),
        content: const Text(
          'This will remove all custom day labels from workouts in this mesocycle. '
          'Day names will be calculated automatically based on the start date.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

        debugPrint('Clearing dayName from ${allWorkouts.length} workouts');

        for (final workout in allWorkouts) {
          if (workout.dayName != null) {
            final updatedWorkout = workout.copyWith(dayName: null);
            await repository.update(updatedWorkout);
            debugPrint(
              '  Cleared: Week ${workout.weekNumber}, Day ${workout.dayNumber}',
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All day labels cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error clearing day names: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing labels: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _addExerciseToWorkout(List<Workout> workouts) {
    if (workouts.isEmpty) return;

    // Always show muscle group selector to allow adding any muscle group
    _showMuscleGroupSelector(workouts);
  }

  void _showMuscleGroupSelector(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    // Get the mesocycle info from the first workout
    final mesocycleId = workouts.first.mesocycleId;
    final dayNumber = workouts.first.dayNumber;
    final weekNumber = workouts.first.weekNumber;
    final dayName = workouts.first.dayName;

    // Create a map of existing muscle groups to their workouts
    final muscleGroupWorkouts = <MuscleGroup, Workout>{};
    for (final workout in workouts) {
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Muscle Group',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allMuscleGroups.length,
                  itemBuilder: (context, index) {
                    final muscleGroup = allMuscleGroups[index];
                    final existingWorkout = muscleGroupWorkouts[muscleGroup];

                    return ListTile(
                      title: Text(muscleGroup.displayName),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        Navigator.pop(context);

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
                            mesocycleId: mesocycleId,
                            weekNumber: weekNumber,
                            dayNumber: dayNumber,
                            dayName: dayName,
                            label: muscleGroup.displayName,
                            exercises: [],
                          );

                          // Save the new workout
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

  void _logBodyweight() {
    debugPrint('Log bodyweight');
  }

  void _resetWorkout(List<Workout> workouts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Workout?'),
        content: const Text(
          'This will clear all logged sets and entered values for this workout. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                final repository = ref.read(workoutRepositoryProvider);

                for (final workout in workouts) {
                  // Create updated exercises with reset sets
                  final updatedExercises = workout.exercises.map((exercise) {
                    final updatedSets = exercise.sets.map((set) {
                      return set.copyWith(
                        isLogged: false,
                        weight: null, // Clear weight
                        reps: '', // Clear reps
                      );
                    }).toList();

                    return exercise.copyWith(sets: updatedSets);
                  }).toList();

                  // Update workout with reset exercises and status
                  final updatedWorkout = workout.copyWith(
                    exercises: updatedExercises,
                    status: WorkoutStatus.incomplete,
                    completedDate: null,
                  );

                  await repository.update(updatedWorkout);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout reset'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resetting workout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _skipWorkout(List<Workout> workouts) {
    debugPrint('Skip workout');
  }

  Widget _buildExerciseCard(
    BuildContext context,
    dynamic exercise, {
    required bool showMuscleGroupBadge,
    int? targetRir,
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
                            equipmentType?.displayName.toUpperCase() ??
                                'UNKNOWN',
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
                          showExerciseInfoDialog(context, exercise as Exercise),
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
                        SizedBox(
                          width: 40,
                          child: Text(
                            'LOG',
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
                                case 'max_reps':
                                  _updateSetType(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    SetType.maxReps,
                                  );
                                  break;
                                case 'end_with_partials':
                                  _updateSetType(
                                    exercise.workoutId,
                                    exercise.id,
                                    index,
                                    SetType.endWithPartials,
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
                              // Skip set
                              PopupMenuItem<String>(
                                value: 'skip',
                                height: 40,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.fast_forward,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      set.isSkipped ? 'Unskip set' : 'Skip set',
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
                        const SizedBox(width: 24),
                        // Weight Input
                        Expanded(
                          child: Container(
                            height: 36,
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
                                key: ValueKey('weight_${set.id}'),
                                initialValue: set.weight?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'lbs',
                                  hintStyle: Theme.of(
                                    context,
                                  ).inputDecorationTheme.hintStyle,
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
                        const SizedBox(width: 24),

                        // Reps Input
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 36,
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
                                      hintText: targetRir != null
                                          ? '$targetRir RIR'
                                          : 'RIR',
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
                                        exercise.workoutId,
                                        exercise.id,
                                        index,
                                        value,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Badge for non-regular set types
                              if (getSetTypeBadge(set.setType) != null)
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
                                      getSetTypeBadge(set.setType)!,
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
                        const SizedBox(width: 24),

                        // Log Checkbox
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: set.isLogged
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : (isLoggable
                                        ? Theme.of(
                                            context,
                                          ).inputDecorationTheme.fillColor
                                        : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: set.isLogged
                                    ? Colors.green
                                    : (isLoggable
                                          ? Colors.green
                                          : Theme.of(context).dividerColor
                                                .withValues(alpha: 0.3)),
                                width: set.isLogged || isLoggable ? 2 : 1,
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
}

/// Dropdown for selecting week and day (appears below AppBar)
class _CalendarDropdown extends ConsumerStatefulWidget {
  final dynamic mesocycle;
  final int currentWeek;
  final int currentDay;
  final int selectedWeek;
  final int selectedDay;
  final List<Workout> allWorkouts;
  final Function(int week, int day) onDaySelected;

  const _CalendarDropdown({
    required this.mesocycle,
    required this.currentWeek,
    required this.currentDay,
    required this.selectedWeek,
    required this.selectedDay,
    required this.allWorkouts,
    required this.onDaySelected,
  });

  @override
  ConsumerState<_CalendarDropdown> createState() => _CalendarDropdownState();
}

class _CalendarDropdownState extends ConsumerState<_CalendarDropdown> {
  late int _selectedWeek;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.selectedWeek;
    _selectedDay = widget.selectedDay;
  }

  Future<void> _addWeek() async {
    // Add a new week before the deload week
    final mesocycle = widget.mesocycle;
    final newWeekNumber = mesocycle
        .weeksTotal; // This will be the new week number (before deload)

    // Get all existing workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

    // Get the last non-deload week as a template
    // If weeksTotal is 4 (1, 2, 3, 4=DL), we want to copy week 3.
    // templateWeek = 4 - 1 = 3.
    final templateWeek = mesocycle.weeksTotal - 1;

    // Safety check: if we only have 1 week (which is deload), we can't really copy "previous" week.
    // But usually a mesocycle starts with at least some weeks.
    // If templateWeek < 1, we might need to copy the deload week but change it?
    // Or just assume there's always at least one normal week if we are adding.
    // If weeksTotal is 1 (just deload?), templateWeek is 0.

    List<Workout> templateWorkouts = [];
    if (templateWeek >= 1) {
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == templateWeek)
          .toList();
    } else {
      // Fallback: if we are at week 1 (deload), and we add a week, maybe copy week 1?
      // But week 1 is deload.
      // Let's just try to find ANY week to copy, or copy the deload week but reset RIR?
      // For now, let's assume we copy the week before deload.
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == mesocycle.weeksTotal)
          .toList();
    }

    if (templateWorkouts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot add week: No template workouts found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 1. Shift Deload Week: Update deload week workouts to be one week later
    // Current deload week is at `mesocycle.weeksTotal`. New position will be `mesocycle.weeksTotal + 1`.
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == mesocycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      final updatedWorkout = workout.copyWith(
        weekNumber: mesocycle.weeksTotal + 1,
      );
      await repository.update(updatedWorkout);
    }

    // 2. Create New Week: Create new workouts for the new week based on template
    // The new week will take the place of the old deload week index (which is `mesocycle.weeksTotal` before increment).
    // Wait, if we have weeks 1, 2, 3(DL). weeksTotal=3.
    // We want 1, 2, 3, 4(DL).
    // Old DL was 3. New DL is 4.
    // New week is 3.
    // So newWeekNumber = mesocycle.weeksTotal (which is 3). Correct.

    for (var templateWorkout in templateWorkouts) {
      final newWorkout = templateWorkout.copyWith(
        id: const Uuid().v4(),
        weekNumber: newWeekNumber,
        status: WorkoutStatus.incomplete, // Reset status
        exercises: templateWorkout.exercises
            .map(
              (exercise) => exercise.copyWith(
                id: const Uuid().v4(),
                workoutId: const Uuid()
                    .v4(), // This will be replaced by newWorkout.id but we need to ensure it matches
                // Actually, we should set workoutId after we have the newWorkout ID, but copyWith on top level handles it?
                // No, workout.exercises usually have workoutId.
                // Let's just generate IDs.
                sets: exercise.sets
                    .map(
                      (set) => set.copyWith(
                        id: const Uuid().v4(),
                        isLogged: false,
                        weight:
                            null, // Reset weight? Or keep previous? Usually keep previous for progressive overload reference?
                        // User request says "add another week". Usually implies copying structure.
                        // Let's keep weight empty or null to force user to enter new weights, or maybe copy?
                        // Existing logic in some apps copies previous weights.
                        // But here let's reset logged state.
                        reps: '',
                        isSkipped: false,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );

      // Fix workoutId in exercises
      final fixedExercises = newWorkout.exercises
          .map((e) => e.copyWith(workoutId: newWorkout.id))
          .toList();
      final finalWorkout = newWorkout.copyWith(exercises: fixedExercises);

      await repository.create(finalWorkout);
    }

    // Update mesocycle weeks total and deload week
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    final updatedMesocycle = mesocycle.copyWith(
      weeksTotal: mesocycle.weeksTotal + 1,
      deloadWeek: mesocycle.deloadWeek + 1,
    );
    await mesocycleRepository.update(updatedMesocycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $newWeekNumber added'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeWeek() async {
    // Remove the last week before the deload week
    final mesocycle = widget.mesocycle;

    // If we have weeks 1, 2, 3, 4(DL). weeksTotal=4.
    // We want to remove week 3.
    // weekToRemove = 4 - 1 = 3.
    final weekToRemove = mesocycle.weeksTotal - 1;

    if (weekToRemove < 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot remove: Must have at least 1 week'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get all workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

    // 1. Delete Week: Delete all workouts for the week to remove
    final workoutsToRemove = allWorkouts
        .where((w) => w.weekNumber == weekToRemove)
        .toList();
    for (var workout in workoutsToRemove) {
      await repository.delete(workout.id);
    }

    // 2. Shift Deload Week: Update deload week workouts to be one week earlier
    // Current deload is `mesocycle.weeksTotal`. New position is `weekToRemove` (which is weeksTotal - 1).
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == mesocycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      final updatedWorkout = workout.copyWith(weekNumber: weekToRemove);
      await repository.update(updatedWorkout);
    }

    // Update mesocycle weeks total and deload week
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    final updatedMesocycle = mesocycle.copyWith(
      weeksTotal: mesocycle.weeksTotal - 1,
      deloadWeek: mesocycle.deloadWeek - 1,
    );
    await mesocycleRepository.update(updatedMesocycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $weekToRemove removed'),
          backgroundColor: Colors.green,
        ),
      );

      // If selected week was removed or is now out of bounds, go to previous week
      if (_selectedWeek >= updatedMesocycle.weeksTotal) {
        setState(() {
          _selectedWeek =
              updatedMesocycle.weeksTotal; // Go to new last week (deload)
        });
        widget.onDaySelected(_selectedWeek, _selectedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate day names based on mesocycle start date
    // Note: Day names are now calculated per-week inside _buildWeekColumn

    // Calculate dynamic height based on number of workout days
    // Header height: 60, Week header: 60, Day button: 48, Day margin: 6
    // Total per day: 54 (48 + 6 margin)
    final headerHeight = 60.0;
    final weekHeaderHeight = 60.0;
    final dayButtonHeight = 48.0;
    final dayMargin = 6.0;
    final bottomPadding = 12.0;

    final calculatedHeight =
        headerHeight +
        weekHeaderHeight +
        (widget.mesocycle.daysPerWeek * (dayButtonHeight + dayMargin)) +
        bottomPadding;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: calculatedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: widget.mesocycle.weeksTotal > 1
                          ? () => _removeWeek()
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: () => _addWeek(),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
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

  Widget _buildWeekColumn(int weekNumber, bool isDeload) {
    // Calculate day names specific to THIS week
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final weekDayNames = List.generate(widget.mesocycle.daysPerWeek, (index) {
      final dayNumber = index + 1;

      // Check if there's a custom label for this day in THIS SPECIFIC week
      final weekDayWorkouts = widget.allWorkouts
          .where((w) => w.dayNumber == dayNumber && w.weekNumber == weekNumber)
          .toList();

      if (weekDayWorkouts.isNotEmpty) {
        // Check if all workouts for this day in this week have the same custom dayName
        final firstDayName = weekDayWorkouts.first.dayName;
        final allHaveSameName = weekDayWorkouts.every(
          (w) => w.dayName == firstDayName,
        );

        // Use custom dayName if all workouts in this week have the same non-null custom name
        if (allHaveSameName &&
            firstDayName != null &&
            firstDayName.isNotEmpty) {
          return firstDayName.substring(0, 3).toUpperCase();
        }
      }

      // Otherwise, calculate based on mesocycle start date
      if (widget.mesocycle.startDate != null) {
        // Get the day of week when mesocycle started (0 = Sunday, 6 = Saturday)
        final startDayOfWeek = widget.mesocycle.startDate!.weekday % 7;

        // Calculate which actual day this workout falls on
        final daysElapsed =
            ((weekNumber - 1) * widget.mesocycle.daysPerWeek) + (dayNumber - 1);

        // Calculate actual day of week
        final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;

        return defaultDayNames[actualDayOfWeek];
      }

      // Fallback to default
      return defaultDayNames[index % defaultDayNames.length];
    });

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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_calculateRIR(weekNumber)} RIR',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Day buttons - limit to available workout days only
          ...List.generate(weekDayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentWeek = weekNumber == widget.currentWeek;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                weekNumber == _selectedWeek && dayNumber == _selectedDay;

            // Check actual workout completion status from database
            final dayWorkouts = widget.allWorkouts
                .where(
                  (w) => w.weekNumber == weekNumber && w.dayNumber == dayNumber,
                )
                .toList();
            final isCompleted =
                dayWorkouts.isNotEmpty &&
                dayWorkouts.every((w) => w.status == WorkoutStatus.completed);

            // Determine background and text colors based on state
            Color backgroundColor;
            Color textColor;

            if (isCompleted) {
              backgroundColor = Colors.green;
              textColor = Colors.white;
            } else if (isCurrentWeek && isCurrentDay) {
              backgroundColor = Colors.red;
              textColor = Colors.white;
            } else {
              backgroundColor = Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest;
              textColor = Theme.of(context).colorScheme.onSurface;
            }

            return GestureDetector(
              onTap: () {
                widget.onDaySelected(weekNumber, dayNumber);
              },
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.orange, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  weekDayNames[dayIndex],
                  style: TextStyle(
                    color: textColor,
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
