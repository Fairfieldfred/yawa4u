import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise_set.dart';
import '../../data/repositories/workout_repository.dart';

/// Adds a new set to an exercise within a workout.
class AddExerciseSetUseCase {
  final WorkoutRepository _workoutRepository;

  AddExerciseSetUseCase(this._workoutRepository);

  /// Adds a new regular set to the end of the exercise's set list.
  ///
  /// [exerciseId] - the exercise to add the set to
  /// [workoutId] - the workout containing the exercise
  Future<void> execute(String exerciseId, String workoutId) async {
    final workout = await _workoutRepository.getById(workoutId);
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

    await _workoutRepository.update(updatedWorkout);
  }
}
