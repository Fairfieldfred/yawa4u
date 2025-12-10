import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../models/custom_exercise_definition.dart';
import '../models/exercise.dart';
import '../models/exercise_feedback.dart';
import '../models/exercise_set.dart';
import '../models/mesocycle.dart';
import '../models/workout.dart';

/// Database service for Hive initialization and management
///
/// Provides singleton access to Hive boxes for all data models.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Box names
  static const String mesocyclesBoxName = 'mesocycles';
  static const String workoutsBoxName = 'workouts';
  static const String exercisesBoxName = 'exercises';
  static const String customExercisesBoxName = 'custom_exercises';

  /// Hive boxes
  Box<Mesocycle>? _mesocyclesBox;
  Box<Workout>? _workoutsBox;
  Box<Exercise>? _exercisesBox;
  Box<CustomExerciseDefinition>? _customExercisesBox;

  bool _initialized = false;

  /// Check if database is initialized
  bool get isInitialized => _initialized;

  /// Initialize Hive and register adapters
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register TypeAdapters for models
    Hive.registerAdapter(MesocycleAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(ExerciseFeedbackAdapter());
    Hive.registerAdapter(CustomExerciseDefinitionAdapter());

    // Register TypeAdapters for enums
    Hive.registerAdapter(MesocycleStatusAdapter());
    Hive.registerAdapter(WorkoutStatusAdapter());
    Hive.registerAdapter(SetTypeAdapter());
    Hive.registerAdapter(JointPainAdapter());
    Hive.registerAdapter(MusclePumpAdapter());
    Hive.registerAdapter(WorkloadAdapter());
    Hive.registerAdapter(SorenessAdapter());
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(MuscleGroupAdapter());
    Hive.registerAdapter(EquipmentTypeAdapter());

    // Open boxes
    _mesocyclesBox = await Hive.openBox<Mesocycle>(mesocyclesBoxName);
    _workoutsBox = await Hive.openBox<Workout>(workoutsBoxName);
    _exercisesBox = await Hive.openBox<Exercise>(exercisesBoxName);
    _customExercisesBox = await Hive.openBox<CustomExerciseDefinition>(
      customExercisesBoxName,
    );

    _initialized = true;
  }

  /// Get mesocycles box
  Box<Mesocycle> get mesocyclesBox {
    if (_mesocyclesBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _mesocyclesBox!;
  }

  /// Get workouts box
  Box<Workout> get workoutsBox {
    if (_workoutsBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _workoutsBox!;
  }

  /// Get exercises box
  Box<Exercise> get exercisesBox {
    if (_exercisesBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _exercisesBox!;
  }

  /// Get custom exercises box
  Box<CustomExerciseDefinition> get customExercisesBox {
    if (_customExercisesBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _customExercisesBox!;
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Clear all data from all boxes
  Future<void> clearDatabase() async {
    await _mesocyclesBox?.clear();
    await _workoutsBox?.clear();
    await _exercisesBox?.clear();
    await _customExercisesBox?.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _mesocyclesBox?.close();
    await _workoutsBox?.close();
    await _exercisesBox?.close();
    await _customExercisesBox?.close();
    _initialized = false;
  }

  /// Compact all boxes to reclaim disk space
  Future<void> compact() async {
    await _mesocyclesBox?.compact();
    await _workoutsBox?.compact();
    await _exercisesBox?.compact();
    await _customExercisesBox?.compact();
  }

  /// Get database stats
  Map<String, dynamic> getStats() {
    return {
      'mesocycles': _mesocyclesBox?.length ?? 0,
      'workouts': _workoutsBox?.length ?? 0,
      'exercises': _exercisesBox?.length ?? 0,
      'customExercises': _customExercisesBox?.length ?? 0,
      'initialized': _initialized,
    };
  }
}
