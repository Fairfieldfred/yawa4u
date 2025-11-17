import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/workout.dart';
import '../../core/constants/enums.dart';
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

/// Provider for workouts by mesocycle ID
final workoutsByMesocycleProvider =
    Provider.family<List<Workout>, String>((ref, mesocycleId) {
  // Watch the workouts stream to get reactive updates
  final workouts = ref.watch(workoutsProvider);
  return workouts.when(
    data: (list) => list.where((w) => w.mesocycleId == mesocycleId).toList()
      ..sort((a, b) {
        // Sort by week, then by day
        final weekCompare = a.weekNumber.compareTo(b.weekNumber);
        if (weekCompare != 0) return weekCompare;
        return a.dayNumber.compareTo(b.dayNumber);
      }),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for workouts by week
final workoutsByWeekProvider =
    Provider.family<List<Workout>, ({String mesocycleId, int weekNumber})>(
  (ref, params) {
    final repository = ref.watch(workoutRepositoryProvider);
    return repository.getByWeek(params.mesocycleId, params.weekNumber);
  },
);

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

/// Provider for workout statistics by mesocycle
final workoutStatsForMesocycleProvider =
    Provider.family<Map<String, dynamic>, String>((ref, mesocycleId) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getStatsForMesocycle(mesocycleId);
});
