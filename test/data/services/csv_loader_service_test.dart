import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/services/csv_loader_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CsvLoaderService service;

  setUp(() {
    service = CsvLoaderService();
    service.clear(); // Reset singleton state
  });

  group('CsvLoaderService', () {
    group('loadExercises', () {
      test('loads exercises from CSV successfully', () async {
        await service.loadExercises();

        expect(service.isLoaded, isTrue);
        expect(service.exerciseCount, greaterThan(0));
        expect(service.exercises, isNotEmpty);
      });

      test('does not reload if already loaded', () async {
        await service.loadExercises();
        final count = service.exerciseCount;

        // Second load should be a no-op
        await service.loadExercises();
        expect(service.exerciseCount, equals(count));
      });
    });

    group('after loading', () {
      setUp(() async {
        await service.loadExercises();
      });

      group('searchByName', () {
        test('finds exercises by partial name match', () {
          final results = service.searchByName('bench');
          expect(results, isNotEmpty);
          expect(
            results.every(
              (e) => e.name.toLowerCase().contains('bench'),
            ),
            isTrue,
          );
        });

        test('is case insensitive', () {
          final lower = service.searchByName('bench');
          final upper = service.searchByName('BENCH');
          expect(lower.length, equals(upper.length));
        });

        test('returns all exercises for empty query', () {
          final results = service.searchByName('');
          expect(results.length, equals(service.exerciseCount));
        });

        test('returns empty list for no matches', () {
          final results = service.searchByName('xyznonexistent');
          expect(results, isEmpty);
        });
      });

      group('filterByMuscleGroup', () {
        test('returns exercises for a valid muscle group', () {
          final results = service.filterByMuscleGroup(MuscleGroup.chest);
          expect(results, isNotEmpty);
          expect(
            results.every((e) => e.muscleGroup == MuscleGroup.chest),
            isTrue,
          );
        });

        test('returns exercises for each muscle group in the library', () {
          final grouped = service.groupByMuscleGroup();
          for (final group in grouped.keys) {
            final results = service.filterByMuscleGroup(group);
            expect(results.length, equals(grouped[group]!.length));
          }
        });
      });

      group('filterByEquipment', () {
        test('returns exercises for a valid equipment type', () {
          final results = service.filterByEquipment(EquipmentType.barbell);
          expect(results, isNotEmpty);
          expect(
            results.every((e) => e.equipmentType == EquipmentType.barbell),
            isTrue,
          );
        });
      });

      group('filter (combined)', () {
        test('filters by search query', () {
          final results = service.filter(searchQuery: 'press');
          expect(results, isNotEmpty);
          expect(
            results.every(
              (e) => e.name.toLowerCase().contains('press'),
            ),
            isTrue,
          );
        });

        test('filters by muscle group', () {
          final results = service.filter(muscleGroup: MuscleGroup.back);
          expect(results, isNotEmpty);
          expect(
            results.every((e) => e.muscleGroup == MuscleGroup.back),
            isTrue,
          );
        });

        test('filters by equipment type', () {
          final results = service.filter(
            equipmentType: EquipmentType.dumbbell,
          );
          expect(results, isNotEmpty);
          expect(
            results.every((e) => e.equipmentType == EquipmentType.dumbbell),
            isTrue,
          );
        });

        test('combines multiple filters', () {
          final results = service.filter(
            muscleGroup: MuscleGroup.chest,
            equipmentType: EquipmentType.barbell,
          );
          expect(
            results.every(
              (e) =>
                  e.muscleGroup == MuscleGroup.chest &&
                  e.equipmentType == EquipmentType.barbell,
            ),
            isTrue,
          );
        });

        test('returns all exercises when no filters', () {
          final results = service.filter();
          expect(results.length, equals(service.exerciseCount));
        });
      });

      group('groupByMuscleGroup', () {
        test('groups all exercises', () {
          final grouped = service.groupByMuscleGroup();
          expect(grouped, isNotEmpty);

          var totalCount = 0;
          for (final list in grouped.values) {
            totalCount += list.length;
          }
          expect(totalCount, equals(service.exerciseCount));
        });
      });

      group('groupByEquipmentType', () {
        test('groups all exercises', () {
          final grouped = service.groupByEquipmentType();
          expect(grouped, isNotEmpty);

          var totalCount = 0;
          for (final list in grouped.values) {
            totalCount += list.length;
          }
          expect(totalCount, equals(service.exerciseCount));
        });
      });

      group('getByName', () {
        test('finds exercise by exact name (case insensitive)', () {
          final exercise = service.getByName('Bench Press');
          expect(exercise, isNotNull);
          expect(exercise!.name, equals('Bench Press'));
        });

        test('returns null for unknown name', () {
          final exercise = service.getByName('NonExistentExercise123');
          expect(exercise, isNull);
        });
      });

      group('getCountByMuscleGroup', () {
        test('returns count for a muscle group', () {
          final count = service.getCountByMuscleGroup(MuscleGroup.chest);
          expect(count, greaterThan(0));

          final exercises = service.filterByMuscleGroup(MuscleGroup.chest);
          expect(count, equals(exercises.length));
        });
      });

      group('getCountByEquipmentType', () {
        test('returns count for an equipment type', () {
          final count = service.getCountByEquipmentType(EquipmentType.barbell);
          expect(count, greaterThan(0));

          final exercises = service.filterByEquipment(EquipmentType.barbell);
          expect(count, equals(exercises.length));
        });
      });

      group('compound muscle groups', () {
        test('exercises with secondary muscle groups exist', () {
          final withSecondary = service.exercises
              .where((e) => e.secondaryMuscleGroup != null)
              .toList();
          expect(withSecondary, isNotEmpty,
              reason: 'CSV should contain compound muscle group exercises');
        });

        test('kettlebell exercises exist', () {
          final kettlebell = service.filterByEquipment(EquipmentType.kettlebell);
          expect(kettlebell, isNotEmpty,
              reason: 'CSV should contain kettlebell exercises');
        });
      });
    });

    group('before loading', () {
      test('exercises getter throws when not loaded', () {
        expect(() => service.exercises, throwsStateError);
      });

      test('searchByName returns empty when not loaded', () {
        expect(service.searchByName('bench'), isEmpty);
      });

      test('filterByMuscleGroup returns empty when not loaded', () {
        expect(service.filterByMuscleGroup(MuscleGroup.chest), isEmpty);
      });

      test('filterByEquipment returns empty when not loaded', () {
        expect(service.filterByEquipment(EquipmentType.barbell), isEmpty);
      });

      test('exerciseCount is 0 when not loaded', () {
        expect(service.exerciseCount, equals(0));
      });

      test('getByName returns null when not loaded', () {
        expect(service.getByName('Bench Press'), isNull);
      });
    });

    group('clear', () {
      test('resets loaded state', () async {
        await service.loadExercises();
        expect(service.isLoaded, isTrue);

        service.clear();
        expect(service.isLoaded, isFalse);
        expect(service.exerciseCount, equals(0));
      });
    });
  });
}
