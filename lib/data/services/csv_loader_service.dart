import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../models/exercise_definition.dart';

/// Service for loading and managing exercise definitions from CSV
///
/// Loads exercises.csv from assets and provides search/filter functionality.
class CsvLoaderService {
  static final CsvLoaderService _instance = CsvLoaderService._internal();
  factory CsvLoaderService() => _instance;
  CsvLoaderService._internal();

  final _log = Logger('CsvLoaderService');
  List<ExerciseDefinition>? _exercises;
  bool _loaded = false;

  /// Check if exercises are loaded
  bool get isLoaded => _loaded;

  /// Get all exercises
  List<ExerciseDefinition> get exercises {
    if (!_loaded) {
      throw StateError('Exercises not loaded. Call loadExercises() first.');
    }
    return _exercises!;
  }

  /// Load exercises from CSV file
  Future<void> loadExercises() async {
    if (_loaded) return;

    try {
      // Load CSV from assets
      final csvString = await rootBundle.loadString('exercises.csv');

      // Parse CSV
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvString,
      );

      // Skip header row and convert to ExerciseDefinition objects
      _exercises = [];
      for (var i = 1; i < csvTable.length; i++) {
        try {
          final row = csvTable[i].map((e) => e.toString()).toList();
          final exercise = ExerciseDefinition.fromCsv(row);
          _exercises!.add(exercise);
        } catch (e) {
          // Skip invalid rows but continue processing
          _log.warning('Skipping invalid exercise row $i: $e');
        }
      }

      _loaded = true;
      _log.info('Loaded ${_exercises!.length} exercises from CSV');
    } catch (e, stackTrace) {
      _log.severe('Error loading exercises from CSV', e, stackTrace);
      rethrow;
    }
  }

  /// Search exercises by name (case-insensitive)
  List<ExerciseDefinition> searchByName(String query) {
    if (!_loaded) return [];
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase();
    return exercises
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter exercises by muscle group
  List<ExerciseDefinition> filterByMuscleGroup(MuscleGroup muscleGroup) {
    if (!_loaded) return [];
    return exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  /// Filter exercises by equipment type
  List<ExerciseDefinition> filterByEquipment(EquipmentType equipmentType) {
    if (!_loaded) return [];
    return exercises.where((e) => e.equipmentType == equipmentType).toList();
  }

  /// Filter exercises by multiple criteria
  List<ExerciseDefinition> filter({
    String? searchQuery,
    MuscleGroup? muscleGroup,
    EquipmentType? equipmentType,
  }) {
    if (!_loaded) return [];

    var result = exercises;

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      result = result
          .where((e) => e.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Apply muscle group filter
    if (muscleGroup != null) {
      result = result.where((e) => e.muscleGroup == muscleGroup).toList();
    }

    // Apply equipment filter
    if (equipmentType != null) {
      result = result.where((e) => e.equipmentType == equipmentType).toList();
    }

    return result;
  }

  /// Get exercises grouped by muscle group
  Map<MuscleGroup, List<ExerciseDefinition>> groupByMuscleGroup() {
    if (!_loaded) return {};

    final grouped = <MuscleGroup, List<ExerciseDefinition>>{};

    for (final exercise in exercises) {
      grouped.putIfAbsent(exercise.muscleGroup, () => []).add(exercise);
    }

    return grouped;
  }

  /// Get exercises grouped by equipment type
  Map<EquipmentType, List<ExerciseDefinition>> groupByEquipmentType() {
    if (!_loaded) return {};

    final grouped = <EquipmentType, List<ExerciseDefinition>>{};

    for (final exercise in exercises) {
      grouped.putIfAbsent(exercise.equipmentType, () => []).add(exercise);
    }

    return grouped;
  }

  /// Get exercise by name (exact match)
  ExerciseDefinition? getByName(String name) {
    if (!_loaded) return null;
    try {
      return exercises.firstWhere(
        (e) => e.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get total exercise count
  int get exerciseCount => _loaded ? _exercises!.length : 0;

  /// Get count by muscle group
  int getCountByMuscleGroup(MuscleGroup muscleGroup) {
    if (!_loaded) return 0;
    return exercises.where((e) => e.muscleGroup == muscleGroup).length;
  }

  /// Get count by equipment type
  int getCountByEquipmentType(EquipmentType equipmentType) {
    if (!_loaded) return 0;
    return exercises.where((e) => e.equipmentType == equipmentType).length;
  }

  /// Clear cached exercises (for testing)
  void clear() {
    _exercises = null;
    _loaded = false;
  }
}
