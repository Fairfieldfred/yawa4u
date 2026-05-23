import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/custom_exercise_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late CustomExerciseRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CustomExerciseRepository(db.customExerciseDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD', () {
    test('add and getById', () async {
      final exercise = TestFixtures.createCustomExerciseDefinition(
        id: 'ce1',
        name: 'Custom Curl',
        muscleGroup: MuscleGroup.biceps,
        equipmentType: EquipmentType.dumbbell,
      );
      await repo.add(exercise);

      final loaded = await repo.getById('ce1');
      expect(loaded, isNotNull);
      expect(loaded!.name, equals('Custom Curl'));
      expect(loaded.muscleGroup, equals(MuscleGroup.biceps));
    });

    test('getById returns null for nonexistent', () async {
      expect(await repo.getById('nonexistent'), isNull);
    });

    test('getAll returns sorted by name', () async {
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce1',
          name: 'Zottman Curl',
        ),
      );
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce2',
          name: 'Arnold Press',
        ),
      );
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce3',
          name: 'Cable Fly',
        ),
      );

      final all = await repo.getAll();
      expect(all, hasLength(3));
      expect(all[0].name, equals('Arnold Press'));
      expect(all[1].name, equals('Cable Fly'));
      expect(all[2].name, equals('Zottman Curl'));
    });

    test('update modifies exercise', () async {
      final exercise = TestFixtures.createCustomExerciseDefinition(
        id: 'ce1',
        name: 'Original',
      );
      await repo.add(exercise);

      final updated = exercise.copyWith(name: 'Updated');
      await repo.update(updated);

      final loaded = await repo.getById('ce1');
      expect(loaded!.name, equals('Updated'));
    });

    test('delete removes exercise', () async {
      await repo.add(TestFixtures.createCustomExerciseDefinition(id: 'ce1'));
      await repo.delete('ce1');
      expect(await repo.getById('ce1'), isNull);
    });

    test('deleteAll clears all', () async {
      await repo.add(TestFixtures.createCustomExerciseDefinition(id: 'ce1'));
      await repo.add(TestFixtures.createCustomExerciseDefinition(id: 'ce2'));
      await repo.deleteAll();
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('Name lookup', () {
    test('getByName case-insensitive', () async {
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce1',
          name: 'Custom Bench Press',
        ),
      );

      final found = await repo.getByName('custom bench press');
      expect(found, isNotNull);
      expect(found!.id, equals('ce1'));
    });

    test('getByName returns null when not found', () async {
      final found = await repo.getByName('Nonexistent');
      expect(found, isNull);
    });

    test('existsByName returns true for existing', () async {
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce1',
          name: 'Custom Curl',
        ),
      );

      expect(await repo.existsByName('Custom Curl'), isTrue);
      expect(await repo.existsByName('custom curl'), isTrue);
      expect(await repo.existsByName('Nonexistent'), isFalse);
    });
  });

  group('Stream', () {
    test('watchAll emits sorted list', () async {
      final stream = repo.watchAll();
      expect(await stream.first, isEmpty);

      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce1',
          name: 'Zottman Curl',
        ),
      );
      await repo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce2',
          name: 'Arnold Press',
        ),
      );

      final list = await stream.first;
      expect(list, hasLength(2));
      expect(list.first.name, equals('Arnold Press'));
    });
  });

  group('Count', () {
    test('count returns correct value', () async {
      expect(await repo.count(), equals(0));
      await repo.add(TestFixtures.createCustomExerciseDefinition(id: 'ce1'));
      await repo.add(TestFixtures.createCustomExerciseDefinition(id: 'ce2'));
      expect(await repo.count(), equals(2));
    });
  });
}
