import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'session_dao.g.dart';

/// Data Access Object for the [Sessions] table.
///
/// Sessions are the polymorphic "workout" in v5+. Strength sessions have
/// related rows in [Exercises] / [ExerciseSets]; cardio sessions have rows
/// in [SessionCardio] / [SessionIntervals] / [SessionSamples].
@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<List<Session>> getAll() => select(sessions).get();

  Stream<List<Session>> watchAll() => select(sessions).watch();

  Future<List<Session>> getByTrainingCycleUuid(String trainingCycleUuid) {
    return (select(sessions)
          ..where((s) => s.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([
            (s) => OrderingTerm.asc(s.periodNumber),
            (s) => OrderingTerm.asc(s.dayNumber),
          ]))
        .get();
  }

  Stream<List<Session>> watchByTrainingCycleUuid(String trainingCycleUuid) {
    return (select(sessions)
          ..where((s) => s.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([
            (s) => OrderingTerm.asc(s.periodNumber),
            (s) => OrderingTerm.asc(s.dayNumber),
          ]))
        .watch();
  }

  Future<Session?> getByUuid(String uuid) {
    return (select(
      sessions,
    )..where((s) => s.uuid.equals(uuid))).getSingleOrNull();
  }

  Stream<Session?> watchByUuid(String uuid) {
    return (select(
      sessions,
    )..where((s) => s.uuid.equals(uuid))).watchSingleOrNull();
  }

  /// Sessions filtered by [Sport]. Order: scheduledDate ascending, nulls last.
  Future<List<Session>> getBySport(int sportIndex) {
    return (select(sessions)
          ..where((s) => s.sport.equals(sportIndex))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .get();
  }

  Stream<List<Session>> watchBySport(int sportIndex) {
    return (select(sessions)
          ..where((s) => s.sport.equals(sportIndex))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .watch();
  }

  /// Cardio sessions (any sport except Sport.strength, which has index 0).
  Stream<List<Session>> watchCardio() {
    return (select(sessions)
          ..where((s) => s.sport.isNotValue(0))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .watch();
  }

  Future<List<Session>> getByDateRange(DateTime start, DateTime end) {
    return (select(sessions)
          ..where(
            (s) =>
                s.scheduledDate.isBiggerOrEqualValue(start) &
                s.scheduledDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .get();
  }

  Stream<List<Session>> watchByDateRange(DateTime start, DateTime end) {
    return (select(sessions)
          ..where(
            (s) =>
                s.scheduledDate.isBiggerOrEqualValue(start) &
                s.scheduledDate.isSmallerOrEqualValue(end),
          )
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .watch();
  }

  /// Look up a previously-imported session by its external identifier.
  /// Used by the health-sync import path to de-dupe.
  Future<Session?> getByExternalId(String externalId) {
    return (select(
      sessions,
    )..where((s) => s.externalId.equals(externalId))).getSingleOrNull();
  }

  Future<int> insertSession(SessionsCompanion session) {
    return into(sessions).insert(session);
  }

  Future<void> insertAll(List<SessionsCompanion> rows) {
    return batch((b) {
      b.insertAll(sessions, rows);
    });
  }

  Future<int> updateByUuid(String uuid, SessionsCompanion row) {
    return (update(sessions)..where((s) => s.uuid.equals(uuid))).write(row);
  }

  Future<int> deleteByUuid(String uuid) {
    return (delete(sessions)..where((s) => s.uuid.equals(uuid))).go();
  }

  Future<int> deleteByTrainingCycleUuid(String trainingCycleUuid) {
    return (delete(
      sessions,
    )..where((s) => s.trainingCycleUuid.equals(trainingCycleUuid))).go();
  }

  /// Cascade delete a session and every related row in its child tables.
  /// Safe for both strength and cardio sessions.
  Future<void> cascadeDeleteByUuid(String sessionUuid) async {
    await customStatement(
      'DELETE FROM session_samples WHERE session_uuid = ?',
      [sessionUuid],
    );
    await customStatement(
      'DELETE FROM session_intervals WHERE session_uuid = ?',
      [sessionUuid],
    );
    await customStatement(
      'DELETE FROM session_cardio WHERE session_uuid = ?',
      [sessionUuid],
    );
    await customStatement(
      'DELETE FROM cardio_feedback WHERE session_uuid = ?',
      [sessionUuid],
    );
    await deleteByUuid(sessionUuid);
  }

  Future<int> countRows() async {
    final countExp = sessions.id.count();
    final query = selectOnly(sessions)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  Future<int> deleteAll() => delete(sessions).go();
}
