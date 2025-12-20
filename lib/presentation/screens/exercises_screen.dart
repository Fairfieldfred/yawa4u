import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/training_cycle_repository.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/calendar_dropdown.dart';
import '../widgets/cycle_summary_dialog.dart';
import '../widgets/dialogs/add_exercise_dialog.dart';
import '../widgets/exercise_card_widget.dart';

/// Helper class to hold history entry data
class _HistoryEntry {
  final Exercise exercise;
  final Workout workout;
  final TrainingCycle? trainingCycle;
  final DateTime? completedDate;

  _HistoryEntry({
    required this.exercise,
    required this.workout,
    this.trainingCycle,
    this.completedDate,
  });
}

/// Exercises library home screen
class ExercisesHomeScreen extends ConsumerStatefulWidget {
  const ExercisesHomeScreen({super.key});

  @override
  ConsumerState<ExercisesHomeScreen> createState() =>
      _ExercisesHomeScreenState();
}

class _ExercisesHomeScreenState extends ConsumerState<ExercisesHomeScreen> {
  int? _selectedWeek;
  int? _selectedDay;

  void _onDaySelected(int week, int day) {
    setState(() {
      _selectedWeek = week;
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTrainingCycle = ref.watch(currentTrainingCycleProvider);

    if (currentTrainingCycle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: Center(
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
              Text(
                'No Active TrainingCycle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Create and start a trainingCycle to begin',
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
      );
    }

    // Check loading state of the base provider
    final workoutsState = ref.watch(workoutsProvider);
    if (workoutsState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get workouts for the current trainingCycle
    final allWorkouts = ref.watch(
      workoutsByTrainingCycleProvider(currentTrainingCycle.id),
    );

    // Find the first incomplete workout day (not just workout/muscle group)
    // Group by (weekNumber, dayNumber) to find unique days
    final Map<String, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      final key = '${workout.weekNumber}-${workout.dayNumber}';
      workoutsByDay.putIfAbsent(key, () => []).add(workout);
    }

    // Find first day with any incomplete workout (for "current" marker)
    int currentWeek = 1;
    int currentDay = 1;
    for (var entry in workoutsByDay.entries) {
      if (entry.value.any((w) => w.status == WorkoutStatus.incomplete)) {
        final parts = entry.key.split('-');
        currentWeek = int.parse(parts[0]);
        currentDay = int.parse(parts[1]);
        break;
      }
    }

    // Use selected week/day if set, otherwise use current (first incomplete)
    final displayWeek = _selectedWeek ?? currentWeek;
    final displayDay = _selectedDay ?? currentDay;
    final displayKey = '$displayWeek-$displayDay';

    // Check if selected day has workouts
    if (!workoutsByDay.containsKey(displayKey)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('No workouts for selected day')),
      );
    }

    // Get workouts for the display day
    final dayWorkouts = workoutsByDay[displayKey]!;

    return _WorkoutSessionView(
      key: ValueKey(displayKey), // Rebuild if day changes
      workouts: dayWorkouts,
      trainingCycle: currentTrainingCycle,
      allWorkouts: allWorkouts,
      currentWeek: currentWeek,
      currentDay: currentDay,
      selectedWeek: displayWeek,
      selectedDay: displayDay,
      onDaySelected: _onDaySelected,
    );
  }
}

class _WorkoutSessionView extends ConsumerStatefulWidget {
  final List<Workout> workouts;
  final TrainingCycle trainingCycle;
  final List<Workout> allWorkouts;
  final int currentWeek;
  final int currentDay;
  final int selectedWeek;
  final int selectedDay;
  final Function(int week, int day) onDaySelected;

  const _WorkoutSessionView({
    required Key key,
    required this.workouts,
    required this.trainingCycle,
    required this.allWorkouts,
    required this.currentWeek,
    required this.currentDay,
    required this.selectedWeek,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  ConsumerState<_WorkoutSessionView> createState() =>
      _WorkoutSessionViewState();
}

class _WorkoutSessionViewState extends ConsumerState<_WorkoutSessionView> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<Exercise> _allExercises;
  late Map<int, _ExerciseSource>
  _exerciseSources; // Maps exercise index to its source workout
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

    // Fetch fresh workout data from repository
    final repository = ref.read(workoutRepositoryProvider);

    // Collect all exercises from all workouts for this day
    for (var originalWorkout in widget.workouts) {
      // Get the latest version from repository
      final workout = repository.getById(originalWorkout.id) ?? originalWorkout;
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
    final trainingCycle = widget.trainingCycle;

    final displayWeek = firstWorkout.weekNumber;
    final displayDay = firstWorkout.dayNumber;
    final dayName = firstWorkout.dayName ?? '';

    // Check if all exercises are completed
    final allExercisesCompleted =
        _allExercises.isNotEmpty &&
        _allExercises.every(
          (exercise) =>
              exercise.sets.every((set) => set.isLogged || set.isSkipped),
        );

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
                onPressed: () =>
                    _showWorkoutMenu(context, trainingCycle, widget.workouts),
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
                      final showMuscleGroupBadge =
                          index == 0 ||
                          _allExercises[index - 1].muscleGroup !=
                              exercise.muscleGroup;

                      return GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: 24,
                            bottom: allExercisesCompleted
                                ? 100
                                : 24, // Extra padding for button
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExerciseCardWidget(
                                key: ValueKey(
                                  '${exercise.id}_${exercise.sets.length}_${exercise.sets.map((s) => s.id).join(",")}_${ref.watch(useMetricProvider)}',
                                ),
                                exercise: exercise,
                                showMuscleGroupBadge: showMuscleGroupBadge,
                                targetRir:
                                    null, // Could calculate this if needed
                                weightUnit: ref.watch(weightUnitProvider),
                                useMetric: ref.watch(useMetricProvider),
                                onAddNote: (exerciseId) =>
                                    _addNote(source.workout.id, exerciseId),
                                showMoveDown:
                                    false, // Single exercise view, no reordering needed
                                onReplace: (exerciseId) => _replaceExercise(
                                  source.workout.id,
                                  exerciseId,
                                ),
                                onJointPain: (exerciseId) => _logJointPain(
                                  source.workout.id,
                                  exerciseId,
                                ),
                                onAddSet: (exerciseId) => _addSetToExercise(
                                  source.workout.id,
                                  exerciseId,
                                ),
                                onSkipSets: (exerciseId) => _skipExerciseSets(
                                  source.workout.id,
                                  exerciseId,
                                ),
                                onDelete: (exerciseId) => _deleteExercise(
                                  source.workout.id,
                                  exerciseId,
                                ),
                                onAddSetBelow: (setIndex) => _addSetBelow(
                                  source.workout.id,
                                  exercise.id,
                                  setIndex,
                                ),
                                onToggleSetSkip: (setIndex) => _toggleSetSkip(
                                  source.workout.id,
                                  exercise.id,
                                  setIndex,
                                ),
                                onDeleteSet: (setIndex) => _deleteSet(
                                  source.workout.id,
                                  exercise.id,
                                  setIndex,
                                ),
                                onUpdateSetType: (setIndex, setType) =>
                                    _updateSetType(
                                      source.workout.id,
                                      exercise.id,
                                      setIndex,
                                      setType,
                                    ),
                                onUpdateSetWeight: (setIndex, value) =>
                                    _updateSetWeight(
                                      source.workout.id,
                                      exercise.id,
                                      setIndex,
                                      value,
                                    ),
                                onUpdateSetReps: (setIndex, value) =>
                                    _updateSetReps(
                                      source.workout.id,
                                      exercise.id,
                                      setIndex,
                                      value,
                                    ),
                                onToggleSetLog: (setIndex) => _toggleSetLog(
                                  source.workout.id,
                                  exercise.id,
                                  setIndex,
                                ),
                              ),
                              // Exercise History Section
                              _buildExerciseHistory(context, exercise),
                            ],
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
                      top: BorderSide(color: Theme.of(context).dividerColor),
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

            // Week selector overlay (shown on top when toggled)
            if (_showWeekSelector) ...[
              // Barrier to dismiss on tap outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showWeekSelector = false;
                    });
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
                  trainingCycle: widget.trainingCycle,
                  currentWeek: widget.currentWeek,
                  currentDay: widget.currentDay,
                  selectedWeek: widget.selectedWeek,
                  selectedDay: widget.selectedDay,
                  allWorkouts: widget.allWorkouts,
                  onDaySelected: (week, day) {
                    setState(() {
                      _showWeekSelector = false;
                    });
                    widget.onDaySelected(week, day);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ========== Navigation ==========
  Future<void> _finishWorkout() async {
    // Read ALL provider values upfront before any async operations
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final currentTrainingCycle = ref.read(currentTrainingCycleProvider);
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);

    if (currentTrainingCycle == null) return;

    // Mark all workouts for this day as completed (await each update)
    for (var workout in widget.workouts) {
      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
      );
      await workoutRepo.update(updatedWorkout);
    }

    // Get fresh workouts directly from repository (not provider which may have stale data)
    final allWorkouts = workoutRepo.getByTrainingCycleId(
      currentTrainingCycle.id,
    );

    // Check if ALL workouts in the trainingCycle are now completed
    final completedDays = <String>{};
    for (final workout in allWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        completedDays.add('${workout.weekNumber}-${workout.dayNumber}');
      }
    }

    // Check if all expected week/day combinations are completed
    final totalWeeks = currentTrainingCycle.weeksTotal;
    final daysPerWeek = currentTrainingCycle.daysPerWeek;
    bool allCompleted = true;

    for (int week = 1; week <= totalWeeks; week++) {
      for (int day = 1; day <= daysPerWeek; day++) {
        if (!completedDays.contains('$week-$day')) {
          allCompleted = false;
          break;
        }
      }
      if (!allCompleted) break;
    }

    if (allCompleted) {
      // Complete the trainingCycle and show dialog
      await _showCycleCompletedDialog(
        currentTrainingCycle,
        cycleTerm,
        trainingCycleRepository,
      );
      return;
    }

    // There are more workouts - invalidate the provider to trigger rebuild
    // But first check if still mounted
    if (!mounted) return;
    ref.invalidate(workoutsByTrainingCycleProvider(currentTrainingCycle.id));
  }

  Future<void> _showCycleCompletedDialog(
    TrainingCycle trainingCycle,
    String cycleTerm,
    TrainingCycleRepository trainingCycleRepository,
  ) async {
    // Complete the trainingCycle first
    await trainingCycleRepository.update(trainingCycle.complete());

    if (!mounted) return;

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
        _buildMenuHeader(ref.watch(trainingCycleTermProvider).toUpperCase()),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: 'Summary',
          onTap: () => _showTrainingCycleSummary(trainingCycle),
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
          icon: Icons.add,
          text: 'Add exercise',
          onTap: () => _addExerciseToWorkout(workouts),
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

  void _showTrainingCycleSummary(dynamic trainingCycle) {
    showDialog(
      context: context,
      builder: (context) => CycleSummaryDialog(trainingCycle: trainingCycle),
    );
  }

  void _addExerciseToWorkout(List<Workout> workouts) {
    if (workouts.isEmpty) return;
    showAddExerciseDialogFromWorkouts(
      context: context,
      ref: ref,
      workouts: workouts,
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
  Future<void> _addNote(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere((e) => e.id == exerciseId);
    final noteController = TextEditingController(text: exercise.notes ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final updatedExercise = exercise.copyWith(
        notes: result.isEmpty ? null : result,
      );
      final updatedExercises = workout.exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);

      // Rebuild exercise list to reflect the change
      setState(() {
        _buildExerciseList();
      });
    }
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

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
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
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
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

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
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

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
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
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
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

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(isSkipped: !set.isSkipped);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
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

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
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
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType setType,
  ) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(setType: setType);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  void _updateSetWeight(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) {
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
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(weight: weight);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    repository.update(updatedWorkout);

    // Force UI update to reflect isLoggable state
    setState(() {
      _buildExerciseList();
    });
  }

  void _updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(reps: value);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    repository.update(updatedWorkout);

    // Force UI update to reflect isLoggable state
    setState(() {
      _buildExerciseList();
    });
  }

  void _toggleSetLog(String workoutId, String exerciseId, int setIndex) {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (setIndex >= exercise.sets.length) return;

    final set = exercise.sets[setIndex];
    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(setIndex, updatedSet);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    repository.update(updatedWorkout);

    // Force UI update
    setState(() {
      _buildExerciseList();
    });
  }

  // ========== Exercise History ==========
  Widget _buildExerciseHistory(BuildContext context, Exercise exercise) {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final trainingCycleRepo = ref.read(trainingCycleRepositoryProvider);
    final allWorkouts = workoutRepo.getAll();
    final allTrainingCycles = trainingCycleRepo.getAll();

    // Create a map of trainingCycleId -> trainingCycle for quick lookup
    final trainingCycleMap = {for (var m in allTrainingCycles) m.id: m};

    // Find all exercises with the same name from all workouts (across all trainingCycles)
    final List<_HistoryEntry> historyEntries = [];

    for (final workout in allWorkouts) {
      for (final ex in workout.exercises) {
        if (ex.name.toLowerCase() == exercise.name.toLowerCase()) {
          // Only include exercises with at least one logged set
          if (ex.sets.any((s) => s.isLogged)) {
            final trainingCycle = trainingCycleMap[workout.trainingCycleId];
            historyEntries.add(
              _HistoryEntry(
                exercise: ex,
                workout: workout,
                trainingCycle: trainingCycle,
                completedDate: workout.completedDate ?? ex.lastPerformed,
              ),
            );
          }
        }
      }
    }

    // Sort by date (most recent first)
    historyEntries.sort((a, b) {
      if (a.completedDate == null && b.completedDate == null) return 0;
      if (a.completedDate == null) return 1;
      if (b.completedDate == null) return -1;
      return b.completedDate!.compareTo(a.completedDate!);
    });

    // Exclude the current exercise instance from history
    final filteredHistory = historyEntries
        .where((entry) => entry.exercise.id != exercise.id)
        .toList();

    if (filteredHistory.isEmpty) {
      return const SizedBox.shrink(); // No history to show
    }

    // Group entries by trainingCycle
    final Map<String, List<_HistoryEntry>> groupedByTrainingCycle = {};
    for (final entry in filteredHistory) {
      final trainingCycleId = entry.trainingCycle?.id ?? 'unknown';
      groupedByTrainingCycle.putIfAbsent(trainingCycleId, () => []).add(entry);
    }

    // Build list with trainingCycle headers
    final List<Widget> children = [];
    for (final trainingCycleId in groupedByTrainingCycle.keys) {
      final entries = groupedByTrainingCycle[trainingCycleId]!;
      final trainingCycle = entries.first.trainingCycle;

      // Add trainingCycle header
      children.add(_buildTrainingCycleHeader(context, trainingCycle));

      // Add entries for this trainingCycle
      for (final entry in entries) {
        children.add(_buildHistoryRow(context, entry));
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'History',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          ...children,
        ],
      ),
    );
  }

  Widget _buildTrainingCycleHeader(
    BuildContext context,
    TrainingCycle? trainingCycle,
  ) {
    final name = trainingCycle?.name ?? 'Unknown TrainingCycle';
    final weeks = trainingCycle?.weeksTotal ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 0),
      child: Text(
        '$name - $weeks WEEKS'.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHistoryRow(BuildContext context, _HistoryEntry entry) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateStr = entry.completedDate != null
        ? dateFormat.format(entry.completedDate!)
        : 'Unknown date';

    final loggedSets = entry.exercise.sets.where((s) => s.isLogged).toList();
    final isDeload =
        entry.trainingCycle != null &&
        entry.workout.weekNumber == entry.trainingCycle!.deloadWeek;

    // Build the weight × reps string with set type badges
    final weight = loggedSets.isNotEmpty && loggedSets.first.weight != null
        ? loggedSets.first.weight!
        : null;
    final weightStr = weight != null
        ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
        : 'BW';

    // Collect reps with their badges
    final repsWithBadges = loggedSets.map((set) {
      final badge = set.setType.badge;
      if (badge != null) {
        return '${set.reps} $badge';
      }
      return set.reps;
    }).toList();

    final repsStr = repsWithBadges.join(',  ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.1).round()),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Weight × Reps + Deload indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: weightStr,
                        style: const TextStyle(fontSize: 18),
                      ),
                      TextSpan(
                        text: ' lbs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurface
                              .withAlpha((255 * 0.7).round()),
                        ),
                      ),
                      const TextSpan(text: '  x  '),
                      TextSpan(
                        text: repsStr,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                if (isDeload) ...[
                  const SizedBox(height: 2),
                  Text(
                    'DELOAD',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Right side: Week/Day + Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  ),
                  children: [
                    const TextSpan(text: 'WEEK '),
                    TextSpan(
                      text: '${entry.workout.weekNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(text: ' - DAY '),
                    TextSpan(
                      text: '${entry.workout.dayNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
