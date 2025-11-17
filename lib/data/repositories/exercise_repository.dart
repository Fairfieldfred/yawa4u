import 'package:hive/hive.dart';
import '../models/exercise.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Repository for Exercise CRUD operations
class ExerciseRepository {
  final Box<Exercise> _box;

  ExerciseRepository(this._box);

  /// Get the underlying Hive box (for watching changes)
  Box<Exercise> get box => _box;

  /// Get all exercises
  List<Exercise> getAll() {
    return _box.values.toList();
  }

  /// Get exercise by ID
  Exercise? getById(String id) {
    return _box.get(id);
  }

  /// Get exercises by workout ID
  List<Exercise> getByWorkoutId(String workoutId) {
    return _box.values
        .where((e) => e.workoutId == workoutId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get exercises by muscle group
  List<Exercise> getByMuscleGroup(MuscleGroup muscleGroup) {
    return _box.values.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  /// Get exercises by equipment type
  List<Exercise> getByEquipmentType(EquipmentType equipmentType) {
    return _box.values
        .where((e) => e.equipmentType == equipmentType)
        .toList();
  }

  /// Get exercises by name (exact match)
  List<Exercise> getByName(String name) {
    return _box.values
        .where((e) => e.name.toLowerCase() == name.toLowerCase())
        .toList();
  }

  /// Search exercises by name (partial match)
  List<Exercise> searchByName(String query) {
    if (query.isEmpty) return getAll();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Create a new exercise
  Future<void> create(Exercise exercise) async {
    await _box.put(exercise.id, exercise);
  }

  /// Update an existing exercise
  Future<void> update(Exercise exercise) async {
    await _box.put(exercise.id, exercise);
  }

  /// Delete an exercise
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all exercises for a workout
  Future<void> deleteByWorkoutId(String workoutId) async {
    final exercises = getByWorkoutId(workoutId);
    for (final exercise in exercises) {
      await delete(exercise.id);
    }
  }

  /// Get completed exercises (all sets logged)
  List<Exercise> getCompleted() {
    return _box.values.where((e) => e.isCompleted).toList();
  }

  /// Get incomplete exercises
  List<Exercise> getIncomplete() {
    return _box.values.where((e) => !e.isCompleted).toList();
  }

  /// Get exercises with Myorep sets
  List<Exercise> getWithMyorepSets() {
    return _box.values.where((e) => e.hasMyorepSets).toList();
  }

  /// Get exercises with feedback
  List<Exercise> getWithFeedback() {
    return _box.values.where((e) => e.feedback != null).toList();
  }

  /// Get total count
  int get count => _box.length;

  /// Check if empty
  bool get isEmpty => _box.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _box.isNotEmpty;

  /// Clear all exercises (use with caution!)
  Future<void> clear() async {
    await _box.clear();
  }

  /// Get exercises performed recently
  List<Exercise> getRecentlyPerformed({int limit = 10}) {
    final withDates = _box.values
        .where((e) => e.lastPerformed != null)
        .toList()
      ..sort((a, b) => b.lastPerformed!.compareTo(a.lastPerformed!));

    return withDates.take(limit).toList();
  }

  /// Get exercise history for a specific exercise name
  List<Exercise> getHistoryByName(String name) {
    return _box.values
        .where((e) => e.name.toLowerCase() == name.toLowerCase())
        .toList()
      ..sort((a, b) {
        if (a.lastPerformed == null && b.lastPerformed == null) return 0;
        if (a.lastPerformed == null) return 1;
        if (b.lastPerformed == null) return -1;
        return b.lastPerformed!.compareTo(a.lastPerformed!);
      });
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final all = getAll();
    return {
      'total': all.length,
      'completed': getCompleted().length,
      'incomplete': getIncomplete().length,
      'with_myoreps': getWithMyorepSets().length,
      'with_feedback': getWithFeedback().length,
    };
  }

  /// Get statistics for a specific workout
  Map<String, dynamic> getStatsForWorkout(String workoutId) {
    final exercises = getByWorkoutId(workoutId);
    final completed = exercises.where((e) => e.isCompleted).length;

    return {
      'total': exercises.length,
      'completed': completed,
      'incomplete': exercises.length - completed,
      'completion_rate': exercises.isEmpty ? 0.0 : completed / exercises.length,
    };
  }

  /// Get count by muscle group
  Map<MuscleGroup, int> getCountByMuscleGroup() {
    final counts = <MuscleGroup, int>{};
    for (final exercise in _box.values) {
      counts[exercise.muscleGroup] = (counts[exercise.muscleGroup] ?? 0) + 1;
    }
    return counts;
  }

  /// Get count by equipment type
  Map<EquipmentType, int> getCountByEquipmentType() {
    final counts = <EquipmentType, int>{};
    for (final exercise in _box.values) {
      counts[exercise.equipmentType] =
          (counts[exercise.equipmentType] ?? 0) + 1;
    }
    return counts;
  }
}
