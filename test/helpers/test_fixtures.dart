import 'package:uuid/uuid.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/models/cardio_detail.dart';
import 'package:yawa4u/data/models/cardio_feedback.dart';
import 'package:yawa4u/data/models/custom_exercise_definition.dart';
import 'package:yawa4u/data/models/cycle_period.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_feedback.dart';
import 'package:yawa4u/data/models/exercise_set.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/data/models/session_interval.dart';
import 'package:yawa4u/data/models/session_sample.dart';
import 'package:yawa4u/data/models/sport_zone.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/user_measurement.dart';
import 'package:yawa4u/data/models/workout.dart';

const _uuid = Uuid();

/// Factory functions for creating test domain model instances
/// with sensible defaults. All fields can be overridden.
class TestFixtures {
  TestFixtures._();

  static ExerciseSet createExerciseSet({
    String? id,
    int setNumber = 1,
    double? weight = 100.0,
    String reps = '10',
    SetType setType = SetType.regular,
    bool isLogged = false,
    String? notes,
    bool isSkipped = false,
  }) {
    return ExerciseSet(
      id: id ?? _uuid.v4(),
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      setType: setType,
      isLogged: isLogged,
      notes: notes,
      isSkipped: isSkipped,
    );
  }

  static ExerciseFeedback createFeedback({
    JointPain? jointPain = JointPain.none,
    MusclePump? musclePump = MusclePump.moderate,
    Workload? workload = Workload.prettyGood,
    Soreness? soreness = Soreness.healedAWhileAgo,
    Map<String, Soreness>? muscleGroupSoreness,
    DateTime? timestamp,
  }) {
    return ExerciseFeedback(
      jointPain: jointPain,
      musclePump: musclePump,
      workload: workload,
      soreness: soreness,
      muscleGroupSoreness: muscleGroupSoreness,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static Exercise createExercise({
    String? id,
    String? workoutId,
    String name = 'Bench Press',
    MuscleGroup muscleGroup = MuscleGroup.chest,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType equipmentType = EquipmentType.barbell,
    List<ExerciseSet>? sets,
    int orderIndex = 0,
    double? bodyweight,
    String? notes,
    ExerciseFeedback? feedback,
    DateTime? lastPerformed,
    String? videoUrl,
    bool isNotePinned = false,
  }) {
    return Exercise(
      id: id ?? _uuid.v4(),
      workoutId: workoutId ?? _uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
      sets: sets,
      orderIndex: orderIndex,
      bodyweight: bodyweight,
      notes: notes,
      feedback: feedback,
      lastPerformed: lastPerformed,
      videoUrl: videoUrl,
      isNotePinned: isNotePinned,
    );
  }

  static Workout createWorkout({
    String? id,
    String? trainingCycleId,
    int periodNumber = 1,
    int dayNumber = 1,
    String? dayName = 'Push Day',
    String label = 'Chest',
    WorkoutStatus status = WorkoutStatus.incomplete,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? notes,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? _uuid.v4(),
      trainingCycleId: trainingCycleId ?? _uuid.v4(),
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      status: status,
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      notes: notes,
      exercises: exercises ?? [],
    );
  }

  static TrainingCycle createTrainingCycle({
    String? id,
    String name = 'Test Cycle',
    int periodsTotal = 4,
    int daysPerPeriod = 5,
    int? recoveryPeriod,
    TrainingCycleStatus status = TrainingCycleStatus.draft,
    Gender? gender,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? endDate,
    List<Workout>? workouts,
    Map<String, int>? muscleGroupPriorities,
    String? templateName,
    String? notes,
    RecoveryPeriodType recoveryPeriodType = RecoveryPeriodType.deload,
  }) {
    return TrainingCycle(
      id: id ?? _uuid.v4(),
      name: name,
      periodsTotal: periodsTotal,
      daysPerPeriod: daysPerPeriod,
      recoveryPeriod: recoveryPeriod,
      status: status,
      gender: gender,
      createdDate: createdDate ?? DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      workouts: workouts ?? [],
      muscleGroupPriorities: muscleGroupPriorities,
      templateName: templateName,
      notes: notes,
      recoveryPeriodType: recoveryPeriodType,
    );
  }

  static StrengthSession createStrengthSession({
    String? id,
    String? trainingCycleId,
    SessionSource source = SessionSource.userLogged,
    WorkoutStatus status = WorkoutStatus.incomplete,
    int? periodNumber = 1,
    int? dayNumber = 1,
    String? dayName = 'Push Day',
    String? label = 'Chest',
    DateTime? scheduledDate,
    DateTime? completedDate,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? externalId,
    List<Exercise>? exercises,
  }) {
    return StrengthSession(
      id: id ?? _uuid.v4(),
      trainingCycleId: trainingCycleId,
      source: source,
      status: status,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      externalId: externalId,
      exercises: exercises ?? [],
    );
  }

  static CardioSession createCardioSession({
    String? id,
    String? trainingCycleId,
    Sport sport = Sport.run,
    SessionSource source = SessionSource.userLogged,
    WorkoutStatus status = WorkoutStatus.incomplete,
    int? periodNumber,
    int? dayNumber,
    String? dayName,
    String? label,
    DateTime? scheduledDate,
    DateTime? completedDate,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? externalId,
    CardioDetail? detail,
    List<SessionInterval>? intervals,
    List<SessionSample>? samples,
  }) {
    return CardioSession(
      id: id ?? _uuid.v4(),
      trainingCycleId: trainingCycleId,
      sport: sport,
      source: source,
      status: status,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      externalId: externalId,
      detail: detail,
      intervals: intervals ?? [],
      samples: samples,
    );
  }

  static CardioDetail createCardioDetail({
    double? plannedDistanceM,
    double? actualDistanceM = 5000.0,
    int? plannedDurationSec,
    int? actualDurationSec = 1800,
    double? elevationGainM,
    double? elevationLossM,
    int? averageHr = 145,
    int? maxHr = 172,
    double? averageCadence,
    double? averagePowerWatts,
    double? normalizedPowerWatts,
    double? averageSpeedMps,
    double? averagePaceSecPerMeter,
    double? poolLengthM,
    StrokeType? strokeType,
    int? lapCount,
    int? swolf,
    int? perceivedExertion,
    String? notes,
  }) {
    return CardioDetail(
      plannedDistanceM: plannedDistanceM,
      actualDistanceM: actualDistanceM,
      plannedDurationSec: plannedDurationSec,
      actualDurationSec: actualDurationSec,
      elevationGainM: elevationGainM,
      elevationLossM: elevationLossM,
      averageHr: averageHr,
      maxHr: maxHr,
      averageCadence: averageCadence,
      averagePowerWatts: averagePowerWatts,
      normalizedPowerWatts: normalizedPowerWatts,
      averageSpeedMps: averageSpeedMps,
      averagePaceSecPerMeter: averagePaceSecPerMeter,
      poolLengthM: poolLengthM,
      strokeType: strokeType,
      lapCount: lapCount,
      swolf: swolf,
      perceivedExertion: perceivedExertion,
      notes: notes,
    );
  }

  static SessionInterval createSessionInterval({
    String? id,
    String? sessionId,
    int orderIndex = 0,
    IntervalIntent intent = IntervalIntent.work,
    IntervalTargetKind targetKind = IntervalTargetKind.durationSec,
    int? targetDurationSec = 300,
    double? targetDistanceM,
    int? targetHrZone,
    int? targetPaceZone,
    int? targetPowerZone,
    double? targetValueMin,
    double? targetValueMax,
    String? targetFreeform,
    int? actualDurationSec,
    double? actualDistanceM,
    int? actualAverageHr,
    double? actualAveragePaceSecPerMeter,
    double? actualAveragePowerWatts,
    int? repeatCount,
    String? parentIntervalId,
    String? notes,
  }) {
    return SessionInterval(
      id: id ?? _uuid.v4(),
      sessionId: sessionId ?? _uuid.v4(),
      orderIndex: orderIndex,
      intent: intent,
      targetKind: targetKind,
      targetDurationSec: targetDurationSec,
      targetDistanceM: targetDistanceM,
      targetHrZone: targetHrZone,
      targetPaceZone: targetPaceZone,
      targetPowerZone: targetPowerZone,
      targetValueMin: targetValueMin,
      targetValueMax: targetValueMax,
      targetFreeform: targetFreeform,
      actualDurationSec: actualDurationSec,
      actualDistanceM: actualDistanceM,
      actualAverageHr: actualAverageHr,
      actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter,
      actualAveragePowerWatts: actualAveragePowerWatts,
      repeatCount: repeatCount,
      parentIntervalId: parentIntervalId,
      notes: notes,
    );
  }

  static SessionSample createSessionSample({
    String? sessionId,
    int offsetSec = 0,
    double? lat,
    double? lng,
    double? altitudeM,
    int? hr = 140,
    double? cadence,
    double? powerW,
    double? speedMps,
    double? strokeRate,
  }) {
    return SessionSample(
      sessionId: sessionId ?? _uuid.v4(),
      offsetSec: offsetSec,
      lat: lat,
      lng: lng,
      altitudeM: altitudeM,
      hr: hr,
      cadence: cadence,
      powerW: powerW,
      speedMps: speedMps,
      strokeRate: strokeRate,
    );
  }

  static CyclePeriod createCyclePeriod({
    String? id,
    String? trainingCycleId,
    int periodNumber = 1,
    TrainingPhase? phase,
    String? notes,
    String? creatorUuid,
    String? ownerUuid,
  }) {
    return CyclePeriod(
      id: id ?? _uuid.v4(),
      trainingCycleId: trainingCycleId ?? _uuid.v4(),
      periodNumber: periodNumber,
      phase: phase,
      notes: notes,
      creatorUuid: creatorUuid,
      ownerUuid: ownerUuid,
    );
  }

  static SportZone createSportZone({
    String? id,
    Sport sport = Sport.run,
    int zoneNumber = 1,
    double minValue = 120.0,
    double maxValue = 140.0,
    String unit = 'bpm',
    String? ownerUuid,
    DateTime? createdAt,
  }) {
    return SportZone(
      id: id ?? _uuid.v4(),
      sport: sport,
      zoneNumber: zoneNumber,
      minValue: minValue,
      maxValue: maxValue,
      unit: unit,
      ownerUuid: ownerUuid,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  static CardioFeedback createCardioFeedback({
    int? rpe = 5,
    int? breathing = 3,
    int? giComfort = 4,
    String? weather,
    String? notes,
    DateTime? timestamp,
    String? creatorUuid,
    String? ownerUuid,
  }) {
    return CardioFeedback(
      rpe: rpe,
      breathing: breathing,
      giComfort: giComfort,
      weather: weather,
      notes: notes,
      timestamp: timestamp ?? DateTime.now(),
      creatorUuid: creatorUuid,
      ownerUuid: ownerUuid,
    );
  }

  static UserMeasurement createUserMeasurement({
    String? id,
    double heightCm = 175.0,
    double weightKg = 80.0,
    DateTime? timestamp,
    String? notes,
    double? bodyFatPercent,
    double? leanMassKg,
  }) {
    return UserMeasurement(
      id: id ?? _uuid.v4(),
      heightCm: heightCm,
      weightKg: weightKg,
      timestamp: timestamp ?? DateTime.now(),
      notes: notes,
      bodyFatPercent: bodyFatPercent,
      leanMassKg: leanMassKg,
    );
  }

  static CustomExerciseDefinition createCustomExerciseDefinition({
    String? id,
    String name = 'Custom Bench Press',
    MuscleGroup muscleGroup = MuscleGroup.chest,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType equipmentType = EquipmentType.dumbbell,
    String? videoUrl,
    int? restSeconds,
    DateTime? createdAt,
  }) {
    return CustomExerciseDefinition(
      id: id ?? _uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
      videoUrl: videoUrl,
      restSeconds: restSeconds,
      createdAt: createdAt,
    );
  }
}
