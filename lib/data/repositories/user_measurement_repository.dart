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
      final measurements = rows
          .map((row) => UserMeasurementMapper.fromRow(row))
          .toList();
      measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return measurements;
    });
  }

  /// Get all measurements sorted by date (newest first)
  Future<List<UserMeasurement>> getAll() async {
    final rows = await _dao.getAllSorted();
    final measurements = rows
        .map((row) => UserMeasurementMapper.fromRow(row))
        .toList();
    measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return measurements;
  }

  /// Get the most recent measurement
  Future<UserMeasurement?> getLatest() async {
    final measurements = await getAll();
    return measurements.isNotEmpty ? measurements.first : null;
  }

  /// Get measurements within a date range
  Future<List<UserMeasurement>> getInRange(DateTime start, DateTime end) async {
    final all = await getAll();
    return all
        .where(
          (m) =>
              m.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
              m.timestamp.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  /// Get measurements for the last N days
  Future<List<UserMeasurement>> getLastDays(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final all = await getAll();
    return all.where((m) => m.timestamp.isAfter(cutoff)).toList();
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

  /// Update an existing measurement
  Future<void> update(UserMeasurement measurement) async {
    final companion = UserMeasurementMapper.toCompanion(measurement);
    final existing = await _dao.getByUuid(measurement.id);
    if (existing != null) {
      // We need to update by uuid but the companion needs the original id
      await _dao.deleteByUuid(measurement.id);
      await _dao.insertMeasurement(companion);
    }
  }

  /// Delete a measurement by ID
  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }

  /// Delete all measurements
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }

  /// Get the number of measurements
  Future<int> count() async {
    final all = await getAll();
    return all.length;
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
