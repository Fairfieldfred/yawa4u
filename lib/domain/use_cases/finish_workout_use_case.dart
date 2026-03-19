import '../../core/constants/enums.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/training_cycle_repository.dart';
import '../../data/repositories/workout_repository.dart';

/// Result of finishing a workout day.
class FinishWorkoutResult {
  /// Whether the entire training cycle was completed.
  final bool cycleCompleted;

  /// The next period to navigate to (null if cycle completed).
  final int? nextPeriod;

  /// The next day to navigate to (null if cycle completed).
  final int? nextDay;

  const FinishWorkoutResult({
    required this.cycleCompleted,
    this.nextPeriod,
    this.nextDay,
  });
}

/// Marks all workouts for a day as completed.
///
/// If all workouts in the training cycle are now completed, marks the
/// cycle as completed. Otherwise, calculates the next day to navigate to.
class FinishWorkoutUseCase {
  final WorkoutRepository _workoutRepository;
  final TrainingCycleRepository _trainingCycleRepository;

  FinishWorkoutUseCase(this._workoutRepository, this._trainingCycleRepository);

  /// Execute the use case.
  ///
  /// [workouts] - all workouts for the current day
  /// [daysPerPeriod] - number of days per period in the cycle
  /// [trainingCycleId] - the ID of the current training cycle
  ///
  /// Returns null if workouts is empty or training cycle not found.
  Future<FinishWorkoutResult?> execute({
    required List<Workout> workouts,
    required int daysPerPeriod,
    required String trainingCycleId,
  }) async {
    if (workouts.isEmpty) return null;

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await _workoutRepository.update(updatedWorkout);
    }

    // Check if ALL workouts in the training cycle are now completed
    final allWorkouts = await _workoutRepository.getByTrainingCycleId(
      trainingCycleId,
    );
    final allCompleted = allWorkouts.every(
      (w) => w.status == WorkoutStatus.completed,
    );

    if (allCompleted) {
      final trainingCycle = await _trainingCycleRepository.getById(
        trainingCycleId,
      );
      if (trainingCycle != null) {
        await _trainingCycleRepository.update(trainingCycle.complete());
      }
      return const FinishWorkoutResult(cycleCompleted: true);
    }

    // Calculate next day
    final firstWorkout = workouts.first;
    int nextDay = firstWorkout.dayNumber + 1;
    int nextPeriod = firstWorkout.periodNumber;

    if (nextDay > daysPerPeriod) {
      nextDay = 1;
      nextPeriod++;
    }

    return FinishWorkoutResult(
      cycleCompleted: false,
      nextPeriod: nextPeriod,
      nextDay: nextDay,
    );
  }
}
