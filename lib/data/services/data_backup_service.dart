import 'dart:convert';

import '../models/custom_exercise_definition.dart';
import '../models/exercise.dart';
import '../models/training_cycle.dart';
import '../models/workout.dart';
import 'database_service.dart';

/// Service for exporting and importing app data
class DataBackupService {
  final DatabaseService _databaseService;

  DataBackupService(this._databaseService);

  /// Export all data to a JSON string
  Future<String> exportToJson() async {
    final trainingCycles = _databaseService.trainingCyclesBox.values.toList();
    final workouts = _databaseService.workoutsBox.values.toList();
    final exercises = _databaseService.exercisesBox.values.toList();
    final customExercises = _databaseService.customExercisesBox.values.toList();

    final data = {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'trainingCycles': trainingCycles.map((m) => m.toJson()).toList(),
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'customExercises': customExercises.map((e) => e.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  /// Import data from a JSON string
  /// Returns a summary of what was imported
  Future<ImportResult> importFromJson(
    String jsonString, {
    bool replace = false,
  }) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as int?;
      if (version == null || version > 2) {
        return ImportResult(
          success: false,
          error: 'Unsupported backup version',
        );
      }

      // Parse data
      final trainingCyclesJson = data['trainingCycles'] as List<dynamic>? ?? [];
      final workoutsJson = data['workouts'] as List<dynamic>? ?? [];
      final exercisesJson = data['exercises'] as List<dynamic>? ?? [];
      final customExercisesJson =
          data['customExercises'] as List<dynamic>? ?? [];

      final trainingCycles = trainingCyclesJson
          .map((m) => TrainingCycle.fromJson(m as Map<String, dynamic>))
          .toList();
      final workouts = workoutsJson
          .map((w) => Workout.fromJson(w as Map<String, dynamic>))
          .toList();
      final exercises = exercisesJson
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
      final customExercises = customExercisesJson
          .map(
            (e) => CustomExerciseDefinition.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      // Clear existing data if replacing
      if (replace) {
        await _databaseService.trainingCyclesBox.clear();
        await _databaseService.workoutsBox.clear();
        await _databaseService.exercisesBox.clear();
        await _databaseService.customExercisesBox.clear();
      }

      // Import trainingCycles
      int trainingCyclesImported = 0;
      for (final trainingCycle in trainingCycles) {
        if (!replace &&
            _databaseService.trainingCyclesBox.containsKey(trainingCycle.id)) {
          continue; // Skip if already exists and not replacing
        }
        await _databaseService.trainingCyclesBox.put(trainingCycle.id, trainingCycle);
        trainingCyclesImported++;
      }

      // Import workouts
      int workoutsImported = 0;
      for (final workout in workouts) {
        if (!replace && _databaseService.workoutsBox.containsKey(workout.id)) {
          continue;
        }
        await _databaseService.workoutsBox.put(workout.id, workout);
        workoutsImported++;
      }

      // Import exercises
      int exercisesImported = 0;
      for (final exercise in exercises) {
        if (!replace &&
            _databaseService.exercisesBox.containsKey(exercise.id)) {
          continue;
        }
        await _databaseService.exercisesBox.put(exercise.id, exercise);
        exercisesImported++;
      }

      // Import custom exercises
      int customExercisesImported = 0;
      for (final customExercise in customExercises) {
        if (!replace &&
            _databaseService.customExercisesBox.containsKey(
              customExercise.id,
            )) {
          continue;
        }
        await _databaseService.customExercisesBox.put(
          customExercise.id,
          customExercise,
        );
        customExercisesImported++;
      }

      return ImportResult(
        success: true,
        trainingCyclesImported: trainingCyclesImported,
        workoutsImported: workoutsImported,
        exercisesImported: exercisesImported,
        customExercisesImported: customExercisesImported,
      );
    } catch (e) {
      return ImportResult(success: false, error: 'Failed to parse backup: $e');
    }
  }

  /// Get stats about current data
  DataStats getStats() {
    return DataStats(
      trainingCycleCount: _databaseService.trainingCyclesBox.length,
      workoutCount: _databaseService.workoutsBox.length,
      exerciseCount: _databaseService.exercisesBox.length,
      customExerciseCount: _databaseService.customExercisesBox.length,
    );
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String? error;
  final int trainingCyclesImported;
  final int workoutsImported;
  final int exercisesImported;
  final int customExercisesImported;

  ImportResult({
    required this.success,
    this.error,
    this.trainingCyclesImported = 0,
    this.workoutsImported = 0,
    this.exercisesImported = 0,
    this.customExercisesImported = 0,
  });

  int get totalImported =>
      trainingCyclesImported +
      workoutsImported +
      exercisesImported +
      customExercisesImported;
}

/// Statistics about current data
class DataStats {
  final int trainingCycleCount;
  final int workoutCount;
  final int exerciseCount;
  final int customExerciseCount;

  DataStats({
    required this.trainingCycleCount,
    required this.workoutCount,
    required this.exerciseCount,
    required this.customExerciseCount,
  });

  int get total =>
      trainingCycleCount + workoutCount + exerciseCount + customExerciseCount;
}
