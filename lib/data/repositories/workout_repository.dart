import 'package:hive/hive.dart';

import '../../core/constants/enums.dart';
import '../models/workout.dart';

/// Repository for Workout CRUD operations
class WorkoutRepository {
  final Box<Workout> _box;

  WorkoutRepository(this._box);

  /// Get the underlying Hive box (for watching changes)
  Box<Workout> get box => _box;

  /// Get all workouts
  List<Workout> getAll() {
    return _box.values.toList();
  }

  /// Get workout by ID
  Workout? getById(String id) {
    return _box.get(id);
  }

  /// Get workouts by trainingCycle ID
  List<Workout> getByTrainingCycleId(String trainingCycleId) {
    return _box.values
        .where((w) => w.trainingCycleId == trainingCycleId)
        .toList()
      ..sort((a, b) {
        // Sort by period, then by day
        final periodCompare = a.periodNumber.compareTo(b.periodNumber);
        if (periodCompare != 0) return periodCompare;
        return a.dayNumber.compareTo(b.dayNumber);
      });
  }

  /// Get workouts by status
  List<Workout> getByStatus(WorkoutStatus status) {
    return _box.values.where((w) => w.status == status).toList();
  }

  /// Get completed workouts
  List<Workout> getCompleted() {
    return getByStatus(WorkoutStatus.completed);
  }

  /// Get incomplete workouts
  List<Workout> getIncomplete() {
    return getByStatus(WorkoutStatus.incomplete);
  }

  /// Get skipped workouts
  List<Workout> getSkipped() {
    return getByStatus(WorkoutStatus.skipped);
  }

  /// Get workouts for a specific period in a trainingCycle
  List<Workout> getByPeriod(String trainingCycleId, int periodNumber) {
    return _box.values
        .where(
          (w) =>
              w.trainingCycleId == trainingCycleId &&
              w.periodNumber == periodNumber,
        )
        .toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  /// Get a specific workout by trainingCycle, period, and day
  Workout? getByPeriodAndDay(
    String trainingCycleId,
    int periodNumber,
    int dayNumber,
  ) {
    try {
      return _box.values.firstWhere(
        (w) =>
            w.trainingCycleId == trainingCycleId &&
            w.periodNumber == periodNumber &&
            w.dayNumber == dayNumber,
      );
    } catch (e) {
      return null;
    }
  }

  /// Create a new workout
  Future<void> create(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  /// Update an existing workout
  Future<void> update(Workout workout) async {
    await _box.put(workout.id, workout);
  }

  /// Delete a workout
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all workouts for a trainingCycle
  Future<void> deleteByTrainingCycleId(String trainingCycleId) async {
    final workouts = getByTrainingCycleId(trainingCycleId);
    for (final workout in workouts) {
      await delete(workout.id);
    }
  }

  /// Mark workout as completed
  Future<void> markAsCompleted(String id) async {
    final workout = getById(id);
    if (workout == null) return;

    await update(workout.complete());
  }

  /// Mark workout as skipped
  Future<void> markAsSkipped(String id) async {
    final workout = getById(id);
    if (workout == null) return;

    await update(workout.skip());
  }

  /// Reset workout to incomplete
  Future<void> resetWorkout(String id) async {
    final workout = getById(id);
    if (workout == null) return;

    await update(workout.reset());
  }

  /// Get total count
  int get count => _box.length;

  /// Check if empty
  bool get isEmpty => _box.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => _box.isNotEmpty;

  /// Clear all workouts (use with caution!)
  Future<void> clear() async {
    await _box.clear();
  }

  /// Get workouts by date range
  List<Workout> getByDateRange(DateTime start, DateTime end) {
    return _box.values.where((w) {
      if (w.scheduledDate == null) return false;
      return w.scheduledDate!.isAfter(start) && w.scheduledDate!.isBefore(end);
    }).toList()..sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
  }

  /// Get upcoming workouts (scheduled but incomplete)
  List<Workout> getUpcoming() {
    final now = DateTime.now();
    return _box.values.where((w) {
      if (w.status != WorkoutStatus.incomplete) return false;
      if (w.scheduledDate == null) return false;
      return w.scheduledDate!.isAfter(now);
    }).toList()..sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
  }

  /// Get today's workouts
  List<Workout> getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(startOfDay, endOfDay);
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final all = getAll();
    return {
      'total': all.length,
      'completed': getCompleted().length,
      'incomplete': getIncomplete().length,
      'skipped': getSkipped().length,
    };
  }

  /// Get statistics for a specific trainingCycle
  Map<String, dynamic> getStatsForTrainingCycle(String trainingCycleId) {
    final workouts = getByTrainingCycleId(trainingCycleId);
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
