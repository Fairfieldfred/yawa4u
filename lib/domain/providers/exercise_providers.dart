import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/custom_exercise_definition.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_definition.dart';
import 'database_providers.dart';
import 'repository_providers.dart';

/// Provider for all exercises
final exercisesProvider = StreamProvider<List<Exercise>>((ref) async* {
  final repository = ref.watch(exerciseRepositoryProvider);
  final box = repository.box;

  // Emit initial value
  yield repository.getAll();

  // Listen to box changes and emit updates
  await for (final _ in box.watch()) {
    yield repository.getAll();
  }
});

/// Provider for exercises by workout ID
final exercisesByWorkoutProvider = Provider.family<List<Exercise>, String>((
  ref,
  workoutId,
) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getByWorkoutId(workoutId);
});

/// Provider for a specific exercise by ID
final exerciseProvider = Provider.family<Exercise?, String>((ref, id) {
  final exercises = ref.watch(exercisesProvider);
  return exercises.when(
    data: (list) {
      try {
        return list.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider for exercise statistics
final exerciseStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getStats();
});

/// Provider for exercise statistics by workout
final exerciseStatsForWorkoutProvider =
    Provider.family<Map<String, dynamic>, String>((ref, workoutId) {
      final repository = ref.watch(exerciseRepositoryProvider);
      return repository.getStatsForWorkout(workoutId);
    });

/// Provider for recently performed exercises
final recentExercisesProvider = Provider.family<List<Exercise>, int>((
  ref,
  limit,
) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getRecentlyPerformed(limit: limit);
});

/// Provider for exercise history by name
final exerciseHistoryProvider = Provider.family<List<Exercise>, String>((
  ref,
  name,
) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getHistoryByName(name);
});

// =============================================================================
// Exercise Library (CSV) Providers
// =============================================================================

/// Provider for all exercise definitions from CSV
final exerciseDefinitionsProvider = Provider<List<ExerciseDefinition>>((ref) {
  final csvService = ref.watch(csvLoaderServiceProvider);
  return csvService.isLoaded ? csvService.exercises : [];
});

/// Provider for exercise definitions by muscle group
final exerciseDefinitionsByMuscleGroupProvider =
    Provider.family<List<ExerciseDefinition>, MuscleGroup>((ref, muscleGroup) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.filterByMuscleGroup(muscleGroup);
    });

/// Provider for exercise definitions by equipment type
final exerciseDefinitionsByEquipmentProvider =
    Provider.family<List<ExerciseDefinition>, EquipmentType>((
      ref,
      equipmentType,
    ) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.filterByEquipment(equipmentType);
    });

/// Provider for searching exercise definitions
final exerciseDefinitionsSearchProvider =
    Provider.family<List<ExerciseDefinition>, String>((ref, query) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.searchByName(query);
    });

/// Provider for filtered exercise definitions
final exerciseDefinitionsFilterProvider =
    Provider.family<
      List<ExerciseDefinition>,
      ({
        String? searchQuery,
        MuscleGroup? muscleGroup,
        EquipmentType? equipmentType,
      })
    >((ref, params) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.filter(
        searchQuery: params.searchQuery,
        muscleGroup: params.muscleGroup,
        equipmentType: params.equipmentType,
      );
    });

/// Provider for exercise definition by name
final exerciseDefinitionByNameProvider =
    Provider.family<ExerciseDefinition?, String>((ref, name) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.getByName(name);
    });

/// Provider for exercise definitions grouped by muscle group
final exerciseDefinitionsGroupedByMuscleProvider =
    Provider<Map<MuscleGroup, List<ExerciseDefinition>>>((ref) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.groupByMuscleGroup();
    });

/// Provider for exercise definitions grouped by equipment
final exerciseDefinitionsGroupedByEquipmentProvider =
    Provider<Map<EquipmentType, List<ExerciseDefinition>>>((ref) {
      final csvService = ref.watch(csvLoaderServiceProvider);
      return csvService.groupByEquipmentType();
    });

// =============================================================================
// Custom Exercise Providers
// =============================================================================

/// Provider for all custom exercise definitions
final customExerciseDefinitionsProvider =
    StreamProvider<List<CustomExerciseDefinition>>((ref) async* {
      final repository = ref.watch(customExerciseRepositoryProvider);
      final box = repository.box;

      // Emit initial value
      yield repository.getAll();

      // Listen to box changes and emit updates
      await for (final _ in box.watch()) {
        yield repository.getAll();
      }
    });

/// Provider for combined exercise definitions (CSV + custom)
/// Custom exercises are marked with a prefix for identification
final allExerciseDefinitionsProvider = Provider<List<ExerciseDefinition>>((
  ref,
) {
  // Get CSV exercises
  final csvService = ref.watch(csvLoaderServiceProvider);
  final csvExercises = csvService.isLoaded
      ? csvService.exercises
      : <ExerciseDefinition>[];

  // Get custom exercises
  final customExercises = ref.watch(customExerciseDefinitionsProvider);
  final customList = customExercises.when(
    data: (list) => list.map((e) => e.toExerciseDefinition()).toList(),
    loading: () => <ExerciseDefinition>[],
    error: (_, _) => <ExerciseDefinition>[],
  );

  // Combine and sort by name
  final combined = [...csvExercises, ...customList];
  combined.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return combined;
});

/// Provider to check if an exercise name exists (in CSV or custom)
final exerciseNameExistsProvider = Provider.family<bool, String>((ref, name) {
  final csvService = ref.watch(csvLoaderServiceProvider);
  final csvExists = csvService.getByName(name) != null;

  if (csvExists) return true;

  final customRepo = ref.watch(customExerciseRepositoryProvider);
  return customRepo.existsByName(name);
});
