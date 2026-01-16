import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/training_cycle.dart';
import 'database_providers.dart';

/// Provider for all trainingCycles
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.watchAll();
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
    error: (_, __) => null,
  );
});

/// Provider for draft trainingCycles
final draftTrainingCyclesProvider = Provider<List<TrainingCycle>>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) =>
        list.where((m) => m.status == TrainingCycleStatus.draft).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for completed trainingCycles
final completedTrainingCyclesProvider = Provider<List<TrainingCycle>>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) =>
        list.where((m) => m.status == TrainingCycleStatus.completed).toList(),
    loading: () => [],
    error: (_, __) => [],
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
    error: (_, __) => null,
  );
});

/// Provider for trainingCycle statistics
final trainingCycleStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final cyclesAsync = ref.watch(trainingCyclesProvider);
  final cycles = cyclesAsync.when(
    data: (list) => list,
    loading: () => <TrainingCycle>[],
    error: (_, __) => <TrainingCycle>[],
  );
  return {
    'total': cycles.length,
    'active': cycles
        .where((c) => c.status == TrainingCycleStatus.current)
        .length,
    'draft': cycles.where((c) => c.status == TrainingCycleStatus.draft).length,
    'completed': cycles
        .where((c) => c.status == TrainingCycleStatus.completed)
        .length,
  };
});
