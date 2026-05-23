import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/domain/providers/training_cycle_providers.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('currentTrainingCyclesProvider', () {
    test('filters to current status only', () {
      final cycles = [
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
          startDate: DateTime(2024, 3, 1),
        ),
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.draft,
        ),
        TestFixtures.createTrainingCycle(
          id: 'c3',
          status: TrainingCycleStatus.completed,
        ),
        TestFixtures.createTrainingCycle(
          id: 'c4',
          status: TrainingCycleStatus.current,
          startDate: DateTime(2024, 1, 1),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final current = container.read(currentTrainingCyclesProvider);
      expect(current.length, 2);
      // Sorted by startDate ascending — earliest first
      expect(current.first.id, 'c4');
      expect(current.last.id, 'c1');
    });

    test('returns empty list when no current cycles', () {
      final cycles = [
        TestFixtures.createTrainingCycle(
          status: TrainingCycleStatus.draft,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentTrainingCyclesProvider), isEmpty);
    });

    test('returns empty list on error', () {
      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(
            AsyncValue.error(Exception('db error'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentTrainingCyclesProvider), isEmpty);
    });
  });

  group('currentTrainingCycleProvider', () {
    test('returns primary (earliest) current cycle', () {
      final cycles = [
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
          startDate: DateTime(2024, 3, 1),
        ),
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.current,
          startDate: DateTime(2024, 1, 1),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final current = container.read(currentTrainingCycleProvider);
      expect(current, isNotNull);
      expect(current!.id, 'c2');
    });

    test('returns null when no current cycle', () {
      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(const AsyncValue.data([])),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentTrainingCycleProvider), isNull);
    });
  });

  group('draftTrainingCyclesProvider', () {
    test('filters to draft only', () {
      final cycles = [
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.draft,
        ),
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.current,
        ),
        TestFixtures.createTrainingCycle(
          id: 'c3',
          status: TrainingCycleStatus.draft,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final drafts = container.read(draftTrainingCyclesProvider);
      expect(drafts.length, 2);
      expect(drafts.every((c) => c.status == TrainingCycleStatus.draft), isTrue);
    });
  });

  group('completedTrainingCyclesProvider', () {
    test('filters to completed only', () {
      final cycles = [
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.completed,
        ),
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.draft,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final completed = container.read(completedTrainingCyclesProvider);
      expect(completed.length, 1);
      expect(completed.first.id, 'c1');
    });
  });

  group('trainingCycleProvider', () {
    test('returns cycle by ID', () {
      final cycles = [
        TestFixtures.createTrainingCycle(id: 'c1', name: 'First'),
        TestFixtures.createTrainingCycle(id: 'c2', name: 'Second'),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final cycle = container.read(trainingCycleProvider('c2'));
      expect(cycle, isNotNull);
      expect(cycle!.name, 'Second');
    });

    test('returns null for nonexistent ID', () {
      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(const AsyncValue.data([])),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(trainingCycleProvider('missing')), isNull);
    });
  });

  group('trainingCycleStatsProvider', () {
    test('returns correct counts by status', () {
      final cycles = [
        TestFixtures.createTrainingCycle(status: TrainingCycleStatus.draft),
        TestFixtures.createTrainingCycle(status: TrainingCycleStatus.draft),
        TestFixtures.createTrainingCycle(status: TrainingCycleStatus.current),
        TestFixtures.createTrainingCycle(
          status: TrainingCycleStatus.completed,
        ),
        TestFixtures.createTrainingCycle(
          status: TrainingCycleStatus.completed,
        ),
        TestFixtures.createTrainingCycle(
          status: TrainingCycleStatus.completed,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(AsyncValue.data(cycles)),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(trainingCycleStatsProvider);
      expect(stats['total'], equals(6));
      expect(stats['draft'], equals(2));
      expect(stats['active'], equals(1));
      expect(stats['completed'], equals(3));
    });

    test('returns zeros on empty', () {
      final container = ProviderContainer(
        overrides: [
          trainingCyclesProvider.overrideWithValue(const AsyncValue.data([])),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(trainingCycleStatsProvider);
      expect(stats['total'], equals(0));
    });
  });
}
