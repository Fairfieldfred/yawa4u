import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/exercise_card_widget.dart';

/// Exercises library home screen
class ExercisesHomeScreen extends ConsumerWidget {
  const ExercisesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMesocycle = ref.watch(currentMesocycleProvider);

    if (currentMesocycle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('No active mesocycle')),
      );
    }

    // Check loading state of the base provider
    final workoutsState = ref.watch(workoutsProvider);
    if (workoutsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get workouts for the current mesocycle
    final allWorkouts = ref.watch(
      workoutsByMesocycleProvider(currentMesocycle.id),
    );

    // Find the first incomplete workout day (not just workout/muscle group)
    // Group by (weekNumber, dayNumber) to find unique days
    final Map<String, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      final key = '${workout.weekNumber}-${workout.dayNumber}';
      workoutsByDay.putIfAbsent(key, () => []).add(workout);
    }

    // Find first day with any incomplete workout
    String? firstIncompleteDay;
    for (var entry in workoutsByDay.entries) {
      if (entry.value.any((w) => w.status == WorkoutStatus.incomplete)) {
        firstIncompleteDay = entry.key;
        break;
      }
    }

    if (firstIncompleteDay == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('All workouts completed!')),
      );
    }

    // Get all workouts for that day
    final dayWorkouts = workoutsByDay[firstIncompleteDay]!;

    return _WorkoutSessionView(
      key: ValueKey(firstIncompleteDay), // Rebuild if day changes
      workouts: dayWorkouts,
    );
  }
}

class _WorkoutSessionView extends ConsumerStatefulWidget {
  final List<Workout> workouts;

  const _WorkoutSessionView({required Key key, required this.workouts})
    : super(key: key);

  @override
  ConsumerState<_WorkoutSessionView> createState() =>
      _WorkoutSessionViewState();
}

class _WorkoutSessionViewState extends ConsumerState<_WorkoutSessionView> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<Exercise> _allExercises;
  late Map<int, _ExerciseSource> _exerciseSources; // Maps exercise index to its source workout

  @override
  void initState() {
    super.initState();
    _buildExerciseList();

    // Find first unfinished exercise set
    final initialPage = _findFirstUnfinishedExerciseIndex();
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void didUpdateWidget(_WorkoutSessionView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild exercise list when workouts change
    _buildExerciseList();
  }

  void _buildExerciseList() {
    _allExercises = [];
    _exerciseSources = {};

    // Collect all exercises from all workouts for this day
    for (var workout in widget.workouts) {
      for (var exercise in workout.exercises) {
        final exerciseIndex = _allExercises.length;
        _exerciseSources[exerciseIndex] = _ExerciseSource(
          workout: workout,
          exerciseIndex: workout.exercises.indexOf(exercise),
        );
        _allExercises.add(exercise);
      }
    }
  }

  int _findFirstUnfinishedExerciseIndex() {
    for (int i = 0; i < _allExercises.length; i++) {
      final exercise = _allExercises[i];
      // Check if any set is not logged
      if (exercise.sets.any((set) => !set.isLogged)) {
        return i;
      }
    }
    // If all exercises are complete, return 0 (first exercise)
    return 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the first workout's display info for the appBar
    final firstWorkout = widget.workouts.first;
    final dayLabel = firstWorkout.dayName ?? 'Week ${firstWorkout.weekNumber} - Day ${firstWorkout.dayNumber}';

    return Scaffold(
      appBar: AppBar(title: Text(dayLabel), centerTitle: true),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_allExercises.isEmpty)
                ? 0
                : (_currentPage + 1) / _allExercises.length,
            backgroundColor: Theme.of(context).dividerColor,
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _allExercises.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final source = _exerciseSources[index]!;
                final exercise = _allExercises[index];
                final showMuscleGroupBadge = index == 0 ||
                    _allExercises[index - 1].muscleGroup != exercise.muscleGroup;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ExerciseCardWidget(
                    key: ValueKey('${exercise.id}_${exercise.sets.length}_${exercise.sets.map((s) => s.id).join(",")}'),
                    exercise: exercise,
                    showMuscleGroupBadge: showMuscleGroupBadge,
                    targetRir: null, // Could calculate this if needed
                    onAddNote: (exerciseId) => _addNote(source.workout.id, exerciseId),
                    onMoveDown: (exerciseId) => _moveExerciseDown(source.workout.id, exerciseId),
                    onReplace: (exerciseId) => _replaceExercise(source.workout.id, exerciseId),
                    onJointPain: (exerciseId) => _logJointPain(source.workout.id, exerciseId),
                    onAddSet: (exerciseId) => _addSetToExercise(source.workout.id, exerciseId),
                    onSkipSets: (exerciseId) => _skipExerciseSets(source.workout.id, exerciseId),
                    onDelete: (exerciseId) => _deleteExercise(source.workout.id, exerciseId),
                    onAddSetBelow: (setIndex) => _addSetBelow(source.workout.id, exercise.id, setIndex),
                    onToggleSetSkip: (setIndex) => _toggleSetSkip(source.workout.id, exercise.id, setIndex),
                    onDeleteSet: (setIndex) => _deleteSet(source.workout.id, exercise.id, setIndex),
                    onUpdateSetType: (setIndex, setType) => _updateSetType(source.workout.id, exercise.id, setIndex, setType),
                    onUpdateSetWeight: (setIndex, value) => _updateSetWeight(source.workout.id, exercise.id, setIndex, value),
                    onUpdateSetReps: (setIndex, value) => _updateSetReps(source.workout.id, exercise.id, setIndex, value),
                    onToggleSetLog: (setIndex) => _toggleSetLog(source.workout.id, exercise.id, setIndex),
                  ),
                );
              },
            ),
          ),

          _BottomActionBar(
            currentExercise: _allExercises[_currentPage],
            currentPage: _currentPage,
            totalPages: _allExercises.length,
            onNext: _goToNextPage,
          ),
        ],
      ),
    );
  }

  // ========== Exercise Callbacks ==========
  void _addNote(String workoutId, String exerciseId) {
    // TODO: Implement add note dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add note feature coming soon')),
    );
  }

  void _moveExerciseDown(String workoutId, String exerciseId) {
    // TODO: Implement move exercise
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move exercise feature coming soon')),
    );
  }

  void _replaceExercise(String workoutId, String exerciseId) {
    // TODO: Implement replace exercise
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Replace exercise feature coming soon')),
    );
  }

  void _logJointPain(String workoutId, String exerciseId) {
    // TODO: Implement joint pain feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joint pain logging coming soon')),
    );
  }

  void _addSetToExercise(String workoutId, String exerciseId) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final newSet = ExerciseSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = [...exercise.sets, newSet];
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _skipExerciseSets(String workoutId, String exerciseId) {
    // TODO: Implement skip sets
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skip sets feature coming soon')),
    );
  }

  void _deleteExercise(String workoutId, String exerciseId) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises.removeAt(exerciseIndex);
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    repository.update(updatedWorkout);

    // Rebuild exercise list
    setState(() {
      _buildExerciseList();
      if (_currentPage >= _allExercises.length && _allExercises.isNotEmpty) {
        _currentPage = _allExercises.length - 1;
      }
    });
  }

  // ========== Set Callbacks ==========
  void _addSetBelow(String workoutId, String exerciseId, int currentSetIndex) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final newSet = ExerciseSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(currentSetIndex + 1, newSet);

    // Renumber sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _toggleSetSkip(String workoutId, String exerciseId, int setIndex) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(isSkipped: !set.isSkipped);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _deleteSet(String workoutId, String exerciseId, int setIndex) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    // Renumber sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _updateSetType(String workoutId, String exerciseId, int setIndex, SetType setType) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(setType: setType);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _updateSetWeight(String workoutId, String exerciseId, int setIndex, String value) {
    final weight = double.tryParse(value);
    if (weight == null && value.isNotEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(weight: weight);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);
  }

  void _updateSetReps(String workoutId, String exerciseId, int setIndex, String value) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(reps: value);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);
  }

  void _toggleSetLog(String workoutId, String exerciseId, int setIndex) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(exerciseIndex, updatedExercise);
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  // ========== Navigation ==========
  void _goToNextPage() {
    if (_currentPage < _allExercises.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    final workoutRepo = ref.read(workoutRepositoryProvider);

    // Mark all workouts for this day as completed
    for (var workout in widget.workouts) {
      workoutRepo.markAsCompleted(workout.id);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout Completed!')));
  }
}

/// Helper class to track which workout an exercise belongs to
class _ExerciseSource {
  final Workout workout;
  final int exerciseIndex; // Index within that workout's exercises list

  _ExerciseSource({required this.workout, required this.exerciseIndex});
}

// The old _ExercisePage and _SetRow classes have been replaced with the shared ExerciseCardWidget

class _BottomActionBar extends StatelessWidget {
  final Exercise currentExercise;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const _BottomActionBar({
    required this.currentExercise,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isExerciseCompleted = currentExercise.isCompleted;
    final isLastPage = currentPage == totalPages - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (isExerciseCompleted)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
                label: Text(isLastPage ? 'Finish Workout' : 'Next Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLastPage ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Optional: Maybe a "Mark Exercise Done" button here if they want to skip logging sets?
                  // For now, let's just allow moving to next even if not fully logged,
                  // or we can force them to log.
                  // The user said "row with either a checkmark fo rfinished, or a next arrow".
                  // This implies if NOT finished, show checkmark.
                  // If finished, show next arrow.

                  // But "Checkmark" usually means "Mark as Done".
                  // If I click Checkmark, it should probably mark all sets as logged?
                  // Or just visually mark exercise as done?

                  // Let's assume "Checkmark" means "I am done with this exercise".
                  onNext();
                },
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
