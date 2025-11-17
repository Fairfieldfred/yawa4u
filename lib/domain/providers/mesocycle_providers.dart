import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mesocycle.dart';
import '../../core/constants/enums.dart';
import 'repository_providers.dart';

/// Provider for all mesocycles
final mesocyclesProvider = StreamProvider<List<Mesocycle>>((ref) async* {
  final repository = ref.watch(mesocycleRepositoryProvider);
  final box = repository.box;

  // Emit initial value
  yield repository.getAllSorted();

  // Listen to box changes and emit updates
  await for (final _ in box.watch()) {
    yield repository.getAllSorted();
  }
});

/// Provider for current (active) mesocycle
final currentMesocycleProvider = Provider<Mesocycle?>((ref) {
  final mesocycles = ref.watch(mesocyclesProvider);
  return mesocycles.when(
    data: (list) {
      try {
        return list.firstWhere((m) => m.status == MesocycleStatus.current);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for draft mesocycles
final draftMesocyclesProvider = Provider<List<Mesocycle>>((ref) {
  final mesocycles = ref.watch(mesocyclesProvider);
  return mesocycles.when(
    data: (list) =>
        list.where((m) => m.status == MesocycleStatus.draft).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for completed mesocycles
final completedMesocyclesProvider = Provider<List<Mesocycle>>((ref) {
  final mesocycles = ref.watch(mesocyclesProvider);
  return mesocycles.when(
    data: (list) =>
        list.where((m) => m.status == MesocycleStatus.completed).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for a specific mesocycle by ID
final mesocycleProvider =
    Provider.family<Mesocycle?, String>((ref, id) {
  final mesocycles = ref.watch(mesocyclesProvider);
  return mesocycles.when(
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

/// Provider for mesocycle statistics
final mesocycleStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(mesocycleRepositoryProvider);
  return repository.getStats();
});
