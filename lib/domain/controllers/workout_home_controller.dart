import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../providers/mesocycle_providers.dart';
import '../providers/repository_providers.dart';
import '../providers/workout_providers.dart';

/// Immutable state for the workout home screen.
class WorkoutHomeState {
  final bool showWeekSelector;
  final int? selectedWeek;
  final int? selectedDay;

  const WorkoutHomeState({
    this.showWeekSelector = false,
    this.selectedWeek,
    this.selectedDay,
  });

  WorkoutHomeState copyWith({
    bool? showWeekSelector,
    int? selectedWeek,
    int? selectedDay,
    bool clearSelection = false,
  }) {
    return WorkoutHomeState(
      showWeekSelector: showWeekSelector ?? this.showWeekSelector,
      selectedWeek: clearSelection ? null : (selectedWeek ?? this.selectedWeek),
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
/// - Mesocycle operations (rename, end, notes)
class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  @override
  WorkoutHomeState build() {
    return const WorkoutHomeState();
  }

  // ---------------------------------------------------------------------------
  // UI State Management
  // ---------------------------------------------------------------------------

  void toggleWeekSelector() {
    state = state.copyWith(showWeekSelector: !state.showWeekSelector);
  }

  void hideWeekSelector() {
    state = state.copyWith(showWeekSelector: false);
  }

  void selectDay(int week, int day) {
    state = state.copyWith(
      showWeekSelector: false,
      selectedWeek: week,
      selectedDay: day,
    );
  }

  void navigateToNextDay(int nextWeek, int nextDay) {
    state = state.copyWith(selectedWeek: nextWeek, selectedDay: nextDay);
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
    int displayWeek,
    int displayDay,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final mesocycle = ref.read(currentMesocycleProvider);
    if (mesocycle == null) return;

    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));

    final todaysWorkouts = allWorkouts
        .where((w) => w.weekNumber == displayWeek && w.dayNumber == displayDay)
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

  Future<bool> finishWorkout(List<Workout> workouts, int daysPerWeek) async {
    if (workouts.isEmpty) return false;

    final repository = ref.read(workoutRepositoryProvider);
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    final mesocycle = ref.read(currentMesocycleProvider);

    if (mesocycle == null) return false;

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await repository.update(updatedWorkout);
    }

    // Check if ALL workouts in the mesocycle are now completed
    final allWorkouts = repository.getByMesocycleId(mesocycle.id);
    final allCompleted = allWorkouts.every(
      (w) => w.status == WorkoutStatus.completed,
    );

    if (allCompleted) {
      await mesocycleRepository.update(mesocycle.complete());
      return true; // Indicates mesocycle completed
    }

    // Navigate to next workout
    final firstWorkout = workouts.first;
    int nextDay = firstWorkout.dayNumber + 1;
    int nextWeek = firstWorkout.weekNumber;

    if (nextDay > daysPerWeek) {
      nextDay = 1;
      nextWeek++;
    }

    navigateToNextDay(nextWeek, nextDay);
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
        workoutsByMesocycleProvider(workout.mesocycleId),
      );
      final workoutsToUpdate = allWorkouts
          .where((w) => w.dayNumber == workout.dayNumber)
          .toList();

      for (final w in workoutsToUpdate) {
        await repository.update(w.copyWith(dayName: label));
      }
    } else {
      final currentWeekNumber = workouts.first.weekNumber;
      final currentWeekWorkouts = workouts
          .where((w) => w.weekNumber == currentWeekNumber)
          .toList();

      for (final w in currentWeekWorkouts) {
        await repository.update(w.copyWith(dayName: label));
      }
    }
  }

  Future<void> clearAllDayNames(String mesocycleId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycleId));

    for (final workout in allWorkouts) {
      if (workout.dayName != null) {
        await repository.update(workout.copyWith(dayName: null));
      }
    }
  }

  Future<void> createWorkoutForMuscleGroup({
    required String mesocycleId,
    required int weekNumber,
    required int dayNumber,
    required String? dayName,
    required String label,
  }) async {
    final repository = ref.read(workoutRepositoryProvider);

    final newWorkout = Workout(
      id: const Uuid().v4(),
      mesocycleId: mesocycleId,
      weekNumber: weekNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      label: label,
      exercises: [],
    );

    await repository.create(newWorkout);
  }

  // ---------------------------------------------------------------------------
  // Mesocycle Operations
  // ---------------------------------------------------------------------------

  Future<void> renameMesocycle(Mesocycle mesocycle, String newName) async {
    final repository = ref.read(mesocycleRepositoryProvider);
    final updatedMesocycle = mesocycle.copyWith(name: newName);
    await repository.update(updatedMesocycle);
  }

  Future<void> endMesocycle(Mesocycle mesocycle) async {
    final repository = ref.read(mesocycleRepositoryProvider);
    final updatedMesocycle = mesocycle.copyWith(
      status: MesocycleStatus.completed,
      endDate: DateTime.now(),
    );
    await repository.update(updatedMesocycle);
  }

  // ---------------------------------------------------------------------------
  // Week Management
  // ---------------------------------------------------------------------------

  Future<void> addWeek(dynamic mesocycle) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));
    final newWeekNumber = mesocycle.weeksTotal;

    final templateWeek = mesocycle.weeksTotal - 1;

    List<Workout> templateWorkouts = [];
    if (templateWeek >= 1) {
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == templateWeek)
          .toList();
    } else {
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == mesocycle.weeksTotal)
          .toList();
    }

    if (templateWorkouts.isEmpty) return;

    // Shift deload week
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == mesocycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      await repository.update(
        workout.copyWith(weekNumber: mesocycle.weeksTotal + 1),
      );
    }

    // Create new week workouts
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
        weekNumber: newWeekNumber,
        status: WorkoutStatus.incomplete,
        exercises: newExercises,
      );

      await repository.create(newWorkout);
    }

    // Update mesocycle
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    await mesocycleRepository.update(
      mesocycle.copyWith(
        weeksTotal: mesocycle.weeksTotal + 1,
        deloadWeek: mesocycle.deloadWeek + 1,
      ),
    );
  }

  Future<void> removeWeek(dynamic mesocycle) async {
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(workoutsByMesocycleProvider(mesocycle.id));
    final weekToRemove = mesocycle.weeksTotal - 1;

    if (weekToRemove < 1) return;

    // Delete week
    final workoutsToRemove = allWorkouts
        .where((w) => w.weekNumber == weekToRemove)
        .toList();
    for (var workout in workoutsToRemove) {
      await repository.delete(workout.id);
    }

    // Shift deload week
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == mesocycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      await repository.update(workout.copyWith(weekNumber: weekToRemove));
    }

    // Update mesocycle
    final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
    await mesocycleRepository.update(
      mesocycle.copyWith(
        weeksTotal: mesocycle.weeksTotal - 1,
        deloadWeek: mesocycle.deloadWeek - 1,
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

/// Find the first incomplete workout in the mesocycle.
(int, int)? findFirstIncompleteWorkout(List<Workout> allWorkouts) {
  final Map<String, List<Workout>> workoutsByDay = {};
  for (var workout in allWorkouts) {
    final key = '${workout.weekNumber}-${workout.dayNumber}';
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

/// Calculate target RIR for a given week based on mesocycle deload schedule.
int calculateRIR(int weekNumber, int deloadWeek) {
  if (weekNumber == deloadWeek) {
    return 8;
  }

  final weeksUntilDeload = deloadWeek - weekNumber;

  if (weeksUntilDeload == 1) {
    return 0;
  } else if (weeksUntilDeload > 1) {
    return weeksUntilDeload - 1;
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
  }
}

/// Calculate day name based on mesocycle start date.
String calculateDayName({
  required List<Workout> workouts,
  required DateTime? startDate,
  required int daysPerWeek,
  required int displayWeek,
  required int displayDay,
}) {
  const defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  if (workouts.isNotEmpty && workouts.first.dayName != null) {
    return workouts.first.dayName!.substring(0, 3).toUpperCase();
  }

  if (startDate != null) {
    final startDayOfWeek = startDate.weekday % 7;
    final daysElapsed = ((displayWeek - 1) * daysPerWeek) + (displayDay - 1);
    final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
    return defaultDayNames[actualDayOfWeek];
  }

  return displayDay >= 1 && displayDay <= defaultDayNames.length
      ? defaultDayNames[displayDay - 1]
      : 'DAY $displayDay';
}
