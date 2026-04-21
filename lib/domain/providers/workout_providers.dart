import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/session.dart';
import '../../data/models/workout.dart';
import 'database_providers.dart';
import 'session_providers.dart';

// Phase 6b: Stream-based `workoutsProvider` and
// `workoutsByTrainingCycleProvider` stay backed by
// [workoutRepositoryProvider] for now. Reactive invalidation semantics
// in the debounce-heavy workout_screen rely on their current shape and
// moving them carries risk. Because [WorkoutRepository] mirror-writes
// every strength workout into the sessions table, session-backed
// surfaces (stats Cardio, weekly summary, etc.) still see the same
// data — they don't need this provider migrated.
//
// The _synchronous_ `workoutsByTrainingCycleListProvider` is safe to
// migrate because its Provider.autoDispose wrapper already debounces
// via .when(); readers that use it (cycle_list_screen) don't care about
// Drift-level table reactivity, only about the latest snapshot.

Workout _sessionToLegacyWorkout(StrengthSession s) {
  return Workout(
    id: s.id,
    trainingCycleId: s.trainingCycleId ?? '',
    periodNumber: s.periodNumber ?? 1,
    dayNumber: s.dayNumber ?? 1,
    dayName: s.dayName,
    label: s.label,
    status: s.status,
    scheduledDate: s.scheduledDate,
    completedDate: s.completedDate,
    startTime: s.startTime,
    endTime: s.endTime,
    notes: s.notes,
    exercises: s.exercises,
  );
}

/// Provider for all workouts (reactive via Stream)
final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.watchAll();
});

/// Provider for workouts by trainingCycle ID (reactive via Stream)
final workoutsByTrainingCycleProvider =
    StreamProvider.autoDispose.family<List<Workout>, String>((ref, trainingCycleId) {
      final repository = ref.watch(workoutRepositoryProvider);
      return repository.watchByTrainingCycleId(trainingCycleId);
    });

/// Provider for workouts by trainingCycle ID (synchronous accessor for
/// convenience). Returns empty list while loading or on error.
///
/// Phase 6b migration: reads from [sessionsByTrainingCycleProvider]
/// and filters to [StrengthSession]. Behavior is identical to the
/// pre-migration version because every strength write now mirrors
/// into the sessions table.
final workoutsByTrainingCycleListProvider =
    Provider.autoDispose.family<List<Workout>, String>((ref, trainingCycleId) {
      final sessionsAsync = ref.watch(
        sessionsByTrainingCycleProvider(trainingCycleId),
      );
      return sessionsAsync.when(
        data: (list) => list
            .whereType<StrengthSession>()
            .map(_sessionToLegacyWorkout)
            .toList(),
        loading: () => [],
        error: (_, _) => [],
      );
    });

/// Provider for workouts by period (async)
final workoutsByPeriodProvider =
    FutureProvider.autoDispose.family<
      List<Workout>,
      ({String trainingCycleId, int periodNumber})
    >((ref, params) async {
      final repository = ref.watch(workoutRepositoryProvider);
      return repository.getByPeriod(
        params.trainingCycleId,
        params.periodNumber,
      );
    });

/// Provider for a specific workout by ID
final workoutProvider = Provider.autoDispose.family<Workout?, String>((ref, id) {
  final workouts = ref.watch(workoutsProvider);
  return workouts.when(
    data: (list) {
      try {
        return list.firstWhere((w) => w.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider for completed workouts
final completedWorkoutsProvider = Provider<List<Workout>>((ref) {
  final workouts = ref.watch(workoutsProvider);
  return workouts.when(
    data: (list) =>
        list.where((w) => w.status == WorkoutStatus.completed).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for today's workouts (async)
final todayWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getToday();
});

/// Provider for upcoming workouts (async)
final upcomingWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUpcoming();
});

/// Provider for workout statistics (async)
final workoutStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getStats();
});

/// Provider for workout statistics by trainingCycle (async)
final workoutStatsForTrainingCycleProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((
      ref,
      trainingCycleId,
    ) async {
      final repository = ref.watch(workoutRepositoryProvider);
      return repository.getStatsForTrainingCycle(trainingCycleId);
    });

/// Notifier for show exercise history preference (persists across navigation)
class ShowExerciseHistoryNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default to showing history

  void toggle() {
    state = !state;
  }
}

final showExerciseHistoryProvider =
    NotifierProvider<ShowExerciseHistoryNotifier, bool>(
      ShowExerciseHistoryNotifier.new,
    );
