import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'sport_zone_dao.g.dart';

/// Data Access Object for the [SportZones] table.
///
/// Stores per-user, per-sport training zones (typically 5 per sport) for
/// heart rate, pace, or power. [SportZones.unit] describes what min/max are
/// measured in (e.g. "bpm", "sec_per_km", "watts").
@DriftAccessor(tables: [SportZones])
class SportZoneDao extends DatabaseAccessor<AppDatabase>
    with _$SportZoneDaoMixin {
  SportZoneDao(super.db);

  Future<List<SportZone>> getAll() => select(sportZones).get();

  Stream<List<SportZone>> watchAll() => select(sportZones).watch();

  Future<List<SportZone>> getBySport(int sportIndex) {
    return (select(sportZones)
          ..where((z) => z.sport.equals(sportIndex))
          ..orderBy([(z) => OrderingTerm.asc(z.zoneNumber)]))
        .get();
  }

  Stream<List<SportZone>> watchBySport(int sportIndex) {
    return (select(sportZones)
          ..where((z) => z.sport.equals(sportIndex))
          ..orderBy([(z) => OrderingTerm.asc(z.zoneNumber)]))
        .watch();
  }

  Future<SportZone?> getByUuid(String uuid) {
    return (select(
      sportZones,
    )..where((z) => z.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> insertZone(SportZonesCompanion row) {
    return into(sportZones).insert(row);
  }

  Future<void> insertAll(List<SportZonesCompanion> rows) {
    return batch((b) {
      b.insertAll(sportZones, rows);
    });
  }

  Future<int> updateByUuid(String uuid, SportZonesCompanion row) {
    return (update(
      sportZones,
    )..where((z) => z.uuid.equals(uuid))).write(row);
  }

  Future<int> deleteByUuid(String uuid) {
    return (delete(sportZones)..where((z) => z.uuid.equals(uuid))).go();
  }

  Future<int> deleteBySport(int sportIndex) {
    return (delete(sportZones)..where((z) => z.sport.equals(sportIndex))).go();
  }

  Future<int> deleteAll() => delete(sportZones).go();
}
