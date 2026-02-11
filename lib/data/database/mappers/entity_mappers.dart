import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../models/exercise.dart' as model;
import '../../models/exercise_feedback.dart' as model;
import '../../models/exercise_set.dart' as model;
import '../../models/training_cycle.dart' as model;
import '../../models/workout.dart' as model;
import '../app_database.dart';

/// Converts between Drift TrainingCycle row and domain TrainingCycle model
class TrainingCycleMapper {
  /// Convert a Drift TrainingCycle row to the domain model
  /// Note: workouts are loaded separately and passed in
  static model.TrainingCycle fromRow(
    TrainingCycle row, {
    List<model.Workout> workouts = const [],
  }) {
    Map<String, int>? priorities;
    if (row.muscleGroupPriorities != null &&
        row.muscleGroupPriorities!.isNotEmpty) {
      final decoded =
          jsonDecode(row.muscleGroupPriorities!) as Map<String, dynamic>;
      priorities = decoded.map((key, value) => MapEntry(key, value as int));
    }

    return model.TrainingCycle(
      id: row.uuid,
      name: row.name,
      periodsTotal: row.periodsTotal,
      daysPerPeriod: row.daysPerPeriod,
      recoveryPeriod: row.recoveryPeriod,
      status: TrainingCycleStatus.values[row.status],
      gender: row.gender != null ? Gender.values[row.gender!] : null,
      createdDate: row.createdDate,
      startDate: row.startDate,
      endDate: row.endDate,
      workouts: workouts,
      muscleGroupPriorities: priorities,
      templateName: row.templateName,
      notes: row.notes,
      recoveryPeriodType: row.recoveryPeriodType != null
          ? RecoveryPeriodType.values[row.recoveryPeriodType!]
          : null,
    );
  }

  /// Convert a domain TrainingCycle model to a Drift Companion for insert/update
  static TrainingCyclesCompanion toCompanion(model.TrainingCycle cycle) {
    return TrainingCyclesCompanion(
      uuid: Value(cycle.id),
      name: Value(cycle.name),
      periodsTotal: Value(cycle.periodsTotal),
      daysPerPeriod: Value(cycle.daysPerPeriod),
      recoveryPeriod: Value(cycle.recoveryPeriod),
      status: Value(cycle.status.index),
      gender: Value(cycle.gender?.index),
      createdDate: Value(cycle.createdDate),
      startDate: Value(cycle.startDate),
      endDate: Value(cycle.endDate),
      muscleGroupPriorities: Value(
        cycle.muscleGroupPriorities != null
            ? jsonEncode(cycle.muscleGroupPriorities)
            : null,
      ),
      templateName: Value(cycle.templateName),
      notes: Value(cycle.notes),
      recoveryPeriodType: Value(cycle.recoveryPeriodType.index),
    );
  }
}

/// Converts between Drift Workout row and domain Workout model
class WorkoutMapper {
  /// Convert a Drift Workout row to the domain model
  /// Note: exercises are loaded separately and passed in
  static model.Workout fromRow(
    Workout row, {
    List<model.Exercise> exercises = const [],
  }) {
    return model.Workout(
      id: row.uuid,
      trainingCycleId: row.trainingCycleUuid,
      periodNumber: row.periodNumber,
      dayNumber: row.dayNumber,
      dayName: row.dayName,
      label: row.label,
      status: WorkoutStatus.values[row.status],
      scheduledDate: row.scheduledDate,
      completedDate: row.completedDate,
      notes: row.notes,
      exercises: exercises,
    );
  }

  /// Convert a domain Workout model to a Drift Companion
  static WorkoutsCompanion toCompanion(model.Workout workout) {
    return WorkoutsCompanion(
      uuid: Value(workout.id),
      trainingCycleUuid: Value(workout.trainingCycleId),
      periodNumber: Value(workout.periodNumber),
      dayNumber: Value(workout.dayNumber),
      dayName: Value(workout.dayName),
      label: Value(workout.label),
      status: Value(workout.status.index),
      scheduledDate: Value(workout.scheduledDate),
      completedDate: Value(workout.completedDate),
      notes: Value(workout.notes),
    );
  }
}

/// Converts between Drift Exercise row and domain Exercise model
class ExerciseMapper {
  /// Convert a Drift Exercise row to the domain model
  /// Note: sets and feedback are loaded separately and passed in
  static model.Exercise fromRow(
    Exercise row, {
    List<model.ExerciseSet> sets = const [],
    model.ExerciseFeedback? feedback,
  }) {
    return model.Exercise(
      id: row.uuid,
      workoutId: row.workoutUuid,
      name: row.name,
      muscleGroup: MuscleGroup.values[row.muscleGroup],
      secondaryMuscleGroup: row.secondaryMuscleGroup != null
          ? MuscleGroup.values[row.secondaryMuscleGroup!]
          : null,
      equipmentType: EquipmentType.values[row.equipmentType],
      sets: sets,
      orderIndex: row.orderIndex,
      bodyweight: row.bodyweight,
      notes: row.notes,
      feedback: feedback,
      lastPerformed: row.lastPerformed,
      videoUrl: row.videoUrl,
      isNotePinned: row.isNotePinned,
    );
  }

  /// Convert a domain Exercise model to a Drift Companion
  static ExercisesCompanion toCompanion(model.Exercise exercise) {
    return ExercisesCompanion(
      uuid: Value(exercise.id),
      workoutUuid: Value(exercise.workoutId),
      name: Value(exercise.name),
      muscleGroup: Value(exercise.muscleGroup.index),
      secondaryMuscleGroup: Value(exercise.secondaryMuscleGroup?.index),
      equipmentType: Value(exercise.equipmentType.index),
      orderIndex: Value(exercise.orderIndex),
      bodyweight: Value(exercise.bodyweight),
      notes: Value(exercise.notes),
      lastPerformed: Value(exercise.lastPerformed),
      videoUrl: Value(exercise.videoUrl),
      isNotePinned: Value(exercise.isNotePinned),
    );
  }
}

/// Converts between Drift ExerciseSet row and domain ExerciseSet model
class ExerciseSetMapper {
  /// Convert a Drift ExerciseSet row to the domain model
  static model.ExerciseSet fromRow(ExerciseSet row) {
    return model.ExerciseSet(
      id: row.uuid,
      setNumber: row.setNumber,
      weight: row.weight,
      reps: row.reps,
      setType: SetType.values[row.setType],
      isLogged: row.isLogged,
      notes: row.notes,
      isSkipped: row.isSkipped,
    );
  }

  /// Convert a domain ExerciseSet model to a Drift Companion
  static ExerciseSetsCompanion toCompanion(
    model.ExerciseSet set,
    String exerciseUuid,
  ) {
    return ExerciseSetsCompanion(
      uuid: Value(set.id),
      exerciseUuid: Value(exerciseUuid),
      setNumber: Value(set.setNumber),
      weight: Value(set.weight),
      reps: Value(set.reps),
      setType: Value(set.setType.index),
      isLogged: Value(set.isLogged),
      notes: Value(set.notes),
      isSkipped: Value(set.isSkipped),
    );
  }
}

/// Converts between Drift ExerciseFeedback row and domain ExerciseFeedback model
class ExerciseFeedbackMapper {
  /// Convert a Drift ExerciseFeedback row to the domain model
  static model.ExerciseFeedback fromRow(ExerciseFeedback row) {
    Map<String, Soreness>? muscleGroupSoreness;
    if (row.muscleGroupSoreness != null &&
        row.muscleGroupSoreness!.isNotEmpty) {
      final decoded =
          jsonDecode(row.muscleGroupSoreness!) as Map<String, dynamic>;
      muscleGroupSoreness = decoded.map(
        (key, value) => MapEntry(key, Soreness.values[value as int]),
      );
    }

    return model.ExerciseFeedback(
      jointPain:
          row.jointPain != null ? JointPain.values[row.jointPain!] : null,
      musclePump:
          row.musclePump != null ? MusclePump.values[row.musclePump!] : null,
      workload: row.workload != null ? Workload.values[row.workload!] : null,
      soreness: row.soreness != null ? Soreness.values[row.soreness!] : null,
      muscleGroupSoreness: muscleGroupSoreness,
      timestamp: row.timestamp,
    );
  }

  /// Convert a domain ExerciseFeedback model to a Drift Companion
  static ExerciseFeedbacksCompanion toCompanion(
    model.ExerciseFeedback feedback,
    String exerciseUuid,
  ) {
    return ExerciseFeedbacksCompanion(
      exerciseUuid: Value(exerciseUuid),
      jointPain: Value(feedback.jointPain?.index),
      musclePump: Value(feedback.musclePump?.index),
      workload: Value(feedback.workload?.index),
      soreness: Value(feedback.soreness?.index),
      muscleGroupSoreness: Value(
        feedback.muscleGroupSoreness != null
            ? jsonEncode(
                feedback.muscleGroupSoreness!
                    .map((key, v) => MapEntry(key, v.index)),
              )
            : null,
      ),
      timestamp: Value(feedback.timestamp),
    );
  }
}
