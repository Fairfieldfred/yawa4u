import '../../core/constants/enums.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/workout_repository.dart';

/// Resets all sets in workouts to unlogged state.
///
/// Clears weight, reps, and logged status for every set in every exercise
/// across the provided workouts, and sets the workout status back to
/// incomplete.
class ResetWorkoutUseCase {
  final WorkoutRepository _workoutRepository;

  ResetWorkoutUseCase(this._workoutRepository);

  /// Resets all [workouts] for a day to their initial state.
  Future<void> execute(List<Workout> workouts) async {
    for (final workout in workouts) {
      final updatedExercises = workout.exercises.map((exercise) {
        final updatedSets = exercise.sets.map((set) {
          return set.copyWith(isLogged: false, weight: null, reps: '');
        }).toList();

        return exercise.copyWith(sets: updatedSets);
      }).toList();

      final updatedWorkout = workout.copyWith(
        exercises: updatedExercises,
        status: WorkoutStatus.incomplete,
        completedDate: null,
      );

      await _workoutRepository.update(updatedWorkout);
    }
  }
}
