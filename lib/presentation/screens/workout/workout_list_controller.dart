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
/// Handles business logic for managing workouts, mirroring periods,
/// and starting trainingCycles.
class WorkoutListController {
  final Ref ref;
  final String trainingCycleId;

  WorkoutListController(this.ref, this.trainingCycleId);

  /// Mirror Period 1 workouts to the selected period
  Future<void> mirrorPeriod1ToSelectedPeriod(
    TrainingCycle trainingCycle,
    int selectedPeriod,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
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
      (ref, trainingCycleId) => WorkoutListController(ref, trainingCycleId),
    );
