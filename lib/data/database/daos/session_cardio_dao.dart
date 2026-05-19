import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'session_cardio_dao.g.dart';

/// Data Access Object for the [SessionCardio] table. One row per cardio
/// session (1:1 with [Sessions] keyed by sessionUuid).
@DriftAccessor(tables: [SessionCardio])
class SessionCardioDao extends DatabaseAccessor<AppDatabase> with _$SessionCardioDaoMixin {
  SessionCardioDao(super.db);

  Future<SessionCardioData?> getBySessionUuid(String sessionUuid) {
    return (select(
      sessionCardio,
    )..where((c) => c.sessionUuid.equals(sessionUuid))).getSingleOrNull();
  }

  Stream<SessionCardioData?> watchBySessionUuid(String sessionUuid) {
    return (select(
      sessionCardio,
    )..where((c) => c.sessionUuid.equals(sessionUuid))).watchSingleOrNull();
  }

  Future<int> upsert(SessionCardioCompanion row) {
    return into(
      sessionCardio,
    ).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteBySessionUuid(String sessionUuid) {
    return (delete(
      sessionCardio,
    )..where((c) => c.sessionUuid.equals(sessionUuid))).go();
  }

  Future<int> deleteAll() => delete(sessionCardio).go();
}
