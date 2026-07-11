// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_period_dao.dart';

// ignore_for_file: type=lint
mixin _$CyclePeriodDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $CyclePeriodsTable get cyclePeriods => attachedDatabase.cyclePeriods;
  CyclePeriodDaoManager get managers => CyclePeriodDaoManager(this);
}

class CyclePeriodDaoManager {
  final _$CyclePeriodDaoMixin _db;
  CyclePeriodDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles => $$TrainingCyclesTableTableManager(
    _db.attachedDatabase,
    _db.trainingCycles,
  );
  $$CyclePeriodsTableTableManager get cyclePeriods =>
      $$CyclePeriodsTableTableManager(_db.attachedDatabase, _db.cyclePeriods);
}
