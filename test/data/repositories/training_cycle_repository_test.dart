import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late TrainingCycleRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TrainingCycleRepository(db.trainingCycleDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD', () {
    test('create and getById', () async {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        name: 'Push Pull Legs',
      );
      await repo.create(cycle);

      final loaded = await repo.getById('c1');
      expect(loaded, isNotNull);
      expect(loaded!.name, equals('Push Pull Legs'));
      expect(loaded.status, equals(TrainingCycleStatus.draft));
    });

    test('getById returns null for nonexistent', () async {
      final loaded = await repo.getById('nonexistent');
      expect(loaded, isNull);
    });

    test('getAll returns cycles sorted by creation date', () async {
      final older = TestFixtures.createTrainingCycle(
        id: 'c1',
        name: 'Older',
        createdDate: DateTime(2024, 1, 1),
      );
      final newer = TestFixtures.createTrainingCycle(
        id: 'c2',
        name: 'Newer',
        createdDate: DateTime(2024, 6, 1),
      );
      await repo.create(older);
      await repo.create(newer);

      final all = await repo.getAll();
      expect(all, hasLength(2));
      // Newest first
      expect(all.first.name, equals('Newer'));
    });

    test('update modifies cycle', () async {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        name: 'Original',
      );
      await repo.create(cycle);

      final updated = cycle.copyWith(name: 'Updated');
      await repo.update(updated);

      final loaded = await repo.getById('c1');
      expect(loaded!.name, equals('Updated'));
    });

    test('delete removes cycle', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'c1');
      await repo.create(cycle);
      await repo.delete('c1');

      expect(await repo.getById('c1'), isNull);
    });

    test('deleteAll clears all cycles', () async {
      await repo.create(TestFixtures.createTrainingCycle(id: 'c1'));
      await repo.create(TestFixtures.createTrainingCycle(id: 'c2'));
      await repo.deleteAll();

      final all = await repo.getAll();
      expect(all, isEmpty);
    });
  });

  group('Status filtering', () {
    test('getByStatus returns matching cycles', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.draft,
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.completed,
        ),
      );

      final drafts = await repo.getByStatus(TrainingCycleStatus.draft);
      expect(drafts, hasLength(1));
      expect(drafts.first.id, equals('c1'));
    });

    test('getDrafts returns draft cycles', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.draft,
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.completed,
        ),
      );

      final drafts = await repo.getDrafts();
      expect(drafts, hasLength(1));
      expect(drafts.first.id, equals('c1'));
    });

    test('getCompleted returns completed cycles', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.completed,
        ),
      );

      final completed = await repo.getCompleted();
      expect(completed, hasLength(1));
    });

    test('getCurrent returns active cycle', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
        ),
      );

      final current = await repo.getCurrent();
      expect(current, isNotNull);
      expect(current!.id, equals('c1'));
    });

    test('getCurrent returns null when no active cycle', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.draft,
        ),
      );

      final current = await repo.getCurrent();
      expect(current, isNull);
    });
  });

  group('Status transitions', () {
    test('setAsCurrent activates cycle and deactivates others', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.draft,
        ),
      );

      await repo.setAsCurrent('c2');

      final c1 = await repo.getById('c1');
      final c2 = await repo.getById('c2');
      // c1 was deactivated
      expect(c1!.status, isNot(equals(TrainingCycleStatus.current)));
      // c2 is now current
      expect(c2!.status, equals(TrainingCycleStatus.current));
    });

    test('stackAsCurrent activates without deactivating others', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          status: TrainingCycleStatus.draft,
        ),
      );

      await repo.stackAsCurrent('c2');

      final c1 = await repo.getById('c1');
      final c2 = await repo.getById('c2');
      // Both should be current
      expect(c1!.status, equals(TrainingCycleStatus.current));
      expect(c2!.status, equals(TrainingCycleStatus.current));
    });

    test('complete marks cycle as completed', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          status: TrainingCycleStatus.current,
        ),
      );

      await repo.complete('c1');
      final loaded = await repo.getById('c1');
      expect(loaded!.status, equals(TrainingCycleStatus.completed));
    });
  });

  group('Search', () {
    test('searchByName finds matching cycles', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          name: 'Push Pull Legs',
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          name: 'Upper Lower',
        ),
      );

      final results = await repo.searchByName('Push');
      expect(results, hasLength(1));
      expect(results.first.name, equals('Push Pull Legs'));
    });

    test('searchByName with empty query returns all', () async {
      await repo.create(TestFixtures.createTrainingCycle(id: 'c1'));
      await repo.create(TestFixtures.createTrainingCycle(id: 'c2'));

      final results = await repo.searchByName('');
      expect(results, hasLength(2));
    });

    test('getByTemplate filters by template name', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          templateName: 'PPL Standard',
        ),
      );
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c2',
          templateName: 'Upper Lower',
        ),
      );

      final results = await repo.getByTemplate('PPL Standard');
      expect(results, hasLength(1));
      expect(results.first.id, equals('c1'));
    });
  });

  group('Duplication', () {
    test('duplicate creates new draft cycle', () async {
      await repo.create(
        TestFixtures.createTrainingCycle(
          id: 'c1',
          name: 'Original',
          periodsTotal: 6,
          daysPerPeriod: 4,
          status: TrainingCycleStatus.completed,
        ),
      );

      final duplicated = await repo.duplicate('c1', 'Copy of Original');
      expect(duplicated.name, equals('Copy of Original'));
      expect(duplicated.status, equals(TrainingCycleStatus.draft));
      expect(duplicated.periodsTotal, equals(6));
      expect(duplicated.daysPerPeriod, equals(4));
      expect(duplicated.id, isNot(equals('c1')));

      // Verify it was persisted
      final loaded = await repo.getById(duplicated.id);
      expect(loaded, isNotNull);
    });

    test('duplicate throws for nonexistent cycle', () async {
      expect(
        () => repo.duplicate('nonexistent', 'Copy'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Stream', () {
    test('watchAll emits on changes', () async {
      final stream = repo.watchAll();
      final first = await stream.first;
      expect(first, isEmpty);

      await repo.create(TestFixtures.createTrainingCycle(id: 'c1'));
      final second = await stream.first;
      expect(second, hasLength(1));
    });
  });

  group('Count', () {
    test('count returns correct value', () async {
      expect(await repo.count(), equals(0));

      await repo.create(TestFixtures.createTrainingCycle(id: 'c1'));
      await repo.create(TestFixtures.createTrainingCycle(id: 'c2'));

      expect(await repo.count(), equals(2));
    });
  });
}
