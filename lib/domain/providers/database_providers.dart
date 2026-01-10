import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/custom_exercise_definition.dart';
import '../../data/models/exercise.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/user_measurement.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/user_measurement_repository.dart';
import '../../data/services/csv_loader_service.dart';
import '../../data/services/database_service.dart';

/// Provider for DatabaseService singleton
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for CsvLoaderService singleton
final csvLoaderServiceProvider = Provider<CsvLoaderService>((ref) {
  return CsvLoaderService();
});

/// Provider for TrainingCycle Hive box
final trainingCyclesBoxProvider = Provider<Box<TrainingCycle>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.trainingCyclesBox;
});

/// Provider for Workout Hive box
final workoutsBoxProvider = Provider<Box<Workout>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.workoutsBox;
});

/// Provider for Exercise Hive box
final exercisesBoxProvider = Provider<Box<Exercise>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.exercisesBox;
});

/// Provider for Custom Exercise Definition Hive box
final customExercisesBoxProvider = Provider<Box<CustomExerciseDefinition>>((
  ref,
) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.customExercisesBox;
});

/// Provider for User Measurement Hive box
final userMeasurementsBoxProvider = Provider<Box<UserMeasurement>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.userMeasurementsBox;
});

/// Provider for UserMeasurementRepository
final userMeasurementRepositoryProvider = Provider<UserMeasurementRepository>((
  ref,
) {
  final box = ref.watch(userMeasurementsBoxProvider);
  return UserMeasurementRepository(box);
});

/// Provider for database initialization status
final databaseInitializedProvider = Provider<bool>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.isInitialized;
});

/// Provider for CSV exercises loaded status
final exercisesLoadedProvider = Provider<bool>((ref) {
  final csvService = ref.watch(csvLoaderServiceProvider);
  return csvService.isLoaded;
});
