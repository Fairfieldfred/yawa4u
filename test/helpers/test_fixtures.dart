import 'package:uuid/uuid.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_feedback.dart';
import 'package:yawa4u/data/models/exercise_set.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/workout.dart';

const _uuid = Uuid();

/// Factory functions for creating test domain model instances
/// with sensible defaults. All fields can be overridden.
class TestFixtures {
  TestFixtures._();

  static ExerciseSet createExerciseSet({
    String? id,
    int setNumber = 1,
    double? weight = 100.0,
    String reps = '10',
    SetType setType = SetType.regular,
    bool isLogged = false,
    String? notes,
    bool isSkipped = false,
  }) {
    return ExerciseSet(
      id: id ?? _uuid.v4(),
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      setType: setType,
      isLogged: isLogged,
      notes: notes,
      isSkipped: isSkipped,
    );
  }

  static ExerciseFeedback createFeedback({
    JointPain? jointPain = JointPain.none,
    MusclePump? musclePump = MusclePump.moderate,
    Workload? workload = Workload.prettyGood,
    Soreness? soreness = Soreness.healedAWhileAgo,
    Map<String, Soreness>? muscleGroupSoreness,
    DateTime? timestamp,
  }) {
    return ExerciseFeedback(
      jointPain: jointPain,
      musclePump: musclePump,
      workload: workload,
      soreness: soreness,
      muscleGroupSoreness: muscleGroupSoreness,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static Exercise createExercise({
    String? id,
    String? workoutId,
    String name = 'Bench Press',
    MuscleGroup muscleGroup = MuscleGroup.chest,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType equipmentType = EquipmentType.barbell,
    List<ExerciseSet>? sets,
    int orderIndex = 0,
    double? bodyweight,
    String? notes,
    ExerciseFeedback? feedback,
    DateTime? lastPerformed,
    String? videoUrl,
    bool isNotePinned = false,
  }) {
    return Exercise(
      id: id ?? _uuid.v4(),
      workoutId: workoutId ?? _uuid.v4(),
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
      sets: sets,
      orderIndex: orderIndex,
      bodyweight: bodyweight,
      notes: notes,
      feedback: feedback,
      lastPerformed: lastPerformed,
      videoUrl: videoUrl,
      isNotePinned: isNotePinned,
    );
  }

  static Workout createWorkout({
    String? id,
    String? trainingCycleId,
    int periodNumber = 1,
    int dayNumber = 1,
    String? dayName = 'Push Day',
    String label = 'Chest',
    WorkoutStatus status = WorkoutStatus.incomplete,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? notes,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? _uuid.v4(),
      trainingCycleId: trainingCycleId ?? _uuid.v4(),
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      status: status,
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      notes: notes,
      exercises: exercises ?? [],
    );
  }

  static TrainingCycle createTrainingCycle({
    String? id,
    String name = 'Test Cycle',
    int periodsTotal = 4,
    int daysPerPeriod = 5,
    int? recoveryPeriod,
    TrainingCycleStatus status = TrainingCycleStatus.draft,
    Gender? gender,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? endDate,
    List<Workout>? workouts,
    Map<String, int>? muscleGroupPriorities,
    String? templateName,
    String? notes,
    RecoveryPeriodType recoveryPeriodType = RecoveryPeriodType.deload,
  }) {
    return TrainingCycle(
      id: id ?? _uuid.v4(),
      name: name,
      periodsTotal: periodsTotal,
      daysPerPeriod: daysPerPeriod,
      recoveryPeriod: recoveryPeriod,
      status: status,
      gender: gender,
      createdDate: createdDate ?? DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      workouts: workouts ?? [],
      muscleGroupPriorities: muscleGroupPriorities,
      templateName: templateName,
      notes: notes,
      recoveryPeriodType: recoveryPeriodType,
    );
  }
}
