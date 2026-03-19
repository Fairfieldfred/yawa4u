import '../../data/models/training_cycle.dart';
import '../../data/repositories/training_cycle_repository.dart';

/// Starts a training cycle by setting it as the current active cycle.
///
/// Deactivates any other currently active cycle and activates the given one.
class StartTrainingCycleUseCase {
  final TrainingCycleRepository _trainingCycleRepository;

  StartTrainingCycleUseCase(this._trainingCycleRepository);

  /// Activates the [trainingCycle], deactivating any other active cycle.
  Future<void> execute(TrainingCycle trainingCycle) async {
    await _trainingCycleRepository.setAsCurrent(trainingCycle.id);
  }
}
