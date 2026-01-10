import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/training_cycle.dart';
import 'repository_providers.dart';

/// Provider for all trainingCycles
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((
  ref,
) async* {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  final box = repository.box;

  // Emit initial value
  yield repository.getAllSorted();

  // Listen to box changes and emit updates
  await for (final _ in box.watch()) {
    yield repository.getAllSorted();
  }
});

/// Provider for current (active) trainingCycle
final currentTrainingCycleProvider = Provider<TrainingCycle?>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) {
      try {
        return list.firstWhere((m) => m.status == TrainingCycleStatus.current);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider for draft trainingCycles
final draftTrainingCyclesProvider = Provider<List<TrainingCycle>>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) =>
        list.where((m) => m.status == TrainingCycleStatus.draft).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for completed trainingCycles
final completedTrainingCyclesProvider = Provider<List<TrainingCycle>>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) =>
        list.where((m) => m.status == TrainingCycleStatus.completed).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for a specific trainingCycle by ID
final trainingCycleProvider = Provider.family<TrainingCycle?, String>((
  ref,
  id,
) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) {
      try {
        return list.firstWhere((m) => m.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// Provider for trainingCycle statistics
final trainingCycleStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.getStats();
});
