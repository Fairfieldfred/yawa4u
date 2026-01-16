import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/workout.dart';
import 'database_providers.dart';

/// Provider for all workouts (reactive via Stream)
final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.watchAll();
});

/// Provider for workouts by trainingCycle ID (reactive via Stream)
final workoutsByTrainingCycleProvider =
    StreamProvider.family<List<Workout>, String>((ref, trainingCycleId) {
      final repository = ref.watch(workoutRepositoryProvider);
      return repository.watchByTrainingCycleId(trainingCycleId);
    });

/// Provider for workouts by trainingCycle ID (synchronous accessor for convenience)
/// Returns empty list while loading or on error
final workoutsByTrainingCycleListProvider =
    Provider.family<List<Workout>, String>((ref, trainingCycleId) {
      final workoutsAsync = ref.watch(
        workoutsByTrainingCycleProvider(trainingCycleId),
      );
      return workoutsAsync.when(
        data: (list) => list,
        loading: () => [],
        error: (_, __) => [],
      );
    });

/// Provider for workouts by period (async)
final workoutsByPeriodProvider =
    FutureProvider.family<
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
final workoutProvider = Provider.family<Workout?, String>((ref, id) {
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
    error: (_, __) => null,
  );
});

/// Provider for completed workouts
final completedWorkoutsProvider = Provider<List<Workout>>((ref) {
  final workouts = ref.watch(workoutsProvider);
  return workouts.when(
    data: (list) =>
        list.where((w) => w.status == WorkoutStatus.completed).toList(),
    loading: () => [],
    error: (_, __) => [],
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
    FutureProvider.family<Map<String, dynamic>, String>((
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
