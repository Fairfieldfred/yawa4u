import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/daos.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// For testing with an in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

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
