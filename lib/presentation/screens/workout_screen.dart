import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/skins/skins.dart';
import '../../core/utils/day_sequence.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/workout.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/exercise_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/calendar_dropdown.dart';
import '../widgets/cycle_summary_dialog.dart';
import '../widgets/dialogs/add_exercise_dialog.dart';
import '../widgets/dialogs/workout_dialogs.dart';
import '../widgets/exercise_card_widget.dart';
import '../widgets/screen_background.dart';
import 'add_exercise_screen.dart';

/// Workout home screen - shows current/upcoming workouts
class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  // ---------------------------------------------------------------------------
  // PageView State for Swipe Navigation
  // ---------------------------------------------------------------------------

  PageController? _pageController;
  bool _isSwiping = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Controller Access
  // ---------------------------------------------------------------------------

  WorkoutHomeController get _controller =>
      ref.read(workoutHomeControllerProvider.notifier);

  WorkoutHomeState get _homeState => ref.watch(workoutHomeControllerProvider);

  void _togglePeriodSelector() {
    _controller.togglePeriodSelector();
  }

  void _selectDay(int period, int day) {
    _controller.selectDay(period, day);
  }

  /// Invalidate workout providers to trigger UI refresh
  /// This is needed because Drift streams only watch their own table,
  /// but nested data (exercises, sets) are in separate tables
  void _invalidateWorkoutProviders() {
    final trainingCycle = ref.read(currentTrainingCycleProvider);
    if (trainingCycle != null) {
      ref.invalidate(workoutsByTrainingCycleListProvider(trainingCycle.id));
      ref.invalidate(workoutsByTrainingCycleProvider(trainingCycle.id));
    }
    ref.invalidate(workoutsProvider);
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
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _toggleSetLog(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _addSetBelow(
    String workoutId,
    String exerciseId,
    int currentSetIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Auto-populate weight from previous performance (with suggestion)
    final historyService = ref.read(exerciseHistoryServiceProvider);
    final insertIndex = currentSetIndex + 1;
    final result = await historyService.getAutoPopulateWeightWithSuggestion(
      exercise.name,
      exercise.id,
      insertIndex,
      exercise.equipmentType,
    );
    final prevWeight = result.weight;

    // Create new set
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
      reps: '',
      setType: SetType.regular,
    );

    // Insert set after current index
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(insertIndex, newSet);

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
    _invalidateWorkoutProviders();
  }

  Future<void> _toggleSetSkip(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _deleteSet(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType type,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _addNote(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);

    final result = await showDialog<ExerciseNoteResult>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: exercise.notes,
        noteType: NoteType.exercise,
        initialPinned: exercise.isNotePinned,
      ),
    );

    if (result != null) {
      final updatedExercise = exercise.copyWith(
        notes: result.note.isEmpty ? null : result.note,
        isNotePinned: result.isPinned,
      );
      final updatedExercises = workout.exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);
      _invalidateWorkoutProviders();
    }
  }

  /// Get all exercises for the current day across all workouts (muscle groups)
  List<Exercise> _getAllExercisesForCurrentDay() {
    final trainingCycle = ref.read(currentTrainingCycleProvider);
    if (trainingCycle == null) return [];

    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );

    final displayPeriod = _homeState.selectedPeriod ?? 1;
    final displayDay = _homeState.selectedDay ?? 1;

    // Get workouts for current day
    final dayWorkouts = allWorkouts
        .where(
          (w) => w.periodNumber == displayPeriod && w.dayNumber == displayDay,
        )
        .toList();

    // Collect all exercises from all workouts for today
    final allExercises = <Exercise>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }
    return allExercises;
  }

  Future<void> _moveExerciseUp(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise up called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForCurrentDay();
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex == -1) {
      debugPrint('Exercise not found in day exercises');
      return;
    }

    if (currentIndex <= 0) {
      debugPrint('Exercise is already at the top');
      return;
    }

    final currentExercise = allExercises[currentIndex];
    final aboveExercise = allExercises[currentIndex - 1];

    debugPrint('Moving exercise "${currentExercise.name}" up');
    debugPrint('Swapping with "${aboveExercise.name}"');

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == aboveExercise.workoutId) {
      final workout = await repository.getById(currentExercise.workoutId);
      if (workout == null) return;

      final exercises = List<Exercise>.from(workout.exercises);
      final idx = exercises.indexWhere((e) => e.id == exerciseId);
      if (idx <= 0) return;

      final exercise = exercises.removeAt(idx);
      exercises.insert(idx - 1, exercise);

      for (var i = 0; i < exercises.length; i++) {
        exercises[i] = exercises[i].copyWith(orderIndex: i);
      }

      await repository.update(workout.copyWith(exercises: exercises));
    } else {
      // Exercises are in different workouts - need to swap between workouts
      final currentWorkout = await repository.getById(
        currentExercise.workoutId,
      );
      final aboveWorkout = await repository.getById(aboveExercise.workoutId);
      if (currentWorkout == null || aboveWorkout == null) return;

      // Remove current exercise from its workout
      var currentExercises = List<Exercise>.from(currentWorkout.exercises);
      currentExercises.removeWhere((e) => e.id == currentExercise.id);

      // Remove above exercise from its workout
      var aboveExercises = List<Exercise>.from(aboveWorkout.exercises);
      aboveExercises.removeWhere((e) => e.id == aboveExercise.id);

      // Add current exercise to above workout (with updated workoutId)
      final movedCurrentExercise = currentExercise.copyWith(
        workoutId: aboveWorkout.id,
      );
      aboveExercises.add(movedCurrentExercise);

      // Add above exercise to current workout (with updated workoutId)
      final movedAboveExercise = aboveExercise.copyWith(
        workoutId: currentWorkout.id,
      );
      currentExercises.add(movedAboveExercise);

      // Renumber exercises in both workouts
      for (var i = 0; i < currentExercises.length; i++) {
        currentExercises[i] = currentExercises[i].copyWith(orderIndex: i);
      }
      for (var i = 0; i < aboveExercises.length; i++) {
        aboveExercises[i] = aboveExercises[i].copyWith(orderIndex: i);
      }

      await repository.update(
        currentWorkout.copyWith(exercises: currentExercises),
      );
      await repository.update(aboveWorkout.copyWith(exercises: aboveExercises));
    }

    _invalidateWorkoutProviders();
    debugPrint('Exercise moved up successfully');
  }

  Future<void> _moveExerciseDown(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise down called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForCurrentDay();
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex == -1) {
      debugPrint('Exercise not found in day exercises');
      return;
    }

    if (currentIndex >= allExercises.length - 1) {
      debugPrint('Exercise is already at the bottom');
      return;
    }

    final currentExercise = allExercises[currentIndex];
    final belowExercise = allExercises[currentIndex + 1];

    debugPrint('Moving exercise "${currentExercise.name}" down');
    debugPrint('Swapping with "${belowExercise.name}"');

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == belowExercise.workoutId) {
      final workout = await repository.getById(currentExercise.workoutId);
      if (workout == null) return;

      final exercises = List<Exercise>.from(workout.exercises);
      final idx = exercises.indexWhere((e) => e.id == exerciseId);
      if (idx == -1 || idx >= exercises.length - 1) return;

      final exercise = exercises.removeAt(idx);
      exercises.insert(idx + 1, exercise);

      for (var i = 0; i < exercises.length; i++) {
        exercises[i] = exercises[i].copyWith(orderIndex: i);
      }

      await repository.update(workout.copyWith(exercises: exercises));
    } else {
      // Exercises are in different workouts - need to swap between workouts
      final currentWorkout = await repository.getById(
        currentExercise.workoutId,
      );
      final belowWorkout = await repository.getById(belowExercise.workoutId);
      if (currentWorkout == null || belowWorkout == null) return;

      // Remove current exercise from its workout
      var currentExercises = List<Exercise>.from(currentWorkout.exercises);
      currentExercises.removeWhere((e) => e.id == currentExercise.id);

      // Remove below exercise from its workout
      var belowExercises = List<Exercise>.from(belowWorkout.exercises);
      belowExercises.removeWhere((e) => e.id == belowExercise.id);

      // Add current exercise to below workout (with updated workoutId)
      final movedCurrentExercise = currentExercise.copyWith(
        workoutId: belowWorkout.id,
      );
      belowExercises.insert(0, movedCurrentExercise);

      // Add below exercise to current workout (with updated workoutId)
      final movedBelowExercise = belowExercise.copyWith(
        workoutId: currentWorkout.id,
      );
      currentExercises.add(movedBelowExercise);

      // Renumber exercises in both workouts
      for (var i = 0; i < currentExercises.length; i++) {
        currentExercises[i] = currentExercises[i].copyWith(orderIndex: i);
      }
      for (var i = 0; i < belowExercises.length; i++) {
        belowExercises[i] = belowExercises[i].copyWith(orderIndex: i);
      }

      await repository.update(
        currentWorkout.copyWith(exercises: currentExercises),
      );
      await repository.update(belowWorkout.copyWith(exercises: belowExercises));
    }

    _invalidateWorkoutProviders();
    debugPrint('Exercise moved down successfully');
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    // Get the workout and exercise from repository (not provider which may be stale)
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    // Navigate to add exercise screen with replace mode
    // The AddExerciseScreen will handle the replacement when a new exercise is selected
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddExerciseScreen(
            trainingCycleId: workout.trainingCycleId,
            workoutId: workout.id,
            initialMuscleGroup: exercise.muscleGroup,
            replaceExerciseId: exerciseId,
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
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Auto-populate weight from previous performance (with suggestion)
    final historyService = ref.read(exerciseHistoryServiceProvider);
    final result = await historyService.getAutoPopulateWeightWithSuggestion(
      exercise.name,
      exercise.id,
      exercise.sets.length,
      exercise.equipmentType,
    );
    final prevWeight = result.weight;

    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
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
    _invalidateWorkoutProviders();
  }

  Future<void> _skipExerciseSets(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    _invalidateWorkoutProviders();
  }

  Future<void> _deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
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
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final trainingCycle = ref.read(currentTrainingCycleProvider);

    if (trainingCycle == null) return;

    // Mark ALL workouts for this day as completed
    final now = DateTime.now();
    final exerciseRepository = ref.read(exerciseRepositoryProvider);
    for (final workout in workouts) {
      // Update lastPerformed on exercises that have logged sets
      final updatedExercises = workout.exercises.map((exercise) {
        if (exercise.sets.any((s) => s.isLogged)) {
          return exercise.copyWith(lastPerformed: now);
        }
        return exercise;
      }).toList();

      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: now,
        exercises: updatedExercises,
      );
      await repository.update(updatedWorkout);

      // Also update individual exercise records in the database
      for (final exercise in updatedExercises) {
        if (exercise.sets.any((s) => s.isLogged)) {
          await exerciseRepository.update(exercise);
        }
      }
    }

    // Check if ALL workouts in the trainingCycle are now completed
    // We need to verify that every period/day combination has at least one completed workout
    final allWorkouts = await repository.getByTrainingCycleId(trainingCycle.id);

    // Build a set of completed period/day combinations
    final completedDays = <String>{};
    for (final workout in allWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        completedDays.add('${workout.periodNumber}-${workout.dayNumber}');
      }
    }

    // Check if all expected period/day combinations are completed
    final totalPeriods = trainingCycle.periodsTotal;
    final daysPerPeriod = trainingCycle.daysPerPeriod;
    bool allCompleted = true;

    for (int period = 1; period <= totalPeriods; period++) {
      for (int day = 1; day <= daysPerPeriod; day++) {
        if (!completedDays.contains('$period-$day')) {
          allCompleted = false;
          break;
        }
      }
      if (!allCompleted) break;
    }

    if (allCompleted) {
      // Complete the trainingCycle
      await trainingCycleRepository.update(trainingCycle.complete());

      if (mounted) {
        final cycleTerm = ref.read(trainingCycleTermProvider);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$cycleTerm Completed!'),
            content: Text(
              'Congratulations! You have finished all workouts in this $cycleTerm.',
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
    int nextPeriod = firstWorkout.periodNumber;

    // Check if we need to move to next period
    if (nextDay > trainingCycle.daysPerPeriod) {
      nextDay = 1;
      nextPeriod++;
    }

    // Update selected day via controller
    _controller.navigateToNextDay(nextPeriod, nextDay);
  }

  @override
  Widget build(BuildContext context) {
    final currentTrainingCycle = ref.watch(currentTrainingCycleProvider);

    // Debug logging
    debugPrint('=== WorkoutHomeScreen Debug ===');
    debugPrint('Current trainingCycle: ${currentTrainingCycle?.name}');
    debugPrint('Start date: ${currentTrainingCycle?.startDate}');
    debugPrint('Status: ${currentTrainingCycle?.status}');

    // If there's a current trainingCycle, show today's workout
    if (currentTrainingCycle != null &&
        currentTrainingCycle.startDate != null) {
      // Get workouts from the workout repository — wait for loading to finish
      // before building the PageView to avoid initializing at page 0 then
      // animating to the correct page when data arrives.
      final cycleWorkoutsAsync = ref.watch(
        workoutsByTrainingCycleProvider(currentTrainingCycle.id),
      );
      if (cycleWorkoutsAsync.isLoading) {
        return _buildEmptyState(context, currentTrainingCycle.name, '');
      }
      final allWorkouts = cycleWorkoutsAsync.asData?.value ?? [];

      debugPrint('Total workouts from repository: ${allWorkouts.length}');
      for (var workout in allWorkouts.take(5)) {
        debugPrint(
          '  Period ${workout.periodNumber} Day ${workout.dayNumber}: ${workout.exercises.length} exercises (ID: ${workout.id})',
        );
        for (var ex in workout.exercises) {
          debugPrint('    - ${ex.name}');
        }
      }

      final currentPeriod = currentTrainingCycle.getCurrentPeriod();
      debugPrint('Current period: $currentPeriod');

      if (currentPeriod == null) {
        // TrainingCycle hasn't started yet or has ended
        return _buildEmptyState(
          context,
          'TrainingCycle Not Active',
          'The trainingCycle is scheduled for a future date or has ended',
        );
      }

      // Use selected period/day if available, otherwise find first incomplete workout
      int displayPeriod;
      int displayDay;

      if (_homeState.selectedPeriod != null && _homeState.selectedDay != null) {
        // User has manually selected a specific workout (or we locked it in)
        displayPeriod = _homeState.selectedPeriod!;
        displayDay = _homeState.selectedDay!;
      } else {
        // Find first incomplete workout
        final firstIncomplete = findFirstIncompleteWorkout(allWorkouts);
        if (firstIncomplete != null) {
          displayPeriod = firstIncomplete.$1;
          displayDay = firstIncomplete.$2;
        } else {
          // All workouts complete, fall back to current period/day
          displayPeriod = currentPeriod;
          displayDay = (() {
            final daysSinceStart = DateTime.now()
                .difference(currentTrainingCycle.startDate!)
                .inDays;
            final daysSincePeriodStart =
                daysSinceStart % currentTrainingCycle.daysPerPeriod;
            return (daysSincePeriodStart + 1).clamp(
              1,
              currentTrainingCycle.daysPerPeriod,
            );
          })();
        }

        // Lock in the selected day so we don't auto-navigate on rebuild
        // This ensures user stays on current day until they press "Finish Workout"
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selectDay(displayPeriod, displayDay);
        });
      }

      debugPrint('Display period: $displayPeriod, Display day: $displayDay');

      // Build day sequence for swipe navigation
      final daySequence = buildDaySequence(
        currentTrainingCycle.periodsTotal,
        currentTrainingCycle.daysPerPeriod,
      );
      final currentPageIndex =
          findDayIndex(daySequence, displayPeriod, displayDay) ?? 0;

      // Initialize or sync PageController
      if (_pageController == null) {
        _pageController = PageController(initialPage: currentPageIndex);
      } else if (!_isSwiping && _pageController!.hasClients) {
        final currentPage = _pageController!.page?.round() ?? 0;
        if (currentPage != currentPageIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController?.hasClients == true) {
              _pageController!.animateToPage(
                currentPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
      _isSwiping = false;

      // Get workouts for the currently displayed day (for AppBar/FINISH)
      final todaysWorkouts = allWorkouts
          .where(
            (w) =>
                w.periodNumber == displayPeriod &&
                w.dayNumber == displayDay,
          )
          .toList();

      // Compute day name for AppBar
      final dayName = calculateDayName(
        workouts: todaysWorkouts,
        startDate: currentTrainingCycle.startDate,
        daysPerPeriod: currentTrainingCycle.daysPerPeriod,
        displayPeriod: displayPeriod,
        displayDay: displayDay,
      );

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const AppIconWidget(),
            leadingWidth: kToolbarHeight + 12,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTrainingCycle.name.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PERIOD $displayPeriod DAY $displayDay $dayName',
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
                onPressed: _togglePeriodSelector,
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
              if (todaysWorkouts.isNotEmpty)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showWorkoutMenu(
                      context,
                      currentTrainingCycle,
                      todaysWorkouts,
                    ),
                  ),
                ),
            ],
          ),
          body: ScreenBackground.workout(
            child: Stack(
              children: [
                // Swipeable day content
                PageView.builder(
                  controller: _pageController,
                  itemCount: daySequence.length,
                  onPageChanged: (index) {
                    _isSwiping = true;
                    FocusScope.of(context).unfocus();
                    final pos = daySequence[index];
                    _selectDay(pos.period, pos.day);
                  },
                  itemBuilder: (context, index) {
                    final pos = daySequence[index];
                    return _buildDayPageContent(
                      context,
                      currentTrainingCycle,
                      allWorkouts,
                      pos.period,
                      pos.day,
                    );
                  },
                ),

                // Calendar dropdown overlay
                if (_homeState.showPeriodSelector) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _controller.hidePeriodSelector(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CalendarDropdown(
                      trainingCycle: currentTrainingCycle,
                      currentPeriod: currentPeriod,
                      currentDay: displayDay,
                      selectedPeriod: displayPeriod,
                      selectedDay: displayDay,
                      allWorkouts: allWorkouts,
                      onDaySelected: _selectDay,
                    ),
                  ),
                ],

                // FINISH WORKOUT button
                if (todaysWorkouts.isNotEmpty &&
                    !todaysWorkouts.every((w) => w.isCompleted) &&
                    todaysWorkouts.every((w) => _isWorkoutComplete(w)))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Semantics(
                          label: 'Finish workout',
                          button: true,
                          child: ElevatedButton(
                            onPressed: () => _finishWorkout(todaysWorkouts),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.successColor,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
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
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // If no current trainingCycle, show empty state
    return _buildEmptyState(
      context,
      'No Active TrainingCycle',
      'Create and start a trainingCycle to begin',
    );
  }

  /// Build the content for a single day page in the PageView.
  ///
  /// Returns the exercise list if workouts exist for this day,
  /// or an empty state with an "Add Exercise" button.
  Widget _buildDayPageContent(
    BuildContext context,
    dynamic trainingCycle,
    List<Workout> allWorkouts,
    int period,
    int day,
  ) {
    final dayWorkouts = allWorkouts
        .where((w) => w.periodNumber == period && w.dayNumber == day)
        .toList();

    if (dayWorkouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Exercises Scheduled',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'No exercises found for Period $period, Day $day',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _addExerciseForDay(
                trainingCycle.id,
                period,
                day,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ],
        ),
      );
    }

    // Collect all exercises from all workouts for this day
    final allExercises = <dynamic>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }

    if (allExercises.isEmpty) {
      return Center(
        child: Text(
          'No exercises',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 24),
      itemCount: allExercises.length,
      separatorBuilder: (context, index) {
        final currentMuscleGroup = allExercises[index].muscleGroup;
        final nextMuscleGroup = index + 1 < allExercises.length
            ? allExercises[index + 1].muscleGroup
            : null;
        final isSameMuscleGroup = currentMuscleGroup == nextMuscleGroup;

        return isSameMuscleGroup
            ? Container(
                height: 1,
                color: Theme.of(context).dividerColor,
              )
            : const SizedBox(height: 32);
      },
      itemBuilder: (context, index) {
        final exercise = allExercises[index];
        final showMuscleGroupBadge = index == 0 ||
            allExercises[index - 1].muscleGroup != exercise.muscleGroup;

        final periodRir = calculateRIR(
          period,
          trainingCycle.recoveryPeriod,
        );

        return ExerciseCardWidget(
          key: ValueKey(
            '${exercise.id}_${exercise.sets.length}_${exercise.sets.map((s) => s.id).join(",")}_${ref.watch(useMetricProvider)}',
          ),
          exercise: exercise,
          showMuscleGroupBadge: showMuscleGroupBadge,
          targetRir: periodRir,
          weightUnit: ref.watch(weightUnitProvider),
          useMetric: ref.watch(useMetricProvider),
          showMoveDown: true,
          isFirstExercise: index == 0,
          isLastExercise: index == allExercises.length - 1,
          callbacks: ExerciseCardCallbacks(
            onAddNote: (id) => _addNote(exercise.workoutId, id),
            onMoveUp: (id) => _moveExerciseUp(exercise.workoutId, id),
            onMoveDown: (id) => _moveExerciseDown(exercise.workoutId, id),
            onReplace: (id) => _replaceExercise(exercise.workoutId, id),
            onJointPain: (id) => _logJointPain(exercise.workoutId, id),
            onAddSet: (id) =>
                _addSetToExercise(exercise.workoutId, id),
            onSkipSets: (id) =>
                _skipExerciseSets(exercise.workoutId, id),
            onDelete: (id) =>
                _deleteExercise(exercise.workoutId, id),
            onAddSetBelow: (i) => _addSetBelow(
              exercise.workoutId, exercise.id, i,
            ),
            onToggleSetSkip: (i) => _toggleSetSkip(
              exercise.workoutId, exercise.id, i,
            ),
            onDeleteSet: (i) => _deleteSet(
              exercise.workoutId, exercise.id, i,
            ),
            onUpdateSetType: (i, type) => _updateSetType(
              exercise.workoutId, exercise.id, i, type,
            ),
            onUpdateSetWeight: (i, v) => _updateSetWeight(
              exercise.workoutId, exercise.id, i, v,
            ),
            onUpdateSetReps: (i, v) => _updateSetReps(
              exercise.workoutId, exercise.id, i, v,
            ),
            onToggleSetLog: (i) => _toggleSetLog(
              exercise.workoutId, exercise.id, i,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: ScreenBackground.workout(
        child: Center(
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
      ),
    );
  }

  void _showWorkoutMenu(
    BuildContext context,
    dynamic trainingCycle,
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
        // TRAINING CYCLE Section
        _buildMenuHeader('TRAINING CYCLE'),
        _buildMenuItem(
          icon: Icons.edit_note,
          text: 'Note',
          onTap: () => _viewTrainingCycleNotes(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: 'Summary',
          onTap: () => _showTrainingCycleSummary(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.edit,
          text: 'Rename',
          onTap: () => _renameTrainingCycle(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.stop_circle_outlined,
          text: 'End ${ref.watch(trainingCycleTermProvider)}',
          onTap: () => _endTrainingCycle(trainingCycle),
          color: context.errorColor,
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
          onTap: () => _clearAllDayNames(trainingCycle),
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
    Color? color,
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
                ? (color ?? Theme.of(context).iconTheme.color)
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
                  ? (color ?? Theme.of(context).textTheme.bodyMedium?.color)
                  : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  // Training Cycle actions
  Future<void> _viewTrainingCycleNotes(dynamic trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentNote = trainingCycle.notes as String?;

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

  void _showTrainingCycleSummary(dynamic trainingCycle) {
    showDialog(
      context: context,
      builder: (context) => CycleSummaryDialog(trainingCycle: trainingCycle),
    );
  }

  Future<void> _renameTrainingCycle(dynamic trainingCycle) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RenameTrainingCycleDialog(initialName: trainingCycle.name),
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
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error renaming trainingCycle: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _endTrainingCycle(dynamic trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End $cycleTerm'),
        content: Text(
          'Are you sure you want to end "${trainingCycle.name}"? This will mark it as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('END ${cycleTerm.toUpperCase()}'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(
          status: TrainingCycleStatus.completed,
          endDate: DateTime.now(),
        );
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${trainingCycle.name}" completed'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ending trainingCycle: $e'),
              backgroundColor: context.errorColor,
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

  Future<void> _relabelWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final workout = workouts.first;
    final currentLabel = workout.dayName ?? 'Day ${workout.dayNumber}';

    // Debug logging to understand what's being passed in
    debugPrint('=== RELABEL DEBUG ===');
    debugPrint('Workouts passed in: ${workouts.length}');
    for (var w in workouts) {
      debugPrint(
        '  - Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
      );
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
          // Update all workouts with the same day number in this trainingCycle
          final allWorkouts = ref.read(
            workoutsByTrainingCycleListProvider(workout.trainingCycleId),
          );
          final workoutsToUpdate = allWorkouts
              .where((w) => w.dayNumber == workout.dayNumber)
              .toList();

          debugPrint(
            'Updating ${workoutsToUpdate.length} workouts (apply to all)',
          );
          for (final w in workoutsToUpdate) {
            debugPrint(
              '  - Updating Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
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
                backgroundColor: context.successColor,
              ),
            );
          }
        } else {
          // Update only the current workout(s) for this specific period and day
          // The workouts list passed in contains ALL workouts for this day across all periods
          // We need to filter to only the current period
          final currentPeriodNumber = workouts.first.periodNumber;
          final currentPeriodWorkouts = workouts
              .where((w) => w.periodNumber == currentPeriodNumber)
              .toList();

          debugPrint(
            'Updating ${currentPeriodWorkouts.length} workouts (current period only)',
          );
          for (final w in currentPeriodWorkouts) {
            debugPrint(
              '  - Updating Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
            );
            final updatedWorkout = w.copyWith(dayName: result.label);
            await repository.update(updatedWorkout);
          }

          // Verify the update by checking all workouts again
          debugPrint('=== VERIFICATION ===');
          final allWorkoutsAfter = ref.read(
            workoutsByTrainingCycleListProvider(workout.trainingCycleId),
          );

          // Show ALL workouts grouped by period
          debugPrint('All workouts in trainingCycle after update:');
          for (int period = 1; period <= 5; period++) {
            final periodWorkouts = allWorkoutsAfter
                .where((w) => w.periodNumber == period)
                .toList();
            if (periodWorkouts.isNotEmpty) {
              debugPrint('  Period $period:');
              for (var w in periodWorkouts) {
                debugPrint(
                  '    - Day ${w.dayNumber}, dayName: "${w.dayName}", ID: ${w.id.substring(0, 8)}...',
                );
              }
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Label updated'),
                backgroundColor: context.successColor,
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
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllDayNames(dynamic trainingCycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Day Labels'),
        content: const Text(
          'This will remove all custom day labels from workouts in this trainingCycle. '
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
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final allWorkouts = ref.read(
          workoutsByTrainingCycleListProvider(trainingCycle.id),
        );

        debugPrint('Clearing dayName from ${allWorkouts.length} workouts');

        for (final workout in allWorkouts) {
          if (workout.dayName != null) {
            final updatedWorkout = workout.copyWith(dayName: null);
            await repository.update(updatedWorkout);
            debugPrint(
              '  Cleared: Period ${workout.periodNumber}, Day ${workout.dayNumber}',
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('All day labels cleared'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error clearing day names: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing labels: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  void _addExerciseToWorkout(List<Workout> workouts) {
    if (workouts.isEmpty) return;
    showAddExerciseDialogFromWorkouts(
      context: context,
      ref: ref,
      workouts: workouts,
    );
  }

  /// Add exercise to a day that has no workouts yet
  void _addExerciseForDay(
    String trainingCycleId,
    int periodNumber,
    int dayNumber,
  ) {
    showAddExerciseDialog(
      context: context,
      ref: ref,
      workouts: [], // No existing workouts
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
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

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Workout reset'),
                    backgroundColor: this.context.successColor,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Error resetting workout: $e'),
                    backgroundColor: this.context.errorColor,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _skipWorkout(List<Workout> workouts) {
    debugPrint('Skip workout');
  }
}
