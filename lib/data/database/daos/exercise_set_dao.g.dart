// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseSetDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $WorkoutsTable get workouts => attachedDatabase.workouts;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseSetsTable get exerciseSets => attachedDatabase.exerciseSets;
  ExerciseSetDaoManager get managers => ExerciseSetDaoManager(this);
}

class ExerciseSetDaoManager {
  final _$ExerciseSetDaoMixin _db;
  ExerciseSetDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(
        _db.attachedDatabase,
        _db.trainingCycles,
      );
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db.attachedDatabase, _db.workouts);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseSetsTableTableManager get exerciseSets =>
      $$ExerciseSetsTableTableManager(_db.attachedDatabase, _db.exerciseSets);
}
