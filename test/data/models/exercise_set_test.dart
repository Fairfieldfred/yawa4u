import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/models/exercise_set.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('ExerciseSet', () {
    group('construction', () {
      test('creates with required fields and defaults', () {
        final set = ExerciseSet(
          id: 'test-id',
          setNumber: 1,
          reps: '10',
        );
        expect(set.id, equals('test-id'));
        expect(set.setNumber, equals(1));
        expect(set.weight, isNull);
        expect(set.reps, equals('10'));
        expect(set.setType, equals(SetType.regular));
        expect(set.isLogged, isFalse);
        expect(set.notes, isNull);
        expect(set.isSkipped, isFalse);
      });

      test('creates with all fields', () {
        final set = ExerciseSet(
          id: 'test-id',
          setNumber: 2,
          weight: 135.0,
          reps: '2 RIR',
          setType: SetType.myorep,
          isLogged: true,
          notes: 'Felt great',
          isSkipped: false,
        );
        expect(set.weight, equals(135.0));
        expect(set.reps, equals('2 RIR'));
        expect(set.setType, equals(SetType.myorep));
        expect(set.isLogged, isTrue);
        expect(set.notes, equals('Felt great'));
      });
    });

    group('copyWith', () {
      test('copies with no changes returns equal object', () {
        final original = TestFixtures.createExerciseSet();
        final copy = original.copyWith();
        expect(copy, equals(original));
      });

      test('copies with changed weight', () {
        final original = TestFixtures.createExerciseSet(weight: 100.0);
        final copy = original.copyWith(weight: 135.0);
        expect(copy.weight, equals(135.0));
        expect(copy.reps, equals(original.reps));
      });

      test('copies with changed reps', () {
        final original = TestFixtures.createExerciseSet(reps: '10');
        final copy = original.copyWith(reps: '2 RIR');
        expect(copy.reps, equals('2 RIR'));
        expect(copy.weight, equals(original.weight));
      });

      test('copies with changed set type', () {
        final original = TestFixtures.createExerciseSet();
        final copy = original.copyWith(setType: SetType.dropSet);
        expect(copy.setType, equals(SetType.dropSet));
      });

      test('copies with changed log status', () {
        final original = TestFixtures.createExerciseSet(isLogged: false);
        final copy = original.copyWith(isLogged: true);
        expect(copy.isLogged, isTrue);
      });
    });

    group('equality', () {
      test('equal sets are equal', () {
        final a = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 100.0,
          reps: '10',
        );
        final b = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 100.0,
          reps: '10',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different IDs are not equal', () {
        final a = ExerciseSet(id: 'id-1', setNumber: 1, reps: '10');
        final b = ExerciseSet(id: 'id-2', setNumber: 1, reps: '10');
        expect(a, isNot(equals(b)));
      });

      test('different weights are not equal', () {
        final a = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 100.0,
          reps: '10',
        );
        final b = ExerciseSet(
          id: 'same-id',
          setNumber: 1,
          weight: 135.0,
          reps: '10',
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('includes key fields', () {
        final set = TestFixtures.createExerciseSet(
          setNumber: 2,
          weight: 100.0,
          reps: '10',
        );
        final str = set.toString();
        expect(str, contains('setNumber: 2'));
        expect(str, contains('weight: 100.0'));
        expect(str, contains('reps: 10'));
      });
    });
  });
}
