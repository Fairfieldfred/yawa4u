import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/repository_providers.dart';
import '../../../domain/providers/workout_providers.dart';

/// Controller for the EditWorkoutScreen
///
/// Handles business logic for managing workouts, mirroring weeks,
/// and starting trainingCycles.
class EditWorkoutController {
  final Ref ref;
  final String trainingCycleId;

  EditWorkoutController(this.ref, this.trainingCycleId);

  /// Mirror Week 1 workouts to the selected week
  Future<void> mirrorWeek1ToSelectedWeek(
    TrainingCycle trainingCycle,
    int selectedWeek,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
    );

    // Get all Week 1 workouts
    final week1Workouts = allWorkouts.where((w) => w.weekNumber == 1).toList();

    if (week1Workouts.isEmpty) {
      throw Exception('No workouts found in Week 1');
    }

    // Delete existing workouts for the selected week
    final existingWorkouts = allWorkouts
        .where((w) => w.weekNumber == selectedWeek)
        .toList();
    for (final workout in existingWorkouts) {
      await repository.delete(workout.id);
    }

    // Create copies of Week 1 workouts for the selected week
    for (final workout in week1Workouts) {
      final newWorkoutId = const Uuid().v4();
      final newWorkout = Workout(
        id: newWorkoutId,
        trainingCycleId: trainingCycle.id,
        weekNumber: selectedWeek,
        dayNumber: workout.dayNumber,
        label: workout.label,
        status: WorkoutStatus.incomplete,
        exercises: workout.exercises
            .map(
              (exercise) => exercise.copyWith(
                id: const Uuid().v4(), // New exercise ID for the new week
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
    required int weekNumber,
    required int dayNumber,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    for (final muscleGroup in muscleGroups) {
      final newWorkout = Workout(
        id: const Uuid().v4(),
        trainingCycleId: trainingCycleId,
        weekNumber: weekNumber,
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
    final workout = repository.getById(workoutId);
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
  }

  /// Remove a set from an exercise
  Future<void> removeSetFromExercise(
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
    final updatedExercise = exercise.removeSet(setIndex);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  /// Delete an exercise from a workout
  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);

    await repository.update(updatedWorkout);
  }

  /// Insert a set at a specific index
  Future<void> insertSetAtIndex(
    String workoutId,
    String exerciseId,
    int index,
    ExerciseSet newSet,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
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
  }

  /// Update a set's type
  Future<void> updateSetType(
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

  /// Update a set's reps
  Future<void> updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String reps,
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

    final updatedSet = exercise.sets[setIndex].copyWith(reps: reps);
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  /// Add a week to the trainingCycle (inserted before the deload week)
  Future<void> addWeek(TrainingCycle trainingCycle) async {
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
    );

    final newWeeksTotal = trainingCycle.weeksTotal + 1;
    final oldDeloadWeek = trainingCycle.deloadWeek;
    final newDeloadWeek = newWeeksTotal; // Deload is always the last week

    // First, update all workouts that are in the deload week to be in the new deload week
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == oldDeloadWeek)
        .toList();
    for (final workout in deloadWorkouts) {
      final updatedWorkout = Workout(
        id: workout.id,
        trainingCycleId: workout.trainingCycleId,
        weekNumber: newDeloadWeek,
        dayNumber: workout.dayNumber,
        label: workout.label,
        status: workout.status,
        exercises: workout.exercises,
        notes: workout.notes,
      );
      await workoutRepo.update(updatedWorkout);
    }

    // Update the trainingCycle with new weeks total and deload week
    final updatedTrainingCycle = trainingCycle.copyWith(
      weeksTotal: newWeeksTotal,
      deloadWeek: newDeloadWeek,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Remove a week from the trainingCycle
  Future<void> removeWeek(
    TrainingCycle trainingCycle, {
    required bool removeDeload,
  }) async {
    if (trainingCycle.weeksTotal <= 2) {
      throw Exception('Cannot have fewer than 2 weeks');
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
    );

    final oldDeloadWeek = trainingCycle.deloadWeek;
    final lastNonDeloadWeek = oldDeloadWeek - 1;

    if (removeDeload) {
      // Remove the deload week - delete deload workouts, keep everything else
      final deloadWorkouts = allWorkouts
          .where((w) => w.weekNumber == oldDeloadWeek)
          .toList();
      for (final workout in deloadWorkouts) {
        await workoutRepo.delete(workout.id);
      }

      // Update trainingCycle: reduce weeks, deload is now the last week
      final newWeeksTotal = trainingCycle.weeksTotal - 1;
      final updatedTrainingCycle = trainingCycle.copyWith(
        weeksTotal: newWeeksTotal,
        deloadWeek: newWeeksTotal,
      );
      await trainingCycleRepo.update(updatedTrainingCycle);
    } else {
      // Remove the last non-deload week - delete those workouts,
      // then move deload workouts down by 1 week
      final lastWeekWorkouts = allWorkouts
          .where((w) => w.weekNumber == lastNonDeloadWeek)
          .toList();
      for (final workout in lastWeekWorkouts) {
        await workoutRepo.delete(workout.id);
      }

      // Move deload workouts to the previous week number
      final deloadWorkouts = allWorkouts
          .where((w) => w.weekNumber == oldDeloadWeek)
          .toList();
      for (final workout in deloadWorkouts) {
        final updatedWorkout = Workout(
          id: workout.id,
          trainingCycleId: workout.trainingCycleId,
          weekNumber: lastNonDeloadWeek,
          dayNumber: workout.dayNumber,
          label: workout.label,
          status: workout.status,
          exercises: workout.exercises,
          notes: workout.notes,
        );
        await workoutRepo.update(updatedWorkout);
      }

      // Update trainingCycle
      final newWeeksTotal = trainingCycle.weeksTotal - 1;
      final updatedTrainingCycle = trainingCycle.copyWith(
        weeksTotal: newWeeksTotal,
        deloadWeek: newWeeksTotal,
      );
      await trainingCycleRepo.update(updatedTrainingCycle);
    }
  }

  /// Add a day to the trainingCycle
  Future<void> addDay(TrainingCycle trainingCycle) async {
    if (trainingCycle.daysPerWeek >= 7) {
      throw Exception('Cannot have more than 7 days per week');
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final newDaysPerWeek = trainingCycle.daysPerWeek + 1;

    final updatedTrainingCycle = trainingCycle.copyWith(
      daysPerWeek: newDaysPerWeek,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Remove a day from the trainingCycle
  Future<void> removeDay(TrainingCycle trainingCycle) async {
    if (trainingCycle.daysPerWeek <= 1) {
      throw Exception('Cannot have fewer than 1 day per week');
    }

    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
    );

    final dayToRemove = trainingCycle.daysPerWeek;

    // Delete all workouts for this day across all weeks
    final workoutsToDelete = allWorkouts
        .where((w) => w.dayNumber == dayToRemove)
        .toList();
    for (final workout in workoutsToDelete) {
      await workoutRepo.delete(workout.id);
    }

    // Update the trainingCycle
    final newDaysPerWeek = trainingCycle.daysPerWeek - 1;
    final updatedTrainingCycle = trainingCycle.copyWith(
      daysPerWeek: newDaysPerWeek,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }

  /// Update the recovery week type
  Future<void> updateRecoveryWeekType(
    TrainingCycle trainingCycle,
    RecoveryWeekType newType,
  ) async {
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      recoveryWeekType: newType,
    );
    await trainingCycleRepo.update(updatedTrainingCycle);
  }
}

/// Provider for the EditWorkoutController
final editWorkoutControllerProvider =
    Provider.family<EditWorkoutController, String>(
      (ref, trainingCycleId) => EditWorkoutController(ref, trainingCycleId),
    );
