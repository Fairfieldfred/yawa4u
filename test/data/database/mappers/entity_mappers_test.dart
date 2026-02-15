import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/database/mappers/entity_mappers.dart';
import 'package:yawa4u/data/models/exercise_feedback.dart' as model;

import '../../../helpers/test_fixtures.dart';

void main() {
  group('TrainingCycleMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final cycle = TestFixtures.createTrainingCycle(
          id: 'cycle-1',
          name: 'Test Cycle',
          periodsTotal: 6,
          daysPerPeriod: 5,
          recoveryPeriod: 1,
          status: TrainingCycleStatus.current,
          gender: Gender.male,
          muscleGroupPriorities: {'Chest': 3, 'Back': 2},
          templateName: 'PPL',
          notes: 'Some notes',
          recoveryPeriodType: RecoveryPeriodType.deload,
        );

        final companion = TrainingCycleMapper.toCompanion(cycle);

        expect(companion.uuid.value, equals('cycle-1'));
        expect(companion.name.value, equals('Test Cycle'));
        expect(companion.periodsTotal.value, equals(6));
        expect(companion.daysPerPeriod.value, equals(5));
        expect(companion.recoveryPeriod.value, equals(1));
        expect(companion.status.value, equals(TrainingCycleStatus.current.index));
        expect(companion.gender.value, equals(Gender.male.index));
        expect(companion.templateName.value, equals('PPL'));
        expect(companion.notes.value, equals('Some notes'));
        expect(
          companion.recoveryPeriodType.value,
          equals(RecoveryPeriodType.deload.index),
        );

        // Verify muscle group priorities are JSON encoded
        final decoded = jsonDecode(companion.muscleGroupPriorities.value!)
            as Map<String, dynamic>;
        expect(decoded['Chest'], equals(3));
        expect(decoded['Back'], equals(2));
      });

      test('handles null optional fields', () {
        final cycle = TestFixtures.createTrainingCycle(
          gender: null,
          muscleGroupPriorities: null,
          templateName: null,
          notes: null,
        );

        final companion = TrainingCycleMapper.toCompanion(cycle);

        expect(companion.gender.value, isNull);
        // recoveryPeriod defaults to periodsTotal (4) when not provided
        expect(companion.recoveryPeriod.value, equals(4));
        expect(companion.muscleGroupPriorities.value, isNull);
        expect(companion.templateName.value, isNull);
        expect(companion.notes.value, isNull);
      });
    });
  });

  group('WorkoutMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final workout = TestFixtures.createWorkout(
          id: 'workout-1',
          trainingCycleId: 'cycle-1',
          periodNumber: 2,
          dayNumber: 3,
          dayName: 'Pull Day',
          label: 'Back',
          status: WorkoutStatus.completed,
          notes: 'Great session',
        );

        final companion = WorkoutMapper.toCompanion(workout);

        expect(companion.uuid.value, equals('workout-1'));
        expect(companion.trainingCycleUuid.value, equals('cycle-1'));
        expect(companion.periodNumber.value, equals(2));
        expect(companion.dayNumber.value, equals(3));
        expect(companion.dayName.value, equals('Pull Day'));
        expect(companion.label.value, equals('Back'));
        expect(
          companion.status.value,
          equals(WorkoutStatus.completed.index),
        );
        expect(companion.notes.value, equals('Great session'));
      });

      test('handles null optional fields', () {
        final workout = TestFixtures.createWorkout(
          dayName: null,
          notes: null,
        );

        final companion = WorkoutMapper.toCompanion(workout);

        expect(companion.dayName.value, isNull);
        expect(companion.notes.value, isNull);
      });
    });
  });

  group('ExerciseMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final exercise = TestFixtures.createExercise(
          id: 'ex-1',
          workoutId: 'workout-1',
          name: 'Barbell Row',
          muscleGroup: MuscleGroup.back,
          secondaryMuscleGroup: MuscleGroup.biceps,
          equipmentType: EquipmentType.barbell,
          orderIndex: 2,
          bodyweight: 180.0,
          notes: 'Focus on squeeze',
          isNotePinned: true,
        );

        final companion = ExerciseMapper.toCompanion(exercise);

        expect(companion.uuid.value, equals('ex-1'));
        expect(companion.workoutUuid.value, equals('workout-1'));
        expect(companion.name.value, equals('Barbell Row'));
        expect(companion.muscleGroup.value, equals(MuscleGroup.back.index));
        expect(
          companion.secondaryMuscleGroup.value,
          equals(MuscleGroup.biceps.index),
        );
        expect(
          companion.equipmentType.value,
          equals(EquipmentType.barbell.index),
        );
        expect(companion.orderIndex.value, equals(2));
        expect(companion.bodyweight.value, equals(180.0));
        expect(companion.notes.value, equals('Focus on squeeze'));
        expect(companion.isNotePinned.value, isTrue);
      });

      test('handles null secondary muscle group', () {
        final exercise = TestFixtures.createExercise(
          secondaryMuscleGroup: null,
        );
        final companion = ExerciseMapper.toCompanion(exercise);
        expect(companion.secondaryMuscleGroup.value, isNull);
      });

      test('handles null bodyweight', () {
        final exercise = TestFixtures.createExercise(bodyweight: null);
        final companion = ExerciseMapper.toCompanion(exercise);
        expect(companion.bodyweight.value, isNull);
      });
    });
  });

  group('ExerciseSetMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final set = TestFixtures.createExerciseSet(
          id: 'set-1',
          setNumber: 3,
          weight: 225.0,
          reps: '2 RIR',
          setType: SetType.myorep,
          isLogged: true,
          notes: 'PR attempt',
          isSkipped: false,
        );

        final companion = ExerciseSetMapper.toCompanion(set, 'ex-1');

        expect(companion.uuid.value, equals('set-1'));
        expect(companion.exerciseUuid.value, equals('ex-1'));
        expect(companion.setNumber.value, equals(3));
        expect(companion.weight.value, equals(225.0));
        expect(companion.reps.value, equals('2 RIR'));
        expect(companion.setType.value, equals(SetType.myorep.index));
        expect(companion.isLogged.value, isTrue);
        expect(companion.notes.value, equals('PR attempt'));
        expect(companion.isSkipped.value, isFalse);
      });

      test('handles null weight', () {
        final set = TestFixtures.createExerciseSet(weight: null);
        final companion = ExerciseSetMapper.toCompanion(set, 'ex-1');
        expect(companion.weight.value, isNull);
      });
    });
  });

  group('ExerciseFeedbackMapper', () {
    group('toCompanion', () {
      test('converts all fields to companion', () {
        final feedback = TestFixtures.createFeedback(
          jointPain: JointPain.low,
          musclePump: MusclePump.amazing,
          workload: Workload.pushedLimits,
          soreness: Soreness.healedJustOnTime,
          muscleGroupSoreness: {
            'chest': Soreness.healedAWhileAgo,
            'triceps': Soreness.stillSore,
          },
        );

        final companion = ExerciseFeedbackMapper.toCompanion(feedback, 'ex-1');

        expect(companion.exerciseUuid.value, equals('ex-1'));
        expect(companion.jointPain.value, equals(JointPain.low.index));
        expect(companion.musclePump.value, equals(MusclePump.amazing.index));
        expect(companion.workload.value, equals(Workload.pushedLimits.index));
        expect(
          companion.soreness.value,
          equals(Soreness.healedJustOnTime.index),
        );

        // Verify muscle group soreness JSON encoding
        final decoded =
            jsonDecode(companion.muscleGroupSoreness.value!) as Map<String, dynamic>;
        expect(
          decoded['chest'],
          equals(Soreness.healedAWhileAgo.index),
        );
        expect(
          decoded['triceps'],
          equals(Soreness.stillSore.index),
        );
      });

      test('handles all null feedback fields', () {
        final feedback = model.ExerciseFeedback();
        final companion = ExerciseFeedbackMapper.toCompanion(feedback, 'ex-1');

        expect(companion.jointPain.value, isNull);
        expect(companion.musclePump.value, isNull);
        expect(companion.workload.value, isNull);
        expect(companion.soreness.value, isNull);
        expect(companion.muscleGroupSoreness.value, isNull);
      });
    });
  });

  group('Enum index round-trip consistency', () {
    test('all SetType indices are valid', () {
      for (var i = 0; i < SetType.values.length; i++) {
        expect(SetType.values[i].index, equals(i));
      }
    });

    test('all MuscleGroup indices are valid', () {
      for (var i = 0; i < MuscleGroup.values.length; i++) {
        expect(MuscleGroup.values[i].index, equals(i));
      }
    });

    test('all EquipmentType indices are valid', () {
      for (var i = 0; i < EquipmentType.values.length; i++) {
        expect(EquipmentType.values[i].index, equals(i));
      }
    });

    test('all TrainingCycleStatus indices are valid', () {
      for (var i = 0; i < TrainingCycleStatus.values.length; i++) {
        expect(TrainingCycleStatus.values[i].index, equals(i));
      }
    });

    test('all WorkoutStatus indices are valid', () {
      for (var i = 0; i < WorkoutStatus.values.length; i++) {
        expect(WorkoutStatus.values[i].index, equals(i));
      }
    });

    test('all JointPain indices are valid', () {
      for (var i = 0; i < JointPain.values.length; i++) {
        expect(JointPain.values[i].index, equals(i));
      }
    });

    test('all MusclePump indices are valid', () {
      for (var i = 0; i < MusclePump.values.length; i++) {
        expect(MusclePump.values[i].index, equals(i));
      }
    });

    test('all Workload indices are valid', () {
      for (var i = 0; i < Workload.values.length; i++) {
        expect(Workload.values[i].index, equals(i));
      }
    });

    test('all Soreness indices are valid', () {
      for (var i = 0; i < Soreness.values.length; i++) {
        expect(Soreness.values[i].index, equals(i));
      }
    });
  });
}
