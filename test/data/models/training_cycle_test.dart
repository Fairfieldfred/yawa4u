import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/data/models/training_cycle.dart';

void main() {
  TrainingCycle p90xCycle() => TrainingCycle(
    id: 'p90x',
    name: 'P90X Classic',
    periodsTotal: 13,
    daysPerPeriod: 7,
    recoveryPeriod: 13,
    additionalRecoveryPeriods: const [4, 8],
  );

  group('recovery periods', () {
    test('flags the final and the additional recovery periods', () {
      final cycle = p90xCycle();

      expect(cycle.recoveryPeriods, [4, 8, 13]);
      expect(
        [
          for (var p = 1; p <= 13; p++)
            if (cycle.isRecoveryPeriod(p)) p,
        ],
        [4, 8, 13],
      );
    });

    test('defaults to only the final recovery period', () {
      final cycle = TrainingCycle(id: 'c', name: 'Plain', periodsTotal: 5, daysPerPeriod: 4);

      expect(cycle.additionalRecoveryPeriods, isEmpty);
      expect(cycle.recoveryPeriods, [5]);
    });

    test('nextRecoveryPeriod counts down to the upcoming recovery period', () {
      final cycle = p90xCycle();

      expect(cycle.nextRecoveryPeriod(1), 4);
      expect(cycle.nextRecoveryPeriod(4), 4);
      expect(cycle.nextRecoveryPeriod(5), 8);
      expect(cycle.nextRecoveryPeriod(9), 13);
    });

    test('renumbers additional recovery periods when a period is inserted', () {
      final cycle = p90xCycle();

      expect(cycle.additionalRecoveryPeriodsAfterInsert(13), [4, 8]);
      expect(cycle.additionalRecoveryPeriodsAfterInsert(5), [4, 9]);
    });

    test('renumbers and drops additional recovery periods when a period is removed', () {
      final cycle = p90xCycle();

      expect(cycle.additionalRecoveryPeriodsAfterRemoval(12), [4, 8]);
      expect(cycle.additionalRecoveryPeriodsAfterRemoval(6), [4, 7]);
      expect(cycle.additionalRecoveryPeriodsAfterRemoval(4), [7]);
    });

    test('survives copyWith and a JSON round trip', () {
      final cycle = p90xCycle();

      expect(cycle.copyWith(name: 'Renamed').additionalRecoveryPeriods, [4, 8]);
      expect(TrainingCycle.fromJson(cycle.toJson()).additionalRecoveryPeriods, [4, 8]);
    });

    test('reads JSON without additionalRecoveryPeriods as none', () {
      final json = p90xCycle().toJson()..remove('additionalRecoveryPeriods');

      expect(TrainingCycle.fromJson(json).additionalRecoveryPeriods, isEmpty);
    });
  });
}
