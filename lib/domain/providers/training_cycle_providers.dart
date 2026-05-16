import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/training_cycle.dart';
import 'database_providers.dart';

/// Provider for all trainingCycles
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.watchAll();
});

/// Provider for all current (active) trainingCycles — supports stacking.
/// Sorted by startDate ascending so the earliest-started cycle is the
/// "primary" (index 0).
final currentTrainingCyclesProvider = Provider<List<TrainingCycle>>((ref) {
  final trainingCycles = ref.watch(trainingCyclesProvider);
  return trainingCycles.when(
    data: (list) => list
        .where((m) => m.status == TrainingCycleStatus.current)
        .toList()
      ..sort(
        (a, b) => (a.startDate ?? a.createdDate)
            .compareTo(b.startDate ?? b.createdDate),
      ),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider for the "primary" current trainingCycle — the earliest-started
/// active cycle. Used by calendar, stats, exercises, and other screens
/// that only need a single cycle reference.
final currentTrainingCycleProvider = Provider<TrainingCycle?>((ref) {
  final currentCycles = ref.watch(currentTrainingCyclesProvider);
  return currentCycles.isEmpty ? null : currentCycles.first;
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
final trainingCycleProvider = Provider.autoDispose.family<TrainingCycle?, String>((
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
  final cyclesAsync = ref.watch(trainingCyclesProvider);
  final cycles = cyclesAsync.when(
    data: (list) => list,
    loading: () => <TrainingCycle>[],
    error: (_, _) => <TrainingCycle>[],
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
