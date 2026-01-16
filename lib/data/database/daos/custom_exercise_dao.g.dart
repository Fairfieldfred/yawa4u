// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomExerciseDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomExerciseDefinitionsTable get customExerciseDefinitions =>
      attachedDatabase.customExerciseDefinitions;
  CustomExerciseDaoManager get managers => CustomExerciseDaoManager(this);
}

class CustomExerciseDaoManager {
  final _$CustomExerciseDaoMixin _db;
  CustomExerciseDaoManager(this._db);
  $$CustomExerciseDefinitionsTableTableManager get customExerciseDefinitions =>
      $$CustomExerciseDefinitionsTableTableManager(
        _db.attachedDatabase,
        _db.customExerciseDefinitions,
      );
}
