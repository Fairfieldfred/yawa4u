import '../../core/constants/enums.dart';
import '../database/daos/exercise_dao.dart';
import '../database/daos/exercise_set_dao.dart';
import '../database/daos/workout_dao.dart';
import '../database/mappers/entity_mappers.dart';
import '../models/exercise.dart' as model;
import '../models/workout.dart';

/// Repository for Workout CRUD operations using Drift
/// Handles loading complete workout hierarchy (workout → exercises → sets)
class WorkoutRepository {
  final WorkoutDao _workoutDao;
  final ExerciseDao _exerciseDao;
  final ExerciseSetDao _exerciseSetDao;

  WorkoutRepository(this._workoutDao, this._exerciseDao, this._exerciseSetDao);

  /// Load exercises with their sets for a given workout UUID
  Future<List<model.Exercise>> _loadExercisesForWorkout(
    String workoutUuid,
  ) async {
    final exerciseRows = await _exerciseDao.getByWorkoutUuid(workoutUuid);
    final exercises = <model.Exercise>[];

    for (final exerciseRow in exerciseRows) {
      final setRows = await _exerciseSetDao.getByExerciseUuid(exerciseRow.uuid);
      final sets = setRows.map((s) => ExerciseSetMapper.fromRow(s)).toList();
      exercises.add(ExerciseMapper.fromRow(exerciseRow, sets: sets));
    }

    return exercises;
  }

  /// Convert a workout row to a complete Workout model with exercises and sets
  Future<Workout> _mapRowToWorkout(dynamic row) async {
    final exercises = await _loadExercisesForWorkout(row.uuid);
    return WorkoutMapper.fromRow(row, exercises: exercises);
  }

  /// Watch all workouts (for reactive UI updates)
  Stream<List<Workout>> watchAll() {
    return _workoutDao.watchAll().asyncMap((rows) async {
      final workouts = <Workout>[];
      for (final row in rows) {
        workouts.add(await _mapRowToWorkout(row));
      }
      return workouts;
    });
  }

  /// Watch workouts for a specific training cycle
  Stream<List<Workout>> watchByTrainingCycleId(String trainingCycleId) {
    return _workoutDao.watchByTrainingCycleUuid(trainingCycleId).asyncMap((
      rows,
    ) async {
      final workouts = <Workout>[];
      for (final row in rows) {
        workouts.add(await _mapRowToWorkout(row));
      }
      return workouts;
    });
  }

  /// Get all workouts
  Future<List<Workout>> getAll() async {
    final rows = await _workoutDao.getAll();
    final workouts = <Workout>[];
    for (final row in rows) {
      workouts.add(await _mapRowToWorkout(row));
    }
    return workouts;
  }

  /// Get workout by ID
  Future<Workout?> getById(String id) async {
    final row = await _workoutDao.getByUuid(id);
    if (row == null) return null;
    return _mapRowToWorkout(row);
  }

  /// Get workouts by trainingCycle ID
  Future<List<Workout>> getByTrainingCycleId(String trainingCycleId) async {
    final rows = await _workoutDao.getByTrainingCycleUuid(trainingCycleId);
    final workouts = <Workout>[];
    for (final row in rows) {
      workouts.add(await _mapRowToWorkout(row));
    }
    workouts.sort((a, b) {
      final periodCompare = a.periodNumber.compareTo(b.periodNumber);
      if (periodCompare != 0) return periodCompare;
      return a.dayNumber.compareTo(b.dayNumber);
    });
    return workouts;
  }

  /// Get workouts by status
  Future<List<Workout>> getByStatus(WorkoutStatus status) async {
    final rows = await _workoutDao.getAll();
    final filtered = rows.where((row) => row.status == status.index);
    final workouts = <Workout>[];
    for (final row in filtered) {
      workouts.add(await _mapRowToWorkout(row));
    }
    return workouts;
  }

  /// Get completed workouts
  Future<List<Workout>> getCompleted() async {
    return getByStatus(WorkoutStatus.completed);
  }

  /// Get incomplete workouts
  Future<List<Workout>> getIncomplete() async {
    return getByStatus(WorkoutStatus.incomplete);
  }

  /// Get skipped workouts
  Future<List<Workout>> getSkipped() async {
    return getByStatus(WorkoutStatus.skipped);
  }

  /// Get workouts for a specific period
  Future<List<Workout>> getByPeriod(
    String trainingCycleId,
    int periodNumber,
  ) async {
    final rows = await _workoutDao.getByTrainingCycleUuid(trainingCycleId);
    final filtered = rows.where((row) => row.periodNumber == periodNumber);
    final workouts = <Workout>[];
    for (final row in filtered) {
      workouts.add(await _mapRowToWorkout(row));
    }
    workouts.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return workouts;
  }

  /// Get workouts for a specific period and day
  Future<List<Workout>> getByPeriodAndDay(
    String trainingCycleId,
    int periodNumber,
    int dayNumber,
  ) async {
    final rows = await _workoutDao.getByPeriodAndDay(
      trainingCycleId,
      periodNumber,
      dayNumber,
    );
    final workouts = <Workout>[];
    for (final row in rows) {
      workouts.add(await _mapRowToWorkout(row));
    }
    return workouts;
  }

  /// Create a new workout with its exercises and sets
  Future<void> create(Workout workout) async {
    final workoutCompanion = WorkoutMapper.toCompanion(workout);
    await _workoutDao.insertWorkout(workoutCompanion);

    for (final exercise in workout.exercises) {
      final exerciseCompanion = ExerciseMapper.toCompanion(exercise);
      await _exerciseDao.insertExercise(exerciseCompanion);

      for (final set in exercise.sets) {
        final setCompanion = ExerciseSetMapper.toCompanion(set, exercise.id);
        await _exerciseSetDao.insertSet(setCompanion);
      }
    }
  }

  /// Update an existing workout and its exercises/sets
  Future<void> update(Workout workout) async {
    final workoutCompanion = WorkoutMapper.toCompanion(workout);
    await _workoutDao.updateByUuid(workout.id, workoutCompanion);

    final existingExercises = await _exerciseDao.getByWorkoutUuid(workout.id);
    final existingExerciseIds = existingExercises.map((e) => e.uuid).toSet();
    final newExerciseIds = workout.exercises.map((e) => e.id).toSet();

    for (final existingExercise in existingExercises) {
      if (!newExerciseIds.contains(existingExercise.uuid)) {
        final sets = await _exerciseSetDao.getByExerciseUuid(
          existingExercise.uuid,
        );
        for (final set in sets) {
          await _exerciseSetDao.deleteByUuid(set.uuid);
        }
        await _exerciseDao.deleteByUuid(existingExercise.uuid);
      }
    }

    for (final exercise in workout.exercises) {
      final exerciseCompanion = ExerciseMapper.toCompanion(exercise);

      // Check if exercise exists in this workout OR globally in database
      // This handles exercises moved from other workouts
      if (existingExerciseIds.contains(exercise.id)) {
        await _exerciseDao.updateByUuid(exercise.id, exerciseCompanion);
      } else {
        // Check if exercise exists globally (moved from another workout)
        final existsGlobally = await _exerciseDao.getByUuid(exercise.id);
        if (existsGlobally != null) {
          await _exerciseDao.updateByUuid(exercise.id, exerciseCompanion);
        } else {
          await _exerciseDao.insertExercise(exerciseCompanion);
        }
      }

      final existingSets = await _exerciseSetDao.getByExerciseUuid(exercise.id);
      final existingSetIds = existingSets.map((s) => s.uuid).toSet();
      final newSetIds = exercise.sets.map((s) => s.id).toSet();

      for (final existingSet in existingSets) {
        if (!newSetIds.contains(existingSet.uuid)) {
          await _exerciseSetDao.deleteByUuid(existingSet.uuid);
        }
      }

      for (final set in exercise.sets) {
        final setCompanion = ExerciseSetMapper.toCompanion(set, exercise.id);

        if (existingSetIds.contains(set.id)) {
          await _exerciseSetDao.updateByUuid(set.id, setCompanion);
        } else {
          await _exerciseSetDao.insertSet(setCompanion);
        }
      }
    }
  }

  /// Delete a workout and all its exercises and sets
  Future<void> delete(String id) async {
    final exercises = await _exerciseDao.getByWorkoutUuid(id);
    for (final exercise in exercises) {
      final sets = await _exerciseSetDao.getByExerciseUuid(exercise.uuid);
      for (final set in sets) {
        await _exerciseSetDao.deleteByUuid(set.uuid);
      }
      await _exerciseDao.deleteByUuid(exercise.uuid);
    }
    await _workoutDao.deleteByUuid(id);
  }

  /// Delete all workouts for a trainingCycle
  Future<void> deleteByTrainingCycleId(String trainingCycleId) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    for (final workout in workouts) {
      await delete(workout.id);
    }
  }

  /// Mark workout as completed
  Future<void> markAsCompleted(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.complete());
  }

  /// Mark workout as skipped
  Future<void> markAsSkipped(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.skip());
  }

  /// Reset workout to incomplete
  Future<void> resetWorkout(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.reset());
  }

  /// Get total count
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  /// Clear all workouts
  Future<void> clear() async {
    await _exerciseSetDao.deleteAll();
    await _exerciseDao.deleteAll();
    await _workoutDao.deleteAll();
  }

  /// Delete all workouts
  Future<void> deleteAll() async {
    await clear();
  }

  /// Get workouts by date range
  Future<List<Workout>> getByDateRange(DateTime start, DateTime end) async {
    final all = await getAll();
    return all.where((w) {
      if (w.scheduledDate == null) return false;
      return w.scheduledDate!.isAfter(start) && w.scheduledDate!.isBefore(end);
    }).toList()..sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
  }

  /// Get upcoming workouts
  Future<List<Workout>> getUpcoming() async {
    final now = DateTime.now();
    final all = await getAll();
    return all.where((w) {
      if (w.status != WorkoutStatus.incomplete) return false;
      if (w.scheduledDate == null) return false;
      return w.scheduledDate!.isAfter(now);
    }).toList()..sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
  }

  /// Get today's workouts
  Future<List<Workout>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    final all = await getAll();
    final completed = await getCompleted();
    final incomplete = await getIncomplete();
    final skipped = await getSkipped();
    return {
      'total': all.length,
      'completed': completed.length,
      'incomplete': incomplete.length,
      'skipped': skipped.length,
    };
  }

  /// Get statistics for a specific trainingCycle
  Future<Map<String, dynamic>> getStatsForTrainingCycle(
    String trainingCycleId,
  ) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    final completed = workouts.where((w) => w.isCompleted).length;
    final skipped = workouts.where((w) => w.isSkipped).length;

    return {
      'total': workouts.length,
      'completed': completed,
      'skipped': skipped,
      'incomplete': workouts.length - completed - skipped,
      'completion_rate': workouts.isEmpty ? 0.0 : completed / workouts.length,
    };
  }
}
