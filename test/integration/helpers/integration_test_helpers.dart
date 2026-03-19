import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/database/database.dart'
    hide
        TrainingCycle,
        Workout,
        Exercise,
        ExerciseSet,
        ExerciseFeedback,
        CustomExerciseDefinition,
        UserMeasurement;
import 'package:yawa4u/data/models/custom_exercise_definition.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_set.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/repositories/custom_exercise_repository.dart';
import 'package:yawa4u/data/repositories/exercise_repository.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/data/services/exercise_history_service.dart';

/// Holds all repositories and the database for integration tests.
///
/// Call [initialize] in setUp and [dispose] in tearDown.
class IntegrationTestContext {
  late AppDatabase db;
  late TrainingCycleRepository cycleRepo;
  late WorkoutRepository workoutRepo;
  late ExerciseRepository exerciseRepo;
  late CustomExerciseRepository customExerciseRepo;
  late ExerciseHistoryService historyService;

  Future<void> initialize() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
    workoutRepo = WorkoutRepository(
      db.workoutDao,
      db.exerciseDao,
      db.exerciseSetDao,
    );
    exerciseRepo = ExerciseRepository(db.exerciseDao, db.exerciseSetDao);
    customExerciseRepo = CustomExerciseRepository(db.customExerciseDao);
    historyService = ExerciseHistoryService(workoutRepo);
  }

  Future<void> dispose() async {
    await db.close();
  }
}

/// Factory methods for creating test data with sensible defaults.
class TestDataFactory {
  static int _counter = 0;

  /// Reset the ID counter between tests.
  static void reset() => _counter = 0;

  static String _nextId([String? prefix]) {
    _counter++;
    return '${prefix ?? 'id'}-$_counter';
  }

  /// Create a training cycle with default values.
  static TrainingCycle createCycle({
    String? id,
    String name = 'Test Cycle',
    int periodsTotal = 4,
    int daysPerPeriod = 5,
    TrainingCycleStatus status = TrainingCycleStatus.draft,
    List<Workout>? workouts,
  }) {
    return TrainingCycle(
      id: id ?? _nextId('cycle'),
      name: name,
      periodsTotal: periodsTotal,
      daysPerPeriod: daysPerPeriod,
      status: status,
      workouts: workouts ?? [],
    );
  }

  /// Create a workout with default values.
  static Workout createWorkout({
    String? id,
    required String trainingCycleId,
    int periodNumber = 1,
    int dayNumber = 1,
    String? dayName,
    String label = 'Chest',
    WorkoutStatus status = WorkoutStatus.incomplete,
    DateTime? scheduledDate,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? _nextId('workout'),
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName ?? 'Day $dayNumber',
      label: label,
      status: status,
      scheduledDate: scheduledDate,
      exercises: exercises ?? [],
    );
  }

  /// Create an exercise with default values.
  static Exercise createExercise({
    String? id,
    required String workoutId,
    String name = 'Bench Press',
    MuscleGroup muscleGroup = MuscleGroup.chest,
    EquipmentType equipmentType = EquipmentType.barbell,
    int orderIndex = 0,
    List<ExerciseSet>? sets,
  }) {
    final exerciseId = id ?? _nextId('exercise');
    return Exercise(
      id: exerciseId,
      workoutId: workoutId,
      name: name,
      muscleGroup: muscleGroup,
      equipmentType: equipmentType,
      orderIndex: orderIndex,
      sets: sets ?? [],
    );
  }

  /// Create an exercise set with default values.
  static ExerciseSet createSet({
    String? id,
    int setNumber = 1,
    double? weight = 100.0,
    String reps = '10',
    SetType setType = SetType.regular,
    bool isLogged = false,
    bool isSkipped = false,
  }) {
    return ExerciseSet(
      id: id ?? _nextId('set'),
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      setType: setType,
      isLogged: isLogged,
      isSkipped: isSkipped,
    );
  }

  /// Create a custom exercise definition.
  static CustomExerciseDefinition createCustomExercise({
    String? id,
    String name = 'Custom Exercise',
    MuscleGroup muscleGroup = MuscleGroup.chest,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType equipmentType = EquipmentType.dumbbell,
    String? videoUrl,
  }) {
    return CustomExerciseDefinition(
      id: id ?? _nextId('custom'),
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
      videoUrl: videoUrl,
    );
  }

  /// Create a full workout with exercises and sets, ready to persist.
  static Workout createFullWorkout({
    String? id,
    required String trainingCycleId,
    int periodNumber = 1,
    int dayNumber = 1,
    String label = 'Chest',
    int exerciseCount = 3,
    int setsPerExercise = 3,
  }) {
    final workoutId = id ?? _nextId('workout');
    final exercises = List.generate(exerciseCount, (ei) {
      final exerciseId = _nextId('exercise');
      final sets = List.generate(
        setsPerExercise,
        (si) => createSet(
          setNumber: si + 1,
          weight: 100.0 + (ei * 10),
        ),
      );
      return createExercise(
        id: exerciseId,
        workoutId: workoutId,
        name: 'Exercise ${ei + 1}',
        orderIndex: ei,
        sets: sets,
      );
    });

    return createWorkout(
      id: workoutId,
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      label: label,
      exercises: exercises,
    );
  }
}
