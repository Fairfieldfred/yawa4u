import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'user_measurement_dao.g.dart';

/// Data Access Object for UserMeasurements table
@DriftAccessor(tables: [UserMeasurements])
class UserMeasurementDao extends DatabaseAccessor<AppDatabase>
    with _$UserMeasurementDaoMixin {
  UserMeasurementDao(super.db);

  /// Get all measurements sorted by timestamp descending
  Future<List<UserMeasurement>> getAllSorted() {
    return (select(
      userMeasurements,
    )..orderBy([(m) => OrderingTerm.desc(m.timestamp)])).get();
  }

  /// Watch all measurements for reactive updates
  Stream<List<UserMeasurement>> watchAllSorted() {
    return (select(
      userMeasurements,
    )..orderBy([(m) => OrderingTerm.desc(m.timestamp)])).watch();
  }

  /// Get the most recent measurement
  Future<UserMeasurement?> getMostRecent() {
    return (select(userMeasurements)
          ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Watch the most recent measurement
  Stream<UserMeasurement?> watchMostRecent() {
    return (select(userMeasurements)
          ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Get a measurement by UUID
  Future<UserMeasurement?> getByUuid(String uuid) {
    return (select(
      userMeasurements,
    )..where((m) => m.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Get measurements within a date range
  Future<List<UserMeasurement>> getByDateRange(DateTime start, DateTime end) {
    return (select(userMeasurements)
          ..where(
            (m) =>
                m.timestamp.isBiggerOrEqualValue(start) &
                m.timestamp.isSmallerOrEqualValue(end),
          )
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
        .get();
  }

  /// Insert a new measurement
  Future<int> insertMeasurement(UserMeasurementsCompanion measurement) {
    return into(userMeasurements).insert(measurement);
  }

  /// Update an existing measurement
  Future<bool> updateMeasurement(UserMeasurement measurement) {
    return update(userMeasurements).replace(measurement);
  }

  /// Delete a measurement by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(userMeasurements)..where((m) => m.uuid.equals(uuid))).go();
  }

  /// Delete all measurements
  Future<int> deleteAll() {
    return delete(userMeasurements).go();
  }
}
