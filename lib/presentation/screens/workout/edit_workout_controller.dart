import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/workout_providers.dart';

/// Controller for the EditWorkoutScreen
///
/// Handles business logic for managing workouts, mirroring periods,
/// and starting trainingCycles.
class EditWorkoutController {
  final Ref ref;
  final String trainingCycleId;

  EditWorkoutController(this.ref, this.trainingCycleId);

  /// Invalidate workout providers to trigger UI refresh
  /// This is needed because Drift streams only watch their own table,
  /// but nested data (exercises, sets) are in separate tables
  void _invalidateWorkoutProviders() {
    ref.invalidate(workoutsProvider);
    ref.invalidate(workoutsByTrainingCycleProvider(trainingCycleId));
  }

  /// Mirror Period 1 workouts to the selected period
  Future<void> mirrorPeriod1ToSelectedPeriod(
    TrainingCycle trainingCycle,
    int selectedPeriod,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycleId),
    );

    // Get all Period 1 workouts
    final period1Workouts = allWorkouts
        .where((w) => w.periodNumber == 1)
        .toList();

    if (period1Workouts.isEmpty) {
      throw Exception('No workouts found in Period 1');
    }

    // Delete existing workouts for the selected period
    final existingWorkouts = allWorkouts
        .where((w) => w.periodNumber == selectedPeriod)
        .toList();
    for (final workout in existingWorkouts) {
      await repository.delete(workout.id);
    }

    // Create copies of Period 1 workouts for the selected period
    for (final workout in period1Workouts) {
      final newWorkoutId = const Uuid().v4();
      final newWorkout = Workout(
        id: newWorkoutId,
        trainingCycleId: trainingCycle.id,
        periodNumber: selectedPeriod,
        dayNumber: workout.dayNumber,
        label: workout.label,
        status: WorkoutStatus.incomplete,
        exercises: workout.exercises
            .map(
              (exercise) => exercise.copyWith(
                id: const Uuid().v4(), // New exercise ID for the new period
                workoutId: newWorkoutId, // Update to point to the new workout!
                sets: exercise.sets
                    .map(
                      (set) => set.copyWith(
                        id: const Uuid().v4(), // New set ID
                        isLogged: false, // Reset logged status
                        weight: null, // Reset weight
                        reps: '', // Reset reps
                        isSkipped: false, // Reset skipped status
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );
      await repository.create(newWorkout);
    }
  }

  /// Delete a muscle group (workout)
  Future<void> deleteMuscleGroup(String workoutId) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.delete(workoutId);
  }

  /// Start the trainingCycle
  Future<void> startTrainingCycle(TrainingCycle trainingCycle) async {
    final repository = ref.read(trainingCycleRepositoryProvider);
    await repository.setAsCurrent(trainingCycle.id);
  }

  /// Create workouts for selected muscle groups
  Future<void> createWorkoutsForMuscleGroups({
    required List<MuscleGroup> muscleGroups,
    required int periodNumber,
    required int dayNumber,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    for (final muscleGroup in muscleGroups) {
      final newWorkout = Workout(
        id: const Uuid().v4(),
        trainingCycleId: trainingCycleId,
        periodNumber: periodNumber,
        dayNumber: dayNumber,
        label: muscleGroup.displayName,
        status: WorkoutStatus.incomplete,
      );

      await repository.create(newWorkout);
    }
  }

  /// Add a set to an exercise
  Future<void> addSetToExercise(
    String workoutId,
    String exerciseId,
    ExerciseSet set,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final updatedExercise = exercise.addSet(set);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
  }

  /// Remove a set from an exercise
  Future<void> removeSetFromExercise(
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
    final updatedExercise = exercise.removeSet(setIndex);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
  }

  /// Delete an exercise from a workout
  Future<void> deleteExercise(String workoutId, String exerciseId) async {
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

  /// Get all exercises for a specific day across all workouts (muscle groups)
  List<Exercise> _getAllExercisesForDay(int periodNumber, int dayNumber) {
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycleId),
    );

    // Get workouts for the specified day
    final dayWorkouts = allWorkouts
        .where(
          (w) => w.periodNumber == periodNumber && w.dayNumber == dayNumber,
        )
        .toList();

    // Collect all exercises from all workouts for that day
    final allExercises = <Exercise>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }
    return allExercises;
  }

  /// Move an exercise up in the day's workout (across all muscle groups)
  Future<void> moveExerciseUp(
    String workoutId,
    String exerciseId, {
    int? periodNumber,
    int? dayNumber,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    // Get the workout to find period/day if not provided
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final period = periodNumber ?? workout.periodNumber;
    final day = dayNumber ?? workout.dayNumber;

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForDay(period, day);
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex <= 0) return; // Already at top or not found

    final currentExercise = allExercises[currentIndex];
    final aboveExercise = allExercises[currentIndex - 1];

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == aboveExercise.workoutId) {
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
  }

  /// Move an exercise down in the day's workout (across all muscle groups)
  Future<void> moveExerciseDown(
    String workoutId,
    String exerciseId, {
    int? periodNumber,
    int? dayNumber,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    // Get the workout to find period/day if not provided
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final period = periodNumber ?? workout.periodNumber;
    final day = dayNumber ?? workout.dayNumber;

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForDay(period, day);
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex == -1 || currentIndex >= allExercises.length - 1) {
      return; // Not found or already at bottom
    }

    final currentExercise = allExercises[currentIndex];
    final belowExercise = allExercises[currentIndex + 1];

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == belowExercise.workoutId) {
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
  }

  /// Insert a set at a specific index
  Future<void> insertSetAtIndex(
    String workoutId,
    String exerciseId,
    int index,
    ExerciseSet newSet,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(index, newSet);

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

  /// Update a set's type
  Future<void> updateSetType(
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

  /// Update a set's reps
  Future<void> updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String reps,
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

    final updatedSet = exercise.sets[setIndex].copyWith(reps: reps);
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

  /// Add a period to the trainingCycle (inserted before the recovery period)
  Future<void> addPeriod(TrainingCycle trainingCycle) async {
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycleId),
    );

    final newPeriodsTotal = trainingCycle.periodsTotal + 1;
    final oldRecoveryPeriod = trainingCycle.recoveryPeriod;
    final newRecoveryPeriod =
        newPeriodsTotal; // Recovery is always the last period

    // First, update all workouts that are in the recovery period to be in the new recovery period
    final recoveryWorkouts = allWorkouts
        .where((w) => w.periodNumber == oldRecoveryPeriod)
        .toList();
    for (final workout in recoveryWorkouts) {
      final updatedWorkout = Workout(
        id: workout.id,
        trainingCycleId: workout.trainingCycleId,
        periodNumber: newRecoveryPeriod,
        dayNumber: workout.dayNumber,
        label: workout.label,
        status: workout.status,
        exercises: workout.exercises,
        notes: workout.notes,
      );
      await workoutRepo.update(updatedWorkout);
    }

    // Update the trainingCycle with new periods total and recovery period
    final updatedTrainingCycle = trainingCycle.copyWith(
      periodsTotal: newPeriodsTotal,
      recoveryPeriod: newRecoveryPeriod,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Remove a period from the trainingCycle
  Future<void> removePeriod(
    TrainingCycle trainingCycle, {
    required bool removeRecovery,
  }) async {
    if (trainingCycle.periodsTotal <= 2) {
      throw Exception('Cannot have fewer than 2 periods');
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycleId),
    );

    final oldRecoveryPeriod = trainingCycle.recoveryPeriod;
    final lastNonRecoveryPeriod = oldRecoveryPeriod - 1;

    if (removeRecovery) {
      // Remove the recovery period - delete recovery workouts, keep everything else
      final recoveryWorkouts = allWorkouts
          .where((w) => w.periodNumber == oldRecoveryPeriod)
          .toList();
      for (final workout in recoveryWorkouts) {
        await workoutRepo.delete(workout.id);
      }

      // Update trainingCycle: reduce periods, recovery is now the last period
      final newPeriodsTotal = trainingCycle.periodsTotal - 1;
      final updatedTrainingCycle = trainingCycle.copyWith(
        periodsTotal: newPeriodsTotal,
        recoveryPeriod: newPeriodsTotal,
      );
      await trainingCycleRepo.update(updatedTrainingCycle);
    } else {
      // Remove the last non-recovery period - delete those workouts,
      // then move recovery workouts down by 1 period
      final lastPeriodWorkouts = allWorkouts
          .where((w) => w.periodNumber == lastNonRecoveryPeriod)
          .toList();
      for (final workout in lastPeriodWorkouts) {
        await workoutRepo.delete(workout.id);
      }

      // Move recovery workouts to the previous period number
      final recoveryWorkouts = allWorkouts
          .where((w) => w.periodNumber == oldRecoveryPeriod)
          .toList();
      for (final workout in recoveryWorkouts) {
        final updatedWorkout = Workout(
          id: workout.id,
          trainingCycleId: workout.trainingCycleId,
          periodNumber: lastNonRecoveryPeriod,
          dayNumber: workout.dayNumber,
          label: workout.label,
          status: workout.status,
          exercises: workout.exercises,
          notes: workout.notes,
        );
        await workoutRepo.update(updatedWorkout);
      }

      // Update trainingCycle
      final newPeriodsTotal = trainingCycle.periodsTotal - 1;
      final updatedTrainingCycle = trainingCycle.copyWith(
        periodsTotal: newPeriodsTotal,
        recoveryPeriod: newPeriodsTotal,
      );
      await trainingCycleRepo.update(updatedTrainingCycle);
    }
  }

  /// Add a day to the trainingCycle
  Future<void> addDay(TrainingCycle trainingCycle) async {
    if (trainingCycle.daysPerPeriod >= AppConstants.maxDaysPerPeriod) {
      throw Exception(
        'Cannot have more than ${AppConstants.maxDaysPerPeriod} days per period',
      );
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final newDaysPerPeriod = trainingCycle.daysPerPeriod + 1;

    final updatedTrainingCycle = trainingCycle.copyWith(
      daysPerPeriod: newDaysPerPeriod,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Remove a day from the trainingCycle
  Future<void> removeDay(TrainingCycle trainingCycle) async {
    if (trainingCycle.daysPerPeriod <= 1) {
      throw Exception('Cannot have fewer than 1 day per period');
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycleId),
    );

    final dayToRemove = trainingCycle.daysPerPeriod;

    // Delete all workouts for this day across all periods
    final workoutsToDelete = allWorkouts
        .where((w) => w.dayNumber == dayToRemove)
        .toList();
    for (final workout in workoutsToDelete) {
      await workoutRepo.delete(workout.id);
    }

    // Update the trainingCycle
    final newDaysPerPeriod = trainingCycle.daysPerPeriod - 1;
    final updatedTrainingCycle = trainingCycle.copyWith(
      daysPerPeriod: newDaysPerPeriod,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Update the recovery period type
  Future<void> updateRecoveryPeriodType(
    TrainingCycle trainingCycle,
    RecoveryPeriodType newType,
  ) async {
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      recoveryPeriodType: newType,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }
}

/// Provider for the EditWorkoutController
final editWorkoutControllerProvider =
    Provider.family<EditWorkoutController, String>(
      (ref, trainingCycleId) => EditWorkoutController(ref, trainingCycleId),
    );
