import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_set.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/data/services/exercise_history_service.dart';

import '../../helpers/test_fixtures.dart';

/// Fake WorkoutRepository that returns a fixed list of workouts.
class FakeWorkoutRepository implements WorkoutRepository {
  final List<Workout> workouts;

  FakeWorkoutRepository(this.workouts);

  @override
  Future<List<Workout>> getAll() async => workouts;

  // Stubs for the rest of the interface — not used by ExerciseHistoryService
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  group('ExerciseHistoryService', () {
    late ExerciseHistoryService service;
    final currentExerciseId = 'current-ex-id';

    Workout _makeCompletedWorkout({
      required String exerciseName,
      required List<ExerciseSet> sets,
      DateTime? completedDate,
      String? exerciseId,
      EquipmentType equipmentType = EquipmentType.barbell,
    }) {
      return TestFixtures.createWorkout(
        status: WorkoutStatus.completed,
        completedDate: completedDate ?? DateTime(2024, 3, 1),
        exercises: [
          TestFixtures.createExercise(
            id: exerciseId ?? 'prev-ex-id',
            name: exerciseName,
            equipmentType: equipmentType,
            sets: sets,
          ),
        ],
      );
    }

    group('getPreviousPerformance', () {
      test('returns null when no previous performance exists', () async {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
        final result = await service.getPreviousPerformance(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isNull);
      });

      test('excludes exercise with currentExerciseId', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          exerciseId: currentExerciseId,
          sets: [TestFixtures.createExerciseSet(isLogged: true)],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        final result = await service.getPreviousPerformance(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isNull);
      });

      test('returns most recent logged exercise', () async {
        final older = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          exerciseId: 'old-id',
          completedDate: DateTime(2024, 1, 1),
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              reps: '8',
              isLogged: true,
            ),
          ],
        );
        final newer = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          exerciseId: 'new-id',
          completedDate: DateTime(2024, 3, 1),
          sets: [
            TestFixtures.createExerciseSet(
              weight: 110,
              reps: '8',
              isLogged: true,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([older, newer]));
        final result = await service.getPreviousPerformance(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isNotNull);
        expect(result!.sets.first.weight, 110);
      });

      test('case-insensitive name matching', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'BENCH PRESS',
          sets: [TestFixtures.createExerciseSet(isLogged: true)],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        final result = await service.getPreviousPerformance(
          'bench press',
          currentExerciseId,
        );
        expect(result, isNotNull);
      });

      test('ignores exercises with no logged sets', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          sets: [TestFixtures.createExerciseSet(isLogged: false)],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        final result = await service.getPreviousPerformance(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isNull);
      });
    });

    group('getPreviousSets', () {
      test('returns empty list when no previous performance', () async {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
        final result = await service.getPreviousSets(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isEmpty);
      });

      test('returns only logged sets', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: true,
              setNumber: 1,
            ),
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: false,
              setNumber: 2,
            ),
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: true,
              setNumber: 3,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        final result = await service.getPreviousSets(
          'Bench Press',
          currentExerciseId,
        );
        expect(result.length, 2);
      });
    });

    group('getAutoPopulateWeight', () {
      test('returns null when no history', () async {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
        final result = await service.getAutoPopulateWeight(
          'Bench Press',
          currentExerciseId,
          0,
        );
        expect(result, isNull);
      });

      test('returns weight at matching set index', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: true,
              setNumber: 1,
            ),
            TestFixtures.createExerciseSet(
              weight: 110,
              isLogged: true,
              setNumber: 2,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        expect(
          await service.getAutoPopulateWeight('Bench Press', currentExerciseId, 0),
          100,
        );
        expect(
          await service.getAutoPopulateWeight('Bench Press', currentExerciseId, 1),
          110,
        );
      });

      test('falls back to last set weight when index exceeds count', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: true,
              setNumber: 1,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));
        expect(
          await service.getAutoPopulateWeight('Bench Press', currentExerciseId, 5),
          100,
        );
      });
    });

    group('formatPerformanceSummary', () {
      late ExerciseHistoryService service;

      setUp(() {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
      });

      test('returns empty string for no logged sets', () {
        final exercise = TestFixtures.createExercise(
          sets: [TestFixtures.createExerciseSet(isLogged: false)],
        );
        expect(service.formatPerformanceSummary(exercise), '');
      });

      test('formats single weight with multiple reps', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(
              weight: 135,
              reps: '8',
              isLogged: true,
              setNumber: 1,
            ),
            TestFixtures.createExerciseSet(
              weight: 135,
              reps: '10',
              isLogged: true,
              setNumber: 2,
            ),
            TestFixtures.createExerciseSet(
              weight: 135,
              reps: '12',
              isLogged: true,
              setNumber: 3,
            ),
          ],
        );
        expect(service.formatPerformanceSummary(exercise), '135 x 8, 10, 12');
      });

      test('formats bodyweight (zero weight) as x reps', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(
              weight: 0,
              reps: '10',
              isLogged: true,
            ),
          ],
        );
        expect(service.formatPerformanceSummary(exercise), 'x 10');
      });

      test('formats null weight as x reps', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(
              weight: null,
              reps: '10',
              isLogged: true,
            ),
          ],
        );
        expect(service.formatPerformanceSummary(exercise), 'x 10');
      });

      test('formats multiple different weights individually', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              reps: '10',
              isLogged: true,
              setNumber: 1,
            ),
            TestFixtures.createExerciseSet(
              weight: 110,
              reps: '8',
              isLogged: true,
              setNumber: 2,
            ),
          ],
        );
        final summary = service.formatPerformanceSummary(exercise);
        expect(summary, '100 x 10, 110 x 8');
      });
    });

    group('formatRelativeDate', () {
      late ExerciseHistoryService service;

      setUp(() {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
      });

      test('returns today for current date', () {
        expect(service.formatRelativeDate(DateTime.now()), 'today');
      });

      test('returns yesterday for one day ago', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(service.formatRelativeDate(yesterday), 'yesterday');
      });

      test('returns N days ago for recent dates', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(service.formatRelativeDate(threeDaysAgo), '3 days ago');
      });

      test('returns N weeks ago for dates within a month', () {
        final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 15));
        expect(service.formatRelativeDate(twoWeeksAgo), '2 weeks ago');
      });

      test('returns 1 week ago singular', () {
        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
        expect(service.formatRelativeDate(oneWeekAgo), '1 week ago');
      });

      test('returns month and day for dates over 30 days ago', () {
        final oldDate = DateTime(2024, 1, 15);
        final result = service.formatRelativeDate(oldDate);
        expect(result, 'Jan 15');
      });
    });

    group('didHitAllReps', () {
      late ExerciseHistoryService service;

      setUp(() {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
      });

      test('returns false for no logged sets', () {
        final exercise = TestFixtures.createExercise(
          sets: [TestFixtures.createExerciseSet(isLogged: false)],
        );
        expect(service.didHitAllReps(exercise), false);
      });

      test('returns true when all reps are integers', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(reps: '10', isLogged: true),
            TestFixtures.createExerciseSet(reps: '8', isLogged: true),
          ],
        );
        expect(service.didHitAllReps(exercise), true);
      });

      test('returns false for range reps like 8-12', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(reps: '8-12', isLogged: true),
          ],
        );
        expect(service.didHitAllReps(exercise), false);
      });

      test('returns false for RIR format', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(reps: '2 RIR', isLogged: true),
          ],
        );
        expect(service.didHitAllReps(exercise), false);
      });

      test('returns false for empty reps', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(reps: '', isLogged: true),
          ],
        );
        expect(service.didHitAllReps(exercise), false);
      });
    });

    group('getWeightIncrement', () {
      late ExerciseHistoryService service;

      setUp(() {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
      });

      test('returns 5.0 for barbell', () {
        expect(service.getWeightIncrement(EquipmentType.barbell), 5.0);
      });

      test('returns 5.0 for smith machine', () {
        expect(service.getWeightIncrement(EquipmentType.smithMachine), 5.0);
      });

      test('returns 2.5 for dumbbell', () {
        expect(service.getWeightIncrement(EquipmentType.dumbbell), 2.5);
      });

      test('returns 2.5 for cable', () {
        expect(service.getWeightIncrement(EquipmentType.cable), 2.5);
      });

      test('returns 2.5 for machine', () {
        expect(service.getWeightIncrement(EquipmentType.machine), 2.5);
      });

      test('returns null for bodyweight only', () {
        expect(service.getWeightIncrement(EquipmentType.bodyweightOnly), isNull);
      });

      test('returns null for bodyweight loadable', () {
        expect(
          service.getWeightIncrement(EquipmentType.bodyweightLoadable),
          isNull,
        );
      });
    });

    group('getAutoPopulateWeightWithSuggestion', () {
      test('returns suggestion when all reps were hit', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          equipmentType: EquipmentType.barbell,
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              reps: '10',
              isLogged: true,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));

        final result = await service.getAutoPopulateWeightWithSuggestion(
          'Bench Press',
          currentExerciseId,
          0,
          EquipmentType.barbell,
        );

        expect(result.weight, 105.0); // 100 + 5 barbell increment
        expect(result.hasSuggestion, true);
      });

      test('returns base weight without suggestion when reps were ranges',
          () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          equipmentType: EquipmentType.barbell,
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              reps: '8-12',
              isLogged: true,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));

        final result = await service.getAutoPopulateWeightWithSuggestion(
          'Bench Press',
          currentExerciseId,
          0,
          EquipmentType.barbell,
        );

        expect(result.weight, 100.0);
        expect(result.hasSuggestion, false);
      });

      test('returns no suggestion for bodyweight exercises', () async {
        final workout = _makeCompletedWorkout(
          exerciseName: 'Pull Up',
          equipmentType: EquipmentType.bodyweightOnly,
          sets: [
            TestFixtures.createExerciseSet(
              weight: 0,
              reps: '10',
              isLogged: true,
            ),
          ],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([workout]));

        final result = await service.getAutoPopulateWeightWithSuggestion(
          'Pull Up',
          currentExerciseId,
          0,
          EquipmentType.bodyweightOnly,
        );

        // bodyweight returns null weight from getWeightIncrement
        expect(result.hasSuggestion, false);
      });
    });

    group('getFullHistory', () {
      test('returns empty list for unknown exercise', () async {
        service = ExerciseHistoryService(FakeWorkoutRepository([]));
        final result = await service.getFullHistory('Nonexistent');
        expect(result, isEmpty);
      });

      test('returns entries sorted most recent first', () async {
        final older = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          exerciseId: 'old',
          completedDate: DateTime(2024, 1, 1),
          sets: [TestFixtures.createExerciseSet(isLogged: true)],
        );
        final newer = _makeCompletedWorkout(
          exerciseName: 'Bench Press',
          exerciseId: 'new',
          completedDate: DateTime(2024, 3, 1),
          sets: [TestFixtures.createExerciseSet(isLogged: true)],
        );
        service = ExerciseHistoryService(FakeWorkoutRepository([older, newer]));
        final result = await service.getFullHistory('Bench Press');
        expect(result.length, 2);
        expect(result.first.date, DateTime(2024, 3, 1));
      });
    });

    group('clearCache', () {
      test('causes next lookup to re-fetch workouts', () async {
        final workouts = [
          _makeCompletedWorkout(
            exerciseName: 'Bench Press',
            sets: [TestFixtures.createExerciseSet(isLogged: true)],
          ),
        ];
        final repo = FakeWorkoutRepository(workouts);
        service = ExerciseHistoryService(repo);

        // First call populates cache
        await service.getPreviousPerformance('Bench Press', currentExerciseId);

        // Modify the repo's data
        repo.workouts.clear();
        service.clearCache();

        // Now should get null since repo is empty
        final result = await service.getPreviousPerformance(
          'Bench Press',
          currentExerciseId,
        );
        expect(result, isNull);
      });
    });

    group('ExerciseHistoryEntry', () {
      test('maxWeight returns highest weight from logged sets', () {
        final exercise = TestFixtures.createExercise(
          sets: [
            TestFixtures.createExerciseSet(
              weight: 100,
              isLogged: true,
              setNumber: 1,
            ),
            TestFixtures.createExerciseSet(
              weight: 120,
              isLogged: true,
              setNumber: 2,
            ),
            TestFixtures.createExerciseSet(
              weight: 110,
              isLogged: false,
              setNumber: 3,
            ),
          ],
        );
        final entry = ExerciseHistoryEntry(
          exercise: exercise,
          workout: TestFixtures.createWorkout(),
        );
        expect(entry.maxWeight, 120);
      });

      test('maxWeight returns 0 for no logged sets', () {
        final exercise = TestFixtures.createExercise(
          sets: [TestFixtures.createExerciseSet(isLogged: false)],
        );
        final entry = ExerciseHistoryEntry(
          exercise: exercise,
          workout: TestFixtures.createWorkout(),
        );
        expect(entry.maxWeight, 0);
      });
    });
  });
}
