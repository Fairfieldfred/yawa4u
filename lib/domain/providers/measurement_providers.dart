import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_measurement.dart';
import 'database_providers.dart';

/// Reactive stream of all user measurements, sorted by timestamp.
final userMeasurementsProvider =
    StreamProvider<List<UserMeasurement>>((ref) {
  final repository = ref.watch(userMeasurementRepositoryProvider);
  return repository.watchAll();
});

/// Latest measurement for quick display.
final latestMeasurementProvider =
    FutureProvider<UserMeasurement?>((ref) {
  final repository = ref.watch(userMeasurementRepositoryProvider);
  return repository.getLatest();
});
