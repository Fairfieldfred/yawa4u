import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/skins/skins.dart';
import '../../core/utils/day_sequence.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../data/repositories/training_cycle_repository.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/exercise_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
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
  int? _selectedPeriod;
  int? _selectedDay;
  bool _showPeriodSelector = false;
  PageController? _dayPageController;
  bool _isDaySwiping = false;
  int? _lastSyncedDayPageIndex;

  @override
  void dispose() {
    _dayPageController?.dispose();
    super.dispose();
  }

  void _togglePeriodSelector() {
    setState(() {
      _showPeriodSelector = !_showPeriodSelector;
    });
  }

  void _onDaySelected(int period, int day) {
    setState(() {
      _selectedPeriod = period;
      _selectedDay = day;
    });
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

  /// Show menu for training cycle operations (used on empty state)
  void _showCycleMenu(BuildContext context, TrainingCycle trainingCycle) {
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

    final cycleTerm = ref.read(trainingCycleTermProvider);

    showMenu(
      context: context,
      position: position,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: <PopupMenuEntry<void>>[
        // TRAINING CYCLE Section
        PopupMenuItem<void>(
          enabled: false,
          height: 32,
          child: Text(
            cycleTerm.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        PopupMenuItem<void>(
          height: 48,
          onTap: () => _writeCycleNote(trainingCycle),
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text('Note', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem<void>(
          height: 48,
          onTap: () => _showCycleSummary(trainingCycle),
          child: Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                size: 20,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 12),
              Text('Summary', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  void _showCycleSummary(TrainingCycle trainingCycle) {
    showDialog(
      context: context,
      builder: (context) => CycleSummaryDialog(trainingCycle: trainingCycle),
    );
  }

  Future<void> _writeCycleNote(TrainingCycle trainingCycle) async {
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentNote = trainingCycle.notes;

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        noteType: NoteType.trainingCycle,
        initialNote: currentNote,
        customTitle: '$cycleTerm Note',
        customHint: 'Enter note for this $cycleTerm...',
      ),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedCycle = trainingCycle.copyWith(notes: newNote);
        await repository.update(updatedCycle);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrainingCycle = ref.watch(currentTrainingCycleProvider);

    if (currentTrainingCycle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: ScreenBackground.exercises(
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
        ),
      );
    }

    // Wait for cycle-specific workouts to load before building PageView
    final cycleWorkoutsAsync = ref.watch(
      workoutsByTrainingCycleProvider(currentTrainingCycle.id),
    );
    if (cycleWorkoutsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get workouts for the current trainingCycle
    final allWorkouts = cycleWorkoutsAsync.asData?.value ?? [];

    // Find the first incomplete workout day (not just workout/muscle group)
    // Group by (periodNumber, dayNumber) to find unique days
    final Map<String, List<Workout>> workoutsByDay = {};
    for (var workout in allWorkouts) {
      final key = '${workout.periodNumber}-${workout.dayNumber}';
      workoutsByDay.putIfAbsent(key, () => []).add(workout);
    }

    // Find first day with any incomplete workout (for "current" marker)
    int currentPeriod = 1;
    int currentDay = 1;
    for (var entry in workoutsByDay.entries) {
      if (entry.value.any((w) => w.status == WorkoutStatus.incomplete)) {
        final parts = entry.key.split('-');
        currentPeriod = int.parse(parts[0]);
        currentDay = int.parse(parts[1]);
        break;
      }
    }

    // Use selected period/day if set, otherwise use current (first incomplete)
    final displayPeriod = _selectedPeriod ?? currentPeriod;
    final displayDay = _selectedDay ?? currentDay;

    // Build day sequence for swipe navigation
    final daySequence = buildDaySequence(
      currentTrainingCycle.periodsTotal,
      currentTrainingCycle.daysPerPeriod,
    );
    final currentPageIndex =
        findDayIndex(daySequence, displayPeriod, displayDay) ?? 0;

    // Initialize or sync day PageController
    if (_dayPageController == null) {
      _dayPageController = PageController(initialPage: currentPageIndex);
      _lastSyncedDayPageIndex = currentPageIndex;
    } else if (!_isDaySwiping &&
        _dayPageController!.hasClients &&
        _lastSyncedDayPageIndex != currentPageIndex) {
      _lastSyncedDayPageIndex = currentPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dayPageController?.hasClients == true) {
          _dayPageController!.animateToPage(
            currentPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
    _isDaySwiping = false;

    return PageView.builder(
      controller: _dayPageController,
      itemCount: daySequence.length,
      onPageChanged: (index) {
        _isDaySwiping = true;
        FocusScope.of(context).unfocus();
        final pos = daySequence[index];
        _onDaySelected(pos.period, pos.day);
      },
      itemBuilder: (context, index) {
        final pos = daySequence[index];
        final key = '${pos.period}-${pos.day}';

        if (!workoutsByDay.containsKey(key)) {
          return _buildEmptyDayPage(
            context,
            currentTrainingCycle,
            pos.period,
            pos.day,
            currentPeriod: currentPeriod,
            currentDay: currentDay,
            allWorkouts: allWorkouts,
          );
        }

        return _WorkoutSessionView(
          key: ValueKey(key),
          workouts: workoutsByDay[key]!,
          trainingCycle: currentTrainingCycle,
          allWorkouts: allWorkouts,
          currentPeriod: currentPeriod,
          currentDay: currentDay,
          selectedPeriod: pos.period,
          selectedDay: pos.day,
          onDaySelected: _onDaySelected,
        );
      },
    );
  }

  /// Build empty state page for a day with no scheduled exercises.
  Widget _buildEmptyDayPage(
    BuildContext context,
    TrainingCycle trainingCycle,
    int period,
    int day, {
    required int currentPeriod,
    required int currentDay,
    required List<Workout> allWorkouts,
  }) {
    return Scaffold(
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
              'PERIOD $period DAY $day',
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
            tooltip: 'Select day',
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showCycleMenu(context, trainingCycle),
            ),
          ),
        ],
      ),
      body: ScreenBackground.exercises(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises scheduled',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Add exercises for Period $period, Day $day',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _addExerciseForDay(
                      trainingCycle.id,
                      period,
                      day,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ],
              ),
            ),
            // Period selector overlay
            if (_showPeriodSelector) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPeriodSelector = false;
                    });
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
                  currentDay: currentDay,
                  selectedPeriod: period,
                  selectedDay: day,
                  allWorkouts: allWorkouts,
                  onDaySelected: (p, d) {
                    setState(() {
                      _showPeriodSelector = false;
                    });
                    _onDaySelected(p, d);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutSessionView extends ConsumerStatefulWidget {
  final List<Workout> workouts;
  final TrainingCycle trainingCycle;
  final List<Workout> allWorkouts;
  final int currentPeriod;
  final int currentDay;
  final int selectedPeriod;
  final int selectedDay;
  final Function(int period, int day) onDaySelected;

  const _WorkoutSessionView({
    required Key key,
    required this.workouts,
    required this.trainingCycle,
    required this.allWorkouts,
    required this.currentPeriod,
    required this.currentDay,
    required this.selectedPeriod,
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
  bool _showPeriodSelector = false;
  bool _initialPageSet = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _togglePeriodSelector() {
    setState(() {
      _showPeriodSelector = !_showPeriodSelector;
    });
  }

  void _toggleHistory() {
    ref.read(showExerciseHistoryProvider.notifier).toggle();
  }

  /// Invalidate workout providers to trigger UI refresh
  /// This matches the pattern used in workout_screen
  void _invalidateWorkoutProviders() {
    ref.invalidate(
      workoutsByTrainingCycleListProvider(widget.trainingCycle.id),
    );
    ref.invalidate(workoutsByTrainingCycleProvider(widget.trainingCycle.id));
    ref.invalidate(workoutsProvider);
  }

  /// Build exercise list and source mapping from workouts
  /// Called in build() to get fresh data each time
  (List<Exercise>, Map<int, _ExerciseSource>) _buildExerciseData() {
    final allExercises = <Exercise>[];
    final exerciseSources = <int, _ExerciseSource>{};

    for (var workout in widget.workouts) {
      for (var exercise in workout.exercises) {
        final exerciseIndex = allExercises.length;
        exerciseSources[exerciseIndex] = _ExerciseSource(
          workout: workout,
          exerciseIndex: workout.exercises.indexOf(exercise),
        );
        allExercises.add(exercise);
      }
    }

    return (allExercises, exerciseSources);
  }

  int _findFirstUnfinishedExerciseIndex(List<Exercise> exercises) {
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
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
    // Build exercise list directly from widget.workouts (fresh from provider)
    final (allExercises, exerciseSources) = _buildExerciseData();

    // Set initial page to first unfinished exercise (only once)
    if (!_initialPageSet && allExercises.isNotEmpty) {
      _initialPageSet = true;
      final initialPage = _findFirstUnfinishedExerciseIndex(allExercises);
      if (initialPage != _currentPage) {
        _currentPage = initialPage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(initialPage);
          }
        });
      }
    }

    // Use the first workout's display info for the appBar
    final firstWorkout = widget.workouts.first;
    final trainingCycle = widget.trainingCycle;

    final displayPeriod = firstWorkout.periodNumber;
    final displayDay = firstWorkout.dayNumber;
    final dayName = firstWorkout.dayName ?? '';

    // Check if all exercises are completed
    final allExercisesCompleted =
        allExercises.isNotEmpty &&
        allExercises.every(
          (exercise) =>
              exercise.sets.every((set) => set.isLogged || set.isSkipped),
        );

    // Check if workouts are already marked as finished
    final workoutsAlreadyFinished = widget.workouts.every((w) => w.isCompleted);

    // Show finish button only if all exercises done AND workout not already finished
    final showFinishButton = allExercisesCompleted && !workoutsAlreadyFinished;

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
            // History toggle
            IconButton(
              icon: Icon(
                Icons.history,
                color: ref.watch(showExerciseHistoryProvider)
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: _toggleHistory,
              tooltip: 'Toggle history',
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
        body: ScreenBackground.exercises(
          child: allExercises.isEmpty
              ? _buildEmptyExercisesState(context, widget.workouts)
              : Stack(
                  children: [
                    Column(
                      children: [
                        // Progress Indicator
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / allExercises.length,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),

                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: allExercises.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final source = exerciseSources[index]!;
                              final exercise = allExercises[index];
                              // Always show muscle group badge on exercises screen
                              const showMuscleGroupBadge = true;

                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    top: 24,
                                    bottom: showFinishButton
                                        ? 100
                                        : 24, // Extra padding for button
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RepaintBoundary(
                                        child: ExerciseCardWidget(
                                        key: ValueKey(
                                          '${exercise.id}_${exercise.sets.length}_${exercise.sets.map((s) => s.id).join(",")}_${ref.watch(useMetricProvider)}',
                                        ),
                                        exercise: exercise,
                                        showMuscleGroupBadge:
                                            showMuscleGroupBadge,
                                        targetRir: calculateRIR(
                                          source.workout.periodNumber,
                                          widget.trainingCycle.recoveryPeriod,
                                        ),
                                        weightUnit: ref.watch(
                                          weightUnitProvider,
                                        ),
                                        useMetric: ref.watch(useMetricProvider),
                                        showMoveDown: false,
                                        callbacks: ExerciseCardCallbacks(
                                          onAddNote: (id) => _addNote(
                                            source.workout.id, id,
                                          ),
                                          onReplace: (id) => _replaceExercise(
                                            source.workout.id, id,
                                          ),
                                          onJointPain: (id) => _logJointPain(
                                            source.workout.id, id,
                                          ),
                                          onAddSet: (id) => _addSetToExercise(
                                            source.workout.id, id,
                                          ),
                                          onSkipSets: (id) =>
                                              _skipExerciseSets(
                                                source.workout.id, id,
                                              ),
                                          onDelete: (id) => _deleteExercise(
                                            source.workout.id, id,
                                          ),
                                          onAddSetBelow: (i) => _addSetBelow(
                                            source.workout.id, exercise.id, i,
                                          ),
                                          onToggleSetSkip: (i) =>
                                              _toggleSetSkip(
                                                source.workout.id,
                                                exercise.id,
                                                i,
                                              ),
                                          onDeleteSet: (i) => _deleteSet(
                                            source.workout.id, exercise.id, i,
                                          ),
                                          onUpdateSetType: (i, type) =>
                                              _updateSetType(
                                                source.workout.id,
                                                exercise.id,
                                                i,
                                                type,
                                              ),
                                          onUpdateSetWeight: (i, v) =>
                                              _updateSetWeight(
                                                source.workout.id,
                                                exercise.id,
                                                i,
                                                v,
                                              ),
                                          onUpdateSetReps: (i, v) =>
                                              _updateSetReps(
                                                source.workout.id,
                                                exercise.id,
                                                i,
                                                v,
                                              ),
                                          onToggleSetLog: (i) => _toggleSetLog(
                                            source.workout.id, exercise.id, i,
                                          ),
                                        ),
                                      ),
                                      ),
                                      // Swipe indicator
                                      if (allExercises.length > 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.swap_horiz,
                                              size: 24,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      // Exercise History Section
                                      if (ref.watch(
                                        showExerciseHistoryProvider,
                                      ))
                                        _buildExerciseHistory(
                                          context,
                                          exercise,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Finish Workout Button (appears when all exercises are complete but workout not yet finished)
                    if (showFinishButton)
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
                                backgroundColor: context.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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

                    // Period selector overlay (shown on top when toggled)
                    if (_showPeriodSelector) ...[
                      // Barrier to dismiss on tap outside
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showPeriodSelector = false;
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
                          currentPeriod: widget.currentPeriod,
                          currentDay: widget.currentDay,
                          selectedPeriod: widget.selectedPeriod,
                          selectedDay: widget.selectedDay,
                          allWorkouts: widget.allWorkouts,
                          onDaySelected: (period, day) {
                            setState(() {
                              _showPeriodSelector = false;
                            });
                            widget.onDaySelected(period, day);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyExercisesState(
    BuildContext context,
    List<Workout> workouts,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises scheduled',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addExerciseToWorkout(workouts),
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
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
    final now = DateTime.now();
    final exerciseRepo = ref.read(exerciseRepositoryProvider);
    for (var workout in widget.workouts) {
      // Update lastPerformed on exercises that have logged sets
      final updatedExercises = workout.exercises.map((exercise) {
        if (exercise.sets.any((s) => s.isLogged)) {
          return exercise.copyWith(lastPerformed: now);
        }
        return exercise;
      }).toList();

      final updatedWorkout = workout.copyWith(
        status: WorkoutStatus.completed,
        completedDate: now,
        exercises: updatedExercises,
      );
      await workoutRepo.update(updatedWorkout);

      // Also update individual exercise records in the database
      for (final exercise in updatedExercises) {
        if (exercise.sets.any((s) => s.isLogged)) {
          await exerciseRepo.update(exercise);
        }
      }
    }

    // Get fresh workouts directly from repository (not provider which may have stale data)
    final allWorkouts = await workoutRepo.getByTrainingCycleId(
      currentTrainingCycle.id,
    );

    // Check if ALL workouts in the trainingCycle are now completed
    final completedDays = <String>{};
    for (final workout in allWorkouts) {
      if (workout.status == WorkoutStatus.completed) {
        completedDays.add('${workout.periodNumber}-${workout.dayNumber}');
      }
    }

    // Check if all expected period/day combinations are completed
    final totalPeriods = currentTrainingCycle.periodsTotal;
    final daysPerPeriod = currentTrainingCycle.daysPerPeriod;
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
          icon: Icons.edit_note,
          text: 'Note',
          onTap: () => _writeTrainingCycleNote(trainingCycle),
        ),
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
          text: 'Note',
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

  Future<void> _writeTrainingCycleNote(dynamic trainingCycle) async {
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
      builder: (context) =>
          NoteDialog(initialNote: currentNote, noteType: NoteType.workout),
    );

    if (newNote != null && newNote != currentNote && mounted) {
      final repository = ref.read(workoutRepositoryProvider);
      final updatedWorkout = workout.copyWith(
        notes: newNote.isEmpty ? null : newNote,
      );
      await repository.update(updatedWorkout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note saved'),
            backgroundColor: context.successColor,
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
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
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

      _invalidateWorkoutProviders();
      if (mounted) {
        setState(() {});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout reset'),
            backgroundColor: context.successColor,
          ),
        );
      }
    }
  }

  // ========== Exercise Callbacks ==========
  Future<void> _addNote(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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

    if (result != null && mounted) {
      final updatedExercise = exercise.copyWith(
        notes: result.note.isEmpty ? null : result.note,
        isNotePinned: result.isPinned,
      );
      final updatedExercises = workout.exercises
          .map((e) => e.id == exerciseId ? updatedExercise : e)
          .toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);

      // Rebuild exercise list to reflect the change
      _invalidateWorkoutProviders();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    // Navigate to AddExerciseScreen with replaceExerciseId
    // This will replace the exercise in-place, preserving sets and order
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddExerciseScreen(
              trainingCycleId: workout.trainingCycleId,
              workoutId: workout.id,
              initialMuscleGroup: exercise.muscleGroup,
              replaceExerciseId: exerciseId,
            ),
          ),
        )
        .then((_) async {
          // Rebuild exercise list when returning from AddExerciseScreen
          if (mounted) {
            _invalidateWorkoutProviders();
            if (mounted) {
              setState(() {});
            }
          }
        });
  }

  void _logJointPain(String workoutId, String exerciseId) {
    // TODO: Implement joint pain feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joint pain logging coming soon')),
    );
  }

  Future<void> _addSetToExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Auto-populate weight from previous performance (with suggestion)
    final historyService = ref.read(exerciseHistoryServiceProvider);
    final result = await historyService.getAutoPopulateWeightWithSuggestion(
      exercise.name,
      exercise.id,
      exercise.sets.length,
      exercise.equipmentType,
    );
    final prevWeight = result.weight;

    final newSet = ExerciseSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = [...exercise.sets, newSet];
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _skipExerciseSets(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Only skip unlogged sets
    final updatedSets = exercise.sets
        .map((s) => !s.isLogged ? s.copyWith(isSkipped: true) : s)
        .toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final updatedExercises = List<Exercise>.from(workout.exercises);
    updatedExercises.removeAt(exerciseIndex);
    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);

    // Rebuild exercise list
    _invalidateWorkoutProviders();
    // Note: _currentPage will be adjusted on next build if needed
  }

  // ========== Set Callbacks ==========
  Future<void> _addSetBelow(
    String workoutId,
    String exerciseId,
    int currentSetIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];

    // Auto-populate weight from previous performance (with suggestion)
    final historyService = ref.read(exerciseHistoryServiceProvider);
    final insertIndex = currentSetIndex + 1;
    final result = await historyService.getAutoPopulateWeightWithSuggestion(
      exercise.name,
      exercise.id,
      insertIndex,
      exercise.equipmentType,
    );
    final prevWeight = result.weight;

    final newSet = ExerciseSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
      reps: '',
      setType: SetType.regular,
    );

    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(insertIndex, newSet);

    // Renumber sets
    for (var i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleSetSkip(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteSet(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType setType,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
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
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);
    // Don't invalidate providers here - it causes parent to rebuild and lose focus
    // Data is saved to database; UI will refresh on navigation or explicit refresh
  }

  Future<void> _updateSetReps(
    String workoutId,
    String exerciseId,
    int setIndex,
    String value,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);
    // Don't invalidate providers here - it causes parent to rebuild and lose focus
    // Data is saved to database; UI will refresh on navigation or explicit refresh
  }

  Future<void> _toggleSetLog(
    String workoutId,
    String exerciseId,
    int setIndex,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
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
    await repository.update(updatedWorkout);

    // Force UI update
    _invalidateWorkoutProviders();
    if (mounted) {
      setState(() {});
    }
  }

  // ========== Exercise History ==========
  Widget _buildExerciseHistory(BuildContext context, Exercise exercise) {
    // Use provider data instead of sync repository calls
    final workoutsAsync = ref.watch(workoutsProvider);
    final trainingCyclesAsync = ref.watch(trainingCyclesProvider);

    // Handle loading/error states by returning empty history
    final allWorkouts = workoutsAsync.value ?? [];
    final allTrainingCycles = trainingCyclesAsync.value ?? [];

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
    final periods = trainingCycle?.periodsTotal ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 0),
      child: Text(
        '$name - $periods PERIODS'.toUpperCase(),
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
    final isRecovery =
        entry.trainingCycle != null &&
        entry.workout.periodNumber == entry.trainingCycle!.recoveryPeriod;

    // Group sets by weight and build weight × reps string
    // This properly handles sets with different weights (e.g., "1 lbs x 1, 10 lbs x 1")
    final weightGroups = <double?, List<ExerciseSet>>{};
    for (final set in loggedSets) {
      weightGroups.putIfAbsent(set.weight, () => []).add(set);
    }

    // Build formatted string for each weight group
    final List<_WeightRepsGroup> groups = [];
    for (final weightEntry in weightGroups.entries) {
      final weight = weightEntry.key;
      final sets = weightEntry.value;

      final weightStr = weight != null
          ? weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)
          : 'BW';

      // Collect reps with their badges for this weight group
      final repsWithBadges = sets.map((set) {
        final badge = set.setType.badge;
        if (badge != null) {
          return '${set.reps} $badge';
        }
        return set.reps;
      }).toList();

      groups.add(
        _WeightRepsGroup(
          weightStr: weightStr,
          repsStr: repsWithBadges.join(', '),
        ),
      );
    }

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
                    children: _buildWeightRepsSpans(context, groups),
                  ),
                ),
                if (isRecovery) ...[
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
          // Right side: Period/Day + Date
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
                    const TextSpan(text: 'PERIOD '),
                    TextSpan(
                      text: '${entry.workout.periodNumber}',
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

  /// Build TextSpan children for weight × reps display, properly grouping by weight
  List<InlineSpan> _buildWeightRepsSpans(
    BuildContext context,
    List<_WeightRepsGroup> groups,
  ) {
    final List<InlineSpan> spans = [];

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];

      // Add separator between groups
      if (i > 0) {
        spans.add(const TextSpan(text: ',  '));
      }

      spans.add(
        TextSpan(text: group.weightStr, style: const TextStyle(fontSize: 18)),
      );
      spans.add(
        TextSpan(
          text: ' lbs',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
          ),
        ),
      );
      spans.add(const TextSpan(text: '  x  '));
      spans.add(
        TextSpan(text: group.repsStr, style: const TextStyle(fontSize: 18)),
      );
    }

    return spans;
  }
}

/// Helper class to track which workout an exercise belongs to
class _ExerciseSource {
  final Workout workout;
  final int exerciseIndex; // Index within that workout's exercises list

  _ExerciseSource({required this.workout, required this.exerciseIndex});
}

/// Helper class for grouping weight and reps in history display
class _WeightRepsGroup {
  final String weightStr;
  final String repsStr;

  _WeightRepsGroup({required this.weightStr, required this.repsStr});
}
