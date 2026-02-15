import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stats_data.dart';
import '../../data/models/workout.dart';
import 'database_providers.dart';

/// Stats for a specific training cycle.
final cycleStatsProvider =
    FutureProvider.family<WorkoutStats, String>((ref, cycleId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final workouts = await repository.getByTrainingCycleId(cycleId);
  return WorkoutStats.fromWorkouts(workouts);
});

/// Stats across all training cycles (lifetime).
final lifetimeStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final workouts = await repository.getAll();
  return WorkoutStats.fromWorkouts(workouts);
});

/// All workouts for a specific training cycle (async, non-stream).
final cycleWorkoutsProvider =
    FutureProvider.family<List<Workout>, String>((ref, cycleId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getByTrainingCycleId(cycleId);
});
