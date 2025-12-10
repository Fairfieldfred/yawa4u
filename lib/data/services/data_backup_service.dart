import 'dart:convert';

import '../models/exercise.dart';
import '../models/mesocycle.dart';
import '../models/workout.dart';
import 'database_service.dart';

/// Service for exporting and importing app data
class DataBackupService {
  final DatabaseService _databaseService;

  DataBackupService(this._databaseService);

  /// Export all data to a JSON string
  Future<String> exportToJson() async {
    final mesocycles = _databaseService.mesocyclesBox.values.toList();
    final workouts = _databaseService.workoutsBox.values.toList();
    final exercises = _databaseService.exercisesBox.values.toList();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'mesocycles': mesocycles.map((m) => m.toJson()).toList(),
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  /// Import data from a JSON string
  /// Returns a summary of what was imported
  Future<ImportResult> importFromJson(String jsonString, {bool replace = false}) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as int?;
      if (version == null || version > 1) {
        return ImportResult(
          success: false,
          error: 'Unsupported backup version',
        );
      }

      // Parse data
      final mesocyclesJson = data['mesocycles'] as List<dynamic>? ?? [];
      final workoutsJson = data['workouts'] as List<dynamic>? ?? [];
      final exercisesJson = data['exercises'] as List<dynamic>? ?? [];

      final mesocycles = mesocyclesJson
          .map((m) => Mesocycle.fromJson(m as Map<String, dynamic>))
          .toList();
      final workouts = workoutsJson
          .map((w) => Workout.fromJson(w as Map<String, dynamic>))
          .toList();
      final exercises = exercisesJson
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();

      // Clear existing data if replacing
      if (replace) {
        await _databaseService.mesocyclesBox.clear();
        await _databaseService.workoutsBox.clear();
        await _databaseService.exercisesBox.clear();
      }

      // Import mesocycles
      int mesocyclesImported = 0;
      for (final mesocycle in mesocycles) {
        if (!replace && _databaseService.mesocyclesBox.containsKey(mesocycle.id)) {
          continue; // Skip if already exists and not replacing
        }
        await _databaseService.mesocyclesBox.put(mesocycle.id, mesocycle);
        mesocyclesImported++;
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
        if (!replace && _databaseService.exercisesBox.containsKey(exercise.id)) {
          continue;
        }
        await _databaseService.exercisesBox.put(exercise.id, exercise);
        exercisesImported++;
      }

      return ImportResult(
        success: true,
        mesocyclesImported: mesocyclesImported,
        workoutsImported: workoutsImported,
        exercisesImported: exercisesImported,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to parse backup: $e',
      );
    }
  }

  /// Get stats about current data
  DataStats getStats() {
    return DataStats(
      mesocycleCount: _databaseService.mesocyclesBox.length,
      workoutCount: _databaseService.workoutsBox.length,
      exerciseCount: _databaseService.exercisesBox.length,
    );
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String? error;
  final int mesocyclesImported;
  final int workoutsImported;
  final int exercisesImported;

  ImportResult({
    required this.success,
    this.error,
    this.mesocyclesImported = 0,
    this.workoutsImported = 0,
    this.exercisesImported = 0,
  });

  int get totalImported => mesocyclesImported + workoutsImported + exercisesImported;
}

/// Statistics about current data
class DataStats {
  final int mesocycleCount;
  final int workoutCount;
  final int exerciseCount;

  DataStats({
    required this.mesocycleCount,
    required this.workoutCount,
    required this.exerciseCount,
  });

  int get total => mesocycleCount + workoutCount + exerciseCount;
}
