import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/core/utils/session_order.dart';
import 'package:yawa4u/data/models/cardio_detail.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_set.dart';
import 'package:yawa4u/data/models/session.dart';

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

StrengthSession _strength({
  required String id,
  WorkoutStatus status = WorkoutStatus.incomplete,
  DateTime? completedDate,
  DateTime? startTime,
  DateTime? scheduledDate,
  List<Exercise> exercises = const [],
}) {
  return StrengthSession(
    id: id,
    trainingCycleId: null,
    source: SessionSource.userLogged,
    status: status,
    completedDate: completedDate,
    startTime: startTime,
    scheduledDate: scheduledDate,
    exercises: exercises,
  );
}

CardioSession _cardio({
  required String id,
  WorkoutStatus status = WorkoutStatus.incomplete,
  DateTime? completedDate,
  DateTime? startTime,
  DateTime? scheduledDate,
  Sport sport = Sport.run,
  SessionSource source = SessionSource.userLogged,
}) {
  return CardioSession(
    id: id,
    trainingCycleId: null,
    sport: sport,
    source: source,
    status: status,
    completedDate: completedDate,
    startTime: startTime,
    scheduledDate: scheduledDate,
    detail: const CardioDetail(),
  );
}

Exercise _exerciseWithLoggedSet({String id = 'e'}) {
  return Exercise(
    id: id,
    workoutId: 'w',
    name: 'Bench',
    muscleGroup: MuscleGroup.chest,
    equipmentType: EquipmentType.barbell,
    sets: [
      ExerciseSet(
        id: '${id}_s1',
        setNumber: 1,
        weight: 100,
        reps: '5',
        isLogged: true,
      ),
    ],
    orderIndex: 0,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('sortByPerformedOrder', () {
    test('returns an empty list for no input', () {
      expect(sortByPerformedOrder(const []), isEmpty);
    });

    test('bucket order: completed → in-progress → planned', () {
      final completed = _strength(
        id: 'a_completed',
        status: WorkoutStatus.completed,
        completedDate: DateTime(2026, 4, 22, 10),
      );
      final inProgress = _cardio(
        id: 'b_in_progress',
        startTime: DateTime(2026, 4, 22, 8),
      );
      final planned = _strength(
        id: 'c_planned',
        scheduledDate: DateTime(2026, 4, 23),
      );

      final result = sortByPerformedOrder([planned, inProgress, completed]);

      expect(result.map((s) => s.id).toList(), [
        'a_completed',
        'b_in_progress',
        'c_planned',
      ]);
    });

    test('completed bucket sorts by completedDate ascending', () {
      final earlier = _strength(
        id: 'early',
        status: WorkoutStatus.completed,
        completedDate: DateTime(2026, 4, 22, 8),
      );
      final later = _cardio(
        id: 'late',
        status: WorkoutStatus.completed,
        completedDate: DateTime(2026, 4, 22, 18),
      );

      final result = sortByPerformedOrder([later, earlier]);

      expect(result.map((s) => s.id).toList(), ['early', 'late']);
    });

    test('in-progress bucket sorts by startTime ascending', () {
      final earlier = _cardio(
        id: 'early',
        startTime: DateTime(2026, 4, 22, 8),
      );
      final later = _strength(
        id: 'late',
        startTime: DateTime(2026, 4, 22, 10),
      );

      final result = sortByPerformedOrder([later, earlier]);

      expect(result.map((s) => s.id).toList(), ['early', 'late']);
    });

    test(
      'strength session with a logged set counts as in-progress',
      () {
        final inProgressStrength = _strength(
          id: 'lifting_now',
          exercises: [_exerciseWithLoggedSet()],
        );
        final pureplanned = _strength(
          id: 'planned',
          scheduledDate: DateTime(2026, 4, 22),
        );

        final result = sortByPerformedOrder([pureplanned, inProgressStrength]);

        expect(result.map((s) => s.id).toList(), [
          'lifting_now',
          'planned',
        ]);
      },
    );

    test('planned bucket sorts by scheduledDate then id', () {
      final april22 = _strength(
        id: 'a',
        scheduledDate: DateTime(2026, 4, 22),
      );
      final april23 = _strength(
        id: 'b',
        scheduledDate: DateTime(2026, 4, 23),
      );
      final noSchedule1 = _strength(id: 'z_no_schedule');
      final noSchedule2 = _strength(id: 'y_no_schedule');

      final result = sortByPerformedOrder(
        [april23, noSchedule1, april22, noSchedule2],
      );

      expect(result.map((s) => s.id).toList(), [
        'a',
        'b',
        'y_no_schedule',
        'z_no_schedule',
      ]);
    });

    test(
      'mixed list preserves all three buckets in the expected order',
      () {
        final c1 = _strength(
          id: 'c1',
          status: WorkoutStatus.completed,
          completedDate: DateTime(2026, 4, 22, 7),
        );
        final c2 = _cardio(
          id: 'c2',
          status: WorkoutStatus.completed,
          completedDate: DateTime(2026, 4, 22, 11),
        );
        final ip = _cardio(
          id: 'ip',
          startTime: DateTime(2026, 4, 22, 9),
        );
        final p1 = _strength(
          id: 'p1',
          scheduledDate: DateTime(2026, 4, 22, 18),
        );
        final p2 = _cardio(
          id: 'p2',
          scheduledDate: DateTime(2026, 4, 22, 19),
        );

        final result = sortByPerformedOrder([p2, c2, ip, p1, c1]);

        expect(result.map((s) => s.id).toList(), [
          'c1',
          'c2',
          'ip',
          'p1',
          'p2',
        ]);
      },
    );
  });
}
