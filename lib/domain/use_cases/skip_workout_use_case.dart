import '../../data/repositories/workout_repository.dart';

/// Marks a workout as skipped.
class SkipWorkoutUseCase {
  final WorkoutRepository _workoutRepository;

  SkipWorkoutUseCase(this._workoutRepository);

  /// Marks the workout with [workoutId] as skipped.
  Future<void> execute(String workoutId) async {
    await _workoutRepository.markAsSkipped(workoutId);
  }
}
