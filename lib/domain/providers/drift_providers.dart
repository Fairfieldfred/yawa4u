import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/daos/daos.dart';

/// Global AppDatabase instance provider
/// This is overridden in main.dart after database initialization
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with a valid AppDatabase instance',
  );
});

/// TrainingCycleDao provider
final trainingCycleDaoProvider = Provider<TrainingCycleDao>((ref) {
  return TrainingCycleDao(ref.watch(appDatabaseProvider));
});

/// WorkoutDao provider
final workoutDaoProvider = Provider<WorkoutDao>((ref) {
  return WorkoutDao(ref.watch(appDatabaseProvider));
});

/// ExerciseDao provider
final exerciseDaoProvider = Provider<ExerciseDao>((ref) {
  return ExerciseDao(ref.watch(appDatabaseProvider));
});

/// ExerciseSetDao provider
final exerciseSetDaoProvider = Provider<ExerciseSetDao>((ref) {
  return ExerciseSetDao(ref.watch(appDatabaseProvider));
});

/// ExerciseFeedbackDao provider
final exerciseFeedbackDaoProvider = Provider<ExerciseFeedbackDao>((ref) {
  return ExerciseFeedbackDao(ref.watch(appDatabaseProvider));
});

/// CustomExerciseDao provider
final customExerciseDaoProvider = Provider<CustomExerciseDao>((ref) {
  return CustomExerciseDao(ref.watch(appDatabaseProvider));
});

/// UserMeasurementDao provider
final userMeasurementDaoProvider = Provider<UserMeasurementDao>((ref) {
  return UserMeasurementDao(ref.watch(appDatabaseProvider));
});

/// SkinDao provider
final skinDaoProvider = Provider<SkinDao>((ref) {
  return SkinDao(ref.watch(appDatabaseProvider));
});
