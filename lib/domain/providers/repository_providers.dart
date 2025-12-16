import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/custom_exercise_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/training_cycle_repository.dart';
import '../../data/repositories/workout_repository.dart';
import 'database_providers.dart';

/// Provider for TrainingCycleRepository
final trainingCycleRepositoryProvider = Provider<TrainingCycleRepository>((ref) {
  final box = ref.watch(trainingCyclesBoxProvider);
  return TrainingCycleRepository(box);
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
