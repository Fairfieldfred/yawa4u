import 'package:drift/drift.dart';

/// Training Cycles table - top-level training program container
///
/// v5 additions:
/// - [primarySport]  UI hint used to prefill daysPerPeriod / pick a default
///                   sport on the session sheet. NEVER restrictive —
///                   a cycle can hold any mix of sports.
/// - [creatorUuid]   Coach-mode hook (nullable). Defaults to local user on
///                   backfill; no active coach-mode feature yet.
/// - [ownerUuid]     Coach-mode hook (nullable). Defaults to local user.
class TrainingCycles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  IntColumn get periodsTotal => integer()();
  IntColumn get daysPerPeriod => integer()();
  IntColumn get recoveryPeriod => integer()();
  IntColumn get status => integer()(); // TrainingCycleStatus enum
  IntColumn get gender => integer().nullable()(); // Gender enum
  DateTimeColumn get createdDate => dateTime()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get muscleGroupPriorities =>
      text().nullable()(); // JSON Map<String, int>
  TextColumn get templateName => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get recoveryPeriodType =>
      integer().nullable()(); // RecoveryPeriodType enum
  IntColumn get primarySport => integer().nullable()(); // Sport enum (v5)
  TextColumn get creatorUuid => text().nullable()(); // v5 coach-mode hook
  TextColumn get ownerUuid => text().nullable()(); // v5 coach-mode hook
}

/// Workouts table - individual workout sessions
///
/// LEGACY as of v5: user-facing code moves to [Sessions]. The row-level
/// semantics here are unchanged and the table stays populated during v5 so
/// existing code keeps working. Will be dropped in a later v6 migration once
/// all readers are on [SessionDao].
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get trainingCycleUuid =>
      text().references(TrainingCycles, #uuid)();
  IntColumn get periodNumber => integer()();
  IntColumn get dayNumber => integer()();
  TextColumn get dayName => text().nullable()();
  TextColumn get label => text().nullable()();
  IntColumn get status => integer()(); // WorkoutStatus enum
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Exercises table - exercise instances within workouts (strength sessions)
///
/// v5: [sessionUuid] added alongside [workoutUuid] so exercises can be
/// resolved through the new [Sessions] table. Both columns stay populated
/// during the transition; [workoutUuid] will be dropped in v6.
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get workoutUuid => text().references(Workouts, #uuid)();
  TextColumn get sessionUuid => text().nullable()(); // v5; FK to sessions.uuid
  TextColumn get name => text()();
  IntColumn get muscleGroup => integer()(); // MuscleGroup enum (primary)
  IntColumn get secondaryMuscleGroup =>
      integer().nullable()(); // MuscleGroup enum (optional)
  IntColumn get equipmentType => integer()(); // EquipmentType enum
  IntColumn get orderIndex => integer()();
  RealColumn get bodyweight => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get lastPerformed => dateTime().nullable()();
  TextColumn get videoUrl => text().nullable()();
  BoolColumn get isNotePinned => boolean().withDefault(const Constant(false))();
  IntColumn get restSeconds => integer().nullable()();
}

/// Exercise Sets table - individual sets within exercises
class ExerciseSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get exerciseUuid => text().references(Exercises, #uuid)();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real().nullable()();
  TextColumn get reps => text()();
  IntColumn get setType => integer()(); // SetType enum
  BoolColumn get isLogged => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
}

/// Exercise Feedback table - feedback for exercises (strength-only)
///
/// v5: [sessionUuid] added alongside [exerciseUuid]. Kept nullable so
/// legacy rows stay valid until the v5 backfill runs.
class ExerciseFeedbacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseUuid =>
      text().unique().references(Exercises, #uuid)(); // One-to-one
  TextColumn get sessionUuid => text().nullable()(); // v5
  IntColumn get jointPain => integer().nullable()(); // JointPain enum
  IntColumn get musclePump => integer().nullable()(); // MusclePump enum
  IntColumn get workload => integer().nullable()(); // Workload enum
  IntColumn get soreness => integer().nullable()(); // Soreness enum
  TextColumn get muscleGroupSoreness =>
      text().nullable()(); // JSON Map<String, int>
  DateTimeColumn get timestamp => dateTime().nullable()();
}

/// Custom Exercise Definitions table - user-created exercises
class CustomExerciseDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  IntColumn get muscleGroup => integer()(); // MuscleGroup enum (primary)
  IntColumn get secondaryMuscleGroup =>
      integer().nullable()(); // MuscleGroup enum (optional)
  IntColumn get equipmentType => integer()(); // EquipmentType enum
  TextColumn get videoUrl => text().nullable()();
  IntColumn get restSeconds => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// User Measurements table - body composition tracking
class UserMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get notes => text().nullable()();
  RealColumn get bodyFatPercent => real().nullable()();
  RealColumn get leanMassKg => real().nullable()();
}

/// Skins table - custom theme storage
class Skins extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get skinJson => text()(); // Full SkinModel as JSON
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

// ---------------------------------------------------------------------------
// v5 — Multi-sport expansion. New tables below this line.
// ---------------------------------------------------------------------------

/// Sessions table - polymorphic "workout" that covers strength, run, bike,
/// swim. One row per training action of any kind.
///
/// - Strength sessions: have related rows in [Exercises] / [ExerciseSets].
/// - Cardio sessions:  have a 1:1 [SessionCardio] row and 0..N
///                     [SessionIntervals] rows.
///
/// [trainingCycleUuid] is nullable so ad-hoc (non-plan) sessions can exist
/// without being tied to a cycle — used when importing from HealthKit etc.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get trainingCycleUuid =>
      text().nullable().references(TrainingCycles, #uuid)();
  IntColumn get sport => integer()(); // Sport enum
  IntColumn get source => integer()(); // SessionSource enum
  IntColumn get periodNumber => integer().nullable()();
  IntColumn get dayNumber => integer().nullable()();
  TextColumn get dayName => text().nullable()();
  TextColumn get label => text().nullable()();
  IntColumn get status => integer()(); // WorkoutStatus enum (reused)
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get externalId => text().nullable()();
  TextColumn get creatorUuid => text().nullable()(); // coach-mode hook
  TextColumn get ownerUuid => text().nullable()(); // coach-mode hook
}

/// Cycle Periods table - 1 row per (trainingCycle, periodNumber).
///
/// Adds a first-class endurance [TrainingPhase] per period (base / build /
/// peak / taper / transition). Strength-only cycles leave [phase] null and
/// rely on the existing [TrainingCycles.recoveryPeriodType] instead.
///
/// Also the natural home for future coach notes / compliance flags.
class CyclePeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get trainingCycleUuid =>
      text().references(TrainingCycles, #uuid)();
  IntColumn get periodNumber => integer()();
  IntColumn get phase => integer().nullable()(); // TrainingPhase enum
  TextColumn get notes => text().nullable()();
  TextColumn get creatorUuid => text().nullable()();
  TextColumn get ownerUuid => text().nullable()();

  @override
  List<String> get customConstraints => [
    'UNIQUE (training_cycle_uuid, period_number)',
  ];
}

/// Session Cardio table - aggregates for a single cardio session (1:1).
///
/// Planned values are what the user / coach intended; actual values are what
/// got recorded (manually or by import). Either side can be null — a purely
/// planned session has no actuals yet, a HealthKit import has no planned
/// values.
class SessionCardio extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionUuid =>
      text().unique().references(Sessions, #uuid)(); // 1:1
  // Distance / duration -----------------------------------------------------
  RealColumn get plannedDistanceM => real().nullable()();
  RealColumn get actualDistanceM => real().nullable()();
  IntColumn get plannedDurationSec => integer().nullable()();
  IntColumn get actualDurationSec => integer().nullable()();
  // Elevation ---------------------------------------------------------------
  RealColumn get elevationGainM => real().nullable()();
  RealColumn get elevationLossM => real().nullable()();
  // Heart rate --------------------------------------------------------------
  IntColumn get averageHr => integer().nullable()();
  IntColumn get maxHr => integer().nullable()();
  // Cadence / power (bike / run) -------------------------------------------
  RealColumn get averageCadence => real().nullable()();
  RealColumn get averagePowerWatts => real().nullable()();
  RealColumn get normalizedPowerWatts => real().nullable()();
  // Speed / pace ------------------------------------------------------------
  RealColumn get averageSpeedMps => real().nullable()();
  RealColumn get averagePaceSecPerMeter => real().nullable()();
  // Swim --------------------------------------------------------------------
  RealColumn get poolLengthM => real().nullable()();
  IntColumn get strokeType => integer().nullable()(); // StrokeType enum
  IntColumn get lapCount => integer().nullable()();
  IntColumn get swolf => integer().nullable()();
  // Subjective --------------------------------------------------------------
  IntColumn get perceivedExertion => integer().nullable()(); // 1..10 RPE
  TextColumn get notes => text().nullable()();
}

/// Session Intervals table - structured workout steps (planned + executed).
///
/// Target fields: only one set is populated per row, chosen by [targetKind].
/// [repeatCount] is non-null for repeat-group rows; [parentIntervalUuid]
/// points at the repeat-group row for intervals inside a repeat.
class SessionIntervals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get sessionUuid => text().references(Sessions, #uuid)();
  IntColumn get orderIndex => integer()();
  IntColumn get intentType => integer()(); // IntervalIntent enum
  IntColumn get targetKind => integer()(); // IntervalTargetKind enum
  // Target values (only one group populated based on targetKind) ------------
  IntColumn get targetDurationSec => integer().nullable()();
  RealColumn get targetDistanceM => real().nullable()();
  IntColumn get targetHrZone => integer().nullable()(); // 1..5
  IntColumn get targetPaceZone => integer().nullable()();
  IntColumn get targetPowerZone => integer().nullable()();
  RealColumn get targetValueMin => real().nullable()(); // numeric lower bound
  RealColumn get targetValueMax => real().nullable()(); // numeric upper bound
  TextColumn get targetFreeform => text().nullable()();
  // Actual (executed) values ------------------------------------------------
  IntColumn get actualDurationSec => integer().nullable()();
  RealColumn get actualDistanceM => real().nullable()();
  IntColumn get actualAverageHr => integer().nullable()();
  RealColumn get actualAveragePaceSecPerMeter => real().nullable()();
  RealColumn get actualAveragePowerWatts => real().nullable()();
  // Repeat-group support ----------------------------------------------------
  IntColumn get repeatCount => integer().nullable()();
  TextColumn get parentIntervalUuid => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Session Samples table - high-resolution recorded streams.
///
/// Optional. Most sessions will have no samples (only aggregates in
/// [SessionCardio]); imports may bring them along. Kept in its own table so
/// the session list can be paged without loading potentially thousands of
/// sample rows per row.
class SessionSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionUuid => text().references(Sessions, #uuid)();
  IntColumn get offsetSec => integer()();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
  IntColumn get hr => integer().nullable()();
  RealColumn get cadence => real().nullable()();
  RealColumn get powerW => real().nullable()();
  RealColumn get speedMps => real().nullable()();
  RealColumn get strokeRate => real().nullable()();
}

/// Sport Zones table - per-user, per-sport training zones (HR / pace /
/// power). Typically 5 zones per sport. [unit] describes what [minValue] /
/// [maxValue] are measured in (e.g. "bpm", "sec_per_km", "watts").
class SportZones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  IntColumn get sport => integer()(); // Sport enum
  IntColumn get zoneNumber => integer()(); // 1..5
  RealColumn get minValue => real()();
  RealColumn get maxValue => real()();
  TextColumn get unit => text()();
  TextColumn get ownerUuid => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Cardio Feedback table - post-session subjective feedback for cardio
/// sessions. Parallels [ExerciseFeedbacks] but with cardio-appropriate
/// questions (RPE, breathing, GI comfort, weather).
class CardioFeedback extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionUuid =>
      text().unique().references(Sessions, #uuid)(); // 1:1
  IntColumn get rpe => integer().nullable()(); // 1..10
  IntColumn get breathing => integer().nullable()(); // 1..5
  IntColumn get giComfort => integer().nullable()(); // 1..5
  TextColumn get weather => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
  TextColumn get creatorUuid => text().nullable()();
  TextColumn get ownerUuid => text().nullable()();
}
