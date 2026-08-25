// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $SessionsTable get sessions => attachedDatabase.sessions;
  SessionDaoManager get managers => SessionDaoManager(this);
}

class SessionDaoManager {
  final _$SessionDaoMixin _db;
  SessionDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(
        _db.attachedDatabase,
        _db.trainingCycles,
      );
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
}
