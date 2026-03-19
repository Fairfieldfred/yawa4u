import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../use_cases/add_exercise_set_use_case.dart';
import '../use_cases/end_training_cycle_use_case.dart';
import '../use_cases/finish_workout_use_case.dart';
import '../use_cases/reset_workout_use_case.dart';
import '../use_cases/skip_workout_use_case.dart';
import '../use_cases/start_training_cycle_use_case.dart';
import 'database_providers.dart';

/// Provider for [FinishWorkoutUseCase].
final finishWorkoutUseCaseProvider = Provider<FinishWorkoutUseCase>((ref) {
  return FinishWorkoutUseCase(
    ref.watch(workoutRepositoryProvider),
    ref.watch(trainingCycleRepositoryProvider),
  );
});

/// Provider for [SkipWorkoutUseCase].
final skipWorkoutUseCaseProvider = Provider<SkipWorkoutUseCase>((ref) {
  return SkipWorkoutUseCase(ref.watch(workoutRepositoryProvider));
});

/// Provider for [ResetWorkoutUseCase].
final resetWorkoutUseCaseProvider = Provider<ResetWorkoutUseCase>((ref) {
  return ResetWorkoutUseCase(ref.watch(workoutRepositoryProvider));
});

/// Provider for [AddExerciseSetUseCase].
final addExerciseSetUseCaseProvider = Provider<AddExerciseSetUseCase>((ref) {
  return AddExerciseSetUseCase(ref.watch(workoutRepositoryProvider));
});

/// Provider for [EndTrainingCycleUseCase].
final endTrainingCycleUseCaseProvider = Provider<EndTrainingCycleUseCase>((
  ref,
) {
  return EndTrainingCycleUseCase(ref.watch(trainingCycleRepositoryProvider));
});

/// Provider for [StartTrainingCycleUseCase].
final startTrainingCycleUseCaseProvider = Provider<StartTrainingCycleUseCase>((
  ref,
) {
  return StartTrainingCycleUseCase(ref.watch(trainingCycleRepositoryProvider));
});
