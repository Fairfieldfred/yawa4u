import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'session_interval_dao.g.dart';

/// Data Access Object for the [SessionIntervals] table. Each row is one step
/// of a structured cardio workout — warmup, work, recovery, cooldown, rest,
/// or a repeat-group header.
@DriftAccessor(tables: [SessionIntervals])
class SessionIntervalDao extends DatabaseAccessor<AppDatabase> with _$SessionIntervalDaoMixin {
  SessionIntervalDao(super.db);

  Future<List<SessionInterval>> getBySessionUuid(String sessionUuid) {
    return (select(sessionIntervals)
          ..where((i) => i.sessionUuid.equals(sessionUuid))
          ..orderBy([(i) => OrderingTerm.asc(i.orderIndex)]))
        .get();
  }

  Stream<List<SessionInterval>> watchBySessionUuid(String sessionUuid) {
    return (select(sessionIntervals)
          ..where((i) => i.sessionUuid.equals(sessionUuid))
          ..orderBy([(i) => OrderingTerm.asc(i.orderIndex)]))
        .watch();
  }

  Future<SessionInterval?> getByUuid(String uuid) {
    return (select(
      sessionIntervals,
    )..where((i) => i.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> insertInterval(SessionIntervalsCompanion row) {
    return into(sessionIntervals).insert(row);
  }

  Future<void> insertAll(List<SessionIntervalsCompanion> rows) {
    return batch((b) {
      b.insertAll(sessionIntervals, rows);
    });
  }

  Future<int> updateByUuid(String uuid, SessionIntervalsCompanion row) {
    return (update(
      sessionIntervals,
    )..where((i) => i.uuid.equals(uuid))).write(row);
  }

  Future<int> deleteByUuid(String uuid) {
    return (delete(sessionIntervals)..where((i) => i.uuid.equals(uuid))).go();
  }

  Future<int> deleteBySessionUuid(String sessionUuid) {
    return (delete(
      sessionIntervals,
    )..where((i) => i.sessionUuid.equals(sessionUuid))).go();
  }

  Future<int> deleteAll() => delete(sessionIntervals).go();
}
