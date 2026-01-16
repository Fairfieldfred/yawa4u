// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_feedback_dao.dart';

// ignore_for_file: type=lint
mixin _$ExerciseFeedbackDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $WorkoutsTable get workouts => attachedDatabase.workouts;
  $ExercisesTable get exercises => attachedDatabase.exercises;
  $ExerciseFeedbacksTable get exerciseFeedbacks =>
      attachedDatabase.exerciseFeedbacks;
  ExerciseFeedbackDaoManager get managers => ExerciseFeedbackDaoManager(this);
}

class ExerciseFeedbackDaoManager {
  final _$ExerciseFeedbackDaoMixin _db;
  ExerciseFeedbackDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(
        _db.attachedDatabase,
        _db.trainingCycles,
      );
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db.attachedDatabase, _db.workouts);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db.attachedDatabase, _db.exercises);
  $$ExerciseFeedbacksTableTableManager get exerciseFeedbacks =>
      $$ExerciseFeedbacksTableTableManager(
        _db.attachedDatabase,
        _db.exerciseFeedbacks,
      );
}
