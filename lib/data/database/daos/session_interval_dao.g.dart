// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_interval_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionIntervalDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionIntervalsTable get sessionIntervals => attachedDatabase.sessionIntervals;
  SessionIntervalDaoManager get managers => SessionIntervalDaoManager(this);
}

class SessionIntervalDaoManager {
  final _$SessionIntervalDaoMixin _db;
  SessionIntervalDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles => $$TrainingCyclesTableTableManager(
    _db.attachedDatabase,
    _db.trainingCycles,
  );
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$SessionIntervalsTableTableManager get sessionIntervals => $$SessionIntervalsTableTableManager(
    _db.attachedDatabase,
    _db.sessionIntervals,
  );
}
