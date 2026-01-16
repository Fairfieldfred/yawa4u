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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will be handled here
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
