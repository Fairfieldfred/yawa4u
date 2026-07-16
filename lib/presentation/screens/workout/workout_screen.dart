import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../data/services/exercise_name_localizer.dart';
import '../../../core/constants/sports.dart';
import '../../../data/database/app_database.dart' show ExerciseSetsCompanion;
import '../../../data/database/daos/exercise_set_dao.dart' show ExerciseSetDao;
import '../../../data/database/mappers/entity_mappers.dart' show ExerciseFeedbackMapper;
import '../../../core/theme/skins/skins.dart';
import '../../../core/utils/session_order.dart';
import '../../../core/utils/weight_conversion.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/live_set_info.dart';
import '../../../data/models/session.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/controllers/workout_home_controller.dart';
import '../../../domain/providers/calendar_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/exercise_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/rest_timer_provider.dart';
import '../../../domain/providers/session_providers.dart';
import '../../../domain/providers/theme_provider.dart';
import '../../../domain/providers/training_cycle_providers.dart';
import '../../../domain/providers/workout_providers.dart';
import '../../widgets/app_icon_widget.dart';
import '../../widgets/calendar_dropdown.dart';
import '../../widgets/cardio/cardio_session_card.dart';
import '../../widgets/cardio/sport_grid.dart';
import '../../widgets/cycle_summary_dialog.dart';
import '../../widgets/dialogs/add_exercise_dialog.dart';
import '../../widgets/dialogs/exercise_feedback_dialog.dart';
import '../../widgets/dialogs/rest_timer_dialog.dart';
import '../../widgets/dialogs/workout_dialogs.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/exercise_card_widget.dart';
import '../../widgets/rest_timer_widget.dart';
import '../../widgets/screen_background.dart';
import '../../../l10n/app_localizations.dart';
import 'add_exercise_screen.dart';

/// Workout home screen - shows current/upcoming workouts
class WorkoutHomeScreen extends ConsumerStatefulWidget {
  const WorkoutHomeScreen({super.key});

  @override
  ConsumerState<WorkoutHomeScreen> createState() => _WorkoutHomeScreenState();
}

class _WorkoutHomeScreenState extends ConsumerState<WorkoutHomeScreen> with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // Scroll / keyboard state
  // ---------------------------------------------------------------------------

  /// Manual override for slot render order (move up/down).
  /// Null = use natural sort from [sortByPerformedOrder].
  /// Reset on any data mutation via [_invalidateWorkoutProviders].
  List<String>? _manualSlotOrder;

  /// Per-field debounce timers for weight/reps saves.
  final Map<String, Timer> _debounceTimers = {};

  /// Cached workouts per cycle to keep UI stable during provider refresh.
  /// Prevents _buildEmptyState from destroying text fields on invalidation.
  Set<String> _cachedCycleIds = {};
  final Map<String, List<Workout>> _cachedWorkoutsPerCycle = {};

  /// Local overrides for set values during typing.
  /// Prevents full provider invalidation on every debounced save.
  final Map<String, double?> _localWeights = {};
  final Map<String, String> _localReps = {};

  /// DAO captured during [initState] for the flush-on-dispose path.
  /// Riverpod forbids `ref.read` inside [dispose] because BuildContext is
  /// already deactivated by then, so we save the reference up front.
  ExerciseSetDao? _setDaoForDispose;

  @override
  void initState() {
    super.initState();
    _setDaoForDispose = ref.read(exerciseSetDaoProvider);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Display timers don't fire in the background — re-derive the rest
    // timer from its persisted wall-clock deadline when we come back.
    if (lifecycleState == AppLifecycleState.resumed) {
      ref.read(restTimerProvider.notifier).resync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // UX review P0 #2 — flush any still-pending debounced set edits
    // BEFORE cancelling their timers so in-flight text-field changes
    // aren't lost when the user navigates away mid-keystroke. We use
    // the DAO reference captured in initState (ref.read is unsafe in
    // dispose). Writes are fire-and-forget by design — we don't want
    // dispose() to block.
    final setDao = _setDaoForDispose;
    if (setDao != null) {
      for (final entry in _debounceTimers.entries) {
        final key = entry.key;
        final timer = entry.value;
        if (timer.isActive) {
          if (key.startsWith('weight_')) {
            final setId = key.substring('weight_'.length);
            setDao.updateByUuid(
              setId,
              ExerciseSetsCompanion(weight: Value(_localWeights[setId])),
            );
          } else if (key.startsWith('reps_')) {
            final setId = key.substring('reps_'.length);
            final reps = _localReps[setId];
            if (reps != null) {
              setDao.updateByUuid(
                setId,
                ExerciseSetsCompanion(reps: Value(reps)),
              );
            }
          }
        }
        timer.cancel();
      }
    } else {
      for (final timer in _debounceTimers.values) {
        timer.cancel();
      }
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Controller Access
  // ---------------------------------------------------------------------------

  WorkoutHomeController get _controller => ref.read(workoutHomeControllerProvider.notifier);

  WorkoutHomeState get _homeState => ref.watch(workoutHomeControllerProvider);

  void _togglePeriodSelector() {
    _controller.togglePeriodSelector();
  }

  void _selectDay(int period, int day) {
    _controller.selectDay(period, day);
  }

  /// Invalidate workout providers to trigger UI refresh.
  /// Only invalidates cycle-specific providers — the global
  /// workoutsProvider is left alone to avoid re-fetching every workout.
  void _invalidateWorkoutProviders() {
    _manualSlotOrder = null;
    for (final cycle in ref.read(currentTrainingCyclesProvider)) {
      ref.invalidate(workoutsByTrainingCycleListProvider(cycle.id));
      ref.invalidate(workoutsByTrainingCycleProvider(cycle.id));
      // v6 chunk A4 — the Workout tab now also watches the Session
      // provider to pull in cardio sessions for the day. Invalidating
      // here keeps the cardio cards in step with every strength write.
      ref.invalidate(sessionsByTrainingCycleProvider(cycle.id));
    }
  }

  /// Runs a workout write, surfacing failures as an error snackbar instead
  /// of silently losing the edit (mirrors the note-save error pattern).
  Future<void> _guardWrite(Future<void> Function() write) async {
    try {
      await write();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      context.showErrorSnackBar(l10n.workoutActionError(e));
    }
  }

  /// Hint shown when the Log checkbox is tapped while weight/reps missing.
  void _showLogHint() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.exerciseCardLogHintMissingFields),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  /// Applies the "Try X" suggested weight to every unlogged set that has
  /// no weight yet, marking them as unconfirmed suggestions.
  Future<void> _applySuggestedWeight(String workoutId, String exerciseId, double weightLbs) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;
    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex == -1) return;
    final exercise = workout.exercises[exerciseIndex];

    final filledIds = <String>{};
    final updatedSets = exercise.sets.map((s) {
      if (s.isLogged || s.weight != null) return s;
      filledIds.add(s.id);
      return s.copyWith(weight: weightLbs);
    }).toList();
    if (filledIds.isEmpty) return;

    await repository.update(
      workout.updateExercise(exerciseIndex, exercise.copyWith(sets: updatedSets)),
    );
    if (!mounted) return;
    // The weight field only re-reads its initialValue when the revision bump
    // changes its key, and that rebuild happens while the invalidated stream
    // providers are still serving the cached pre-write workout — so without a
    // local override the recreated field would show the stale empty weight.
    // Seed _localWeights (the same override typing uses) so the merged
    // exercise already carries the suggestion on that rebuild.
    setState(() {
      for (final id in filledIds) {
        _localWeights[id] = weightLbs;
      }
    });
    ref.read(autoSuggestedSetIdsProvider.notifier).addAll(filledIds);
    ref.read(suggestionRevisionProvider.notifier).bump();
    _invalidateWorkoutProviders();
  }

  /// Direct single-row update for set weight — avoids full workout
  /// tree reconstruction (O(1) instead of O(1+N+M) queries).
  /// Debounced to coalesce rapid keystrokes into a single DB write.
  /// Local state tracks edits so the Log button updates without
  /// invalidating the full workout provider tree.
  void _updateSetWeight(String setId, String value) {
    final weight = double.tryParse(value);
    if (weight == null && value.isNotEmpty) return;

    final wasLoggable = _isSetLoggable(setId);
    _localWeights[setId] = weight;
    // A manual edit confirms (unmarks) an auto-suggested weight.
    ref.read(autoSuggestedSetIdsProvider.notifier).confirm(setId);
    if (wasLoggable != _isSetLoggable(setId)) setState(() {});

    final key = 'weight_$setId';
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      await ref
          .read(exerciseSetDaoProvider)
          .updateByUuid(
            setId,
            ExerciseSetsCompanion(weight: Value(weight)),
          );
    });
  }

  /// Direct single-row update for set reps (debounced).
  void _updateSetReps(String setId, String value) {
    final wasLoggable = _isSetLoggable(setId);
    _localReps[setId] = value;
    if (wasLoggable != _isSetLoggable(setId)) setState(() {});

    final key = 'reps_$setId';
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      await ref
          .read(exerciseSetDaoProvider)
          .updateByUuid(
            setId,
            ExerciseSetsCompanion(reps: Value(value)),
          );
    });
  }

  /// Check if a set is loggable using local overrides + original data.
  bool _isSetLoggable(String setId) {
    final original = _findOriginalSet(setId);
    final weight = _localWeights.containsKey(setId) ? _localWeights[setId] : original?.weight;
    final reps = _localReps.containsKey(setId) ? _localReps[setId]! : (original?.reps ?? '');
    return weight != null && reps.isNotEmpty;
  }

  /// Look up the original set data from cached workouts.
  ExerciseSet? _findOriginalSet(String setId) {
    for (final workouts in _cachedWorkoutsPerCycle.values) {
      for (final workout in workouts) {
        for (final exercise in workout.exercises) {
          for (final set in exercise.sets) {
            if (set.id == setId) return set;
          }
        }
      }
    }
    return null;
  }

  /// Apply local weight/reps overrides to an exercise's sets.
  Exercise _applyLocalEdits(Exercise exercise) {
    if (_localWeights.isEmpty && _localReps.isEmpty) return exercise;

    bool anyChanged = false;
    final updatedSets = exercise.sets.map((set) {
      final hasWeight = _localWeights.containsKey(set.id);
      final hasReps = _localReps.containsKey(set.id);
      if (!hasWeight && !hasReps) return set;
      anyChanged = true;
      return ExerciseSet(
        id: set.id,
        setNumber: set.setNumber,
        weight: hasWeight ? _localWeights[set.id] : set.weight,
        reps: hasReps ? _localReps[set.id]! : set.reps,
        setType: set.setType,
        isLogged: set.isLogged,
        notes: set.notes,
        isSkipped: set.isSkipped,
      );
    }).toList();

    return anyChanged ? exercise.copyWith(sets: updatedSets) : exercise;
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
    final set = exercise.sets[setIndex];
    if (set.weight == null || set.reps.isEmpty) return;

    final nowLogging = !set.isLogged;
    if (nowLogging) {
      // Logging confirms an auto-suggested weight.
      ref.read(autoSuggestedSetIdsProvider.notifier).confirm(set.id);
    }
    final updatedSet = set.copyWith(isLogged: nowLogging);
    var updatedExercise = exercise.updateSet(setIndex, updatedSet);

    // Myorep Match: propagate weight/reps to the next set if it's myorepMatch
    if (nowLogging) {
      final nextIndex = setIndex + 1;
      if (nextIndex < updatedExercise.sets.length && updatedExercise.sets[nextIndex].setType == SetType.myorepMatch) {
        final nextSet = updatedExercise.sets[nextIndex].copyWith(
          weight: set.weight,
          reps: set.reps,
        );
        updatedExercise = updatedExercise.updateSet(nextIndex, nextSet);
      }
    }

    var updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    // Auto-record start time on the first logged set
    if (nowLogging && updatedWorkout.startTime == null) {
      updatedWorkout = updatedWorkout.copyWith(startTime: DateTime.now());
    }

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();

    // Start rest timer when a set is logged
    if (nowLogging && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ref
          .read(restTimerProvider.notifier)
          .start(
            set.setType,
            exerciseRestSeconds: exercise.restSeconds,
            exerciseId: exercise.id,
            workoutId: exercise.workoutId,
            notificationTitle: l10n.restTimerNotificationTitle,
            notificationBody: l10n.restTimerNotificationBody,
            liveInfo: _buildLiveSetInfo(l10n, updatedExercise),
          );
    }
  }

  /// Builds the lock-screen live card content for the rest after a logged
  /// set: localized exercise name plus the upcoming set's target. Strings are
  /// resolved here because the notification layers (including the background
  /// action isolate) have no BuildContext to localize with.
  LiveSetInfo _buildLiveSetInfo(AppLocalizations l10n, Exercise exercise) {
    ExerciseSet? next;
    for (final s in exercise.sets) {
      if (!s.isLogged && !s.isSkipped) {
        next = s;
        break;
      }
    }
    final String body;
    if (next == null) {
      body = l10n.restLiveAllSetsDone;
    } else if (next.weight != null && next.reps.isNotEmpty) {
      final weight = formatWeightForDisplay(next.weight, ref.read(useMetricProvider));
      final unit = ref.read(weightUnitProvider);
      body = l10n.restLiveNextSetTarget(next.setNumber, exercise.sets.length, '$weight $unit × ${next.reps}');
    } else {
      body = l10n.restLiveNextSet(next.setNumber, exercise.sets.length);
    }
    return LiveSetInfo(
      title: context.localizedExerciseName(exercise.name),
      body: body,
      addLabel: l10n.restLiveActionAdd,
      subtractLabel: l10n.restLiveActionSubtract,
      skipLabel: l10n.restLiveActionSkip,
    );
  }

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

    // Create new set
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
      reps: '',
      setType: SetType.regular,
    );
    if (prevWeight != null) {
      ref.read(autoSuggestedSetIdsProvider.notifier).addAll([newSet.id]);
    }

    // Insert set after current index
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets.insert(insertIndex, newSet);

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
    _invalidateWorkoutProviders();
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
    _invalidateWorkoutProviders();
  }

  /// Delete a set — optimistic with a 6s Undo snackbar.
  ///
  /// This is the UX pattern Gmail / Material use for destructive actions:
  /// we commit the delete immediately so the user sees the effect, but
  /// show an Undo chip that restores the original set if tapped in time.
  /// A confirmation dialog would be safer but more annoying, especially
  /// in the middle of a workout.
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

    // Snapshot the set we're removing so Undo can put it back.
    final removedSet = exercise.sets[setIndex];

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
    _invalidateWorkoutProviders();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.workoutSetDeleted(removedSet.setNumber)),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => _restoreSet(workoutId, exerciseId, setIndex, removedSet),
          ),
        ),
      );
  }

  /// Undo helper for [_deleteSet]. Re-inserts [removedSet] at the
  /// original [originalIndex] and renumbers the following sets.
  Future<void> _restoreSet(
    String workoutId,
    String exerciseId,
    int originalIndex,
    ExerciseSet removedSet,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    final restored = List<ExerciseSet>.from(exercise.sets)
      ..insert(originalIndex.clamp(0, exercise.sets.length), removedSet);

    for (var i = 0; i < restored.length; i++) {
      restored[i] = restored[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = exercise.copyWith(sets: restored);
    await repository.update(
      workout.updateExercise(exerciseIndex, updatedExercise),
    );
    _invalidateWorkoutProviders();
  }

  Future<void> _updateSetType(
    String workoutId,
    String exerciseId,
    int setIndex,
    SetType type,
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

    // Myorep Match: prefill weight/reps from the preceding set
    final ExerciseSet updatedSet;
    if (type == SetType.myorepMatch && setIndex > 0) {
      final prevSet = exercise.sets[setIndex - 1];
      updatedSet = exercise.sets[setIndex].copyWith(
        setType: type,
        weight: prevSet.weight,
        reps: prevSet.reps.isNotEmpty ? prevSet.reps : null,
      );
    } else {
      updatedSet = exercise.sets[setIndex].copyWith(setType: type);
    }
    final updatedSets = List<ExerciseSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
  }

  Future<void> _addNote(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null || !mounted) return;

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
      final updatedExercises = workout.exercises.map((e) => e.id == exerciseId ? updatedExercise : e).toList();
      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      await repository.update(updatedWorkout);
      _invalidateWorkoutProviders();
    }
  }

  /// Get all exercises for the current day across all workouts (muscle groups)
  List<Exercise> _getAllExercisesForCurrentDay() {
    final trainingCycle = ref.read(currentTrainingCycleProvider);
    if (trainingCycle == null) return [];

    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );

    final selectedDate = ref.read(selectedWorkoutDateProvider);
    final slot =
        selectedPeriodDay(trainingCycle, allWorkouts, selectedDate) ?? currentPeriodDay(trainingCycle, allWorkouts);
    final displayPeriod = slot?.period ?? 1;
    final displayDay = slot?.day ?? 1;

    // Get workouts for current day
    final dayWorkouts = allWorkouts
        .where(
          (w) => w.periodNumber == displayPeriod && w.dayNumber == displayDay,
        )
        .toList();

    // Collect all exercises from all workouts for today
    final allExercises = <Exercise>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }
    return allExercises;
  }

  Future<void> _moveExerciseUp(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise up called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForCurrentDay();
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex == -1) {
      debugPrint('Exercise not found in day exercises');
      return;
    }

    if (currentIndex <= 0) {
      debugPrint('Exercise is already at the top');
      return;
    }

    final currentExercise = allExercises[currentIndex];
    final aboveExercise = allExercises[currentIndex - 1];

    debugPrint('Moving exercise "${currentExercise.name}" up');
    debugPrint('Swapping with "${aboveExercise.name}"');

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == aboveExercise.workoutId) {
      final workout = await repository.getById(currentExercise.workoutId);
      if (workout == null) return;

      final exercises = List<Exercise>.from(workout.exercises);
      final idx = exercises.indexWhere((e) => e.id == exerciseId);
      if (idx <= 0) return;

      final exercise = exercises.removeAt(idx);
      exercises.insert(idx - 1, exercise);

      for (var i = 0; i < exercises.length; i++) {
        exercises[i] = exercises[i].copyWith(orderIndex: i);
      }

      await repository.update(workout.copyWith(exercises: exercises));
    } else {
      // Exercises are in different workouts - need to swap between workouts
      final currentWorkout = await repository.getById(
        currentExercise.workoutId,
      );
      final aboveWorkout = await repository.getById(aboveExercise.workoutId);
      if (currentWorkout == null || aboveWorkout == null) return;

      // Remove current exercise from its workout
      var currentExercises = List<Exercise>.from(currentWorkout.exercises);
      currentExercises.removeWhere((e) => e.id == currentExercise.id);

      // Remove above exercise from its workout
      var aboveExercises = List<Exercise>.from(aboveWorkout.exercises);
      aboveExercises.removeWhere((e) => e.id == aboveExercise.id);

      // Add current exercise to above workout (with updated workoutId)
      final movedCurrentExercise = currentExercise.copyWith(
        workoutId: aboveWorkout.id,
      );
      aboveExercises.add(movedCurrentExercise);

      // Add above exercise to current workout (with updated workoutId)
      final movedAboveExercise = aboveExercise.copyWith(
        workoutId: currentWorkout.id,
      );
      currentExercises.add(movedAboveExercise);

      // Renumber exercises in both workouts
      for (var i = 0; i < currentExercises.length; i++) {
        currentExercises[i] = currentExercises[i].copyWith(orderIndex: i);
      }
      for (var i = 0; i < aboveExercises.length; i++) {
        aboveExercises[i] = aboveExercises[i].copyWith(orderIndex: i);
      }

      await repository.update(
        currentWorkout.copyWith(exercises: currentExercises),
      );
      await repository.update(aboveWorkout.copyWith(exercises: aboveExercises));
    }

    _invalidateWorkoutProviders();
    debugPrint('Exercise moved up successfully');
  }

  Future<void> _moveExerciseDown(String workoutId, String exerciseId) async {
    debugPrint(
      'Move exercise down called: workoutId=$workoutId, exerciseId=$exerciseId',
    );
    final repository = ref.read(workoutRepositoryProvider);

    // Get all exercises for the current day across all muscle groups
    final allExercises = _getAllExercisesForCurrentDay();
    final currentIndex = allExercises.indexWhere((e) => e.id == exerciseId);

    if (currentIndex == -1) {
      debugPrint('Exercise not found in day exercises');
      return;
    }

    if (currentIndex >= allExercises.length - 1) {
      debugPrint('Exercise is already at the bottom');
      return;
    }

    final currentExercise = allExercises[currentIndex];
    final belowExercise = allExercises[currentIndex + 1];

    debugPrint('Moving exercise "${currentExercise.name}" down');
    debugPrint('Swapping with "${belowExercise.name}"');

    // If both exercises are in the same workout, just swap within that workout
    if (currentExercise.workoutId == belowExercise.workoutId) {
      final workout = await repository.getById(currentExercise.workoutId);
      if (workout == null) return;

      final exercises = List<Exercise>.from(workout.exercises);
      final idx = exercises.indexWhere((e) => e.id == exerciseId);
      if (idx == -1 || idx >= exercises.length - 1) return;

      final exercise = exercises.removeAt(idx);
      exercises.insert(idx + 1, exercise);

      for (var i = 0; i < exercises.length; i++) {
        exercises[i] = exercises[i].copyWith(orderIndex: i);
      }

      await repository.update(workout.copyWith(exercises: exercises));
    } else {
      // Exercises are in different workouts - need to swap between workouts
      final currentWorkout = await repository.getById(
        currentExercise.workoutId,
      );
      final belowWorkout = await repository.getById(belowExercise.workoutId);
      if (currentWorkout == null || belowWorkout == null) return;

      // Remove current exercise from its workout
      var currentExercises = List<Exercise>.from(currentWorkout.exercises);
      currentExercises.removeWhere((e) => e.id == currentExercise.id);

      // Remove below exercise from its workout
      var belowExercises = List<Exercise>.from(belowWorkout.exercises);
      belowExercises.removeWhere((e) => e.id == belowExercise.id);

      // Add current exercise to below workout (with updated workoutId)
      final movedCurrentExercise = currentExercise.copyWith(
        workoutId: belowWorkout.id,
      );
      belowExercises.insert(0, movedCurrentExercise);

      // Add below exercise to current workout (with updated workoutId)
      final movedBelowExercise = belowExercise.copyWith(
        workoutId: currentWorkout.id,
      );
      currentExercises.add(movedBelowExercise);

      // Renumber exercises in both workouts
      for (var i = 0; i < currentExercises.length; i++) {
        currentExercises[i] = currentExercises[i].copyWith(orderIndex: i);
      }
      for (var i = 0; i < belowExercises.length; i++) {
        belowExercises[i] = belowExercises[i].copyWith(orderIndex: i);
      }

      await repository.update(
        currentWorkout.copyWith(exercises: currentExercises),
      );
      await repository.update(belowWorkout.copyWith(exercises: belowExercises));
    }

    _invalidateWorkoutProviders();
    debugPrint('Exercise moved down successfully');
  }

  Future<void> _replaceExercise(String workoutId, String exerciseId) async {
    // Get the workout and exercise from repository (not provider which may be stale)
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => throw Exception('Exercise not found'),
    );

    // Navigate to add exercise screen with replace mode
    // The AddExerciseScreen will handle the replacement when a new exercise is selected
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddExerciseScreen(
            trainingCycleId: workout.trainingCycleId,
            workoutId: workout.id,
            initialMuscleGroup: exercise.muscleGroup,
            replaceExerciseId: exerciseId,
          ),
        ),
      );
    }
  }

  Future<void> _logJointPain(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exercise = workout.exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => workout.exercises.first,
    );

    if (!mounted) return;

    final feedback = await ExerciseFeedbackDialog.show(
      context,
      exerciseName: exercise.name,
      existing: exercise.feedback,
    );

    if (feedback == null) return;

    final dao = ref.read(exerciseFeedbackDaoProvider);
    final companion = ExerciseFeedbackMapper.toCompanion(
      feedback,
      exerciseId,
    );
    await dao.upsertFeedback(companion);
    _invalidateWorkoutProviders();
  }

  Future<void> _setRestTimer(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final exerciseIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (exerciseIndex == -1) return;

    final exercise = workout.exercises[exerciseIndex];
    if (!mounted) return;

    final result = await RestTimerDialog.show(
      context,
      currentRestSeconds: exercise.restSeconds,
    );
    if (result == null) return;

    // -1 means "use default" (clear override)
    final newRestSeconds = result == -1 ? null : result;
    final updatedExercise = exercise.copyWith(restSeconds: newRestSeconds);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );
    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
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
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      weight: prevWeight,
      reps: '',
      setType: SetType.regular,
    );
    if (prevWeight != null) {
      ref.read(autoSuggestedSetIdsProvider.notifier).addAll([newSet.id]);
    }

    final updatedSets = List<ExerciseSet>.from(exercise.sets)..add(newSet);
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
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
    final updatedSets = (exercise.sets).map((s) => !s.isLogged ? s.copyWith(isSkipped: true) : s).toList();

    final updatedExercise = exercise.copyWith(sets: updatedSets);
    final updatedWorkout = workout.updateExercise(
      exerciseIndex,
      updatedExercise,
    );

    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();
  }

  /// Delete an exercise — optimistic with a 6s Undo snackbar.
  ///
  /// Mirrors [_deleteSet]'s pattern. Exercises with any logged sets are
  /// already guarded upstream in [ExerciseCardWidget]'s popup menu (the
  /// Delete item is disabled), so the undo path here only has to worry
  /// about not-yet-logged exercises — which is exactly the case where
  /// a mistyped tap is the likely cause.
  Future<void> _deleteExercise(String workoutId, String exerciseId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final originalIndex = workout.exercises.indexWhere(
      (e) => e.id == exerciseId,
    );
    if (originalIndex == -1) return;

    // Snapshot so Undo can put it back exactly where it was.
    final removedExercise = workout.exercises[originalIndex];

    final updatedExercises = List<Exercise>.from(workout.exercises)..removeAt(originalIndex);

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    await repository.update(updatedWorkout);
    _invalidateWorkoutProviders();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.workoutExerciseDeleted(
              context.localizedExerciseName(removedExercise.name),
            ),
          ),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => _restoreExercise(
              workoutId,
              originalIndex,
              removedExercise,
            ),
          ),
        ),
      );
  }

  /// Undo helper for [_deleteExercise]. Re-inserts [removedExercise] at
  /// its original [originalIndex] (clamped so a since-shortened exercise
  /// list still takes it).
  Future<void> _restoreExercise(
    String workoutId,
    int originalIndex,
    Exercise removedExercise,
  ) async {
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(workoutId);
    if (workout == null) return;

    final restored = List<Exercise>.from(workout.exercises)
      ..insert(originalIndex.clamp(0, workout.exercises.length), removedExercise);

    await repository.update(workout.copyWith(exercises: restored));
    _invalidateWorkoutProviders();
  }

  // ---------------------------------------------------------------------------
  // Cardio session actions
  // ---------------------------------------------------------------------------

  /// Open the note dialog for a cardio session. Uses the lightweight
  /// [SessionRepository.updateSession] path so intervals/detail are
  /// not re-written.
  Future<void> _addCardioNote(String sessionId) async {
    final repo = ref.read(sessionRepositoryProvider);
    final session = await repo.getById(sessionId);
    if (session == null || session is! CardioSession) return;

    if (!mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: session.notes,
        noteType: NoteType.cardioSession,
      ),
    );

    if (result != null) {
      final updated = session.copyWith(
        notes: result.isEmpty ? null : result,
      );
      await repo.updateSession(updated);
      _invalidateWorkoutProviders();
    }
  }

  /// Delete the current cardio session and navigate to the new-session
  /// screen with the same sport/period/day so the user can create a
  /// replacement.
  Future<void> _replaceCardioSession(CardioSession session) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.delete(session.id);
    _invalidateWorkoutProviders();

    if (!mounted) return;
    final params = <String, String>{
      'sport': session.sport.name,
    };
    if (session.trainingCycleId != null) {
      params['trainingCycleId'] = session.trainingCycleId!;
    }
    if (session.periodNumber != null) {
      params['period'] = session.periodNumber.toString();
    }
    if (session.dayNumber != null) {
      params['day'] = session.dayNumber.toString();
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    context.push('/cardio-session/new?$query');
  }

  /// Mark a cardio session as skipped.
  Future<void> _skipCardioSession(String sessionId) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.markAsSkipped(sessionId);
    _invalidateWorkoutProviders();
  }

  /// Delete a cardio session with a 6-second undo snackbar.
  Future<void> _deleteCardioSession(String sessionId) async {
    final repo = ref.read(sessionRepositoryProvider);
    final session = await repo.getById(sessionId);
    if (session == null || session is! CardioSession) return;

    await repo.delete(sessionId);
    _invalidateWorkoutProviders();

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final label = session.label?.trim().isNotEmpty == true ? session.label! : session.sport.localizedName(l10n);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.workoutCardioSessionDeleted(label)),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => _restoreCardioSession(session),
          ),
        ),
      );
  }

  /// Undo helper for [_deleteCardioSession].
  Future<void> _restoreCardioSession(CardioSession session) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.createCardio(session);
    _invalidateWorkoutProviders();
  }

  /// Move a slot (strength block or cardio card) up in the day's
  /// render order. Operates on the ephemeral [_manualSlotOrder].
  void _moveSlotUp(String slotId) {
    final order = _manualSlotOrder;
    if (order == null) return;
    final idx = order.indexOf(slotId);
    if (idx <= 0) return;
    setState(() {
      final updated = List<String>.from(order);
      final tmp = updated[idx - 1];
      updated[idx - 1] = updated[idx];
      updated[idx] = tmp;
      _manualSlotOrder = updated;
    });
  }

  /// Move a slot (strength block or cardio card) down in the day's
  /// render order. Operates on the ephemeral [_manualSlotOrder].
  void _moveSlotDown(String slotId) {
    final order = _manualSlotOrder;
    if (order == null) return;
    final idx = order.indexOf(slotId);
    if (idx < 0 || idx >= order.length - 1) return;
    setState(() {
      final updated = List<String>.from(order);
      final tmp = updated[idx + 1];
      updated[idx + 1] = updated[idx];
      updated[idx] = tmp;
      _manualSlotOrder = updated;
    });
  }

  /// Initialise [_manualSlotOrder] from the current render order if it
  /// hasn't been set yet. Called lazily before the first move operation.
  void _ensureManualSlotOrder(List<_RenderSlot> renderOrder) {
    _manualSlotOrder ??= renderOrder.map((s) => s.slotId).toList();
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

  Future<void> _finishWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final repository = ref.read(workoutRepositoryProvider);
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final trainingCycle = ref.read(currentTrainingCycleProvider);

    if (trainingCycle == null) return;

    // Mark ALL workouts for this day as completed
    final now = DateTime.now();
    final exerciseRepository = ref.read(exerciseRepositoryProvider);
    for (final workout in workouts) {
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
      await repository.update(updatedWorkout);

      // Also update individual exercise records in the database
      for (final exercise in updatedExercises) {
        if (exercise.sets.any((s) => s.isLogged)) {
          await exerciseRepository.update(exercise);
        }
      }
    }

    // Check if ALL workouts in the trainingCycle are now completed
    // We need to verify that every period/day combination has at least one completed workout
    final allWorkouts = await repository.getByTrainingCycleId(trainingCycle.id);

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
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.workoutCycleCompletedTitle(cycleTerm)),
            content: Text(
              l10n.workoutCycleCompletedContent(cycleTerm),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  context.go('/'); // Go back to list screen
                },
                child: Text(l10n.workoutCycleCompletedAction),
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

  /// Compute the displayed (period, day) for a stacked cycle, following the
  /// shared selected date (falling back to that cycle's today slot when the
  /// selected date falls outside the cycle).
  (int, int) _displayDayForCycle(TrainingCycle cycle) {
    final workouts = _cachedWorkoutsPerCycle[cycle.id] ?? const <Workout>[];
    final selectedDate = ref.read(selectedWorkoutDateProvider);
    final slot = selectedPeriodDay(cycle, workouts, selectedDate) ?? currentPeriodDay(cycle, workouts);
    return slot != null ? (slot.period, slot.day) : (1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentCycles = ref.watch(currentTrainingCyclesProvider);
    final currentTrainingCycle = currentCycles.isEmpty ? null : currentCycles.first;

    // If there's a current trainingCycle, show today's workout
    if (currentTrainingCycle != null && currentTrainingCycle.startDate != null) {
      // Clear cache when the set of active cycles changes.
      final cycleIds = currentCycles.map((c) => c.id).toSet();
      if (_cachedCycleIds.length != cycleIds.length || !_cachedCycleIds.containsAll(cycleIds)) {
        _cachedCycleIds = cycleIds;
        _cachedWorkoutsPerCycle.clear();
        _localWeights.clear();
        _localReps.clear();
      }

      // Get workouts from the workout repository for ALL current cycles.
      // Use cached data during provider refresh to keep the UI stable
      // (prevents text field focus loss when providers are invalidated
      // after debounced saves).
      for (final cycle in currentCycles) {
        final cycleWorkoutsAsync = ref.watch(
          workoutsByTrainingCycleProvider(cycle.id),
        );
        if (cycleWorkoutsAsync.hasValue) {
          final newWorkouts = cycleWorkoutsAsync.value;
          if (!identical(newWorkouts, _cachedWorkoutsPerCycle[cycle.id])) {
            _cachedWorkoutsPerCycle[cycle.id] = newWorkouts ?? [];
            _localWeights.clear();
            _localReps.clear();
          }
        }
      }

      // Primary cycle drives period/day selection and AppBar.
      final allWorkouts = _cachedWorkoutsPerCycle[currentTrainingCycle.id] ?? [];
      if (allWorkouts.isEmpty && !_cachedWorkoutsPerCycle.containsKey(currentTrainingCycle.id)) {
        // First load — data still in flight. Show a loading state, NOT the
        // empty state, so users don't see a "no workouts" flash.
        return _buildLoadingState(context);
      }

      // Canonical "today" slot for the primary cycle (date-based, shared with
      // the Calendar screen). Null means the cycle hasn't started or has ended.
      final current = currentPeriodDay(currentTrainingCycle, allWorkouts);

      if (current == null) {
        // TrainingCycle hasn't started yet or has ended
        final l10n = AppLocalizations.of(context)!;
        return _buildEmptyState(
          context,
          l10n.workoutCycleNotActiveTitle,
          l10n.workoutCycleNotActiveMessage,
        );
      }

      final currentPeriod = current.period;
      final currentDay = current.day;

      // The displayed day follows the shared selected date; fall back to today
      // when the selected date is outside this cycle.
      final selectedDate = ref.watch(selectedWorkoutDateProvider);
      final selected = selectedPeriodDay(currentTrainingCycle, allWorkouts, selectedDate) ?? current;
      final displayPeriod = selected.period;
      final displayDay = selected.day;

      debugPrint('Display period: $displayPeriod, Display day: $displayDay');

      // Get workouts for the currently displayed day (for AppBar/FINISH)
      // from the PRIMARY cycle.
      final todaysWorkouts = allWorkouts
          .where(
            (w) => w.periodNumber == displayPeriod && w.dayNumber == displayDay,
          )
          .toList();

      // Collect workouts from SECONDARY stacked cycles for their own
      // independently computed (period, day).
      final secondaryCycleWorkouts = <TrainingCycle, List<Workout>>{};
      final secondaryCycleCardio = <TrainingCycle, List<CardioSession>>{};
      for (final cycle in currentCycles.skip(1)) {
        final (secPeriod, secDay) = _displayDayForCycle(cycle);
        final secWorkouts = (_cachedWorkoutsPerCycle[cycle.id] ?? <Workout>[])
            .where(
              (w) => w.periodNumber == secPeriod && w.dayNumber == secDay,
            )
            .toList();
        secondaryCycleWorkouts[cycle] = secWorkouts;

        final secSessionsAsync = ref.watch(
          sessionsByTrainingCycleProvider(cycle.id),
        );
        final secSessions = secSessionsAsync.value ?? const <Session>[];
        secondaryCycleCardio[cycle] = secSessions
            .whereType<CardioSession>()
            .where(
              (s) => s.periodNumber == secPeriod && s.dayNumber == secDay,
            )
            .toList();
      }

      // Cardio sessions attached to the primary cycle, for the displayed day.
      final cycleSessionsAsync = ref.watch(
        sessionsByTrainingCycleProvider(currentTrainingCycle.id),
      );
      final cycleSessions = cycleSessionsAsync.value ?? const <Session>[];
      final cycleCardioForDay = cycleSessions
          .whereType<CardioSession>()
          .where(
            (s) => s.periodNumber == displayPeriod && s.dayNumber == displayDay,
          )
          .toList();

      // Ad-hoc imports (HealthKit / Strava / Peloton) that landed today
      // with no cycle attached. Included only when the user is viewing
      // today's cycle day so imports show up in the right place without
      // leaking onto other days' views.
      final now = DateTime.now();
      final daysSinceStart = currentTrainingCycle.startDate == null
          ? null
          : now.difference(currentTrainingCycle.startDate!).inDays;
      final todayPeriod = daysSinceStart == null ? null : (daysSinceStart ~/ currentTrainingCycle.daysPerPeriod) + 1;
      final todayDay = daysSinceStart == null ? null : (daysSinceStart % currentTrainingCycle.daysPerPeriod) + 1;
      final isViewingToday = todayPeriod == displayPeriod && todayDay == displayDay;

      final todaysSessionsAsync = ref.watch(todaysSessionsProvider);
      final adHocImportsToday = !isViewingToday
          ? const <CardioSession>[]
          : (todaysSessionsAsync.value ?? const <Session>[])
                .whereType<CardioSession>()
                .where((s) => s.trainingCycleId == null)
                .toList();

      final dayCardioSessions = [
        ...cycleCardioForDay,
        ...adHocImportsToday,
      ];

      // Aggregate ALL strength workouts across all stacked cycles for
      // the FINISH WORKOUT check.
      final allDayWorkouts = [
        ...todaysWorkouts,
        ...secondaryCycleWorkouts.values.expand((w) => w),
      ];

      // Whether to show the "FINISH WORKOUT" button: all strength workouts
      // across all stacked cycles are fully logged.
      final showFinishButton =
          allDayWorkouts.isNotEmpty &&
          !allDayWorkouts.every((w) => w.isCompleted) &&
          allDayWorkouts.every((w) => _isWorkoutComplete(w));

      // The user's chosen sports drive which boxes appear in the
      // SportGrid. Watching here means edits made in Settings rebuild
      // the Workout tab automatically.
      final selectedSports = ref.watch(selectedSportsProvider);

      // Compute day name for AppBar (primary cycle)
      final dayName = calculateDayName(
        workouts: todaysWorkouts,
        startDate: currentTrainingCycle.startDate,
        daysPerPeriod: currentTrainingCycle.daysPerPeriod,
        displayPeriod: displayPeriod,
        displayDay: displayDay,
        allCycleWorkouts: allWorkouts,
        periodsTotal: currentTrainingCycle.periodsTotal,
      );

      // Determine if all stacked cycles have any content today.
      final allDayCardio = [
        ...dayCardioSessions,
        ...secondaryCycleCardio.values.expand((c) => c),
      ];
      final hasAnySessions = allDayWorkouts.isNotEmpty || allDayCardio.isNotEmpty;

      final l10n = AppLocalizations.of(context)!;

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          floatingActionButton: !hasAnySessions
              ? null
              : FloatingActionButton(
                  heroTag: 'workoutAddSessionFab',
                  onPressed: () => _showAddSessionDialog(
                    cycleId: currentTrainingCycle.id,
                    period: displayPeriod,
                    day: displayDay,
                    workouts: todaysWorkouts,
                    sports: selectedSports,
                  ),
                  tooltip: l10n.workoutAddSessionTooltip,
                  child: const Icon(Icons.add),
                ),
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: Semantics(
              label: l10n.workoutAppLogoLabel,
              child: const AppIconWidget(),
            ),
            leadingWidth: kToolbarHeight + 12,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTrainingCycle.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.workoutPeriodDayTitle(displayPeriod, displayDay, dayName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              // v6 — quick-log cardio moved out of the AppBar into the
              // pinned SportGrid footer. See Section A/B of
              // DESIGN_OPPORTUNITIES.md.
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _togglePeriodSelector,
                tooltip: l10n.workoutSelectDayTooltip,
              ),
              IconButton(
                icon: Icon(
                  ref.watch(isDarkModeProvider) ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                tooltip: l10n.toggleThemeTooltip,
              ),
              if (todaysWorkouts.isNotEmpty)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.more_vert),
                    tooltip: l10n.workoutMenuWorkoutHeader,
                    onPressed: () => _showWorkoutMenu(
                      context,
                      currentTrainingCycle,
                      todaysWorkouts,
                      displayPeriod,
                      displayDay,
                      selectedSports,
                    ),
                  ),
                ),
            ],
          ),
          body: ScreenBackground.workout(
            child: Stack(
              children: [
                // Session-present mode: unified vertical scroll of session
                // cards + FINISH WORKOUT button. A FAB opens the
                // add-session dialog (sport picker + muscle groups).
                //
                // Empty-day mode: when the day has zero sessions, the
                // full-screen expanded SportGrid IS the body — no
                // FAB, no separate empty illustration.
                Positioned.fill(
                  child: !hasAnySessions
                      ? _buildEmptyDayBody(
                          cycleId: currentTrainingCycle.id,
                          period: displayPeriod,
                          day: displayDay,
                          sports: selectedSports,
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: _buildStackedSessionScroll(
                                context: context,
                                primaryCycle: currentTrainingCycle,
                                primaryPeriod: displayPeriod,
                                primaryDay: displayDay,
                                primaryWorkouts: todaysWorkouts,
                                primaryCardio: dayCardioSessions,
                                secondaryCycleWorkouts: secondaryCycleWorkouts,
                                secondaryCycleCardio: secondaryCycleCardio,
                                sports: selectedSports,
                                showHeaders: currentCycles.length > 1,
                              ),
                            ),
                            if (showFinishButton) _buildFinishWorkoutBar(allDayWorkouts),
                          ],
                        ),
                ),

                // Calendar dropdown overlay — stays in the Stack so it
                // can render above the Column's pinned footer.
                if (_homeState.showPeriodSelector) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _controller.hidePeriodSelector(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CalendarDropdown(
                      trainingCycle: currentTrainingCycle,
                      currentPeriod: currentPeriod,
                      currentDay: currentDay,
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

    // If no current trainingCycle, show empty state
    final l10n = AppLocalizations.of(context)!;
    return _buildEmptyState(
      context,
      l10n.workoutNoActiveCycleTitle,
      l10n.workoutNoActiveCycleMessage,
    );
  }

  // ---------------------------------------------------------------------------
  // v6 chunk A4 — new body structure
  // ---------------------------------------------------------------------------

  /// Builds the scrollable session list with optional cycle section headers.
  ///
  /// When [showHeaders] is false (single active cycle), delegates directly
  /// to [_buildSessionScroll] for the primary cycle — no visual change from
  /// the pre-stacking behaviour.
  ///
  /// When [showHeaders] is true (multiple stacked cycles), renders each
  /// cycle's sessions under a labelled section header showing the cycle
  /// name and its independently-computed period/day. All cycles' slivers
  /// are combined into a single [CustomScrollView] to avoid nested scrolls.
  Widget _buildStackedSessionScroll({
    required BuildContext context,
    required TrainingCycle primaryCycle,
    required int primaryPeriod,
    required int primaryDay,
    required List<Workout> primaryWorkouts,
    required List<CardioSession> primaryCardio,
    required Map<TrainingCycle, List<Workout>> secondaryCycleWorkouts,
    required Map<TrainingCycle, List<CardioSession>> secondaryCycleCardio,
    required List<Sport> sports,
    required bool showHeaders,
  }) {
    if (!showHeaders) {
      // Single cycle — delegate directly (preserves existing UX).
      return _buildSessionScroll(
        context: context,
        trainingCycle: primaryCycle,
        displayPeriod: primaryPeriod,
        displayDay: primaryDay,
        dayStrengthWorkouts: primaryWorkouts,
        dayCardioSessions: primaryCardio,
        sports: sports,
      );
    }

    // Multiple stacked cycles — build a combined CustomScrollView with
    // section headers separating each cycle's sessions. We use
    // _buildSessionSlivers to extract raw slivers (no nested scrollview).
    final slivers = <Widget>[
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];

    // --- Primary cycle section ---
    if (primaryWorkouts.isNotEmpty || primaryCardio.isNotEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: _CycleSectionHeader(
            cycleName: primaryCycle.name,
            period: primaryPeriod,
            day: primaryDay,
          ),
        ),
      );
      slivers.addAll(
        _buildSessionSlivers(
          context: context,
          trainingCycle: primaryCycle,
          displayPeriod: primaryPeriod,
          displayDay: primaryDay,
          dayStrengthWorkouts: primaryWorkouts,
          dayCardioSessions: primaryCardio,
          sports: sports,
        ),
      );
    }

    // --- Secondary cycle sections ---
    for (final entry in secondaryCycleWorkouts.entries) {
      final cycle = entry.key;
      final workouts = entry.value;
      final cardio = secondaryCycleCardio[cycle] ?? [];
      if (workouts.isEmpty && cardio.isEmpty) continue;

      final (secPeriod, secDay) = _displayDayForCycle(cycle);
      slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
      slivers.add(
        SliverToBoxAdapter(
          child: _CycleSectionHeader(
            cycleName: cycle.name,
            period: secPeriod,
            day: secDay,
          ),
        ),
      );
      slivers.addAll(
        _buildSessionSlivers(
          context: context,
          trainingCycle: cycle,
          displayPeriod: secPeriod,
          displayDay: secDay,
          dayStrengthWorkouts: workouts,
          dayCardioSessions: cardio,
          sports: sports,
        ),
      );
    }

    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 88)));

    // Scrolling intentionally does NOT dismiss the keyboard — yanking it
    // away mid-entry was a top in-gym annoyance. Tapping outside a field
    // (the screen-level GestureDetector) still dismisses it.
    return CustomScrollView(slivers: slivers);
  }

  /// Build the scrollable portion of the Workout tab — strength exercises
  /// and cardio sessions as siblings in a single vertical scroll.
  ///
  /// Empty-day mode: returns the expanded [SportGrid] filling the space
  /// so the 2×2 grid IS the empty state (no separate illustration).
  Widget _buildSessionScroll({
    required BuildContext context,
    required dynamic trainingCycle,
    required int displayPeriod,
    required int displayDay,
    required List<Workout> dayStrengthWorkouts,
    required List<CardioSession> dayCardioSessions,
    required List<Sport> sports,
  }) {
    final slivers = _buildSessionSlivers(
      context: context,
      trainingCycle: trainingCycle,
      displayPeriod: displayPeriod,
      displayDay: displayDay,
      dayStrengthWorkouts: dayStrengthWorkouts,
      dayCardioSessions: dayCardioSessions,
      sports: sports,
    );

    // If slivers is empty, show empty day body.
    if (slivers.isEmpty) {
      return _buildEmptyDayBody(
        cycleId: trainingCycle.id as String,
        period: displayPeriod,
        day: displayDay,
        sports: sports,
      );
    }

    // Scrolling intentionally does NOT dismiss the keyboard — yanking it
    // away mid-entry was a top in-gym annoyance. Tapping outside a field
    // (the screen-level GestureDetector) still dismisses it.
    return CustomScrollView(slivers: slivers);
  }

  /// Returns the raw sliver list for a single cycle's day of sessions.
  /// Used by both [_buildSessionScroll] (single cycle) and
  /// [_buildStackedSessionScroll] (multi-cycle combined scroll).
  ///
  /// Returns an empty list if there are no renderable slots.
  List<Widget> _buildSessionSlivers({
    required BuildContext context,
    required dynamic trainingCycle,
    required int displayPeriod,
    required int displayDay,
    required List<Workout> dayStrengthWorkouts,
    required List<CardioSession> dayCardioSessions,
    required List<Sport> sports,
  }) {
    // Flatten strength exercises.
    final allExercises = <Exercise>[];
    for (final w in dayStrengthWorkouts) {
      allExercises.addAll(w.exercises);
    }

    // Classify strength block (as a single sort unit) by its aggregate
    // state — mirrors the bucket logic in sortByPerformedOrder.
    final hasStrength = allExercises.isNotEmpty;
    final strengthAllCompleted = hasStrength && dayStrengthWorkouts.every((w) => w.isCompleted);
    final strengthAnyInProgress =
        hasStrength &&
        !strengthAllCompleted &&
        dayStrengthWorkouts.any(
          (w) => w.exercises.any((e) => e.sets.any((s) => s.isLogged)),
        );
    final strengthBucket = strengthAllCompleted ? 0 : (strengthAnyInProgress ? 1 : 2);

    // Sort cardio sessions using the shared helper.
    final sortedCardio = sortByPerformedOrder(dayCardioSessions).cast<CardioSession>();

    // Merge into render items by bucket. Within each bucket the cardio
    // cards appear in performed order; strength (as a single block of
    // exercise cards) slots in between once, at its bucket's natural
    // sort position.
    var renderOrder = <_RenderSlot>[];
    bool strengthInserted = false;
    final strengthSlot = _RenderSlot.strengthBlock();

    for (final session in sortedCardio) {
      final bucket = session.isCompleted ? 0 : (session.startTime != null ? 1 : 2);
      if (hasStrength && !strengthInserted && strengthBucket <= bucket) {
        renderOrder.add(strengthSlot);
        strengthInserted = true;
      }
      renderOrder.add(_RenderSlot.cardio(session));
    }
    if (hasStrength && !strengthInserted) {
      renderOrder.add(strengthSlot);
    }

    // Apply manual slot order if the user has reordered via move up/down.
    if (_manualSlotOrder != null) {
      final byId = {for (final s in renderOrder) s.slotId: s};
      final validIds = _manualSlotOrder!.where(byId.containsKey).toList();
      final newIds = byId.keys.where((id) => !validIds.contains(id)).toList();
      validIds.addAll(newIds);
      renderOrder = validIds.map((id) => byId[id]!).toList();
    }

    // Return empty if nothing to render.
    if (renderOrder.isEmpty) return [];

    // Batch-fetch previous performance for all strength exercises in
    // this day. Stable key-by-name so the list identity is consistent.
    final batchKey = batchProviderKey(
      allExercises.map((e) => (id: e.id, name: e.name)).toList(),
    );
    final batchAsync = ref.watch(
      previousPerformanceBatchProvider(batchKey),
    );
    final batchMap = batchAsync.value ?? <String, Exercise?>{};
    final periodRir = calculateRIR(displayPeriod, trainingCycle.recoveryPeriod);
    final useMetric = ref.watch(useMetricProvider);
    final weightUnit = ref.watch(weightUnitProvider);

    // Build the sliver children list.
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: RestTimerWidget(
          onTap: (exerciseId, workoutId) => _setRestTimer(workoutId, exerciseId),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];

    for (var slotIndex = 0; slotIndex < renderOrder.length; slotIndex++) {
      final slot = renderOrder[slotIndex];
      final isLastSlot = slotIndex == renderOrder.length - 1;

      if (slot.isStrength) {
        // Strength block — render every exercise in order with the
        // existing muscle-group separator logic.
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = allExercises[index];
                final showMuscleGroupBadge = index == 0 || allExercises[index - 1].muscleGroup != exercise.muscleGroup;
                final mergedExercise = _applyLocalEdits(exercise);
                final card = RepaintBoundary(
                  child: ExerciseCardWidget(
                    key: ValueKey(
                      '${exercise.id}_${exercise.sets.length}'
                      '_${exercise.sets.map((s) => s.id).join(",")}',
                    ),
                    exercise: mergedExercise,
                    showMuscleGroupBadge: showMuscleGroupBadge,
                    targetRir: periodRir,
                    weightUnit: weightUnit,
                    useMetric: useMetric,
                    showMoveDown: true,
                    isFirstExercise: index == 0,
                    isLastExercise: index == allExercises.length - 1,
                    previousPerformance: batchMap[exercise.id],
                    callbacks: ExerciseCardCallbacks(
                      onAddNote: (id) => _addNote(exercise.workoutId, id),
                      onMoveUp: (id) => _moveExerciseUp(exercise.workoutId, id),
                      onMoveDown: (id) => _moveExerciseDown(exercise.workoutId, id),
                      onReplace: (id) => _replaceExercise(exercise.workoutId, id),
                      onJointPain: (id) => _logJointPain(exercise.workoutId, id),
                      onRestTimer: (id) => _setRestTimer(exercise.workoutId, id),
                      onAddSet: (id) => _guardWrite(() => _addSetToExercise(exercise.workoutId, id)),
                      onSkipSets: (id) => _skipExerciseSets(exercise.workoutId, id),
                      onDelete: (id) => _deleteExercise(exercise.workoutId, id),
                      onAddSetBelow: (i) => _guardWrite(
                        () => _addSetBelow(exercise.workoutId, exercise.id, i),
                      ),
                      onToggleSetSkip: (i) => _toggleSetSkip(
                        exercise.workoutId,
                        exercise.id,
                        i,
                      ),
                      onDeleteSet: (i) => _guardWrite(
                        () => _deleteSet(exercise.workoutId, exercise.id, i),
                      ),
                      onUpdateSetType: (i, type) => _guardWrite(
                        () => _updateSetType(exercise.workoutId, exercise.id, i, type),
                      ),
                      onUpdateSetWeight: (i, setId, v) => _updateSetWeight(setId, v),
                      onUpdateSetReps: (i, setId, v) => _updateSetReps(setId, v),
                      onToggleSetLog: (i) => _guardWrite(
                        () => _toggleSetLog(exercise.workoutId, exercise.id, i),
                      ),
                      onDisabledLogTap: (_) => _showLogHint(),
                      onApplySuggestedWeight: (id, weightLbs) => _guardWrite(
                        () => _applySuggestedWeight(exercise.workoutId, id, weightLbs),
                      ),
                    ),
                  ),
                );

                // Separator between consecutive exercises — preserves
                // the existing muscle-group logic (1px when same group,
                // 32px gap when different).
                if (index == allExercises.length - 1) return card;
                final nextMuscle = allExercises[index + 1].muscleGroup;
                final sameGroup = exercise.muscleGroup == nextMuscle;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    card,
                    if (sameGroup)
                      Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      )
                    else
                      const SizedBox(height: 32),
                  ],
                );
              },
              childCount: allExercises.length,
            ),
          ),
        );
      } else {
        // Cardio card.
        final session = slot.cardio!;
        slivers.add(
          SliverToBoxAdapter(
            child: CardioSessionCard(
              key: ValueKey('cardio_${session.id}'),
              session: session,
              isFirstInDayList: slotIndex == 0,
              isLastInDayList: isLastSlot,
              callbacks: CardioSessionCardCallbacks(
                onPrimary: (id) => context.push('/cardio-session/$id'),
                onAddFeedback: (id) => context.push('/cardio-session/$id'),
                onAddNote: (id) => _addCardioNote(id),
                onMoveUp: (id) {
                  _ensureManualSlotOrder(renderOrder);
                  _moveSlotUp(id);
                },
                onMoveDown: (id) {
                  _ensureManualSlotOrder(renderOrder);
                  _moveSlotDown(id);
                },
                onReplace: (id) => _replaceCardioSession(session),
                onSkip: (id) => _skipCardioSession(id),
                onDelete: (id) => _deleteCardioSession(id),
                onViewIntervals: (id) => context.push('/cardio-session/$id/intervals'),
              ),
            ),
          ),
        );
      }

      // Inter-slot spacer (except after the last slot).
      if (!isLastSlot) {
        slivers.add(
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        );
      }
    }

    // Extra bottom padding so the last LOG button isn't hidden behind
    // the floating action button (56 px FAB + 16 px margin + buffer).
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 88)));

    return slivers;
  }

  /// Build the empty-day body — the expanded SportGrid filling the
  /// available space so the grid itself IS the empty state. Per Section
  /// A of `DESIGN_OPPORTUNITIES.md`: no separate illustration; the grid
  /// communicates "tap to start something" on its own.
  ///
  /// [sports] is the user's onboarding/Settings selection — empty list
  /// means we'll fall back to all four (defensive — in practice the
  /// provider returns at least `[Sport.strength]`).
  Widget _buildEmptyDayBody({
    required String cycleId,
    required int period,
    required int day,
    required List<Sport> sports,
  }) {
    return SafeArea(
      top: false,
      child: Center(
        child: SportGrid(
          variant: SportGridVariant.expanded,
          sports: sports.isEmpty ? null : sports,
          callbacks: SportGridCallbacks(
            onLift: () => _onLiftPressed(cycleId, period, day),
            onRun: () => _onCardioPressed(Sport.run, cycleId, period, day),
            onBike: () => _onCardioPressed(Sport.bike, cycleId, period, day),
            onSwim: () => _onCardioPressed(Sport.swim, cycleId, period, day),
          ),
        ),
      ),
    );
  }

  /// Build the FINISH WORKOUT button that sits BELOW the SportGrid
  /// (per the locked-in design decision — the grid never lifts above
  /// the button). Visibility is driven upstream by [build]; this
  /// widget just produces the bar itself.
  Widget _buildFinishWorkoutBar(List<Workout> todaysWorkouts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Semantics(
          label: AppLocalizations.of(context)!.workoutFinishLabel,
          button: true,
          child: ElevatedButton(
            onPressed: () => _finishWorkout(todaysWorkouts),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.successColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.workoutFinishButton,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// SportGrid "Lift" tap handler.
  ///
  /// Auto-creates a `StrengthSession` for (cycleId, period, day) if one
  /// doesn't already exist, then pushes [AddExerciseScreen]. This keeps
  /// the tap path single-step even when the day is empty.
  Future<void> _onLiftPressed(
    String cycleId,
    int period,
    int day,
  ) async {
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final existing = await workoutRepo.getByTrainingCycleId(cycleId);
    final dayWorkouts = existing.where((w) => w.periodNumber == period && w.dayNumber == day).toList();

    String workoutId;
    if (dayWorkouts.isNotEmpty) {
      workoutId = dayWorkouts.first.id;
    } else {
      // Create an empty strength workout for the day so AddExerciseScreen
      // has a parent to attach the new exercise to.
      workoutId = const Uuid().v4();
      final newWorkout = Workout(
        id: workoutId,
        trainingCycleId: cycleId,
        periodNumber: period,
        dayNumber: day,
        status: WorkoutStatus.incomplete,
      );
      await workoutRepo.create(newWorkout);
      _invalidateWorkoutProviders();
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          trainingCycleId: cycleId,
          workoutId: workoutId,
        ),
      ),
    );
  }

  /// SportGrid Run/Bike/Swim tap handler. Pushes the cardio session
  /// creator, pre-filled with cycle/period/day so the session attaches
  /// to the correct slot on save.
  void _onCardioPressed(
    Sport sport,
    String cycleId,
    int period,
    int day,
  ) {
    context.push(
      '/cardio-session/new'
      '?sport=${sport.name}'
      '&trainingCycleId=$cycleId'
      '&period=$period'
      '&day=$day'
      '&planned=true',
    );
  }

  /// FAB handler — opens the unified add-session dialog with sport
  /// picker at the top. Replaces the removed compact SportGrid footer.
  void _showAddSessionDialog({
    required String cycleId,
    required int period,
    required int day,
    required List<Workout> workouts,
    required List<Sport> sports,
  }) {
    showAddExerciseDialog(
      context: context,
      ref: ref,
      workouts: workouts,
      trainingCycleId: cycleId,
      periodNumber: period,
      dayNumber: day,
      selectedSports: sports,
    );
  }

  /// Shown while the first workout load is in flight — distinct from the
  /// true empty state.
  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.workoutSessionTitle)),
      body: ScreenBackground.workout(
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    final cycleTerm = ref.watch(trainingCycleTermProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutSessionTitle)),
      body: ScreenBackground.workout(
        child: EmptyStateWidget(
          icon: Icons.fitness_center,
          iconSize: 80,
          title: title,
          subtitle: message,
          primaryAction: EmptyStateAction(
            key: const ValueKey('empty_workout_create_cycle'),
            label: l10n.emptyWorkoutCreateCycle(cycleTerm),
            icon: Icons.add,
            onPressed: () => context.push('/trainingCycles/create'),
          ),
          secondaryAction: EmptyStateAction(
            label: l10n.emptyWorkoutUseTemplate,
            icon: Icons.grid_view_rounded,
            onPressed: () => context.push('/templates'),
          ),
        ),
      ),
    );
  }

  void _showWorkoutMenu(
    BuildContext context,
    dynamic trainingCycle,
    List<Workout> workouts,
    int period,
    int day,
    List<Sport> sports,
  ) {
    final l10n = AppLocalizations.of(this.context)!;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
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
        _buildMenuHeader(l10n.workoutMenuTrainingCycleHeader),
        _buildMenuItem(
          icon: Icons.edit_note,
          text: l10n.workoutMenuNote,
          onTap: () => _viewTrainingCycleNotes(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.summarize_outlined,
          text: l10n.workoutMenuSummary,
          onTap: () => _showTrainingCycleSummary(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.edit,
          text: l10n.workoutMenuRename,
          onTap: () => _renameTrainingCycle(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.stop_circle_outlined,
          text: l10n.workoutMenuEndCycle(ref.watch(trainingCycleTermProvider)),
          onTap: () => _endTrainingCycle(trainingCycle),
          color: context.errorColor,
        ),
        const PopupMenuDivider(height: 1),

        // WORKOUT Section
        _buildMenuHeader(l10n.workoutMenuWorkoutHeader),
        _buildMenuItem(
          icon: Icons.edit,
          text: l10n.workoutMenuNewNote,
          onTap: () => _newWorkoutNote(workouts),
        ),
        _buildMenuItem(
          icon: Icons.label_outline,
          text: l10n.workoutMenuRelabel,
          onTap: () => _relabelWorkout(workouts),
        ),
        _buildMenuItem(
          icon: Icons.clear_all,
          text: l10n.workoutMenuClearDayLabels,
          onTap: () => _clearAllDayNames(trainingCycle),
        ),
        _buildMenuItem(
          icon: Icons.add,
          text: l10n.workoutMenuAddSession,
          onTap: () => _showAddSessionDialog(
            cycleId: trainingCycle.id as String,
            period: period,
            day: day,
            workouts: workouts,
            sports: sports,
          ),
        ),
        _buildMenuItem(
          icon: Icons.monitor_weight_outlined,
          text: l10n.workoutMenuBodyweight,
          onTap: () => _logBodyweight(),
        ),
        _buildMenuItem(
          icon: Icons.undo,
          text: l10n.workoutMenuReset,
          onTap: () => _resetWorkout(workouts),
          enabled:
              !workouts.any((w) => w.status == WorkoutStatus.completed) &&
              workouts.any(
                (w) => w.exercises.any(
                  (e) => e.sets.any(
                    (s) => s.isLogged || (s.weight != null) || (s.reps.isNotEmpty && s.reps != '0'),
                  ),
                ),
              ),
        ),
        _buildMenuItem(
          icon: Icons.skip_next,
          text: l10n.workoutMenuSkipWorkout,
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
        style: context.textTheme.labelMedium?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
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
            color: enabled ? (color ?? Theme.of(context).iconTheme.color) : Theme.of(context).disabledColor,
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
    final l10n = AppLocalizations.of(context)!;
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentNote = trainingCycle.notes as String?;

    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => NoteDialog(
        initialNote: currentNote,
        noteType: NoteType.trainingCycle,
        customTitle: l10n.cycleListNoteDialogTitle(cycleTerm),
        customHint: l10n.cycleListNoteDialogHint(cycleTerm),
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
          context.showSuccessSnackBar(l10n.noteSaved);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.noteSaveError(e));
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
    final l10n = AppLocalizations.of(context)!;
    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameTrainingCycleDialog(initialName: trainingCycle.name),
    );

    if (newName != null && newName != trainingCycle.name && mounted) {
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        final updatedTrainingCycle = trainingCycle.copyWith(name: newName);
        await repository.update(updatedTrainingCycle);

        if (mounted) {
          context.showSuccessSnackBar(l10n.workoutRenamedTo(newName));
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.workoutRenameError(e));
        }
      }
    }
  }

  Future<void> _endTrainingCycle(dynamic trainingCycle) async {
    final l10n = AppLocalizations.of(context)!;
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workoutEndCycleTitle(cycleTerm)),
        content: Text(
          l10n.workoutEndCycleContent(trainingCycle.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelUpper),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.workoutEndCycleAction(cycleTerm)),
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
          context.showSuccessSnackBar(l10n.workoutCycleCompleted(trainingCycle.name));
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.workoutEndCycleError(e));
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
      final l10n = AppLocalizations.of(context)!;
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final updatedWorkout = workout.copyWith(notes: newNote);
        await repository.update(updatedWorkout);

        if (mounted) {
          context.showSuccessSnackBar(l10n.noteSaved);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.noteSaveError(e));
        }
      }
    }
  }

  Future<void> _relabelWorkout(List<Workout> workouts) async {
    if (workouts.isEmpty) return;

    final workout = workouts.first;
    final l10n = AppLocalizations.of(context)!;
    final currentLabel = workout.dayName ?? '${l10n.editWorkoutDayLabel} ${workout.dayNumber}';

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
            workoutsByTrainingCycleListProvider(workout.trainingCycleId),
          );
          final workoutsToUpdate = allWorkouts.where((w) => w.dayNumber == workout.dayNumber).toList();

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
            context.showSuccessSnackBar(l10n.workoutLabelUpdatedForAllDays(workout.dayNumber));
          }
        } else {
          // Update only the current workout(s) for this specific period and day
          // The workouts list passed in contains ALL workouts for this day across all periods
          // We need to filter to only the current period
          final currentPeriodNumber = workouts.first.periodNumber;
          final currentPeriodWorkouts = workouts.where((w) => w.periodNumber == currentPeriodNumber).toList();

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
            workoutsByTrainingCycleListProvider(workout.trainingCycleId),
          );

          // Show ALL workouts grouped by period
          debugPrint('All workouts in trainingCycle after update:');
          for (int period = 1; period <= 5; period++) {
            final periodWorkouts = allWorkoutsAfter.where((w) => w.periodNumber == period).toList();
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
            context.showSuccessSnackBar(l10n.workoutLabelUpdated);
          }
        }
      } catch (e) {
        debugPrint('Error updating label: $e');
        if (mounted) {
          context.showErrorSnackBar(l10n.workoutLabelUpdateError(e));
        }
      }
    }
  }

  Future<void> _clearAllDayNames(dynamic trainingCycle) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workoutClearDayLabelsTitle),
        content: Text(
          l10n.workoutClearDayLabelsContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelUpper),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(l10n.workoutClearDayLabelsAction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final allWorkouts = ref.read(
          workoutsByTrainingCycleListProvider(trainingCycle.id),
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
          context.showSuccessSnackBar(l10n.workoutAllDayLabelsCleared);
        }
      } catch (e) {
        debugPrint('Error clearing day names: $e');
        if (mounted) {
          context.showErrorSnackBar(l10n.workoutClearLabelsError(e));
        }
      }
    }
  }

  void _logBodyweight() {
    debugPrint('Log bodyweight');
  }

  void _resetWorkout(List<Workout> workouts) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workoutResetTitle),
        content: Text(
          l10n.workoutResetContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelUpper),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              try {
                final repository = ref.read(workoutRepositoryProvider);

                // Snapshot the pre-reset state (fresh from the DB) so the
                // snackbar's Undo can restore every set exactly.
                final resetSnapshots = <Workout>[];

                for (final workout in workouts) {
                  final fresh = await repository.getById(workout.id) ?? workout;
                  resetSnapshots.add(fresh);

                  // Create updated exercises with reset sets
                  final updatedExercises = fresh.exercises.map((exercise) {
                    final updatedSets = exercise.sets.map((set) {
                      return set.copyWith(
                        isLogged: false,
                        clearWeight: true,
                        reps: '', // Clear reps
                      );
                    }).toList();

                    return exercise.copyWith(sets: updatedSets);
                  }).toList();

                  // Update workout with reset exercises and status
                  final updatedWorkout = fresh.copyWith(
                    exercises: updatedExercises,
                    status: WorkoutStatus.incomplete,
                    completedDate: null,
                  );

                  await repository.update(updatedWorkout);
                }
                _invalidateWorkoutProviders();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.workoutReset),
                    backgroundColor: this.context.successColor,
                    duration: const Duration(seconds: 6),
                    action: SnackBarAction(
                      label: l10n.undo,
                      onPressed: () => _restoreWorkouts(resetSnapshots),
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.workoutResetError(e)),
                    backgroundColor: this.context.errorColor,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(l10n.workoutResetAction),
          ),
        ],
      ),
    );
  }

  /// Undo helper for the Reset action — writes the pre-reset snapshots
  /// back, restoring weight/reps/isLogged for every set.
  Future<void> _restoreWorkouts(List<Workout> snapshots) async {
    await _guardWrite(() async {
      final repository = ref.read(workoutRepositoryProvider);
      for (final workout in snapshots) {
        await repository.update(workout);
      }
      _invalidateWorkoutProviders();
    });
  }

  void _skipWorkout(List<Workout> workouts) {
    debugPrint('Skip workout');
  }
}

/// A single slot in the v6 chunk A4 unified scroll.
///
/// Either a strength block (one slot per day, contains every exercise
/// across all that day's strength workouts) or a single cardio session
/// card. Used by `_buildSessionScroll` to interleave the two card types
/// in performed-order while keeping the strength block as a single
/// sortable unit. Bucket / sort-key choices happen at the call site;
/// the slot itself is just a render-time discriminator.
class _RenderSlot {
  final bool isStrength;
  final CardioSession? cardio;

  const _RenderSlot._({required this.isStrength, required this.cardio});

  factory _RenderSlot.strengthBlock() {
    return const _RenderSlot._(isStrength: true, cardio: null);
  }

  factory _RenderSlot.cardio(CardioSession session) {
    return _RenderSlot._(isStrength: false, cardio: session);
  }

  /// Stable identifier for manual reordering. The strength block uses a
  /// sentinel string; cardio slots use the session UUID.
  String get slotId => isStrength ? 'strength' : cardio!.id;
}

/// Section header shown above each cycle's sessions when multiple training
/// cycles are stacked (running simultaneously). Displays the cycle name and
/// the independently-computed period/day for that cycle.
class _CycleSectionHeader extends StatelessWidget {
  const _CycleSectionHeader({
    required this.cycleName,
    required this.period,
    required this.day,
  });

  final String cycleName;
  final int period;
  final int day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cycleName.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)!.workoutCycleSectionPeriodDay(period, day),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
