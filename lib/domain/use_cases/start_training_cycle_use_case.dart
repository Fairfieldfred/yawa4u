import '../../data/models/training_cycle.dart';
import '../../data/repositories/training_cycle_repository.dart';

/// Starts a training cycle by setting it as the current active cycle.
///
/// When [stack] is false (default), deactivates any other currently active
/// cycle first. When [stack] is true, the new cycle is activated alongside
/// existing current cycles.
class StartTrainingCycleUseCase {
  final TrainingCycleRepository _trainingCycleRepository;

  StartTrainingCycleUseCase(this._trainingCycleRepository);

  /// Activates the [trainingCycle].
  ///
  /// If [stack] is true, existing current cycles remain active (stacking).
  /// If [stack] is false (default), all other current cycles are deactivated
  /// first (replacement).
  Future<void> execute(
    TrainingCycle trainingCycle, {
    bool stack = false,
  }) async {
    if (stack) {
      await _trainingCycleRepository.stackAsCurrent(trainingCycle.id);
    } else {
      await _trainingCycleRepository.setAsCurrent(trainingCycle.id);
    }
  }
}
