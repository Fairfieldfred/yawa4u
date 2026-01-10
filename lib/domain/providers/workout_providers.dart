import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/workout.dart';
import 'repository_providers.dart';

/// Provider for all workouts
final workoutsProvider = StreamProvider<List<Workout>>((ref) async* {
  final repository = ref.watch(workoutRepositoryProvider);
  final box = repository.box;

  // Emit initial value
  yield repository.getAll();

  // Listen to box changes and emit updates
  await for (final _ in box.watch()) {
    yield repository.getAll();
  }
});

/// Provider for workouts by trainingCycle ID
final workoutsByTrainingCycleProvider = Provider.family<List<Workout>, String>((
  ref,
  trainingCycleId,
) {
  // Watch the workouts stream to get reactive updates
  final workouts = ref.watch(workoutsProvider);
  return workouts.when(
    data: (list) =>
        list.where((w) => w.trainingCycleId == trainingCycleId).toList()
          ..sort((a, b) {
            // Sort by period, then by day
            final periodCompare = a.periodNumber.compareTo(b.periodNumber);
            if (periodCompare != 0) return periodCompare;
            return a.dayNumber.compareTo(b.dayNumber);
          }),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for workouts by period
final workoutsByPeriodProvider =
    Provider.family<
      List<Workout>,
      ({String trainingCycleId, int periodNumber})
    >((ref, params) {
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

/// Provider for today's workouts
final todayWorkoutsProvider = Provider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getToday();
});

/// Provider for upcoming workouts
final upcomingWorkoutsProvider = Provider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUpcoming();
});

/// Provider for workout statistics
final workoutStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getStats();
});

/// Provider for workout statistics by trainingCycle
final workoutStatsForTrainingCycleProvider =
    Provider.family<Map<String, dynamic>, String>((ref, trainingCycleId) {
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
