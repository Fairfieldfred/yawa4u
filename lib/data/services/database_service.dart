import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../models/custom_exercise_definition.dart';
import '../models/exercise.dart';
import '../models/exercise_feedback.dart';
import '../models/exercise_set.dart';
import '../models/training_cycle.dart';
import '../models/user_measurement.dart';
import '../models/workout.dart';

/// Database service for Hive initialization and management
///
/// Provides singleton access to Hive boxes for all data models.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Box names
  static const String trainingCyclesBoxName = 'trainingCycles';
  static const String workoutsBoxName = 'workouts';
  static const String exercisesBoxName = 'exercises';
  static const String customExercisesBoxName = 'custom_exercises';
  static const String userMeasurementsBoxName = 'user_measurements';

  /// Hive boxes
  Box<TrainingCycle>? _trainingCyclesBox;
  Box<Workout>? _workoutsBox;
  Box<Exercise>? _exercisesBox;
  Box<CustomExerciseDefinition>? _customExercisesBox;
  Box<UserMeasurement>? _userMeasurementsBox;

  bool _initialized = false;

  /// Check if database is initialized
  bool get isInitialized => _initialized;

  /// Initialize Hive and register adapters
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register TypeAdapters for models
    Hive.registerAdapter(TrainingCycleAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(ExerciseSetAdapter());
    Hive.registerAdapter(ExerciseFeedbackAdapter());
    Hive.registerAdapter(CustomExerciseDefinitionAdapter());

    // Register TypeAdapters for enums
    Hive.registerAdapter(TrainingCycleStatusAdapter());
    Hive.registerAdapter(WorkoutStatusAdapter());
    Hive.registerAdapter(SetTypeAdapter());
    Hive.registerAdapter(JointPainAdapter());
    Hive.registerAdapter(MusclePumpAdapter());
    Hive.registerAdapter(WorkloadAdapter());
    Hive.registerAdapter(SorenessAdapter());
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(MuscleGroupAdapter());
    Hive.registerAdapter(EquipmentTypeAdapter());
    Hive.registerAdapter(RecoveryPeriodTypeAdapter());
    Hive.registerAdapter(UserMeasurementAdapter());

    // Open boxes with error handling for corrupted data
    try {
      _trainingCyclesBox = await Hive.openBox<TrainingCycle>(
        trainingCyclesBoxName,
      );
      _workoutsBox = await Hive.openBox<Workout>(workoutsBoxName);
      _exercisesBox = await Hive.openBox<Exercise>(exercisesBoxName);
      _customExercisesBox = await Hive.openBox<CustomExerciseDefinition>(
        customExercisesBoxName,
      );
      _userMeasurementsBox = await Hive.openBox<UserMeasurement>(
        userMeasurementsBoxName,
      );
    } on HiveError catch (e) {
      // If we get a typeId error, the data is corrupted - delete and recreate
      if (e.message.contains('unknown typeId')) {
        await _clearCorruptedData();
        // Retry opening boxes
        _trainingCyclesBox = await Hive.openBox<TrainingCycle>(
          trainingCyclesBoxName,
        );
        _workoutsBox = await Hive.openBox<Workout>(workoutsBoxName);
        _exercisesBox = await Hive.openBox<Exercise>(exercisesBoxName);
        _customExercisesBox = await Hive.openBox<CustomExerciseDefinition>(
          customExercisesBoxName,
        );
        _userMeasurementsBox = await Hive.openBox<UserMeasurement>(
          userMeasurementsBoxName,
        );
      } else {
        rethrow;
      }
    }

    _initialized = true;
  }

  /// Clear corrupted Hive data
  Future<void> _clearCorruptedData() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = appDir;

    // Delete all Hive box files
    final boxNames = [
      trainingCyclesBoxName,
      workoutsBoxName,
      exercisesBoxName,
      customExercisesBoxName,
      userMeasurementsBoxName,
    ];

    for (final boxName in boxNames) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {
        // Ignore errors during cleanup
      }
    }
  }

  /// Get trainingCycles box
  Box<TrainingCycle> get trainingCyclesBox {
    if (_trainingCyclesBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _trainingCyclesBox!;
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

  /// Get user measurements box
  Box<UserMeasurement> get userMeasurementsBox {
    if (_userMeasurementsBox == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _userMeasurementsBox!;
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Clear all data from all boxes
  Future<void> clearDatabase() async {
    await _trainingCyclesBox?.clear();
    await _workoutsBox?.clear();
    await _exercisesBox?.clear();
    await _customExercisesBox?.clear();
    await _userMeasurementsBox?.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _trainingCyclesBox?.close();
    await _workoutsBox?.close();
    await _exercisesBox?.close();
    await _customExercisesBox?.close();
    await _userMeasurementsBox?.close();
    _initialized = false;
  }

  /// Compact all boxes to reclaim disk space
  Future<void> compact() async {
    await _trainingCyclesBox?.compact();
    await _workoutsBox?.compact();
    await _exercisesBox?.compact();
    await _customExercisesBox?.compact();
    await _userMeasurementsBox?.compact();
  }

  /// Get database stats
  Map<String, dynamic> getStats() {
    return {
      'trainingCycles': _trainingCyclesBox?.length ?? 0,
      'workouts': _workoutsBox?.length ?? 0,
      'exercises': _exercisesBox?.length ?? 0,
      'customExercises': _customExercisesBox?.length ?? 0,
      'userMeasurements': _userMeasurementsBox?.length ?? 0,
      'initialized': _initialized,
    };
  }
}
