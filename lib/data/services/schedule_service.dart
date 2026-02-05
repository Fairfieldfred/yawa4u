import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/utils/date_helpers.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../repositories/training_cycle_repository.dart';
import '../repositories/workout_repository.dart';

const _uuid = Uuid();

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
  final DateTime? scheduledDate;

  WorkoutSnapshot({
    required this.id,
    required this.periodNumber,
    required this.dayNumber,
    this.scheduledDate,
  });

  factory WorkoutSnapshot.fromWorkout(Workout workout) {
    return WorkoutSnapshot(
      id: workout.id,
      periodNumber: workout.periodNumber,
      dayNumber: workout.dayNumber,
      scheduledDate: workout.scheduledDate,
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
  /// and all subsequent workouts forward by one calendar day.
  ///
  /// IMPORTANT: This preserves the workout's original periodNumber/dayNumber
  /// designations (e.g., P2D2 stays P2D2). Only the scheduledDate is shifted
  /// to move workouts to a later calendar date.
  ///
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

    if (cycle.startDate == null) {
      throw Exception('Training cycle has no start date');
    }

    final cycleStart = DateHelpers.stripTime(cycle.startDate!);
    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Create snapshot for undo (including scheduledDates)
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts
          .map((w) => WorkoutSnapshot.fromWorkout(w))
          .toList(),
      description: 'Inserted day before P${fromPeriod}D$fromDay',
    );

    // Convert period/day to absolute day number (0-indexed from cycle start)
    int toAbsoluteDayIndex(int period, int day) =>
        (period - 1) * cycle.daysPerPeriod + (day - 1);

    final fromAbsoluteDayIndex = toAbsoluteDayIndex(fromPeriod, fromDay);

    // Find all workouts on or after the specified day and shift their scheduledDate forward
    final workoutsToShift = workouts.where((w) {
      final workoutAbsoluteDayIndex = toAbsoluteDayIndex(
        w.periodNumber,
        w.dayNumber,
      );
      return workoutAbsoluteDayIndex >= fromAbsoluteDayIndex;
    }).toList();

    // Shift each workout's scheduledDate forward by one day
    // If scheduledDate is null, calculate it from the default position first
    for (final workout in workoutsToShift) {
      // Calculate the current date for this workout
      DateTime currentDate;
      if (workout.scheduledDate != null) {
        currentDate = DateHelpers.stripTime(workout.scheduledDate!);
      } else {
        // Calculate default date from period/day
        final absoluteDayIndex = toAbsoluteDayIndex(
          workout.periodNumber,
          workout.dayNumber,
        );
        currentDate = DateHelpers.addDays(cycleStart, absoluteDayIndex);
      }

      // Shift forward by one day
      final newScheduledDate = DateHelpers.addDays(currentDate, 1);

      // Update ONLY the scheduledDate, NOT the periodNumber/dayNumber
      final updatedWorkout = workout.copyWith(scheduledDate: newScheduledDate);
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

  /// Move an individual exercise from one workout/day to another.
  /// Creates a new workout on the target day if needed.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> moveExercise({
    required String cycleId,
    required String sourceWorkoutId,
    required String exerciseId,
    required int targetPeriod,
    required int targetDay,
    int? targetIndex,
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
      description: 'Move exercise to P${targetPeriod}D$targetDay',
    );

    // Find source workout
    final sourceWorkout = workouts.firstWhere(
      (w) => w.id == sourceWorkoutId,
      orElse: () => throw Exception('Source workout not found'),
    );

    // Find exercise in source workout
    final exerciseIndex = sourceWorkout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) {
      throw Exception('Exercise not found in source workout');
    }

    final exercise = sourceWorkout.exercises[exerciseIndex];

    // Remove exercise from source workout
    final updatedSourceExercises = List<Exercise>.from(sourceWorkout.exercises);
    updatedSourceExercises.removeAt(exerciseIndex);

    // Update order indices for remaining exercises
    for (var i = 0; i < updatedSourceExercises.length; i++) {
      updatedSourceExercises[i] = updatedSourceExercises[i].copyWith(
        orderIndex: i,
      );
    }

    final updatedSourceWorkout = sourceWorkout.copyWith(
      exercises: updatedSourceExercises,
    );
    await _workoutRepository.update(updatedSourceWorkout);

    // Find or create target workout
    var targetWorkout = workouts.cast<Workout?>().firstWhere(
      (w) =>
          w!.periodNumber == targetPeriod &&
          w.dayNumber == targetDay &&
          w.label == exercise.muscleGroup.displayName,
      orElse: () => null,
    );

    if (targetWorkout == null) {
      // Find any workout on target day to get the dayName
      final existingOnDay = workouts.where(
        (w) => w.periodNumber == targetPeriod && w.dayNumber == targetDay,
      );
      final dayName = existingOnDay.isNotEmpty
          ? existingOnDay.first.dayName
          : null;

      // Generate ID upfront since create() returns void
      final newWorkoutId = _uuid.v4();

      // Create a new workout for this muscle group on the target day
      final newWorkout = Workout(
        id: newWorkoutId,
        trainingCycleId: cycleId,
        periodNumber: targetPeriod,
        dayNumber: targetDay,
        dayName: dayName,
        label: exercise.muscleGroup.displayName,
        status: WorkoutStatus.incomplete,
        exercises: [],
      );

      await _workoutRepository.create(newWorkout);
      targetWorkout = newWorkout;
    }

    // At this point targetWorkout is guaranteed non-null due to assignment above
    final theTargetWorkout = targetWorkout;
    final targetExercises = List<Exercise>.from(theTargetWorkout.exercises);
    final insertIndex = targetIndex ?? targetExercises.length;

    // Update exercise with new workout ID and order index
    final movedExercise = exercise.copyWith(
      workoutId: theTargetWorkout.id,
      orderIndex: insertIndex,
    );

    // Insert at the specified index
    targetExercises.insert(
      insertIndex.clamp(0, targetExercises.length),
      movedExercise,
    );

    // Update order indices for all exercises
    for (var i = 0; i < targetExercises.length; i++) {
      targetExercises[i] = targetExercises[i].copyWith(orderIndex: i);
    }

    final updatedTargetWorkout = theTargetWorkout.copyWith(
      exercises: targetExercises,
    );
    await _workoutRepository.update(updatedTargetWorkout);

    return snapshot;
  }

  /// Reorder an exercise within the same day
  Future<void> reorderExerciseWithinDay({
    required String cycleId,
    required int periodNumber,
    required int dayNumber,
    required int oldIndex,
    required int newIndex,
  }) async {
    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Collect all exercises for this day across all workouts
    final dayWorkouts = workouts
        .where(
          (w) => w.periodNumber == periodNumber && w.dayNumber == dayNumber,
        )
        .toList();

    // Build flat list of exercises with their parent workouts
    final allExercises = <_ExerciseWithWorkout>[];
    for (final workout in dayWorkouts) {
      for (final exercise in workout.exercises) {
        allExercises.add(_ExerciseWithWorkout(exercise, workout));
      }
    }

    if (oldIndex < 0 ||
        oldIndex >= allExercises.length ||
        newIndex < 0 ||
        newIndex >= allExercises.length) {
      return;
    }

    // Get the exercise being moved
    final movingItem = allExercises[oldIndex];

    // Perform the reorder in our flat list
    allExercises.removeAt(oldIndex);
    allExercises.insert(newIndex, movingItem);

    // Rebuild workouts with reordered exercises
    final workoutExercisesMap = <String, List<Exercise>>{};
    for (final workout in dayWorkouts) {
      workoutExercisesMap[workout.id] = [];
    }

    var orderIndex = 0;
    for (final item in allExercises) {
      // Keep exercise in its original workout
      final updatedExercise = item.exercise.copyWith(orderIndex: orderIndex);
      workoutExercisesMap[item.workout.id]!.add(updatedExercise);
      orderIndex++;
    }

    // Update each workout
    for (final workout in dayWorkouts) {
      final updatedWorkout = workout.copyWith(
        exercises: workoutExercisesMap[workout.id],
      );
      await _workoutRepository.update(updatedWorkout);
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

    // Restore workout positions and scheduled dates
    for (final workoutSnapshot in snapshot.workoutSnapshots) {
      final workout = await _workoutRepository.getById(workoutSnapshot.id);
      if (workout != null) {
        // Check if anything needs to be restored
        final needsUpdate =
            workout.periodNumber != workoutSnapshot.periodNumber ||
            workout.dayNumber != workoutSnapshot.dayNumber ||
            workout.scheduledDate != workoutSnapshot.scheduledDate;

        if (needsUpdate) {
          // Use clearScheduledDate when restoring to null
          final shouldClearScheduledDate =
              workoutSnapshot.scheduledDate == null &&
              workout.scheduledDate != null;

          final updated = workout.copyWith(
            periodNumber: workoutSnapshot.periodNumber,
            dayNumber: workoutSnapshot.dayNumber,
            scheduledDate: workoutSnapshot.scheduledDate,
            clearScheduledDate: shouldClearScheduledDate,
          );
          await _workoutRepository.update(updated);
        }
      }
    }
  }
}

/// Helper class to track an exercise along with its parent workout
class _ExerciseWithWorkout {
  final Exercise exercise;
  final Workout workout;

  _ExerciseWithWorkout(this.exercise, this.workout);
}
