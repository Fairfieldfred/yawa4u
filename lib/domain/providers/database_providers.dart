import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/cardio_feedback_repository.dart';
import '../../data/repositories/custom_exercise_repository.dart';
import '../../data/repositories/cycle_period_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/sport_zone_repository.dart';
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

// ---------------------------------------------------------------------------
// v5 — Multi-sport DAO providers.
// ---------------------------------------------------------------------------

/// Provider for SessionDao (v5).
final sessionDaoProvider = Provider<SessionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sessionDao;
});

/// Provider for CyclePeriodDao (v5).
final cyclePeriodDaoProvider = Provider<CyclePeriodDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.cyclePeriodDao;
});

/// Provider for SessionCardioDao (v5).
final sessionCardioDaoProvider = Provider<SessionCardioDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sessionCardioDao;
});

/// Provider for SessionIntervalDao (v5).
final sessionIntervalDaoProvider = Provider<SessionIntervalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sessionIntervalDao;
});

/// Provider for SessionSampleDao (v5).
final sessionSampleDaoProvider = Provider<SessionSampleDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sessionSampleDao;
});

/// Provider for SportZoneDao (v5).
final sportZoneDaoProvider = Provider<SportZoneDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.sportZoneDao;
});

/// Provider for CardioFeedbackDao (v5).
final cardioFeedbackDaoProvider = Provider<CardioFeedbackDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.cardioFeedbackDao;
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

/// Provider for WorkoutRepository.
///
/// Phase 6: this is now a facade over [SessionRepository]. It no longer
/// touches the `workouts` table directly — every read/write routes
/// through the sessions table (filtered to [StrengthSession]). The
/// [ExerciseDao] dependency is only kept for the exercise-level helper
/// `findPinnedNoteByExerciseName`, which queries the `exercises` table
/// directly and is orthogonal to the workouts-vs-sessions split.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(
    ref.watch(sessionRepositoryProvider),
    ref.watch(exerciseDaoProvider),
  );
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

// ---------------------------------------------------------------------------
// v5 — Multi-sport repository providers.
// ---------------------------------------------------------------------------

/// Provider for [SessionRepository] (v5+).
///
/// Reads the polymorphic sessions table and hydrates the appropriate child
/// tables (exercises/sets for strength, cardio detail / intervals / samples
/// for cardio). As of Phase 6c this is the canonical write path for both
/// sports — [workoutRepositoryProvider] is now a facade that delegates
/// every strength mutation here.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.watch(sessionDaoProvider),
    ref.watch(exerciseDaoProvider),
    ref.watch(exerciseSetDaoProvider),
    ref.watch(sessionCardioDaoProvider),
    ref.watch(sessionIntervalDaoProvider),
    ref.watch(sessionSampleDaoProvider),
    ref.watch(cardioFeedbackDaoProvider),
  );
});

/// Provider for [CyclePeriodRepository] (v5).
final cyclePeriodRepositoryProvider = Provider<CyclePeriodRepository>((ref) {
  return CyclePeriodRepository(ref.watch(cyclePeriodDaoProvider));
});

/// Provider for [SportZoneRepository] (v5).
final sportZoneRepositoryProvider = Provider<SportZoneRepository>((ref) {
  return SportZoneRepository(ref.watch(sportZoneDaoProvider));
});

/// Provider for [CardioFeedbackRepository] (v5).
final cardioFeedbackRepositoryProvider = Provider<CardioFeedbackRepository>((
  ref,
) {
  return CardioFeedbackRepository(ref.watch(cardioFeedbackDaoProvider));
});
