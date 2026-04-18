import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/daos.dart';
import 'migrations/v5_backfill.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Main Drift database for the application
@DriftDatabase(
  tables: [
    TrainingCycles,
    Workouts,
    Exercises,
    ExerciseSets,
    ExerciseFeedbacks,
    CustomExerciseDefinitions,
    UserMeasurements,
    Skins,
    // v5 — multi-sport expansion
    Sessions,
    CyclePeriods,
    SessionCardio,
    SessionIntervals,
    SessionSamples,
    SportZones,
    CardioFeedback,
  ],
  daos: [
    TrainingCycleDao,
    WorkoutDao,
    ExerciseDao,
    ExerciseSetDao,
    ExerciseFeedbackDao,
    CustomExerciseDao,
    UserMeasurementDao,
    SkinDao,
    // v5 — multi-sport expansion
    SessionDao,
    CyclePeriodDao,
    SessionCardioDao,
    SessionIntervalDao,
    SessionSampleDao,
    SportZoneDao,
    CardioFeedbackDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// For testing with an in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration v1 -> v2: Add secondaryMuscleGroup column
        if (from < 2) {
          await m.addColumn(exercises, exercises.secondaryMuscleGroup);
          await m.addColumn(
            customExerciseDefinitions,
            customExerciseDefinitions.secondaryMuscleGroup,
          );
        }
        // Migration v2 -> v3: Add workout duration columns
        if (from < 3) {
          await m.addColumn(workouts, workouts.startTime);
          await m.addColumn(workouts, workouts.endTime);
        }
        // Migration v3 -> v4: Add rest seconds columns
        if (from < 4) {
          await m.addColumn(exercises, exercises.restSeconds);
          await m.addColumn(
            customExerciseDefinitions,
            customExerciseDefinitions.restSeconds,
          );
        }
        // Migration v4 -> v5: Multi-sport expansion.
        //
        // Structural-only in this commit. Data backfill
        // (creatorUuid / ownerUuid / primarySport / workouts->sessions copy
        // / cycle_periods generation) lives in a separate step wired up by
        // [AppDatabaseV5Backfill] so it can be tested and reasoned about
        // independently of the table / column shape.
        if (from < 5) {
          // New columns on existing tables
          await m.addColumn(trainingCycles, trainingCycles.primarySport);
          await m.addColumn(trainingCycles, trainingCycles.creatorUuid);
          await m.addColumn(trainingCycles, trainingCycles.ownerUuid);
          await m.addColumn(exercises, exercises.sessionUuid);
          await m.addColumn(exerciseFeedbacks, exerciseFeedbacks.sessionUuid);

          // New tables
          await m.createTable(sessions);
          await m.createTable(cyclePeriods);
          await m.createTable(sessionCardio);
          await m.createTable(sessionIntervals);
          await m.createTable(sessionSamples);
          await m.createTable(sportZones);
          await m.createTable(cardioFeedback);

          // Backfill existing rows so readers see a consistent v5 shape.
          await AppDatabaseV5Backfill(this).run();
        }
      },
      beforeOpen: (details) async {
        // Create indexes for frequently-filtered columns (idempotent)
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_training_cycles_status '
          'ON training_cycles(status)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workouts_training_cycle_uuid '
          'ON workouts(training_cycle_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workouts_status '
          'ON workouts(status)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_workouts_scheduled_date '
          'ON workouts(scheduled_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_exercises_workout_uuid '
          'ON exercises(workout_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_exercises_name '
          'ON exercises(name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_exercise_sets_exercise_uuid '
          'ON exercise_sets(exercise_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_exercise_feedbacks_exercise_uuid '
          'ON exercise_feedbacks(exercise_uuid)',
        );
        // v5 indexes
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sessions_training_cycle_uuid '
          'ON sessions(training_cycle_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sessions_sport '
          'ON sessions(sport)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sessions_scheduled_date '
          'ON sessions(scheduled_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sessions_external_id '
          'ON sessions(external_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cycle_periods_cycle_uuid '
          'ON cycle_periods(training_cycle_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_session_cardio_session_uuid '
          'ON session_cardio(session_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_session_intervals_session_uuid '
          'ON session_intervals(session_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_session_samples_session_uuid '
          'ON session_samples(session_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_exercises_session_uuid '
          'ON exercises(session_uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_sport_zones_sport '
          'ON sport_zones(sport)',
        );
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yawa4u.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
