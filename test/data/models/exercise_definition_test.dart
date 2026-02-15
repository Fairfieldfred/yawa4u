import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/exercise_definition.dart';

void main() {
  group('ExerciseDefinition', () {
    group('fromCsv', () {
      test('parses a standard row', () {
        final def = ExerciseDefinition.fromCsv(['Bench Press', 'Chest', 'Barbell']);
        expect(def.name, equals('Bench Press'));
        expect(def.muscleGroup, equals(MuscleGroup.chest));
        expect(def.secondaryMuscleGroup, isNull);
        expect(def.equipmentType, equals(EquipmentType.barbell));
      });

      test('trims whitespace from all fields', () {
        final def = ExerciseDefinition.fromCsv([
          '  Bench Press  ',
          '  Chest  ',
          '  Barbell  ',
        ]);
        expect(def.name, equals('Bench Press'));
        expect(def.muscleGroup, equals(MuscleGroup.chest));
        expect(def.equipmentType, equals(EquipmentType.barbell));
      });

      test('parses compound muscle group with "/"', () {
        final def = ExerciseDefinition.fromCsv([
          'Romanian Deadlift',
          'Glutes/Hamstrings',
          'Barbell',
        ]);
        expect(def.muscleGroup, equals(MuscleGroup.glutes));
        expect(def.secondaryMuscleGroup, equals(MuscleGroup.hamstrings));
      });

      test('trims whitespace around "/" in compound muscle group', () {
        final def = ExerciseDefinition.fromCsv([
          'Hip Thrust',
          ' Glutes / Hamstrings ',
          'Barbell',
        ]);
        expect(def.muscleGroup, equals(MuscleGroup.glutes));
        expect(def.secondaryMuscleGroup, equals(MuscleGroup.hamstrings));
      });

      test('handles invalid secondary muscle group gracefully', () {
        final def = ExerciseDefinition.fromCsv([
          'Exercise',
          'Chest/InvalidGroup',
          'Barbell',
        ]);
        expect(def.muscleGroup, equals(MuscleGroup.chest));
        // Invalid secondary returns null (doesn't throw)
        expect(def.secondaryMuscleGroup, isNull);
      });

      test('handles empty secondary after "/"', () {
        final def = ExerciseDefinition.fromCsv([
          'Exercise',
          'Chest/',
          'Barbell',
        ]);
        expect(def.muscleGroup, equals(MuscleGroup.chest));
        expect(def.secondaryMuscleGroup, isNull);
      });

      test('throws for row with less than 3 columns', () {
        expect(
          () => ExerciseDefinition.fromCsv(['Bench Press', 'Chest']),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ExerciseDefinition.fromCsv(['Bench Press']),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => ExerciseDefinition.fromCsv([]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for invalid primary muscle group', () {
        expect(
          () => ExerciseDefinition.fromCsv([
            'Exercise',
            'InvalidGroup',
            'Barbell',
          ]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws for invalid equipment type', () {
        expect(
          () => ExerciseDefinition.fromCsv([
            'Exercise',
            'Chest',
            'InvalidEquipment',
          ]),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('parses all equipment types', () {
        for (final type in EquipmentType.values) {
          final def = ExerciseDefinition.fromCsv([
            'Exercise',
            'Chest',
            type.displayName,
          ]);
          expect(def.equipmentType, equals(type));
        }
      });

      test('parses all muscle groups', () {
        for (final group in MuscleGroup.values) {
          final def = ExerciseDefinition.fromCsv([
            'Exercise',
            group.displayName,
            'Barbell',
          ]);
          expect(def.muscleGroup, equals(group));
        }
      });
    });

    group('toCsv', () {
      test('converts to CSV row without secondary', () {
        final def = const ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        expect(def.toCsv(), equals(['Bench Press', 'Chest', 'Barbell']));
      });

      test('converts to CSV row with secondary', () {
        final def = const ExerciseDefinition(
          name: 'RDL',
          muscleGroup: MuscleGroup.glutes,
          secondaryMuscleGroup: MuscleGroup.hamstrings,
          equipmentType: EquipmentType.barbell,
        );
        expect(def.toCsv(), equals(['RDL', 'Glutes/Hamstrings', 'Barbell']));
      });
    });

    group('JSON round-trip', () {
      test('serializes and deserializes without secondary', () {
        final original = const ExerciseDefinition(
          name: 'Pull Up',
          muscleGroup: MuscleGroup.back,
          equipmentType: EquipmentType.bodyweightLoadable,
          videoUrl: 'https://example.com/video',
        );
        final json = original.toJson();
        final restored = ExerciseDefinition.fromJson(json);
        expect(restored.name, equals(original.name));
        expect(restored.muscleGroup, equals(original.muscleGroup));
        expect(restored.secondaryMuscleGroup, isNull);
        expect(restored.equipmentType, equals(original.equipmentType));
        expect(restored.videoUrl, equals(original.videoUrl));
      });

      test('serializes and deserializes with secondary', () {
        final original = const ExerciseDefinition(
          name: 'Deadlift',
          muscleGroup: MuscleGroup.glutes,
          secondaryMuscleGroup: MuscleGroup.hamstrings,
          equipmentType: EquipmentType.barbell,
        );
        final json = original.toJson();
        final restored = ExerciseDefinition.fromJson(json);
        expect(restored.secondaryMuscleGroup, equals(MuscleGroup.hamstrings));
      });
    });

    group('equality', () {
      test('equal definitions are equal', () {
        const a = ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        const b = ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different names are not equal', () {
        const a = ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        const b = ExerciseDefinition(
          name: 'Incline Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        expect(a, isNot(equals(b)));
      });

      test('different secondary muscle groups are not equal', () {
        const a = ExerciseDefinition(
          name: 'Exercise',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        const b = ExerciseDefinition(
          name: 'Exercise',
          muscleGroup: MuscleGroup.chest,
          secondaryMuscleGroup: MuscleGroup.triceps,
          equipmentType: EquipmentType.barbell,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with no changes returns equal object', () {
        const original = ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('copies with changed name', () {
        const original = ExerciseDefinition(
          name: 'Bench Press',
          muscleGroup: MuscleGroup.chest,
          equipmentType: EquipmentType.barbell,
        );
        final copy = original.copyWith(name: 'Incline Press');
        expect(copy.name, equals('Incline Press'));
        expect(copy.muscleGroup, equals(MuscleGroup.chest));
      });
    });
  });
}
