import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/custom_exercise_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/mesocycle_repository.dart';
import '../../data/repositories/workout_repository.dart';
import 'database_providers.dart';

/// Provider for MesocycleRepository
final mesocycleRepositoryProvider = Provider<MesocycleRepository>((ref) {
  final box = ref.watch(mesocyclesBoxProvider);
  return MesocycleRepository(box);
});

/// Provider for WorkoutRepository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final box = ref.watch(workoutsBoxProvider);
  return WorkoutRepository(box);
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final box = ref.watch(exercisesBoxProvider);
  return ExerciseRepository(box);
});

/// Provider for CustomExerciseRepository
final customExerciseRepositoryProvider = Provider<CustomExerciseRepository>((
  ref,
) {
  final box = ref.watch(customExercisesBoxProvider);
  return CustomExerciseRepository(box);
});
