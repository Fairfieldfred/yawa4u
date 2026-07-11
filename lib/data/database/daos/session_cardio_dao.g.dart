// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_cardio_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionCardioDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SessionCardioTable get sessionCardio => attachedDatabase.sessionCardio;
  SessionCardioDaoManager get managers => SessionCardioDaoManager(this);
}

class SessionCardioDaoManager {
  final _$SessionCardioDaoMixin _db;
  SessionCardioDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles => $$TrainingCyclesTableTableManager(
    _db.attachedDatabase,
    _db.trainingCycles,
  );
  $$SessionsTableTableManager get sessions => $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$SessionCardioTableTableManager get sessionCardio =>
      $$SessionCardioTableTableManager(_db.attachedDatabase, _db.sessionCardio);
}
