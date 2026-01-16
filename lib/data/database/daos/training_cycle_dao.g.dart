// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_cycle_dao.dart';

// ignore_for_file: type=lint
mixin _$TrainingCycleDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  TrainingCycleDaoManager get managers => TrainingCycleDaoManager(this);
}

class TrainingCycleDaoManager {
  final _$TrainingCycleDaoMixin _db;
  TrainingCycleDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(
        _db.attachedDatabase,
        _db.trainingCycles,
      );
}
