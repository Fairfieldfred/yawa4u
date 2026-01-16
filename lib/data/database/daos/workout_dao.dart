import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'workout_dao.g.dart';

/// Data Access Object for Workouts table
@DriftAccessor(tables: [Workouts])
class WorkoutDao extends DatabaseAccessor<AppDatabase> with _$WorkoutDaoMixin {
  WorkoutDao(super.db);

  /// Get all workouts
  Future<List<Workout>> getAll() {
    return select(workouts).get();
  }

  /// Watch all workouts for reactive updates
  Stream<List<Workout>> watchAll() {
    return select(workouts).watch();
  }

  /// Get workouts by training cycle UUID
  Future<List<Workout>> getByTrainingCycleUuid(String trainingCycleUuid) {
    return (select(workouts)
          ..where((w) => w.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([
            (w) => OrderingTerm.asc(w.periodNumber),
            (w) => OrderingTerm.asc(w.dayNumber),
          ]))
        .get();
  }

  /// Watch workouts by training cycle UUID
  Stream<List<Workout>> watchByTrainingCycleUuid(String trainingCycleUuid) {
    return (select(workouts)
          ..where((w) => w.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([
            (w) => OrderingTerm.asc(w.periodNumber),
            (w) => OrderingTerm.asc(w.dayNumber),
          ]))
        .watch();
  }

  /// Get a single workout by UUID
  Future<Workout?> getByUuid(String uuid) {
    return (select(
      workouts,
    )..where((w) => w.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Watch a single workout by UUID
  Stream<Workout?> watchByUuid(String uuid) {
    return (select(
      workouts,
    )..where((w) => w.uuid.equals(uuid))).watchSingleOrNull();
  }

  /// Get workouts for a specific period and day
  Future<List<Workout>> getByPeriodAndDay(
    String trainingCycleUuid,
    int periodNumber,
    int dayNumber,
  ) {
    return (select(workouts)..where(
          (w) =>
              w.trainingCycleUuid.equals(trainingCycleUuid) &
              w.periodNumber.equals(periodNumber) &
              w.dayNumber.equals(dayNumber),
        ))
        .get();
  }

  /// Insert a new workout
  Future<int> insertWorkout(WorkoutsCompanion workout) {
    return into(workouts).insert(workout);
  }

  /// Insert multiple workouts in a batch
  Future<void> insertAll(List<WorkoutsCompanion> workoutList) {
    return batch((b) {
      b.insertAll(workouts, workoutList);
    });
  }

  /// Update an existing workout
  Future<bool> updateWorkout(Workout workout) {
    return update(workouts).replace(workout);
  }

  /// Update a workout by UUID
  Future<int> updateByUuid(String uuid, WorkoutsCompanion workout) {
    return (update(workouts)..where((w) => w.uuid.equals(uuid))).write(workout);
  }

  /// Delete a workout by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(workouts)..where((w) => w.uuid.equals(uuid))).go();
  }

  /// Delete all workouts for a training cycle
  Future<int> deleteByTrainingCycleUuid(String trainingCycleUuid) {
    return (delete(
      workouts,
    )..where((w) => w.trainingCycleUuid.equals(trainingCycleUuid))).go();
  }

  /// Delete all workouts
  Future<int> deleteAll() {
    return delete(workouts).go();
  }
}
