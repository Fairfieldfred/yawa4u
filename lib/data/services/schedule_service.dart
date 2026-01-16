import '../../core/utils/date_helpers.dart';
import '../models/workout.dart';
import '../repositories/training_cycle_repository.dart';
import '../repositories/workout_repository.dart';

/// Modes for moving a workout to a different date
enum MoveMode {
  /// Move the selected workout and shift all subsequent workouts (default)
  shiftSubsequent,

  /// Swap the selected workout with the workout on the target date
  swap,

  /// Move only the selected workout, potentially creating gaps
  single,
}

/// Snapshot of schedule state for undo functionality
class ScheduleSnapshot {
  final DateTime? cycleStartDate;
  final List<WorkoutSnapshot> workoutSnapshots;
  final String description;
  final DateTime timestamp;

  ScheduleSnapshot({
    required this.cycleStartDate,
    required this.workoutSnapshots,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Minimal workout state snapshot for undo
class WorkoutSnapshot {
  final String id;
  final int periodNumber;
  final int dayNumber;

  WorkoutSnapshot({
    required this.id,
    required this.periodNumber,
    required this.dayNumber,
  });

  factory WorkoutSnapshot.fromWorkout(Workout workout) {
    return WorkoutSnapshot(
      id: workout.id,
      periodNumber: workout.periodNumber,
      dayNumber: workout.dayNumber,
    );
  }
}

/// Service for managing workout schedule changes
class ScheduleService {
  final TrainingCycleRepository _cycleRepository;
  final WorkoutRepository _workoutRepository;

  ScheduleService({
    required TrainingCycleRepository cycleRepository,
    required WorkoutRepository workoutRepository,
  }) : _cycleRepository = cycleRepository,
       _workoutRepository = workoutRepository;

  /// Shift the entire training cycle start date by the given number of days.
  /// Positive values shift forward, negative values shift backward.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> shiftTrainingCycleStart(
    String cycleId,
    int days,
  ) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Create snapshot for undo
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts
          .map((w) => WorkoutSnapshot.fromWorkout(w))
          .toList(),
      description:
          'Shift cycle ${days > 0 ? 'forward' : 'backward'} ${days.abs()} day${days.abs() == 1 ? '' : 's'}',
    );

    // Update cycle start date
    if (cycle.startDate != null) {
      final newStartDate = DateHelpers.addDays(cycle.startDate!, days);
      final updatedCycle = cycle.copyWith(startDate: newStartDate);
      await _cycleRepository.update(updatedCycle);
    }

    return snapshot;
  }

  /// Insert a rest day before the specified period/day, shifting that day
  /// and all subsequent workouts forward by one day.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> insertDayBefore({
    required String cycleId,
    required int fromPeriod,
    required int fromDay,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Create snapshot for undo
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts
          .map((w) => WorkoutSnapshot.fromWorkout(w))
          .toList(),
      description: 'Inserted day before P${fromPeriod}D$fromDay',
    );

    // Convert period/day to absolute day number for comparison
    int toAbsoluteDay(int period, int day) =>
        (period - 1) * cycle.daysPerPeriod + day;

    final fromAbsoluteDay = toAbsoluteDay(fromPeriod, fromDay);

    // Find all workouts on or after the specified day and shift them forward
    final workoutsToShift = workouts.where((w) {
      final workoutAbsoluteDay = toAbsoluteDay(w.periodNumber, w.dayNumber);
      return workoutAbsoluteDay >= fromAbsoluteDay;
    }).toList();

    // Shift each workout forward by one day
    for (final workout in workoutsToShift) {
      final currentAbsolute = toAbsoluteDay(
        workout.periodNumber,
        workout.dayNumber,
      );
      final newAbsolute = currentAbsolute + 1;

      // Convert back to period/day
      final newPeriod = ((newAbsolute - 1) ~/ cycle.daysPerPeriod) + 1;
      final newDay = ((newAbsolute - 1) % cycle.daysPerPeriod) + 1;

      final updatedWorkout = workout.copyWith(
        periodNumber: newPeriod,
        dayNumber: newDay,
      );
      await _workoutRepository.update(updatedWorkout);
    }

    return snapshot;
  }

  /// Move a workout to a target date using the specified mode.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> moveWorkout({
    required String cycleId,
    required int sourcePeriod,
    required int sourceDay,
    required int targetPeriod,
    required int targetDay,
    required MoveMode mode,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Create snapshot for undo
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts
          .map((w) => WorkoutSnapshot.fromWorkout(w))
          .toList(),
      description:
          'Move workout from P${sourcePeriod}D$sourceDay to P${targetPeriod}D$targetDay',
    );

    // Get source workouts (all workouts on the source day)
    final sourceWorkouts = workouts
        .where(
          (w) => w.periodNumber == sourcePeriod && w.dayNumber == sourceDay,
        )
        .toList();

    if (sourceWorkouts.isEmpty) {
      throw Exception('No workouts found on source date');
    }

    switch (mode) {
      case MoveMode.shiftSubsequent:
        await _moveWithShift(
          workouts: workouts,
          sourceWorkouts: sourceWorkouts,
          sourcePeriod: sourcePeriod,
          sourceDay: sourceDay,
          targetPeriod: targetPeriod,
          targetDay: targetDay,
          daysPerPeriod: cycle.daysPerPeriod,
        );
        break;

      case MoveMode.swap:
        await _moveWithSwap(
          workouts: workouts,
          sourceWorkouts: sourceWorkouts,
          sourcePeriod: sourcePeriod,
          sourceDay: sourceDay,
          targetPeriod: targetPeriod,
          targetDay: targetDay,
        );
        break;

      case MoveMode.single:
        await _moveSingle(
          sourceWorkouts: sourceWorkouts,
          targetPeriod: targetPeriod,
          targetDay: targetDay,
        );
        break;
    }

    return snapshot;
  }

  /// Move workout and shift all subsequent workouts
  Future<void> _moveWithShift({
    required List<Workout> workouts,
    required List<Workout> sourceWorkouts,
    required int sourcePeriod,
    required int sourceDay,
    required int targetPeriod,
    required int targetDay,
    required int daysPerPeriod,
  }) async {
    // Calculate source and target as linear day indices
    final sourceIndex = (sourcePeriod - 1) * daysPerPeriod + sourceDay;
    final targetIndex = (targetPeriod - 1) * daysPerPeriod + targetDay;
    final shift = targetIndex - sourceIndex;

    if (shift == 0) return;

    // Determine which workouts need to shift
    final workoutsToShift = <Workout>[];

    if (shift > 0) {
      // Moving forward: shift workouts between source+1 and target backward
      for (final workout in workouts) {
        final workoutIndex =
            (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        if (workoutIndex > sourceIndex && workoutIndex <= targetIndex) {
          workoutsToShift.add(workout);
        }
      }

      // Shift these workouts backward by 1 day
      for (final workout in workoutsToShift) {
        final currentIndex =
            (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        final newIndex = currentIndex - 1;
        final newPeriod = (newIndex - 1) ~/ daysPerPeriod + 1;
        final newDay = ((newIndex - 1) % daysPerPeriod) + 1;

        final updated = workout.copyWith(
          periodNumber: newPeriod,
          dayNumber: newDay,
        );
        await _workoutRepository.update(updated);
      }
    } else {
      // Moving backward: shift workouts between target and source-1 forward
      for (final workout in workouts) {
        final workoutIndex =
            (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        if (workoutIndex >= targetIndex && workoutIndex < sourceIndex) {
          workoutsToShift.add(workout);
        }
      }

      // Shift these workouts forward by 1 day
      for (final workout in workoutsToShift) {
        final currentIndex =
            (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        final newIndex = currentIndex + 1;
        final newPeriod = (newIndex - 1) ~/ daysPerPeriod + 1;
        final newDay = ((newIndex - 1) % daysPerPeriod) + 1;

        final updated = workout.copyWith(
          periodNumber: newPeriod,
          dayNumber: newDay,
        );
        await _workoutRepository.update(updated);
      }
    }

    // Move source workouts to target
    for (final workout in sourceWorkouts) {
      final updated = workout.copyWith(
        periodNumber: targetPeriod,
        dayNumber: targetDay,
      );
      await _workoutRepository.update(updated);
    }
  }

  /// Swap source and target workouts
  Future<void> _moveWithSwap({
    required List<Workout> workouts,
    required List<Workout> sourceWorkouts,
    required int sourcePeriod,
    required int sourceDay,
    required int targetPeriod,
    required int targetDay,
  }) async {
    // Get target workouts
    final targetWorkouts = workouts
        .where(
          (w) => w.periodNumber == targetPeriod && w.dayNumber == targetDay,
        )
        .toList();

    // Move source workouts to target position
    for (final workout in sourceWorkouts) {
      final updated = workout.copyWith(
        periodNumber: targetPeriod,
        dayNumber: targetDay,
      );
      await _workoutRepository.update(updated);
    }

    // Move target workouts to source position
    for (final workout in targetWorkouts) {
      final updated = workout.copyWith(
        periodNumber: sourcePeriod,
        dayNumber: sourceDay,
      );
      await _workoutRepository.update(updated);
    }
  }

  /// Move only the selected workout
  Future<void> _moveSingle({
    required List<Workout> sourceWorkouts,
    required int targetPeriod,
    required int targetDay,
  }) async {
    for (final workout in sourceWorkouts) {
      final updated = workout.copyWith(
        periodNumber: targetPeriod,
        dayNumber: targetDay,
      );
      await _workoutRepository.update(updated);
    }
  }

  /// Restore a schedule from a snapshot (undo operation)
  Future<void> restoreSnapshot(
    String cycleId,
    ScheduleSnapshot snapshot,
  ) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    // Restore cycle start date if it was changed
    if (snapshot.cycleStartDate != null &&
        cycle.startDate != snapshot.cycleStartDate) {
      final updatedCycle = cycle.copyWith(startDate: snapshot.cycleStartDate);
      await _cycleRepository.update(updatedCycle);
    }

    // Restore workout positions
    for (final workoutSnapshot in snapshot.workoutSnapshots) {
      final workout = await _workoutRepository.getById(workoutSnapshot.id);
      if (workout != null &&
          (workout.periodNumber != workoutSnapshot.periodNumber ||
              workout.dayNumber != workoutSnapshot.dayNumber)) {
        final updated = workout.copyWith(
          periodNumber: workoutSnapshot.periodNumber,
          dayNumber: workoutSnapshot.dayNumber,
        );
        await _workoutRepository.update(updated);
      }
    }
  }
}
