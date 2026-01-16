import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/custom_exercise_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/training_cycle_repository.dart';
import '../../data/repositories/user_measurement_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/services/database_service.dart';

/// Provider for the DatabaseService singleton
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for the AppDatabase instance
/// This should be overridden in main.dart after initializing the database
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.database;
});

// =============================================================================
// DAO Providers
// =============================================================================

/// Provider for TrainingCycleDao
final trainingCycleDaoProvider = Provider<TrainingCycleDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.trainingCycleDao;
});

/// Provider for WorkoutDao
final workoutDaoProvider = Provider<WorkoutDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.workoutDao;
});

/// Provider for ExerciseDao
final exerciseDaoProvider = Provider<ExerciseDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.exerciseDao;
});

/// Provider for ExerciseSetDao
final exerciseSetDaoProvider = Provider<ExerciseSetDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.exerciseSetDao;
});

/// Provider for ExerciseFeedbackDao
final exerciseFeedbackDaoProvider = Provider<ExerciseFeedbackDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.exerciseFeedbackDao;
});

/// Provider for CustomExerciseDao
final customExerciseDaoProvider = Provider<CustomExerciseDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.customExerciseDao;
});

/// Provider for UserMeasurementDao
final userMeasurementDaoProvider = Provider<UserMeasurementDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.userMeasurementDao;
});

/// Provider for SkinDao
final skinDaoProvider = Provider<SkinDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.skinDao;
});

// =============================================================================
// Repository Providers
// =============================================================================

/// Provider for TrainingCycleRepository
final trainingCycleRepositoryProvider = Provider<TrainingCycleRepository>((
  ref,
) {
  final dao = ref.watch(trainingCycleDaoProvider);
  return TrainingCycleRepository(dao);
});

/// Provider for WorkoutRepository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final workoutDao = ref.watch(workoutDaoProvider);
  final exerciseDao = ref.watch(exerciseDaoProvider);
  final exerciseSetDao = ref.watch(exerciseSetDaoProvider);
  return WorkoutRepository(workoutDao, exerciseDao, exerciseSetDao);
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final exerciseDao = ref.watch(exerciseDaoProvider);
  final exerciseSetDao = ref.watch(exerciseSetDaoProvider);
  return ExerciseRepository(exerciseDao, exerciseSetDao);
});

/// Provider for CustomExerciseRepository
final customExerciseRepositoryProvider = Provider<CustomExerciseRepository>((
  ref,
) {
  final dao = ref.watch(customExerciseDaoProvider);
  return CustomExerciseRepository(dao);
});

/// Provider for UserMeasurementRepository
final userMeasurementRepositoryProvider = Provider<UserMeasurementRepository>((
  ref,
) {
  final dao = ref.watch(userMeasurementDaoProvider);
  return UserMeasurementRepository(dao);
});
