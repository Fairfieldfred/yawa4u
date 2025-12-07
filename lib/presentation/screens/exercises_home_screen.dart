import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/exercise_card_widget.dart';
import '../widgets/mesocycle_summary_dialog.dart';

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
  bool _showWeekSelector = false;

  @override
  void initState() {
    super.initState();
    _buildExerciseList();

    // Find first unfinished exercise set
    final initialPage = _findFirstUnfinishedExerciseIndex();
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  void _toggleWeekSelector() {
    setState(() {
      _showWeekSelector = !_showWeekSelector;
    });
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
    final currentMesocycle = ref.watch(currentMesocycleProvider);

    final displayWeek = firstWorkout.weekNumber;
    final displayDay = firstWorkout.dayNumber;
    final dayName = firstWorkout.dayName ?? '';

    // Check if all exercises are completed
    final allExercisesCompleted = _allExercises.isNotEmpty &&
        _allExercises.every((exercise) => exercise.sets.every((set) => set.isLogged || set.isSkipped));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentMesocycle?.name.toUpperCase() ?? 'MESOCYCLE',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'WEEK $displayWeek DAY $displayDay $dayName',
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
              onPressed: _toggleWeekSelector,
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
                onPressed: () => _showWorkoutMenu(context, currentMesocycle, widget.workouts),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
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

                      return GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: 24,
                            bottom: allExercisesCompleted ? 100 : 24, // Extra padding for button
                          ),
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Finish Workout Button (appears when all exercises are complete)
            if (allExercisesCompleted)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: () => _finishWorkout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
    );
  }

  // ========== Navigation ==========
  void _finishWorkout() {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final currentMesocycle = ref.read(currentMesocycleProvider);
    if (currentMesocycle == null) return;

    // Mark all workouts for this day as completed
    for (var workout in widget.workouts) {
      workoutRepo.markAsCompleted(workout.id);
    }

    // Get all workouts for the mesocycle
    final allWorkouts = ref.read(workoutsByMesocycleProvider(currentMesocycle.id));

    // Find the next workout day with incomplete exercises
    final currentWeek = widget.workouts.first.weekNumber;
    final currentDay = widget.workouts.first.dayNumber;

    // Group all workouts by (week, day)
    final Map<String, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      final key = '${workout.weekNumber}-${workout.dayNumber}';
      workoutsByDay.putIfAbsent(key, () => []).add(workout);
    }

    // Sort keys to find next day
    final sortedKeys = workoutsByDay.keys.toList()..sort((a, b) {
      final aParts = a.split('-').map(int.parse).toList();
      final bParts = b.split('-').map(int.parse).toList();
      if (aParts[0] != bParts[0]) return aParts[0].compareTo(bParts[0]); // Compare week
      return aParts[1].compareTo(bParts[1]); // Compare day
    });

    // Find next incomplete day
    final currentKey = '$currentWeek-$currentDay';
    final currentIndex = sortedKeys.indexOf(currentKey);

    for (int i = currentIndex + 1; i < sortedKeys.length; i++) {
      final dayWorkouts = workoutsByDay[sortedKeys[i]]!;

      // Check if this day has any incomplete exercises
      final hasIncomplete = dayWorkouts.any((w) =>
        w.exercises.any((e) => e.sets.any((s) => !s.isLogged && !s.isSkipped))
      );

      if (hasIncomplete) {
        // Navigate to this workout day
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => _WorkoutSessionView(
              key: ValueKey(sortedKeys[i]),
              workouts: dayWorkouts,
            ),
          ),
        );
        return;
      }
    }

    // No more incomplete workouts - show completion message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All workouts completed! Great job!')),
    );
    Navigator.of(context).pop();
  }

  void _showWorkoutMenu(
    BuildContext context,
    dynamic mesocycle,
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
        // MESOCYCLE Section
        _buildMenuHeader('MESOCYCLE'),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: 'Summary',
          onTap: () => _showMesocycleSummary(mesocycle),
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
                ? Theme.of(context).iconTheme.color
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
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showMesocycleSummary(dynamic mesocycle) {
    showDialog(
      context: context,
      builder: (context) => MesocycleSummaryDialog(mesocycle: mesocycle),
    );
  }

  Future<void> _newWorkoutNote(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final workout = workouts.first;
    final currentNote = workout.notes;

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => _WorkoutNoteDialog(initialNote: currentNote),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      final repository = ref.read(workoutRepositoryProvider);
      final updatedWorkout = workout.copyWith(notes: newNote);
      await repository.update(updatedWorkout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _resetWorkout(List<Workout> workouts) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Workout'),
        content: const Text(
          'This will clear all logged sets and entered data for this workout. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repository = ref.read(workoutRepositoryProvider);

      for (final workout in workouts) {
        final resetExercises = workout.exercises.map((exercise) {
          final resetSets = exercise.sets.map((set) {
            return set.copyWith(
              weight: null,
              reps: '',
              isLogged: false,
              isSkipped: false,
            );
          }).toList();
          return exercise.copyWith(sets: resetSets);
        }).toList();

        final resetWorkout = workout.copyWith(
          exercises: resetExercises,
          status: WorkoutStatus.incomplete,
        );

        await repository.update(resetWorkout);
      }

      setState(() {
        _buildExerciseList();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout reset'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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

}

/// Helper class to track which workout an exercise belongs to
class _ExerciseSource {
  final Workout workout;
  final int exerciseIndex; // Index within that workout's exercises list

  _ExerciseSource({required this.workout, required this.exerciseIndex});
}

/// Dialog for adding/editing workout notes
class _WorkoutNoteDialog extends StatefulWidget {
  final String? initialNote;

  const _WorkoutNoteDialog({this.initialNote});

  @override
  State<_WorkoutNoteDialog> createState() => _WorkoutNoteDialogState();
}

class _WorkoutNoteDialogState extends State<_WorkoutNoteDialog> {
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  'Workout Note',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: noteController,
              autofocus: true,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter note for this workout...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(noteController.text.trim());
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
