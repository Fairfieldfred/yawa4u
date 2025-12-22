import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/user_measurement.dart';

/// Repository for managing user body measurements
///
/// Provides CRUD operations for UserMeasurement objects stored in Hive.
class UserMeasurementRepository {
  final Box<UserMeasurement> _box;
  final _uuid = const Uuid();

  UserMeasurementRepository(this._box);

  /// Get all measurements sorted by date (newest first)
  List<UserMeasurement> getAll() {
    final measurements = _box.values.toList();
    measurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return measurements;
  }

  /// Get the most recent measurement
  UserMeasurement? getLatest() {
    if (_box.isEmpty) return null;
    final measurements = getAll();
    return measurements.isNotEmpty ? measurements.first : null;
  }

  /// Get measurements within a date range
  List<UserMeasurement> getInRange(DateTime start, DateTime end) {
    return getAll()
        .where(
          (m) =>
              m.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
              m.timestamp.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList();
  }

  /// Get measurements for the last N days
  List<UserMeasurement> getLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return getAll().where((m) => m.timestamp.isAfter(cutoff)).toList();
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
    await _box.put(measurement.id, measurement);
    return measurement;
  }

  /// Update an existing measurement
  Future<void> update(UserMeasurement measurement) async {
    await _box.put(measurement.id, measurement);
  }

  /// Delete a measurement by ID
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all measurements
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Get the number of measurements
  int get count => _box.length;

  /// Check if there are any measurements
  bool get isEmpty => _box.isEmpty;

  /// Check if there are measurements
  bool get isNotEmpty => _box.isNotEmpty;

  /// Get BMI history for graphing (returns list of {date, bmi} maps)
  List<Map<String, dynamic>> getBmiHistory() {
    return getAll()
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

  /// Get body composition history for graphing
  List<Map<String, dynamic>> getBodyCompositionHistory() {
    return getAll()
        .where((m) => m.bodyFatPercent != null)
        .map(
          (m) => {
            'date': m.timestamp,
            'bodyFatPercent': m.bodyFatPercent,
            'leanMassKg': m.calculatedLeanMassKg,
            'fatMassKg': m.fatMassKg,
            'weight': m.weightKg,
          },
        )
        .toList();
  }
}
