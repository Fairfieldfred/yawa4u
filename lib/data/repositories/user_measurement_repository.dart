import 'package:uuid/uuid.dart';

import '../database/daos/user_measurement_dao.dart';
import '../database/mappers/secondary_mappers.dart';
import '../models/user_measurement.dart';

/// Repository for managing user body measurements using Drift
class UserMeasurementRepository {
  final UserMeasurementDao _dao;
  final _uuid = const Uuid();

  UserMeasurementRepository(this._dao);

  /// Watch all measurements (for reactive UI updates)
  Stream<List<UserMeasurement>> watchAll() {
    return _dao.watchAllSorted().map((rows) {
      return rows.map((row) => UserMeasurementMapper.fromRow(row)).toList();
    });
  }

  /// Get all measurements sorted by date (newest first)
  Future<List<UserMeasurement>> getAll() async {
    final rows = await _dao.getAllSorted();
    return rows.map((row) => UserMeasurementMapper.fromRow(row)).toList();
  }

  /// Get the most recent measurement
  Future<UserMeasurement?> getLatest() async {
    final row = await _dao.getMostRecent();
    return row != null ? UserMeasurementMapper.fromRow(row) : null;
  }

  /// Get measurements within a date range (uses DB query)
  Future<List<UserMeasurement>> getInRange(DateTime start, DateTime end) async {
    final rows = await _dao.getByDateRange(start, end);
    return rows.map((row) => UserMeasurementMapper.fromRow(row)).toList();
  }

  /// Get measurements for the last N days
  Future<List<UserMeasurement>> getLastDays(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return getInRange(cutoff, DateTime.now());
  }

  /// Add a new measurement
  Future<UserMeasurement> add({
    required double heightCm,
    required double weightKg,
    DateTime? timestamp,
    String? notes,
    double? bodyFatPercent,
    double? leanMassKg,
  }) async {
    final measurement = UserMeasurement(
      id: _uuid.v4(),
      heightCm: heightCm,
      weightKg: weightKg,
      timestamp: timestamp ?? DateTime.now(),
      notes: notes,
      bodyFatPercent: bodyFatPercent,
      leanMassKg: leanMassKg,
    );
    final companion = UserMeasurementMapper.toCompanion(measurement);
    await _dao.insertMeasurement(companion);
    return measurement;
  }

  /// Update an existing measurement (uses proper DAO updateByUuid)
  Future<void> update(UserMeasurement measurement) async {
    final companion = UserMeasurementMapper.toCompanion(measurement);
    await _dao.updateByUuid(measurement.id, companion);
  }

  /// Delete a measurement by ID
  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }

  /// Delete all measurements
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }

  /// Get the number of measurements (uses SQL COUNT)
  Future<int> count() async {
    return _dao.countRows();
  }

  /// Check if there are any measurements
  Future<bool> isEmpty() async {
    final c = await count();
    return c == 0;
  }

  /// Check if there are measurements
  Future<bool> isNotEmpty() async {
    final c = await count();
    return c > 0;
  }

  /// Get BMI history for graphing (returns list of {date, bmi} maps)
  Future<List<Map<String, dynamic>>> getBmiHistory() async {
    final all = await getAll();
    return all
        .map(
          (m) => {
            'date': m.timestamp,
            'bmi': m.bmi,
            'weight': m.weightKg,
            'height': m.heightCm,
          },
        )
        .toList();
  }
}
