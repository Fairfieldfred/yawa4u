import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/utils/date_helpers.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../models/workout.dart';
import '../repositories/session_repository.dart';
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
  final List<CardioSessionSnapshot> cardioSnapshots;

  /// Where each exercise lived (workout + order) before a drag/reorder.
  /// Empty for pure date shifts, which don't move exercises between
  /// workouts.
  final List<ExercisePlacementSnapshot> exercisePlacements;

  final String description;
  final DateTime timestamp;

  ScheduleSnapshot({
    required this.cycleStartDate,
    required this.workoutSnapshots,
    this.cardioSnapshots = const [],
    this.exercisePlacements = const [],
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Which workout an exercise belonged to (and at which position) before a
/// drag-drop move or reorder.
class ExercisePlacementSnapshot {
  final String exerciseId;
  final String workoutId;
  final int orderIndex;

  ExercisePlacementSnapshot({
    required this.exerciseId,
    required this.workoutId,
    required this.orderIndex,
  });
}

/// Capture the placement of every exercise across [workouts].
List<ExercisePlacementSnapshot> _placementsOf(List<Workout> workouts) {
  return [
    for (final w in workouts)
      for (final e in w.exercises)
        ExercisePlacementSnapshot(exerciseId: e.id, workoutId: w.id, orderIndex: e.orderIndex),
  ];
}

/// Minimal cardio-session state snapshot for undo
class CardioSessionSnapshot {
  final String id;
  final int? periodNumber;
  final int? dayNumber;
  final DateTime? scheduledDate;

  CardioSessionSnapshot({
    required this.id,
    this.periodNumber,
    this.dayNumber,
    this.scheduledDate,
  });

  factory CardioSessionSnapshot.fromSession(CardioSession session) {
    return CardioSessionSnapshot(
      id: session.id,
      periodNumber: session.periodNumber,
      dayNumber: session.dayNumber,
      scheduledDate: session.scheduledDate,
    );
  }
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
  final SessionRepository _sessionRepository;

  ScheduleService({
    required TrainingCycleRepository cycleRepository,
    required WorkoutRepository workoutRepository,
    required SessionRepository sessionRepository,
  }) : _cycleRepository = cycleRepository,
       _workoutRepository = workoutRepository,
       _sessionRepository = sessionRepository;

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
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      description: 'Shift cycle ${days > 0 ? 'forward' : 'backward'} ${days.abs()} day${days.abs() == 1 ? '' : 's'}',
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
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      description: 'Inserted day before P${fromPeriod}D$fromDay',
    );

    // Convert period/day to absolute day number (0-indexed from cycle start)
    int toAbsoluteDayIndex(int period, int day) => (period - 1) * cycle.daysPerPeriod + (day - 1);

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

  /// Insert a rest day before the specified calendar date, shifting all
  /// workouts scheduled on or after that date forward by one calendar day.
  ///
  /// This is the date-based sibling of [insertDayBefore]. It is the form used
  /// when multiple training cycles are active concurrently: each stacked cycle
  /// maps the same calendar date to a different (period, day) slot, so the shift
  /// must be keyed on the date rather than on period/day. Mirrors the date-based
  /// filtering already used by [removeRestDay].
  ///
  /// Returns a snapshot for undo, or `null` when the cycle cannot be shifted
  /// (no start date) so callers can skip it without aborting other cycles.
  Future<ScheduleSnapshot?> insertDayBeforeDate({
    required String cycleId,
    required DateTime restDayDate,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null || cycle.startDate == null) {
      return null;
    }

    final cycleStart = DateHelpers.stripTime(cycle.startDate!);
    final strippedRestDay = DateHelpers.stripTime(restDayDate);
    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Shift cardio sessions on or after the rest day forward by one day,
    // capturing their pre-edit state for undo.
    final cardioSnapshots = await _shiftCardioByDate(
      cycleId: cycleId,
      cycleStart: cycleStart,
      daysPerPeriod: cycle.daysPerPeriod,
      pivotDate: strippedRestDay,
      inclusive: true,
      dayDelta: 1,
    );

    // Create snapshot for undo (including scheduledDates)
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      cardioSnapshots: cardioSnapshots,
      description: 'Inserted day before ${DateHelpers.shortDate.format(restDayDate)}',
    );

    // Helper to get a workout's effective scheduled date
    DateTime getWorkoutDate(Workout w) {
      if (w.scheduledDate != null) {
        return DateHelpers.stripTime(w.scheduledDate!);
      }
      final absoluteDayIndex = (w.periodNumber - 1) * cycle.daysPerPeriod + (w.dayNumber - 1);
      return DateHelpers.addDays(cycleStart, absoluteDayIndex);
    }

    // Find all workouts on or after the rest day and shift them forward
    final workoutsToShift = workouts.where((w) {
      final workoutDate = getWorkoutDate(w);
      return !workoutDate.isBefore(strippedRestDay);
    }).toList();

    // Shift each workout's scheduledDate forward by one day, preserving
    // periodNumber/dayNumber designations.
    for (final workout in workoutsToShift) {
      final currentDate = getWorkoutDate(workout);
      final newScheduledDate = DateHelpers.addDays(currentDate, 1);
      final updatedWorkout = workout.copyWith(scheduledDate: newScheduledDate);
      await _workoutRepository.update(updatedWorkout);
    }

    return snapshot;
  }

  /// Shift the scheduled dates of a cycle's cardio sessions by [dayDelta] days.
  ///
  /// Mirrors the strength-workout shift used when inserting/removing a rest day:
  /// only the `scheduledDate` is changed, period/day designations are preserved.
  /// When [inclusive] is true, sessions on or after [pivotDate] move; otherwise
  /// only those strictly after it. External (imported) sessions are never moved
  /// — they record when an activity actually happened.
  ///
  /// Returns a snapshot of every session it shifted, for undo.
  Future<List<CardioSessionSnapshot>> _shiftCardioByDate({
    required String cycleId,
    required DateTime cycleStart,
    required int daysPerPeriod,
    required DateTime pivotDate,
    required bool inclusive,
    required int dayDelta,
  }) async {
    final cardioSessions = await _sessionRepository.getCardioByTrainingCycleId(
      cycleId,
    );

    DateTime? effectiveDate(CardioSession s) {
      if (s.scheduledDate != null) return DateHelpers.stripTime(s.scheduledDate!);
      if (s.completedDate != null) return DateHelpers.stripTime(s.completedDate!);
      if (s.periodNumber != null && s.dayNumber != null) {
        final index = (s.periodNumber! - 1) * daysPerPeriod + (s.dayNumber! - 1);
        return DateHelpers.addDays(cycleStart, index);
      }
      return null;
    }

    final snapshots = <CardioSessionSnapshot>[];
    for (final session in cardioSessions) {
      if (session.isReadOnly) continue;
      final date = effectiveDate(session);
      if (date == null) continue;

      final matches = inclusive ? !date.isBefore(pivotDate) : date.isAfter(pivotDate);
      if (!matches) continue;

      snapshots.add(CardioSessionSnapshot.fromSession(session));
      final newDate = DateHelpers.addDays(date, dayDelta);
      await _sessionRepository.updateSession(
        session.copyWith(scheduledDate: newDate),
      );
    }

    return snapshots;
  }

  /// Remove a rest day at the specified calendar date, shifting all workouts
  /// scheduled after that date backward by one day.
  ///
  /// This is the opposite of insertDayBefore - it removes a gap in the calendar
  /// while preserving workout periodNumber/dayNumber designations.
  ///
  /// [restDayDate] is the calendar date of the rest day to remove.
  /// All workouts scheduled AFTER this date will shift back by one day.
  ///
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> removeRestDay({
    required String cycleId,
    required DateTime restDayDate,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    if (cycle.startDate == null) {
      throw Exception('Training cycle has no start date');
    }

    final cycleStart = DateHelpers.stripTime(cycle.startDate!);
    final strippedRestDay = DateHelpers.stripTime(restDayDate);
    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);

    // Shift cardio sessions scheduled after the rest day backward by one day,
    // capturing their pre-edit state for undo.
    final cardioSnapshots = await _shiftCardioByDate(
      cycleId: cycleId,
      cycleStart: cycleStart,
      daysPerPeriod: cycle.daysPerPeriod,
      pivotDate: strippedRestDay,
      inclusive: false,
      dayDelta: -1,
    );

    // Create snapshot for undo
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      cardioSnapshots: cardioSnapshots,
      description: 'Removed rest day',
    );

    // Helper to get the effective scheduled date for a workout
    DateTime getWorkoutDate(Workout w) {
      if (w.scheduledDate != null) {
        return DateHelpers.stripTime(w.scheduledDate!);
      }
      // Calculate default date from period/day
      final absoluteDayIndex = (w.periodNumber - 1) * cycle.daysPerPeriod + (w.dayNumber - 1);
      return DateHelpers.addDays(cycleStart, absoluteDayIndex);
    }

    // Find all workouts scheduled AFTER the rest day and shift them backward
    final workoutsToShift = workouts.where((w) {
      final workoutDate = getWorkoutDate(w);
      return workoutDate.isAfter(strippedRestDay);
    }).toList();

    // Shift each workout's scheduledDate backward by one day
    for (final workout in workoutsToShift) {
      final currentDate = getWorkoutDate(workout);
      final newScheduledDate = DateHelpers.addDays(currentDate, -1);

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
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      description: 'Move workout from P${sourcePeriod}D$sourceDay to P${targetPeriod}D$targetDay',
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
        final workoutIndex = (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        if (workoutIndex > sourceIndex && workoutIndex <= targetIndex) {
          workoutsToShift.add(workout);
        }
      }

      // Shift these workouts backward by 1 day
      for (final workout in workoutsToShift) {
        final currentIndex = (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
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
        final workoutIndex = (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
        if (workoutIndex >= targetIndex && workoutIndex < sourceIndex) {
          workoutsToShift.add(workout);
        }
      }

      // Shift these workouts forward by 1 day
      for (final workout in workoutsToShift) {
        final currentIndex = (workout.periodNumber - 1) * daysPerPeriod + workout.dayNumber;
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
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
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
      (w) => w!.periodNumber == targetPeriod && w.dayNumber == targetDay && w.label == exercise.muscleGroup.displayName,
      orElse: () => null,
    );

    if (targetWorkout == null) {
      // Find any workout on target day to get the dayName
      final existingOnDay = workouts.where(
        (w) => w.periodNumber == targetPeriod && w.dayNumber == targetDay,
      );
      final dayName = existingOnDay.isNotEmpty ? existingOnDay.first.dayName : null;

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

  /// Move an individual exercise from one workout/day to another by target date.
  /// This method finds workouts by their scheduled date (accounting for shifts)
  /// rather than by period/day numbers.
  /// Creates a new workout on the target day if needed.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> moveExerciseToDate({
    required String cycleId,
    required String sourceWorkoutId,
    required String exerciseId,
    required DateTime targetDate,
    int? targetIndex,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) {
      throw Exception('Training cycle not found');
    }

    if (cycle.startDate == null) {
      throw Exception('Training cycle has no start date');
    }

    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);
    final cycleStart = DateHelpers.stripTime(cycle.startDate!);
    final strippedTargetDate = DateHelpers.stripTime(targetDate);

    // Create snapshot for undo — includes exercise placements because this
    // operation moves an exercise between workouts.
    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: workouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      exercisePlacements: _placementsOf(workouts),
      description: 'Move exercise to ${DateHelpers.shortDate.format(targetDate)}',
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

    // Helper to get a workout's effective scheduled date
    DateTime getWorkoutDate(Workout w) {
      if (w.scheduledDate != null) {
        return DateHelpers.stripTime(w.scheduledDate!);
      }
      final absoluteDayIndex = (w.periodNumber - 1) * cycle.daysPerPeriod + (w.dayNumber - 1);
      return DateHelpers.addDays(cycleStart, absoluteDayIndex);
    }

    // Find workouts on the target date
    final workoutsOnTargetDate = workouts.where((w) {
      return getWorkoutDate(w) == strippedTargetDate;
    }).toList();

    // Find or create target workout for this muscle group on the target date
    var targetWorkout = workoutsOnTargetDate.cast<Workout?>().firstWhere(
      (w) => w!.label == exercise.muscleGroup.displayName,
      orElse: () => null,
    );

    if (targetWorkout == null) {
      // Get period/day from existing workouts on target date, or calculate
      int targetPeriod;
      int targetDay;
      String? dayName;

      if (workoutsOnTargetDate.isNotEmpty) {
        // Use period/day from existing workouts on that date
        targetPeriod = workoutsOnTargetDate.first.periodNumber;
        targetDay = workoutsOnTargetDate.first.dayNumber;
        dayName = workoutsOnTargetDate.first.dayName;
      } else {
        // Calculate default period/day for this date
        final daysFromStart = DateHelpers.daysBetween(
          cycleStart,
          strippedTargetDate,
        );
        targetPeriod = (daysFromStart ~/ cycle.daysPerPeriod) + 1;
        targetDay = (daysFromStart % cycle.daysPerPeriod) + 1;
      }

      // Generate ID upfront since create() returns void
      final newWorkoutId = _uuid.v4();

      // Create a new workout for this muscle group on the target date
      final newWorkout = Workout(
        id: newWorkoutId,
        trainingCycleId: cycleId,
        periodNumber: targetPeriod,
        dayNumber: targetDay,
        dayName: dayName,
        label: exercise.muscleGroup.displayName,
        status: WorkoutStatus.incomplete,
        scheduledDate: strippedTargetDate, // Set the scheduled date!
        exercises: [],
      );

      await _workoutRepository.create(newWorkout);
      targetWorkout = newWorkout;
    }

    // At this point targetWorkout is guaranteed non-null
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

    if (oldIndex < 0 || oldIndex >= allExercises.length || newIndex < 0 || newIndex >= allExercises.length) {
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

  /// Reorder an exercise within the same day, finding workouts by date
  /// Returns a snapshot for undo, or null when the reorder was a no-op.
  Future<ScheduleSnapshot?> reorderExerciseWithinDayByDate({
    required String cycleId,
    required DateTime targetDate,
    required int oldIndex,
    required int newIndex,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null || cycle.startDate == null) {
      return null;
    }

    final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);
    final cycleStart = DateHelpers.stripTime(cycle.startDate!);
    final strippedTargetDate = DateHelpers.stripTime(targetDate);

    // Helper to get a workout's effective scheduled date
    DateTime getWorkoutDate(Workout w) {
      if (w.scheduledDate != null) {
        return DateHelpers.stripTime(w.scheduledDate!);
      }
      final absoluteDayIndex = (w.periodNumber - 1) * cycle.daysPerPeriod + (w.dayNumber - 1);
      return DateHelpers.addDays(cycleStart, absoluteDayIndex);
    }

    // Find workouts on the target date
    final dayWorkouts = workouts.where((w) {
      return getWorkoutDate(w) == strippedTargetDate;
    }).toList();

    // Build flat list of exercises with their parent workouts
    final allExercises = <_ExerciseWithWorkout>[];
    for (final workout in dayWorkouts) {
      for (final exercise in workout.exercises) {
        allExercises.add(_ExerciseWithWorkout(exercise, workout));
      }
    }

    if (oldIndex < 0 || oldIndex >= allExercises.length || newIndex < 0 || newIndex >= allExercises.length) {
      return null;
    }

    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: dayWorkouts.map((w) => WorkoutSnapshot.fromWorkout(w)).toList(),
      exercisePlacements: _placementsOf(dayWorkouts),
      description: 'Reordered exercises',
    );

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

    return snapshot;
  }

  /// Move a cardio session to a different calendar date.
  ///
  /// Updates `scheduledDate`, `periodNumber`, and `dayNumber` so the session
  /// is fully consistent with the target date — mirroring the approach used
  /// by [moveExerciseToDate] for strength exercises.
  /// Returns a snapshot for undo.
  Future<ScheduleSnapshot> moveCardioToDate({
    required String cycleId,
    required CardioSession session,
    required DateTime targetDate,
  }) async {
    final cycle = await _cycleRepository.getById(cycleId);
    if (cycle == null) throw Exception('Training cycle not found');

    final snapshot = ScheduleSnapshot(
      cycleStartDate: cycle.startDate,
      workoutSnapshots: const [],
      cardioSnapshots: [CardioSessionSnapshot.fromSession(session)],
      description: 'Move session to ${DateHelpers.shortDate.format(targetDate)}',
    );

    final cycleStart = DateHelpers.stripTime(
      cycle.startDate ?? cycle.createdDate,
    );
    final strippedTarget = DateHelpers.stripTime(targetDate);
    final daysFromStart = DateHelpers.daysBetween(
      cycleStart,
      strippedTarget,
    );
    final targetPeriod = (daysFromStart ~/ cycle.daysPerPeriod) + 1;
    final targetDay = (daysFromStart % cycle.daysPerPeriod) + 1;

    final updated = session.copyWith(
      scheduledDate: strippedTarget,
      periodNumber: targetPeriod,
      dayNumber: targetDay,
    );
    await _sessionRepository.updateSession(updated);

    return snapshot;
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
    if (snapshot.cycleStartDate != null && cycle.startDate != snapshot.cycleStartDate) {
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
          final shouldClearScheduledDate = workoutSnapshot.scheduledDate == null && workout.scheduledDate != null;

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

    // Restore exercise placements (which workout each exercise belongs to
    // and at which position) — undoes drag-drop moves and reorders.
    if (snapshot.exercisePlacements.isNotEmpty) {
      final workouts = await _workoutRepository.getByTrainingCycleId(cycleId);
      final placementById = {for (final p in snapshot.exercisePlacements) p.exerciseId: p};

      // Pull the affected exercises out of whichever workout currently
      // holds them, then re-insert them at their snapshot position.
      final lists = {for (final w in workouts) w.id: List<Exercise>.of(w.exercises)};
      final pulled = <String, Exercise>{};
      for (final w in workouts) {
        lists[w.id]!.removeWhere((e) {
          if (!placementById.containsKey(e.id)) return false;
          pulled[e.id] = e;
          return true;
        });
      }

      final placements = [...snapshot.exercisePlacements]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final placement in placements) {
        final exercise = pulled[placement.exerciseId];
        final target = lists[placement.workoutId];
        if (exercise == null || target == null) continue;
        target.insert(
          placement.orderIndex.clamp(0, target.length),
          exercise.copyWith(workoutId: placement.workoutId),
        );
      }

      for (final w in workouts) {
        final list = lists[w.id]!;
        final renumbered = [for (var i = 0; i < list.length; i++) list[i].copyWith(orderIndex: i)];
        await _workoutRepository.update(w.copyWith(exercises: renumbered));
      }
    }

    // Restore cardio session scheduled dates
    for (final cardioSnapshot in snapshot.cardioSnapshots) {
      final session = await _sessionRepository.getById(cardioSnapshot.id);
      if (session is! CardioSession) continue;

      final needsUpdate =
          session.periodNumber != cardioSnapshot.periodNumber ||
          session.dayNumber != cardioSnapshot.dayNumber ||
          session.scheduledDate != cardioSnapshot.scheduledDate;

      if (needsUpdate) {
        // Use clearScheduledDate when restoring to null
        final shouldClearScheduledDate = cardioSnapshot.scheduledDate == null && session.scheduledDate != null;

        final updated = session.copyWith(
          periodNumber: cardioSnapshot.periodNumber,
          dayNumber: cardioSnapshot.dayNumber,
          scheduledDate: cardioSnapshot.scheduledDate,
          clearScheduledDate: shouldClearScheduledDate,
        );
        await _sessionRepository.updateSession(updated);
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
