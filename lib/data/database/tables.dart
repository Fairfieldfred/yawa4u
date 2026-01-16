import 'package:drift/drift.dart';

/// Training Cycles table - top-level training program container
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
}

/// Workouts table - individual workout sessions
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
  TextColumn get notes => text().nullable()();
}

/// Exercises table - exercise instances within workouts
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get workoutUuid => text().references(Workouts, #uuid)();
  TextColumn get name => text()();
  IntColumn get muscleGroup => integer()(); // MuscleGroup enum
  IntColumn get equipmentType => integer()(); // EquipmentType enum
  IntColumn get orderIndex => integer()();
  RealColumn get bodyweight => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get lastPerformed => dateTime().nullable()();
  TextColumn get videoUrl => text().nullable()();
  BoolColumn get isNotePinned => boolean().withDefault(const Constant(false))();
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

/// Exercise Feedback table - feedback for exercises
class ExerciseFeedbacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseUuid =>
      text().unique().references(Exercises, #uuid)(); // One-to-one
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
  IntColumn get muscleGroup => integer()(); // MuscleGroup enum
  IntColumn get equipmentType => integer()(); // EquipmentType enum
  TextColumn get videoUrl => text().nullable()();
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
