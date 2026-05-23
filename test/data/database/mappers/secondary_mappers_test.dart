import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/database/mappers/secondary_mappers.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('CustomExerciseMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final now = DateTime(2024, 6, 15);
        final exercise = TestFixtures.createCustomExerciseDefinition(
          id: 'ce-1',
          name: 'Custom Incline Press',
          muscleGroup: MuscleGroup.chest,
          secondaryMuscleGroup: MuscleGroup.triceps,
          equipmentType: EquipmentType.dumbbell,
          videoUrl: 'https://example.com/video.mp4',
          restSeconds: 90,
          createdAt: now,
        );

        final companion = CustomExerciseMapper.toCompanion(exercise);

        expect(companion.uuid.value, equals('ce-1'));
        expect(companion.name.value, equals('Custom Incline Press'));
        expect(
          companion.muscleGroup.value,
          equals(MuscleGroup.chest.index),
        );
        expect(
          companion.secondaryMuscleGroup.value,
          equals(MuscleGroup.triceps.index),
        );
        expect(
          companion.equipmentType.value,
          equals(EquipmentType.dumbbell.index),
        );
        expect(
          companion.videoUrl.value,
          equals('https://example.com/video.mp4'),
        );
        expect(companion.restSeconds.value, equals(90));
        expect(companion.createdAt.value, equals(now));
      });

      test('handles null secondary muscle group', () {
        final exercise = TestFixtures.createCustomExerciseDefinition(
          secondaryMuscleGroup: null,
        );
        final companion = CustomExerciseMapper.toCompanion(exercise);
        expect(companion.secondaryMuscleGroup.value, isNull);
      });

      test('handles null optional fields', () {
        final exercise = TestFixtures.createCustomExerciseDefinition(
          videoUrl: null,
          restSeconds: null,
          // createdAt defaults to DateTime.now() — non-nullable
        );

        final companion = CustomExerciseMapper.toCompanion(exercise);

        expect(companion.videoUrl.value, isNull);
        expect(companion.restSeconds.value, isNull);
        expect(companion.createdAt.value, isNotNull);
      });

      test('maps all MuscleGroup enum values correctly', () {
        for (final mg in MuscleGroup.values) {
          final exercise = TestFixtures.createCustomExerciseDefinition(
            muscleGroup: mg,
          );
          final c = CustomExerciseMapper.toCompanion(exercise);
          expect(c.muscleGroup.value, equals(mg.index));
        }
      });

      test('maps all EquipmentType enum values correctly', () {
        for (final et in EquipmentType.values) {
          final exercise = TestFixtures.createCustomExerciseDefinition(
            equipmentType: et,
          );
          final c = CustomExerciseMapper.toCompanion(exercise);
          expect(c.equipmentType.value, equals(et.index));
        }
      });
    });
  });

  group('UserMeasurementMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final now = DateTime(2024, 6, 15);
        final measurement = TestFixtures.createUserMeasurement(
          id: 'um-1',
          heightCm: 182.5,
          weightKg: 84.3,
          timestamp: now,
          notes: 'Morning measurement',
          bodyFatPercent: 15.5,
          leanMassKg: 71.2,
        );

        final companion = UserMeasurementMapper.toCompanion(measurement);

        expect(companion.uuid.value, equals('um-1'));
        expect(companion.heightCm.value, equals(182.5));
        expect(companion.weightKg.value, equals(84.3));
        expect(companion.timestamp.value, equals(now));
        expect(companion.notes.value, equals('Morning measurement'));
        expect(companion.bodyFatPercent.value, equals(15.5));
        expect(companion.leanMassKg.value, equals(71.2));
      });

      test('handles null optional fields', () {
        final measurement = TestFixtures.createUserMeasurement(
          notes: null,
          bodyFatPercent: null,
          leanMassKg: null,
        );

        final companion = UserMeasurementMapper.toCompanion(measurement);

        expect(companion.notes.value, isNull);
        expect(companion.bodyFatPercent.value, isNull);
        expect(companion.leanMassKg.value, isNull);
      });
    });
  });
}
