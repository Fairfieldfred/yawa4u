import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'session_sample_dao.g.dart';

/// Data Access Object for the [SessionSamples] table.
///
/// Samples can be high-volume (one per second of recorded activity).
/// Callers should prefer aggregated reads unless they really need the
/// stream; the repository layer gates sample loading behind an explicit
/// opt-in for this reason.
@DriftAccessor(tables: [SessionSamples])
class SessionSampleDao extends DatabaseAccessor<AppDatabase> with _$SessionSampleDaoMixin {
  SessionSampleDao(super.db);

  Future<List<SessionSample>> getBySessionUuid(String sessionUuid) {
    return (select(sessionSamples)
          ..where((s) => s.sessionUuid.equals(sessionUuid))
          ..orderBy([(s) => OrderingTerm.asc(s.offsetSec)]))
        .get();
  }

  Future<int> countBySessionUuid(String sessionUuid) async {
    final countExp = sessionSamples.id.count();
    final query = selectOnly(sessionSamples)
      ..addColumns([countExp])
      ..where(sessionSamples.sessionUuid.equals(sessionUuid));
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  Future<void> insertAll(List<SessionSamplesCompanion> rows) {
    return batch((b) {
      b.insertAll(sessionSamples, rows);
    });
  }

  Future<int> deleteBySessionUuid(String sessionUuid) {
    return (delete(
      sessionSamples,
    )..where((s) => s.sessionUuid.equals(sessionUuid))).go();
  }

  Future<int> deleteAll() => delete(sessionSamples).go();
}
