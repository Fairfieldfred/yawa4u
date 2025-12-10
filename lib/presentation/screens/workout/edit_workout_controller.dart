import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/mesocycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/repository_providers.dart';
import '../../../domain/providers/workout_providers.dart';

/// Controller for the EditWorkoutScreen
///
/// Handles business logic for managing workouts, mirroring weeks,
/// and starting mesocycles.
class EditWorkoutController {
  final Ref ref;
  final String mesocycleId;

  EditWorkoutController(this.ref, this.mesocycleId);

  /// Mirror Week 1 workouts to the selected week
  Future<void> mirrorWeek1ToSelectedWeek(
    Mesocycle mesocycle,
    int selectedWeek,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycleId));

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
        mesocycleId: mesocycle.id,
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

  /// Start the mesocycle
  Future<void> startMesocycle(Mesocycle mesocycle) async {
    final repository = ref.read(mesocycleRepositoryProvider);
    await repository.setAsCurrent(mesocycle.id);
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
        mesocycleId: mesocycleId,
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

  /// Add a week to the mesocycle (inserted before the deload week)
  Future<void> addWeek(Mesocycle mesocycle) async {
    final mesocycleRepo = ref.read(mesocycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycleId));

    final newWeeksTotal = mesocycle.weeksTotal + 1;
    final oldDeloadWeek = mesocycle.deloadWeek;
    final newDeloadWeek = newWeeksTotal; // Deload is always the last week

    // First, update all workouts that are in the deload week to be in the new deload week
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == oldDeloadWeek)
        .toList();
    for (final workout in deloadWorkouts) {
      final updatedWorkout = Workout(
        id: workout.id,
        mesocycleId: workout.mesocycleId,
        weekNumber: newDeloadWeek,
        dayNumber: workout.dayNumber,
        label: workout.label,
        status: workout.status,
        exercises: workout.exercises,
        notes: workout.notes,
      );
      await workoutRepo.update(updatedWorkout);
    }

    // Update the mesocycle with new weeks total and deload week
    final updatedMesocycle = mesocycle.copyWith(
      weeksTotal: newWeeksTotal,
      deloadWeek: newDeloadWeek,
    );
    await mesocycleRepo.update(updatedMesocycle);
  }

  /// Remove a week from the mesocycle
  Future<void> removeWeek(
    Mesocycle mesocycle, {
    required bool removeDeload,
  }) async {
    if (mesocycle.weeksTotal <= 2) {
      throw Exception('Cannot have fewer than 2 weeks');
    }

    final mesocycleRepo = ref.read(mesocycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycleId));

    final oldDeloadWeek = mesocycle.deloadWeek;
    final lastNonDeloadWeek = oldDeloadWeek - 1;

    if (removeDeload) {
      // Remove the deload week - delete deload workouts, keep everything else
      final deloadWorkouts = allWorkouts
          .where((w) => w.weekNumber == oldDeloadWeek)
          .toList();
      for (final workout in deloadWorkouts) {
        await workoutRepo.delete(workout.id);
      }

      // Update mesocycle: reduce weeks, deload is now the last week
      final newWeeksTotal = mesocycle.weeksTotal - 1;
      final updatedMesocycle = mesocycle.copyWith(
        weeksTotal: newWeeksTotal,
        deloadWeek: newWeeksTotal,
      );
      await mesocycleRepo.update(updatedMesocycle);
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
          mesocycleId: workout.mesocycleId,
          weekNumber: lastNonDeloadWeek,
          dayNumber: workout.dayNumber,
          label: workout.label,
          status: workout.status,
          exercises: workout.exercises,
          notes: workout.notes,
        );
        await workoutRepo.update(updatedWorkout);
      }

      // Update mesocycle
      final newWeeksTotal = mesocycle.weeksTotal - 1;
      final updatedMesocycle = mesocycle.copyWith(
        weeksTotal: newWeeksTotal,
        deloadWeek: newWeeksTotal,
      );
      await mesocycleRepo.update(updatedMesocycle);
    }
  }

  /// Add a day to the mesocycle
  Future<void> addDay(Mesocycle mesocycle) async {
    if (mesocycle.daysPerWeek >= 7) {
      throw Exception('Cannot have more than 7 days per week');
    }

    final mesocycleRepo = ref.read(mesocycleRepositoryProvider);
    final newDaysPerWeek = mesocycle.daysPerWeek + 1;

    final updatedMesocycle = mesocycle.copyWith(daysPerWeek: newDaysPerWeek);
    await mesocycleRepo.update(updatedMesocycle);
  }

  /// Remove a day from the mesocycle
  Future<void> removeDay(Mesocycle mesocycle) async {
    if (mesocycle.daysPerWeek <= 1) {
      throw Exception('Cannot have fewer than 1 day per week');
    }

    final mesocycleRepo = ref.read(mesocycleRepositoryProvider);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycleId));

    final dayToRemove = mesocycle.daysPerWeek;

    // Delete all workouts for this day across all weeks
    final workoutsToDelete = allWorkouts
        .where((w) => w.dayNumber == dayToRemove)
        .toList();
    for (final workout in workoutsToDelete) {
      await workoutRepo.delete(workout.id);
    }

    // Update the mesocycle
    final newDaysPerWeek = mesocycle.daysPerWeek - 1;
    final updatedMesocycle = mesocycle.copyWith(daysPerWeek: newDaysPerWeek);
    await mesocycleRepo.update(updatedMesocycle);
  }
}

/// Provider for the EditWorkoutController
final editWorkoutControllerProvider =
    Provider.family<EditWorkoutController, String>(
      (ref, mesocycleId) => EditWorkoutController(ref, mesocycleId),
    );
