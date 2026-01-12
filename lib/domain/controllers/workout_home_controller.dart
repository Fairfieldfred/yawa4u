import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../providers/repository_providers.dart';
import '../providers/training_cycle_providers.dart';
import '../providers/workout_providers.dart';

/// Immutable state for the workout home screen.
class WorkoutHomeState {
  final bool showPeriodSelector;
  final int? selectedPeriod;
  final int? selectedDay;

  const WorkoutHomeState({
    this.showPeriodSelector = false,
    this.selectedPeriod,
    this.selectedDay,
  });

  WorkoutHomeState copyWith({
    bool? showPeriodSelector,
    int? selectedPeriod,
    int? selectedDay,
    bool clearSelection = false,
  }) {
    return WorkoutHomeState(
      showPeriodSelector: showPeriodSelector ?? this.showPeriodSelector,
      selectedPeriod: clearSelection
          ? null
          : (selectedPeriod ?? this.selectedPeriod),
      selectedDay: clearSelection ? null : (selectedDay ?? this.selectedDay),
    );
  }
}

/// Controller for workout home screen business logic.
///
/// Handles all workout-related operations including:
/// - Set management (add, update, delete, toggle log/skip)
/// - Exercise management (add, delete, move, replace)
/// - Workout operations (finish, reset, skip)
/// - TrainingCycle operations (rename, end, notes)
class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  @override
  WorkoutHomeState build() {
    return const WorkoutHomeState();
  }

  // ---------------------------------------------------------------------------
  // UI State Management
  // ---------------------------------------------------------------------------

  void togglePeriodSelector() {
    state = state.copyWith(showPeriodSelector: !state.showPeriodSelector);
  }

  void hidePeriodSelector() {
    state = state.copyWith(showPeriodSelector: false);
  }

  void selectDay(int period, int day) {
    state = state.copyWith(
      showPeriodSelector: false,
      selectedPeriod: period,
      selectedDay: day,
    );
  }

  void navigateToNextDay(int nextPeriod, int nextDay) {
    state = state.copyWith(selectedPeriod: nextPeriod, selectedDay: nextDay);
  }

  // ---------------------------------------------------------------------------
  // Set Operations
  // ---------------------------------------------------------------------------

  Future<void> updateSetWeight(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final weight = double.tryParse(value);
    if (weight == null && value.isNotEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(weight: weight);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(reps: value);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> toggleSetLog(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    if (set.weight == null || set.reps.isEmpty) return;

    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> addSetBelow(
    String workoutId,
    String exerciseId,
    int currentSetIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(currentSetIndex + 1, newSet);

    // Re-number sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> toggleSetSkip(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final currentSet = exercise.sets[setIndex];
    final updatedSet = currentSet.copyWith(isSkipped: !currentSet.isSkipped);
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> deleteSet(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    // Re-number sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType type,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final updatedSet = exercise.sets[setIndex].copyWith(setType: type);
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  // ---------------------------------------------------------------------------
  // Exercise Operations
  // ---------------------------------------------------------------------------

  Future<void> updateExerciseNote(
    String workoutId,
    String exerciseId,
    String? note,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);
    final updatedExercise = exercise.copyWith(
      notes: note?.isEmpty == true ? null : note,
    );
    final updatedExercises = workout.exercises
        .map((e) => e.id == exerciseId ? updatedExercise : e)
        .toList();
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
  }

  Future<void> moveExerciseDown(
    String exerciseId,
    int displayPeriod,
    int displayDay,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final trainingCycle = ref.read(currentTrainingCycleProvider);
    if (trainingCycle == null) return;

    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    final todaysWorkouts = allWorkouts
        .where(
          (w) => w.periodNumber == displayPeriod && w.dayNumber == displayDay,
        )
        .toList();

    // Collect all exercises from all workouts
    final allExercises = <Exercise>[];
    for (var workout in todaysWorkouts) {
      allExercises.addAll(workout.exercises);
    }

    final globalIndex = allExercises.indexWhere((e) => e.id == exerciseId);
    if (globalIndex == -1 || globalIndex >= allExercises.length - 1) return;

    final exerciseToMove = allExercises[globalIndex];
    final exerciseToSwapWith = allExercises[globalIndex + 1];

    Workout? workoutWithMovingExercise;
    Workout? workoutWithSwapExercise;

    for (var workout in todaysWorkouts) {
      if (workout.exercises.any((e) => e.id == exerciseToMove.id)) {
        workoutWithMovingExercise = workout;
      }
      if (workout.exercises.any((e) => e.id == exerciseToSwapWith.id)) {
        workoutWithSwapExercise = workout;
      }
    }

    if (workoutWithMovingExercise == null || workoutWithSwapExercise == null) {
      return;
    }

    if (workoutWithMovingExercise.id == workoutWithSwapExercise.id) {
      final workout = workoutWithMovingExercise;
      final exercises = List<Exercise>.from(workout.exercises);
      final idx1 = exercises.indexWhere((e) => e.id == exerciseToMove.id);
      final idx2 = exercises.indexWhere((e) => e.id == exerciseToSwapWith.id);

      final temp = exercises[idx1];
      exercises[idx1] = exercises[idx2];
      exercises[idx2] = temp;

      final updatedWorkout = workout.copyWith(exercises: exercises);
      await repository.update(updatedWorkout);
    } else {
      final exercises1 = workoutWithMovingExercise.exercises
          .where((e) => e.id != exerciseToMove.id)
          .toList();

      final exercises2 = List<Exercise>.from(workoutWithSwapExercise.exercises);
      final insertIndex = exercises2.indexWhere(
        (e) => e.id == exerciseToSwapWith.id,
      );

      final movedExercise = exerciseToMove.copyWith(
        workoutId: workoutWithSwapExercise.id,
      );
      exercises2.insert(insertIndex, movedExercise);

      await repository.update(
        workoutWithMovingExercise.copyWith(exercises: exercises1),
      );
      await repository.update(
        workoutWithSwapExercise.copyWith(exercises: exercises2),
      );
    }
  }

  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
  }

  Future<void> addSetToExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets)..add(newSet);
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> skipExerciseSets(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    final updatedSets = exercise.sets
        .map((s) => !s.isLogged ? s.copyWith(isSkipped: true) : s)
        .toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  // ---------------------------------------------------------------------------
  // Workout Operations
  // ---------------------------------------------------------------------------

  Future<bool> finishWorkout(List<Workout> workouts, int daysPerPeriod) async {
    if (workouts.isEmpty) return false;

    final repository = ref.read(workoutRepositoryProvider);
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final trainingCycle = ref.read(currentTrainingCycleProvider);

    if (trainingCycle == null) return false;

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await repository.update(updatedWorkout);
    }

    // Check if ALL workouts in the trainingCycle are now completed
    final allWorkouts = repository.getByTrainingCycleId(trainingCycle.id);
    final allCompleted = allWorkouts.every(
      (w) => w.status == WorkoutStatus.completed,
    );

    if (allCompleted) {
      await trainingCycleRepository.update(trainingCycle.complete());
      return true; // Indicates trainingCycle completed
    }

    // Navigate to next workout
    final firstWorkout = workouts.first;
    int nextDay = firstWorkout.dayNumber + 1;
    int nextPeriod = firstWorkout.periodNumber;

    if (nextDay > daysPerPeriod) {
      nextDay = 1;
      nextPeriod++;
    }

    navigateToNextDay(nextPeriod, nextDay);
    return false;
  }

  Future<void> resetWorkout(List<Workout> workouts) async {
    final repository = ref.read(workoutRepositoryProvider);

    for (final workout in workouts) {
      final updatedExercises = workout.exercises.map((exercise) {
        final updatedSets = exercise.sets.map((set) {
          return set.copyWith(isLogged: false, weight: null, reps: '');
        }).toList();

        return exercise.copyWith(sets: updatedSets);
      }).toList();

      final updatedWorkout = workout.copyWith(
        exercises: updatedExercises,
        status: WorkoutStatus.incomplete,
        completedDate: null,
      );

      await repository.update(updatedWorkout);
    }
  }

  Future<void> updateWorkoutNote(List<Workout> workouts, String? note) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final workout = workouts.first;
    final updatedWorkout = workout.copyWith(notes: note);
    await repository.update(updatedWorkout);
  }

  Future<void> relabelWorkout(
    List<Workout> workouts,
    String label,
    bool applyToAll,
  ) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final workout = workouts.first;

    if (applyToAll) {
      final allWorkouts = ref.read(
        workoutsByTrainingCycleProvider(workout.trainingCycleId),
      );
      final workoutsToUpdate = allWorkouts
          .where((w) => w.dayNumber == workout.dayNumber)
          .toList();

      for (final w in workoutsToUpdate) {
        await repository.update(w.copyWith(dayName: label));
      }
    } else {
      final currentPeriodNumber = workouts.first.periodNumber;
      final currentPeriodWorkouts = workouts
          .where((w) => w.periodNumber == currentPeriodNumber)
          .toList();

      for (final w in currentPeriodWorkouts) {
        await repository.update(w.copyWith(dayName: label));
      }
    }
  }

  Future<void> clearAllDayNames(String trainingCycleId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycleId),
    );

    for (final workout in allWorkouts) {
      if (workout.dayName != null) {
        await repository.update(workout.copyWith(dayName: null));
      }
    }
  }

  Future<void> createWorkoutForMuscleGroup({
    required String trainingCycleId,
    required int periodNumber,
    required int dayNumber,
    required String? dayName,
    required String label,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    final newWorkout = Workout(
      id: const Uuid().v4(),
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      exercises: [],
    );

    await repository.create(newWorkout);
  }

  // ---------------------------------------------------------------------------
  // TrainingCycle Operations
  // ---------------------------------------------------------------------------

  Future<void> renameTrainingCycle(
    TrainingCycle trainingCycle,
    String newName,
  ) async {
    final repository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(name: newName);
    await repository.update(updatedTrainingCycle);
  }

  Future<void> endTrainingCycle(TrainingCycle trainingCycle) async {
    final repository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      status: TrainingCycleStatus.completed,
      endDate: DateTime.now(),
    );
    await repository.update(updatedTrainingCycle);
  }

  // ---------------------------------------------------------------------------
  // Period Management
  // ---------------------------------------------------------------------------

  Future<void> addPeriod(dynamic trainingCycle) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );
    final newPeriodNumber = trainingCycle.periodsTotal;

    final templatePeriod = trainingCycle.periodsTotal - 1;

    List<Workout> templateWorkouts = [];
    if (templatePeriod >= 1) {
      templateWorkouts = allWorkouts
          .where((w) => w.periodNumber == templatePeriod)
          .toList();
    } else {
      templateWorkouts = allWorkouts
          .where((w) => w.periodNumber == trainingCycle.periodsTotal)
          .toList();
    }

    if (templateWorkouts.isEmpty) return;

    // Shift recovery period
    final recoveryWorkouts = allWorkouts
        .where((w) => w.periodNumber == trainingCycle.periodsTotal)
        .toList();
    for (var workout in recoveryWorkouts) {
      await repository.update(
        workout.copyWith(periodNumber: trainingCycle.periodsTotal + 1),
      );
    }

    // Create new period workouts
    for (var templateWorkout in templateWorkouts) {
      final newWorkoutId = const Uuid().v4();
      final newExercises = templateWorkout.exercises
          .map(
            (e) => e.copyWith(
              id: const Uuid().v4(),
              workoutId: newWorkoutId,
              sets: e.sets
                  .map(
                    (s) => s.copyWith(
                      id: const Uuid().v4(),
                      isLogged: false,
                      weight: null,
                      reps: '',
                      isSkipped: false,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();

      final newWorkout = templateWorkout.copyWith(
        id: newWorkoutId,
        periodNumber: newPeriodNumber,
        status: WorkoutStatus.incomplete,
        exercises: newExercises,
      );

      await repository.create(newWorkout);
    }

    // Update trainingCycle
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    await trainingCycleRepository.update(
      trainingCycle.copyWith(
        periodsTotal: trainingCycle.periodsTotal + 1,
        recoveryPeriod: trainingCycle.recoveryPeriod + 1,
      ),
    );
  }

  Future<void> removePeriod(dynamic trainingCycle) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );
    final periodToRemove = trainingCycle.periodsTotal - 1;

    if (periodToRemove < 1) return;

    // Delete period
    final workoutsToRemove = allWorkouts
        .where((w) => w.periodNumber == periodToRemove)
        .toList();
    for (var workout in workoutsToRemove) {
      await repository.delete(workout.id);
    }

    // Shift recovery period
    final recoveryWorkouts = allWorkouts
        .where((w) => w.periodNumber == trainingCycle.periodsTotal)
        .toList();
    for (var workout in recoveryWorkouts) {
      await repository.update(workout.copyWith(periodNumber: periodToRemove));
    }

    // Update trainingCycle
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    await trainingCycleRepository.update(
      trainingCycle.copyWith(
        periodsTotal: trainingCycle.periodsTotal - 1,
        recoveryPeriod: trainingCycle.recoveryPeriod - 1,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

/// Provider for WorkoutHomeController.
final workoutHomeControllerProvider =
    NotifierProvider<WorkoutHomeController, WorkoutHomeState>(() {
      return WorkoutHomeController();
    });

/// Find the first incomplete workout in the trainingCycle.
(int, int)? findFirstIncompleteWorkout(List<Workout> allWorkouts) {
  final Map<String, List<Workout>> workoutsByDay = {};
  for (var workout in allWorkouts) {
    final key = '${workout.periodNumber}-${workout.dayNumber}';
    workoutsByDay.putIfAbsent(key, () => []).add(workout);
  }

  final sortedKeys = workoutsByDay.keys.toList()
    ..sort((a, b) {
      final aParts = a.split('-').map(int.parse).toList();
      final bParts = b.split('-').map(int.parse).toList();
      if (aParts[0] != bParts[0]) return aParts[0].compareTo(bParts[0]);
      return aParts[1].compareTo(bParts[1]);
    });

  for (final key in sortedKeys) {
    final dayWorkouts = workoutsByDay[key]!;

    final hasIncomplete = dayWorkouts.any(
      (w) => w.exercises.any(
        (e) => e.sets.any((s) => !s.isLogged && !s.isSkipped),
      ),
    );

    if (hasIncomplete) {
      final parts = key.split('-').map(int.parse).toList();
      return (parts[0], parts[1]);
    }
  }

  return null;
}

/// Check if a workout is complete (all sets logged or skipped).
bool isWorkoutComplete(Workout workout) {
  for (final exercise in workout.exercises) {
    for (final set in exercise.sets) {
      if (!set.isLogged && !set.isSkipped) {
        return false;
      }
    }
  }
  return true;
}

/// Calculate target RIR for a given period based on trainingCycle recovery schedule.
int calculateRIR(int periodNumber, int recoveryPeriod) {
  if (periodNumber == recoveryPeriod) {
    return 8;
  }

  final periodsUntilRecovery = recoveryPeriod - periodNumber;

  if (periodsUntilRecovery == 1) {
    return 0;
  } else if (periodsUntilRecovery > 1) {
    return periodsUntilRecovery - 1;
  } else {
    return 0;
  }
}

/// Get the set type badge abbreviation.
String? getSetTypeBadge(SetType setType) {
  switch (setType) {
    case SetType.regular:
      return null;
    case SetType.myorep:
      return 'M';
    case SetType.myorepMatch:
      return 'MM';
    case SetType.maxReps:
      return 'MX';
    case SetType.endWithPartials:
      return 'EP';
    case SetType.dropSet:
      return 'DS';
  }
}

/// Calculate day name based on trainingCycle start date.
String calculateDayName({
  required List<Workout> workouts,
  required DateTime? startDate,
  required int daysPerPeriod,
  required int displayPeriod,
  required int displayDay,
}) {
  const defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  if (workouts.isNotEmpty && workouts.first.dayName != null) {
    return workouts.first.dayName!.substring(0, 3).toUpperCase();
  }

  if (startDate != null) {
    final startDayOfWeek = startDate.weekday % 7;
    final daysElapsed =
        ((displayPeriod - 1) * daysPerPeriod) + (displayDay - 1);
    final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
    return defaultDayNames[actualDayOfWeek];
  }

  return displayDay >= 1 && displayDay <= defaultDayNames.length
      ? defaultDayNames[displayDay - 1]
      : 'DAY $displayDay';
}
