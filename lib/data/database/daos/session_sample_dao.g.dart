// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_sample_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionSampleDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionSamplesTable get sessionSamples => attachedDatabase.sessionSamples;
  SessionSampleDaoManager get managers => SessionSampleDaoManager(this);
}

class SessionSampleDaoManager {
  final _$SessionSampleDaoMixin _db;
  SessionSampleDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles => $$TrainingCyclesTableTableManager(
    _db.attachedDatabase,
    _db.trainingCycles,
  );
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$SessionSamplesTableTableManager get sessionSamples => $$SessionSamplesTableTableManager(
    _db.attachedDatabase,
    _db.sessionSamples,
  );
}
