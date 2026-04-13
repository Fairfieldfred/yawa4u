import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../database/daos/exercise_dao.dart';
import '../database/daos/exercise_set_dao.dart';
import '../database/mappers/entity_mappers.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';

/// Repository for Exercise CRUD operations using Drift
/// Handles loading complete exercise hierarchy (exercise -> sets)
class ExerciseRepository {
  final ExerciseDao _exerciseDao;
  final ExerciseSetDao _exerciseSetDao;

  ExerciseRepository(this._exerciseDao, this._exerciseSetDao);

  /// Load sets for a given exercise UUID
  Future<List<ExerciseSet>> _loadSetsForExercise(String exerciseUuid) async {
    final setRows = await _exerciseSetDao.getByExerciseUuid(exerciseUuid);
    return setRows.map((s) => ExerciseSetMapper.fromRow(s)).toList();
  }

  /// Convert an exercise row to a complete Exercise model with sets
  Future<Exercise> _mapRowToExercise(dynamic row) async {
    final sets = await _loadSetsForExercise(row.uuid);
    return ExerciseMapper.fromRow(row, sets: sets);
  }

  /// Map a list of rows to Exercise models with sets
  Future<List<Exercise>> _mapRowsToExercises(Iterable<dynamic> rows) async {
    final exercises = <Exercise>[];
    for (final row in rows) {
      exercises.add(await _mapRowToExercise(row));
    }
    return exercises;
  }

  /// Watch all exercises (for reactive UI updates)
  Stream<List<Exercise>> watchAll() {
    return _exerciseDao.watchAll().asyncMap(_mapRowsToExercises);
  }

  /// Watch exercises for a specific workout
  Stream<List<Exercise>> watchByWorkoutId(String workoutId) {
    return _exerciseDao
        .watchByWorkoutUuid(workoutId)
        .asyncMap(_mapRowsToExercises);
  }

  /// Get all exercises
  Future<List<Exercise>> getAll() async {
    final rows = await _exerciseDao.getAll();
    return _mapRowsToExercises(rows);
  }

  /// Get exercise by ID
  Future<Exercise?> getById(String id) async {
    final row = await _exerciseDao.getByUuid(id);
    if (row == null) return null;
    return _mapRowToExercise(row);
  }

  /// Get exercises by workout ID
  Future<List<Exercise>> getByWorkoutId(String workoutId) async {
    final rows = await _exerciseDao.getByWorkoutUuid(workoutId);
    return _mapRowsToExercises(rows);
  }

  /// Get exercises by muscle group (uses indexed DB query)
  Future<List<Exercise>> getByMuscleGroup(MuscleGroup muscleGroup) async {
    final rows = await _exerciseDao.getByMuscleGroup(muscleGroup.index);
    return _mapRowsToExercises(rows);
  }

  /// Get exercises by equipment type (uses indexed DB query)
  Future<List<Exercise>> getByEquipmentType(EquipmentType equipmentType) async {
    final rows = await _exerciseDao.getByEquipmentType(equipmentType.index);
    return _mapRowsToExercises(rows);
  }

  /// Get exercises by name (exact match)
  Future<List<Exercise>> getByName(String name) async {
    final rows = await _exerciseDao.getByName(name);
    return _mapRowsToExercises(rows);
  }

  /// Search exercises by name (uses DB LIKE query)
  Future<List<Exercise>> searchByName(String query) async {
    if (query.isEmpty) return getAll();
    final rows = await _exerciseDao.searchByName(query);
    return _mapRowsToExercises(rows);
  }

  /// Create a new exercise with its sets
  Future<void> create(Exercise exercise) async {
    final companion = ExerciseMapper.toCompanion(exercise);
    await _exerciseDao.insertExercise(companion);

    for (final set in exercise.sets) {
      final setCompanion = ExerciseSetMapper.toCompanion(set, exercise.id);
      await _exerciseSetDao.insertSet(setCompanion);
    }
  }

  /// Update an existing exercise and its sets
  Future<void> update(Exercise exercise) async {
    final companion = ExerciseMapper.toCompanion(exercise);
    await _exerciseDao.updateByUuid(exercise.id, companion);

    // Handle sets: delete removed, update existing, insert new
    final existingSets = await _exerciseSetDao.getByExerciseUuid(exercise.id);
    final existingSetIds = existingSets.map((s) => s.uuid).toSet();
    final newSetIds = exercise.sets.map((s) => s.id).toSet();

    // Delete removed sets
    for (final existingSet in existingSets) {
      if (!newSetIds.contains(existingSet.uuid)) {
        await _exerciseSetDao.deleteByUuid(existingSet.uuid);
      }
    }

    // Update or insert sets
    for (final set in exercise.sets) {
      final setCompanion = ExerciseSetMapper.toCompanion(set, exercise.id);
      if (existingSetIds.contains(set.id)) {
        await _exerciseSetDao.updateByUuid(set.id, setCompanion);
      } else {
        await _exerciseSetDao.insertSet(setCompanion);
      }
    }
  }

  /// Delete an exercise and its sets and feedback (cascade)
  Future<void> delete(String id) async {
    await _exerciseDao.cascadeDeleteByUuid(id);
  }

  /// Delete all exercises and their sets
  Future<void> deleteAll() async {
    await _exerciseSetDao.deleteAll();
    await _exerciseDao.deleteAll();
  }

  /// Delete all exercises for a workout (cascade deletes sets + feedbacks)
  Future<void> deleteByWorkoutId(String workoutId) async {
    await _exerciseDao.cascadeDeleteByWorkoutUuid(workoutId);
  }

  /// Get completed exercises (all sets logged)
  Future<List<Exercise>> getCompleted() async {
    final all = await getAll();
    return all.where((e) => e.isCompleted).toList();
  }

  /// Get incomplete exercises
  Future<List<Exercise>> getIncomplete() async {
    final all = await getAll();
    return all.where((e) => !e.isCompleted).toList();
  }

  /// Get exercises with Myorep sets
  Future<List<Exercise>> getWithMyorepSets() async {
    final all = await getAll();
    return all.where((e) => e.hasMyorepSets).toList();
  }

  /// Get total count (uses SQL COUNT instead of loading all rows)
  Future<int> count() async {
    return _exerciseDao.countRows();
  }

  /// Clear all exercises
  Future<void> clear() async {
    await deleteAll();
  }
}
