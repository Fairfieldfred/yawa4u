import '../../core/constants/enums.dart';
import '../../data/models/training_cycle.dart';
import '../../data/repositories/training_cycle_repository.dart';

/// Ends a training cycle by marking it as completed with an end date.
class EndTrainingCycleUseCase {
  final TrainingCycleRepository _trainingCycleRepository;

  EndTrainingCycleUseCase(this._trainingCycleRepository);

  /// Marks the [trainingCycle] as completed with the current timestamp.
  Future<void> execute(TrainingCycle trainingCycle) async {
    final updatedTrainingCycle = trainingCycle.copyWith(
      status: TrainingCycleStatus.completed,
      endDate: DateTime.now(),
    );
    await _trainingCycleRepository.update(updatedTrainingCycle);
  }
}
