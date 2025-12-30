import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/skins/skins.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/calendar_dropdown.dart';
import '../widgets/cycle_summary_dialog.dart';
import '../widgets/dialogs/add_exercise_dialog.dart';
import '../widgets/dialogs/workout_dialogs.dart';
import '../widgets/exercise_card_widget.dart';
import '../widgets/screen_background.dart';
import 'add_exercise_screen.dart';

/// Workout home screen - shows current/upcoming workouts
class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> {
  // ---------------------------------------------------------------------------
  // Controller Access
  // ---------------------------------------------------------------------------

  WorkoutHomeController get _controller =>
      ref.read(workoutHomeControllerProvider.notifier);

  WorkoutHomeState get _homeState => ref.watch(workoutHomeControllerProvider);

  void _togglePeriodSelector() {
    _controller.togglePeriodSelector();
  }

  void _selectDay(int period, int day) {
    _controller.selectDay(period, day);
  }

  Future<void> _updateSetWeight(
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

  Future<void> _updateSetReps(
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

  Future<void> _toggleSetLog(
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

  Future<void> _addSetBelow(
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

    // Create new set
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    // Insert set after current index
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

  Future<void> _toggleSetSkip(
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

  Future<void> _deleteSet(
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

    // Remove set
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

  Future<void> _updateSetType(
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

  Future<void> _addNote(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);

    final result = await showDialog<ExerciseNoteResult>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: exercise.notes,
        noteType: NoteType.exercise,
        initialPinned: exercise.isNotePinned,
      ),
    );

    if (result != null) {
      final updatedExercise = exercise.copyWith(
        notes: result.note.isEmpty ? null : result.note,
        isNotePinned: result.isPinned,
      );
      final updatedExercises = workout.exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);
    }
  }

  Future<void> _moveExerciseDown(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise down called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get the current trainingCycle to find all workouts for today
    final trainingCycle = ref.read(currentTrainingCycleProvider);
    if (trainingCycle == null) {
      debugPrint('No current trainingCycle');
      return;
    }

    // Get all workouts for this trainingCycle
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    // Get current period and day
    final currentPeriod = trainingCycle.getCurrentPeriod();
    if (currentPeriod == null) {
      debugPrint('Could not determine current period');
      return;
    }

    // Use selected period/day if available, otherwise use current
    final displayPeriod = _homeState.selectedPeriod ?? currentPeriod;
    final displayDay =
        _homeState.selectedDay ??
        (() {
          final daysSinceStart = DateTime.now()
              .difference(trainingCycle.startDate!)
              .inDays;
          final daysSincePeriodStart =
              daysSinceStart % trainingCycle.daysPerPeriod;
          return (daysSincePeriodStart + 1).clamp(
            1,
            trainingCycle.daysPerPeriod,
          );
        })();

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

    debugPrint('Total exercises across all workouts: ${allExercises.length}');

    // Find the exercise's position in the complete list
    final globalIndex = allExercises.indexWhere((e) => e.id == exerciseId);
    if (globalIndex == -1) {
      debugPrint('Exercise not found in allExercises');
      return;
    }

    if (globalIndex >= allExercises.length - 1) {
      debugPrint('Exercise is already at the bottom');
      return;
    }

    // Get the exercise to move and the exercise to swap with
    final exerciseToMove = allExercises[globalIndex];
    final exerciseToSwapWith = allExercises[globalIndex + 1];

    debugPrint(
      'Moving "${exerciseToMove.name}" down, swapping with "${exerciseToSwapWith.name}"',
    );

    // Find which workouts contain these exercises
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
      debugPrint('Could not find workouts containing the exercises');
      return;
    }

    if (workoutWithMovingExercise.id == workoutWithSwapExercise.id) {
      // Same workout - just swap positions
      final workout = workoutWithMovingExercise;
      final exercises = List<Exercise>.from(workout.exercises);
      final idx1 = exercises.indexWhere((e) => e.id == exerciseToMove.id);
      final idx2 = exercises.indexWhere((e) => e.id == exerciseToSwapWith.id);

      final temp = exercises[idx1];
      exercises[idx1] = exercises[idx2];
      exercises[idx2] = temp;

      final updatedWorkout = workout.copyWith(exercises: exercises);
      await repository.update(updatedWorkout);
      debugPrint('Swapped exercises within same workout');
    } else {
      // Different workouts - move exercise between workouts
      // Remove from first workout
      final exercises1 = workoutWithMovingExercise.exercises
          .where((e) => e.id != exerciseToMove.id)
          .toList();

      // Add to second workout (insert at the position before the swap exercise)
      final exercises2 = List<Exercise>.from(workoutWithSwapExercise.exercises);
      final insertIndex = exercises2.indexWhere(
        (e) => e.id == exerciseToSwapWith.id,
      );

      // Update the exercise's workoutId to match the new workout
      final movedExercise = exerciseToMove.copyWith(
        workoutId: workoutWithSwapExercise.id,
      );
      exercises2.insert(insertIndex, movedExercise);

      final updatedWorkout1 = workoutWithMovingExercise.copyWith(
        exercises: exercises1,
      );
      final updatedWorkout2 = workoutWithSwapExercise.copyWith(
        exercises: exercises2,
      );

      await repository.update(updatedWorkout1);
      await repository.update(updatedWorkout2);
      debugPrint(
        'Moved exercise from workout ${workoutWithMovingExercise.id} to ${workoutWithSwapExercise.id}',
      );
    }

    debugPrint('Exercise moved successfully');
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    // Get the workout and exercise
    final workout = ref.read(workoutProvider(workoutId));
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    // First delete the current exercise
    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await ref.read(workoutRepositoryProvider).update(updatedWorkout);

    // Navigate to add exercise screen with the same muscle group
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddExerciseScreen(
            trainingCycleId: workout.trainingCycleId,
            workoutId: workout.id,
            initialMuscleGroup: exercise.muscleGroup,
          ),
        ),
      );
    }
  }

  Future<void> _logJointPain(String workoutId, String exerciseId) async {
    // TODO: Implement joint pain dialog
    debugPrint('Log joint pain for exercise: $exerciseId');
  }

  Future<void> _addSetToExercise(String workoutId, String exerciseId) async {
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

  Future<void> _skipExerciseSets(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Only skip unlogged sets
    final updatedSets = (exercise.sets)
        .map((s) => !s.isLogged ? s.copyWith(isSkipped: true) : s)
        .toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
  }

  Future<void> _deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final updatedExercises = workout.exercises
        .where((e) => e.id != exerciseId)
        .toList();

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
  }

  bool _isWorkoutComplete(Workout workout) {
    // Check if all sets in all exercises are either logged or skipped
    for (final exercise in workout.exercises) {
      final sets = exercise.sets;
      for (final set in sets) {
        if (!set.isLogged && !set.isSkipped) {
          return false;
        }
      }
    }
    return true;
  }

  /// Calculate target RIR for a given period based on trainingCycle recovery schedule
  int _calculateRIR(int periodNumber, dynamic trainingCycle) {
    final recoveryPeriod = trainingCycle.recoveryPeriod;

    // Recovery period has 8 RIR
    if (periodNumber == recoveryPeriod) {
      return 8;
    }

    // Calculate periods until recovery
    final periodsUntilRecovery = recoveryPeriod - periodNumber;

    // Period before recovery = 0 RIR
    // 2 periods before = 1 RIR
    // 3 periods before = 2 RIR, etc.
    if (periodsUntilRecovery == 1) {
      return 0;
    } else if (periodsUntilRecovery > 1) {
      return periodsUntilRecovery - 1;
    } else {
      // After recovery period
      return 0;
    }
  }

  Future<void> _finishWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final trainingCycle = ref.read(currentTrainingCycleProvider);

    if (trainingCycle == null) return;

    // Mark ALL workouts for this day as completed
    for (final workout in workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await repository.update(updatedWorkout);
    }

    // Check if ALL workouts in the trainingCycle are now completed
    // We need to verify that every period/day combination has at least one completed workout
    final allWorkouts = repository.getByTrainingCycleId(trainingCycle.id);

    // Build a set of completed period/day combinations
    final completedDays = <String>{};
    for (final workout in allWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        completedDays.add('${workout.periodNumber}-${workout.dayNumber}');
      }
    }

    // Check if all expected period/day combinations are completed
    final totalPeriods = trainingCycle.periodsTotal;
    final daysPerPeriod = trainingCycle.daysPerPeriod;
    bool allCompleted = true;

    for (int period = 1; period <= totalPeriods; period++) {
      for (int day = 1; day <= daysPerPeriod; day++) {
        if (!completedDays.contains('$period-$day')) {
          allCompleted = false;
          break;
        }
      }
      if (!allCompleted) break;
    }

    if (allCompleted) {
      // Complete the trainingCycle
      await trainingCycleRepository.update(trainingCycle.complete());

      if (mounted) {
        final cycleTerm = ref.read(trainingCycleTermProvider);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$cycleTerm Completed!'),
            content: Text(
              'Congratulations! You have finished all workouts in this $cycleTerm.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/'); // Go back to list screen
                },
                child: const Text('AWESOME'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Navigate to next workout using the first workout's info
    final firstWorkout = workouts.first;

    // Find next workout
    int nextDay = firstWorkout.dayNumber + 1;
    int nextPeriod = firstWorkout.periodNumber;

    // Check if we need to move to next period
    if (nextDay > trainingCycle.daysPerPeriod) {
      nextDay = 1;
      nextPeriod++;
    }

    // Update selected day via controller
    _controller.navigateToNextDay(nextPeriod, nextDay);
  }

  @override
  Widget build(BuildContext context) {
    final currentTrainingCycle = ref.watch(currentTrainingCycleProvider);

    // Debug logging
    debugPrint('=== WorkoutHomeScreen Debug ===');
    debugPrint('Current trainingCycle: ${currentTrainingCycle?.name}');
    debugPrint('Start date: ${currentTrainingCycle?.startDate}');
    debugPrint('Status: ${currentTrainingCycle?.status}');

    // If there's a current trainingCycle, show today's workout
    if (currentTrainingCycle != null &&
        currentTrainingCycle.startDate != null) {
      // Get workouts from the workout repository instead of embedded workouts
      final allWorkouts = ref.watch(
        workoutsByTrainingCycleProvider(currentTrainingCycle.id),
      );

      debugPrint('Total workouts from repository: ${allWorkouts.length}');
      for (var workout in allWorkouts.take(5)) {
        debugPrint(
          '  Period ${workout.periodNumber} Day ${workout.dayNumber}: ${workout.exercises.length} exercises (ID: ${workout.id})',
        );
        for (var ex in workout.exercises) {
          debugPrint('    - ${ex.name}');
        }
      }

      final currentPeriod = currentTrainingCycle.getCurrentPeriod();
      debugPrint('Current period: $currentPeriod');

      if (currentPeriod == null) {
        // TrainingCycle hasn't started yet or has ended
        return _buildEmptyState(
          context,
          'TrainingCycle Not Active',
          'The trainingCycle is scheduled for a future date or has ended',
        );
      }

      // Use selected period/day if available, otherwise find first incomplete workout
      int displayPeriod;
      int displayDay;

      if (_homeState.selectedPeriod != null && _homeState.selectedDay != null) {
        // User has manually selected a specific workout (or we locked it in)
        displayPeriod = _homeState.selectedPeriod!;
        displayDay = _homeState.selectedDay!;
      } else {
        // Find first incomplete workout
        final firstIncomplete = findFirstIncompleteWorkout(allWorkouts);
        if (firstIncomplete != null) {
          displayPeriod = firstIncomplete.$1;
          displayDay = firstIncomplete.$2;
        } else {
          // All workouts complete, fall back to current period/day
          displayPeriod = currentPeriod;
          displayDay = (() {
            final daysSinceStart = DateTime.now()
                .difference(currentTrainingCycle.startDate!)
                .inDays;
            final daysSincePeriodStart =
                daysSinceStart % currentTrainingCycle.daysPerPeriod;
            return (daysSincePeriodStart + 1).clamp(
              1,
              currentTrainingCycle.daysPerPeriod,
            );
          })();
        }

        // Lock in the selected day so we don't auto-navigate on rebuild
        // This ensures user stays on current day until they press "Finish Workout"
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selectDay(displayPeriod, displayDay);
        });
      }

      debugPrint('Display period: $displayPeriod, Display day: $displayDay');

      // Get all workouts for the display period and day
      final todaysWorkouts = allWorkouts
          .where(
            (w) => w.periodNumber == displayPeriod && w.dayNumber == displayDay,
          )
          .toList();

      debugPrint(
        'Found ${todaysWorkouts.length} workouts for P$displayPeriod D$displayDay',
      );

      if (todaysWorkouts.isNotEmpty) {
        // Show selected day's workouts
        return _buildTodaysWorkoutView(
          context,
          ref,
          currentTrainingCycle,
          todaysWorkouts,
          displayPeriod,
          displayDay,
          currentPeriod: currentPeriod,
          allWorkouts: allWorkouts,
        );
      }

      // No workout found for selected day
      return _buildNoWorkoutForDay(
        context,
        ref,
        currentTrainingCycle,
        displayPeriod,
        displayDay,
        currentPeriod: currentPeriod,
        allWorkouts: allWorkouts,
      );
    }

    // If no current trainingCycle, show empty state
    return _buildEmptyState(
      context,
      'No Active TrainingCycle',
      'Create and start a trainingCycle to begin',
    );
  }

  /// Build empty state for a selected day that has no workout scheduled
  /// This includes the full AppBar with calendar navigation
  Widget _buildNoWorkoutForDay(
    BuildContext context,
    WidgetRef ref,
    dynamic trainingCycle,
    int displayPeriod,
    int displayDay, {
    required int currentPeriod,
    required List<Workout> allWorkouts,
  }) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: const AppIconWidget(),
          leadingWidth: kToolbarHeight + 12,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainingCycle.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PERIOD $displayPeriod DAY $displayDay',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _togglePeriodSelector,
            ),
            IconButton(
              icon: Icon(
                ref.watch(isDarkModeProvider)
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: ScreenBackground.workout(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Exercises Scheduled',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No exercises found for Period $displayPeriod, Day $displayDay',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _addExerciseForDay(
                        trainingCycle.id,
                        displayPeriod,
                        displayDay,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Exercise'),
                    ),
                  ],
                ),
              ),
              // Period selector overlay
              if (_homeState.showPeriodSelector) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _controller.hidePeriodSelector();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CalendarDropdown(
                    trainingCycle: trainingCycle,
                    currentPeriod: currentPeriod,
                    currentDay: displayDay,
                    selectedPeriod: displayPeriod,
                    selectedDay: displayDay,
                    allWorkouts: allWorkouts,
                    onDaySelected: _selectDay,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: ScreenBackground.workout(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 80,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysWorkoutView(
    BuildContext context,
    WidgetRef ref,
    dynamic trainingCycle,
    List<Workout> workouts,
    int displayPeriod,
    int displayDay, {
    required int currentPeriod,
    required List<Workout> allWorkouts,
  }) {
    // Calculate day name based on the trainingCycle start date
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    String dayName;

    // Debug logging
    debugPrint('=== DAY NAME CALCULATION ===');
    debugPrint('Start date: ${trainingCycle.startDate}');
    debugPrint('Start date weekday: ${trainingCycle.startDate?.weekday}');
    debugPrint('Display period: $displayPeriod, Display day: $displayDay');
    debugPrint('Days per period: ${trainingCycle.daysPerPeriod}');
    debugPrint(
      'Has custom dayName: ${workouts.isNotEmpty && workouts.first.dayName != null}',
    );
    if (workouts.isNotEmpty && workouts.first.dayName != null) {
      debugPrint('Custom dayName: ${workouts.first.dayName}');
    }

    if (workouts.isNotEmpty && workouts.first.dayName != null) {
      // Use custom day name from workout if available
      dayName = workouts.first.dayName!.substring(0, 3).toUpperCase();
      debugPrint('Using custom dayName: $dayName');
    } else if (trainingCycle.startDate != null) {
      // Calculate based on start date
      // Get the day of week when trainingCycle started (0 = Sunday, 6 = Saturday)
      final startDayOfWeek =
          trainingCycle.startDate!.weekday % 7; // Convert Monday=1 to Sunday=0
      debugPrint('Start day of week (after conversion): $startDayOfWeek');

      // Calculate days elapsed since start
      final daysElapsed =
          ((displayPeriod - 1) * trainingCycle.daysPerPeriod) +
          (displayDay - 1);
      debugPrint('Days elapsed: $daysElapsed');

      // Calculate actual day of week
      final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
      debugPrint('Actual day of week: $actualDayOfWeek');

      dayName = defaultDayNames[actualDayOfWeek];
      debugPrint('Calculated dayName: $dayName');
    } else {
      // Fallback to default if no start date
      dayName = displayDay >= 1 && displayDay <= defaultDayNames.length
          ? defaultDayNames[displayDay - 1]
          : 'DAY $displayDay';
      debugPrint('Using fallback dayName: $dayName');
    }

    // Collect all exercises from all workouts for today
    final allExercises = <dynamic>[];
    for (var workout in workouts) {
      allExercises.addAll(workout.exercises);
    }

    debugPrint(
      'Building workout view with ${allExercises.length} total exercises from ${workouts.length} workouts',
    );
    for (var i = 0; i < allExercises.length; i++) {
      debugPrint('  Exercise $i: ${allExercises[i].name}');
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: const AppIconWidget(),
          leadingWidth: kToolbarHeight + 12,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainingCycle.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PERIOD $displayPeriod DAY $displayDay $dayName',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _togglePeriodSelector,
            ),
            // Theme toggle
            IconButton(
              icon: Icon(
                ref.watch(isDarkModeProvider)
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              tooltip: 'Toggle theme',
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () =>
                    _showWorkoutMenu(context, trainingCycle, workouts),
              ),
            ),
          ],
        ),
        body: ScreenBackground.workout(
          child: Stack(
            children: [
              // Exercise list
              allExercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80, top: 24),
                      itemCount: allExercises.length,
                      separatorBuilder: (context, index) {
                        // Check if next exercise is same muscle group
                        final currentMuscleGroup =
                            allExercises[index].muscleGroup;
                        final nextMuscleGroup = index + 1 < allExercises.length
                            ? allExercises[index + 1].muscleGroup
                            : null;
                        final isSameMuscleGroup =
                            currentMuscleGroup == nextMuscleGroup;

                        // Thin grey divider for same muscle group, black spacer for different
                        return isSameMuscleGroup
                            ? Container(
                                height: 1,
                                color: const Color(0xFF3A3A3C),
                              )
                            : const SizedBox(height: 32);
                      },
                      itemBuilder: (context, index) {
                        final exercise = allExercises[index];
                        final showMuscleGroupBadge =
                            index == 0 ||
                            allExercises[index - 1].muscleGroup !=
                                exercise.muscleGroup;

                        // Calculate target RIR for current period
                        final periodRir = _calculateRIR(
                          displayPeriod,
                          trainingCycle,
                        );

                        return ExerciseCardWidget(
                          key: ValueKey(
                            '${exercise.id}_${exercise.sets.length}_${exercise.sets.map((s) => s.id).join(",")}_${ref.watch(useMetricProvider)}',
                          ),
                          exercise: exercise,
                          showMuscleGroupBadge: showMuscleGroupBadge,
                          targetRir: periodRir,
                          weightUnit: ref.watch(weightUnitProvider),
                          useMetric: ref.watch(useMetricProvider),
                          onAddNote: (exerciseId) =>
                              _addNote(exercise.workoutId, exerciseId),
                          onMoveDown: (exerciseId) =>
                              _moveExerciseDown(exercise.workoutId, exerciseId),
                          showMoveDown: true,
                          onReplace: (exerciseId) =>
                              _replaceExercise(exercise.workoutId, exerciseId),
                          onJointPain: (exerciseId) =>
                              _logJointPain(exercise.workoutId, exerciseId),
                          onAddSet: (exerciseId) =>
                              _addSetToExercise(exercise.workoutId, exerciseId),
                          onSkipSets: (exerciseId) =>
                              _skipExerciseSets(exercise.workoutId, exerciseId),
                          onDelete: (exerciseId) =>
                              _deleteExercise(exercise.workoutId, exerciseId),
                          onAddSetBelow: (setIndex) => _addSetBelow(
                            exercise.workoutId,
                            exercise.id,
                            setIndex,
                          ),
                          onToggleSetSkip: (setIndex) => _toggleSetSkip(
                            exercise.workoutId,
                            exercise.id,
                            setIndex,
                          ),
                          onDeleteSet: (setIndex) => _deleteSet(
                            exercise.workoutId,
                            exercise.id,
                            setIndex,
                          ),
                          onUpdateSetType: (setIndex, setType) =>
                              _updateSetType(
                                exercise.workoutId,
                                exercise.id,
                                setIndex,
                                setType,
                              ),
                          onUpdateSetWeight: (setIndex, value) =>
                              _updateSetWeight(
                                exercise.workoutId,
                                exercise.id,
                                setIndex,
                                value,
                              ),
                          onUpdateSetReps: (setIndex, value) => _updateSetReps(
                            exercise.workoutId,
                            exercise.id,
                            setIndex,
                            value,
                          ),
                          onToggleSetLog: (setIndex) => _toggleSetLog(
                            exercise.workoutId,
                            exercise.id,
                            setIndex,
                          ),
                        );
                      },
                    ),

              // Period selector overlay (shown on top when toggled)
              if (_homeState.showPeriodSelector) ...[
                // Barrier to dismiss on tap outside
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      _controller.hidePeriodSelector();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                // The dropdown itself
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CalendarDropdown(
                    trainingCycle: trainingCycle,
                    currentPeriod: currentPeriod,
                    currentDay: displayDay,
                    selectedPeriod: displayPeriod,
                    selectedDay: displayDay,
                    allWorkouts: allWorkouts,
                    onDaySelected: _selectDay,
                  ),
                ),
              ],

              // FINISH WORKOUT button (appears when all sets are logged or skipped)
              if (workouts.isNotEmpty &&
                  !workouts.every((w) => w.isCompleted) &&
                  workouts.every((w) => _isWorkoutComplete(w)))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: ElevatedButton(
                        onPressed: () => _finishWorkout(workouts),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'FINISH WORKOUT',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutMenu(
    BuildContext context,
    dynamic trainingCycle,
    List<Workout> workouts,
  ) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonPosition + const Offset(-180, 40),
        buttonPosition + const Offset(-180, 40) + const Offset(250, 0),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: <PopupMenuEntry<void>>[
        // TRAINING CYCLE Section
        _buildMenuHeader('TRAINING CYCLE'),
        _buildMenuItem(
          icon: Icons.edit_note,
          text: 'Note',
          onTap: () => _viewTrainingCycleNotes(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: 'Summary',
          onTap: () => _showTrainingCycleSummary(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.edit,
          text: 'Rename',
          onTap: () => _renameTrainingCycle(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.stop_circle_outlined,
          text: 'End ${ref.watch(trainingCycleTermProvider)}',
          onTap: () => _endTrainingCycle(trainingCycle),
          color: context.errorColor,
        ),
        const PopupMenuDivider(height: 1),

        // WORKOUT Section
        _buildMenuHeader('WORKOUT'),
        _buildMenuItem(
          icon: Icons.edit,
          text: 'New note',
          onTap: () => _newWorkoutNote(workouts),
        ),
        _buildMenuItem(
          icon: Icons.label_outline,
          text: 'Relabel',
          onTap: () => _relabelWorkout(workouts),
        ),
        _buildMenuItem(
          icon: Icons.clear_all,
          text: 'Clear all day labels',
          onTap: () => _clearAllDayNames(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.add,
          text: 'Add exercise',
          onTap: () => _addExerciseToWorkout(workouts),
        ),
        _buildMenuItem(
          icon: Icons.monitor_weight_outlined,
          text: 'Bodyweight',
          onTap: () => _logBodyweight(),
        ),
        _buildMenuItem(
          icon: Icons.undo,
          text: 'Reset',
          onTap: () => _resetWorkout(workouts),
          enabled:
              !workouts.any((w) => w.status == WorkoutStatus.completed) &&
              workouts.any(
                (w) => w.exercises.any(
                  (e) => e.sets.any(
                    (s) =>
                        s.isLogged ||
                        (s.weight != null) ||
                        (s.reps.isNotEmpty && s.reps != '0'),
                  ),
                ),
              ),
        ),
        _buildMenuItem(
          icon: Icons.skip_next,
          text: 'Skip workout',
          onTap: () => _skipWorkout(workouts),
        ),
      ],
    );
  }

  PopupMenuItem<void> _buildMenuHeader(String title) {
    return PopupMenuItem<void>(
      enabled: false,
      height: 32,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  PopupMenuItem<void> _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
    Color? color,
  }) {
    return PopupMenuItem<void>(
      enabled: enabled,
      height: 48,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled
                ? (color ?? Theme.of(context).iconTheme.color)
                : Theme.of(context).disabledColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: enabled
                  ? (color ?? Theme.of(context).textTheme.bodyMedium?.color)
                  : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  // Training Cycle actions
  Future<void> _viewTrainingCycleNotes(dynamic trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentNote = trainingCycle.notes as String?;

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: currentNote,
        noteType: NoteType.trainingCycle,
        customTitle: '$cycleTerm Note',
        customHint: 'Enter note for this $cycleTerm...',
      ),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(
          notes: newNote.isEmpty ? null : newNote,
        );
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note saved'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showTrainingCycleSummary(dynamic trainingCycle) {
    showDialog(
      context: context,
      builder: (context) => CycleSummaryDialog(trainingCycle: trainingCycle),
    );
  }

  Future<void> _renameTrainingCycle(dynamic trainingCycle) async {
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          RenameTrainingCycleDialog(initialName: trainingCycle.name),
    );

    if (newName != null && newName != trainingCycle.name && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(name: newName);
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Renamed to "$newName"'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error renaming trainingCycle: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _endTrainingCycle(dynamic trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End $cycleTerm'),
        content: Text(
          'Are you sure you want to end "${trainingCycle.name}"? This will mark it as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('END ${cycleTerm.toUpperCase()}'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(
          status: TrainingCycleStatus.completed,
          endDate: DateTime.now(),
        );
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${trainingCycle.name}" completed'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ending trainingCycle: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _newWorkoutNote(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    // Use the first workout to store the note for the day
    final workout = workouts.first;
    final currentNote = workout.notes;

    final newNote = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorkoutNoteDialog(initialNote: currentNote),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final updatedWorkout = workout.copyWith(notes: newNote);
        await repository.update(updatedWorkout);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note saved'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _relabelWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final workout = workouts.first;
    final currentLabel = workout.dayName ?? 'Day ${workout.dayNumber}';

    // Debug logging to understand what's being passed in
    debugPrint('=== RELABEL DEBUG ===');
    debugPrint('Workouts passed in: ${workouts.length}');
    for (var w in workouts) {
      debugPrint(
        '  - Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
      );
    }

    final result = await showDialog<({String label, bool applyToAll})>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RelabelDayDialog(initialLabel: currentLabel),
    );

    if (result != null && mounted) {
      debugPrint('Apply to all: ${result.applyToAll}');
      debugPrint('New label: ${result.label}');

      try {
        final repository = ref.read(workoutRepositoryProvider);

        if (result.applyToAll) {
          // Update all workouts with the same day number in this trainingCycle
          final allWorkouts = ref.read(
            workoutsByTrainingCycleProvider(workout.trainingCycleId),
          );
          final workoutsToUpdate = allWorkouts
              .where((w) => w.dayNumber == workout.dayNumber)
              .toList();

          debugPrint(
            'Updating ${workoutsToUpdate.length} workouts (apply to all)',
          );
          for (final w in workoutsToUpdate) {
            debugPrint(
              '  - Updating Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
            );
            final updatedWorkout = w.copyWith(dayName: result.label);
            await repository.update(updatedWorkout);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Updated label for all Day ${workout.dayNumber} workouts',
                ),
                backgroundColor: context.successColor,
              ),
            );
          }
        } else {
          // Update only the current workout(s) for this specific period and day
          // The workouts list passed in contains ALL workouts for this day across all periods
          // We need to filter to only the current period
          final currentPeriodNumber = workouts.first.periodNumber;
          final currentPeriodWorkouts = workouts
              .where((w) => w.periodNumber == currentPeriodNumber)
              .toList();

          debugPrint(
            'Updating ${currentPeriodWorkouts.length} workouts (current period only)',
          );
          for (final w in currentPeriodWorkouts) {
            debugPrint(
              '  - Updating Period ${w.periodNumber}, Day ${w.dayNumber}, ID: ${w.id}',
            );
            final updatedWorkout = w.copyWith(dayName: result.label);
            await repository.update(updatedWorkout);
          }

          // Verify the update by checking all workouts again
          debugPrint('=== VERIFICATION ===');
          final allWorkoutsAfter = ref.read(
            workoutsByTrainingCycleProvider(workout.trainingCycleId),
          );

          // Show ALL workouts grouped by period
          debugPrint('All workouts in trainingCycle after update:');
          for (int period = 1; period <= 5; period++) {
            final periodWorkouts = allWorkoutsAfter
                .where((w) => w.periodNumber == period)
                .toList();
            if (periodWorkouts.isNotEmpty) {
              debugPrint('  Period $period:');
              for (var w in periodWorkouts) {
                debugPrint(
                  '    - Day ${w.dayNumber}, dayName: "${w.dayName}", ID: ${w.id.substring(0, 8)}...',
                );
              }
            }
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Label updated'),
                backgroundColor: context.successColor,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error updating label: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating label: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllDayNames(dynamic trainingCycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Day Labels'),
        content: const Text(
          'This will remove all custom day labels from workouts in this trainingCycle. '
          'Day names will be calculated automatically based on the start date.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final allWorkouts = ref.read(
          workoutsByTrainingCycleProvider(trainingCycle.id),
        );

        debugPrint('Clearing dayName from ${allWorkouts.length} workouts');

        for (final workout in allWorkouts) {
          if (workout.dayName != null) {
            final updatedWorkout = workout.copyWith(dayName: null);
            await repository.update(updatedWorkout);
            debugPrint(
              '  Cleared: Period ${workout.periodNumber}, Day ${workout.dayNumber}',
            );
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('All day labels cleared'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error clearing day names: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing labels: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
      }
    }
  }

  void _addExerciseToWorkout(List<Workout> workouts) {
    if (workouts.isEmpty) return;
    showAddExerciseDialogFromWorkouts(
      context: context,
      ref: ref,
      workouts: workouts,
    );
  }

  /// Add exercise to a day that has no workouts yet
  void _addExerciseForDay(
    String trainingCycleId,
    int periodNumber,
    int dayNumber,
  ) {
    showAddExerciseDialog(
      context: context,
      ref: ref,
      workouts: [], // No existing workouts
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
    );
  }

  void _logBodyweight() {
    debugPrint('Log bodyweight');
  }

  void _resetWorkout(List<Workout> workouts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Workout?'),
        content: const Text(
          'This will clear all logged sets and entered values for this workout. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                final repository = ref.read(workoutRepositoryProvider);

                for (final workout in workouts) {
                  // Create updated exercises with reset sets
                  final updatedExercises = workout.exercises.map((exercise) {
                    final updatedSets = exercise.sets.map((set) {
                      return set.copyWith(
                        isLogged: false,
                        weight: null, // Clear weight
                        reps: '', // Clear reps
                      );
                    }).toList();

                    return exercise.copyWith(sets: updatedSets);
                  }).toList();

                  // Update workout with reset exercises and status
                  final updatedWorkout = workout.copyWith(
                    exercises: updatedExercises,
                    status: WorkoutStatus.incomplete,
                    completedDate: null,
                  );

                  await repository.update(updatedWorkout);
                }

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: const Text('Workout reset'),
                    backgroundColor: this.context.successColor,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Error resetting workout: $e'),
                    backgroundColor: this.context.errorColor,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _skipWorkout(List<Workout> workouts) {
    debugPrint('Skip workout');
  }
}

/// Old modal widget - kept for reference but not used
class _PeriodSelectorModal extends StatefulWidget {
  final TrainingCycle trainingCycle;
  final int currentPeriod;
  final int currentDay;

  const _PeriodSelectorModal({
    required this.trainingCycle,
    required this.currentPeriod,
    required this.currentDay,
  });

  @override
  State<_PeriodSelectorModal> createState() => _PeriodSelectorModalState();
}

class _PeriodSelectorModalState extends State<_PeriodSelectorModal> {
  late int _selectedPeriod;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.currentPeriod;
    _selectedDay = widget.currentDay;
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final availableDays = dayNames
        .take(widget.trainingCycle.daysPerPeriod)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'PERIODS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Period selector buttons (+ and -)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _selectedPeriod > 1
                      ? () {
                          setState(() {
                            _selectedPeriod--;
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _selectedPeriod < widget.trainingCycle.periodsTotal
                      ? () {
                          setState(() {
                            _selectedPeriod++;
                          });
                        }
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),

          // Period grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.trainingCycle.periodsTotal, (
                  periodIndex,
                ) {
                  final periodNumber = periodIndex + 1;
                  return _buildPeriodColumn(
                    periodNumber,
                    availableDays,
                    widget.trainingCycle.recoveryPeriod == periodNumber,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodColumn(
    int periodNumber,
    List<String> dayNames,
    bool isRecovery,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Period header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                Text(
                  '$periodNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isRecovery)
                  Text(
                    'DL',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  '${_calculateRIR(periodNumber)} RIR',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Day buttons
          ...List.generate(dayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentPeriod = periodNumber == widget.currentPeriod;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                periodNumber == _selectedPeriod && dayNumber == _selectedDay;
            final isCompleted =
                periodNumber < widget.currentPeriod ||
                (isCurrentPeriod && dayNumber < widget.currentDay);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = periodNumber;
                  _selectedDay = dayNumber;
                });

                Navigator.pop(context);
              },
              child: Container(
                width: 80,
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.successColor
                      : (isCurrentPeriod && isCurrentDay)
                      ? context.errorColor
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNames[dayIndex],
                  style: TextStyle(
                    color: isCompleted || (isCurrentPeriod && isCurrentDay)
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),

          // Extra days for periods with fewer workout days
          if (dayNames.length < 7)
            ...List.generate(7 - dayNames.length, (index) {
              final extraDayIndex = dayNames.length + index;
              final extraDayNames = [
                'Sun',
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
              ];
              return Container(
                width: 80,
                height: 56,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  extraDayNames[extraDayIndex],
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  int _calculateRIR(int periodNumber) {
    final recoveryPeriod = widget.trainingCycle.recoveryPeriod;

    // Recovery period has 8 RIR
    if (periodNumber == recoveryPeriod) {
      return 8;
    }

    // Calculate periods until recovery
    final periodsUntilRecovery = recoveryPeriod - periodNumber;

    // Period before recovery = 0 RIR
    // 2 periods before = 1 RIR
    // 3 periods before = 2 RIR, etc.
    if (periodsUntilRecovery == 1) {
      return 0;
    } else if (periodsUntilRecovery > 1) {
      return periodsUntilRecovery - 1;
    } else {
      // After recovery period
      return 0;
    }
  }
}
