import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/mesocycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/repository_providers.dart';
import '../../../domain/providers/workout_providers.dart';

/// Controller for the WorkoutListScreen
///
/// Handles business logic for managing workouts, mirroring weeks,
/// and starting mesocycles.
class WorkoutListController {
  final Ref ref;
  final String mesocycleId;

  WorkoutListController(this.ref, this.mesocycleId);

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
      final newWorkout = Workout(
        id: const Uuid().v4(),
        mesocycleId: mesocycle.id,
        weekNumber: selectedWeek,
        dayNumber: workout.dayNumber,
        dayName: workout.dayName,
        label: workout.label,
        status: WorkoutStatus.incomplete,
        exercises: workout.exercises
            .map((exercise) => exercise.copyWith())
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
    required String dayName,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    for (final muscleGroup in muscleGroups) {
      final newWorkout = Workout(
        id: const Uuid().v4(),
        mesocycleId: mesocycleId,
        weekNumber: weekNumber,
        dayNumber: dayNumber,
        dayName: dayName,
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
}

/// Provider for the WorkoutListController
final workoutListControllerProvider =
    Provider.family<WorkoutListController, String>(
      (ref, mesocycleId) => WorkoutListController(ref, mesocycleId),
    );
