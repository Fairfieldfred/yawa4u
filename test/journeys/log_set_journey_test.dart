import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/domain/providers/database_providers.dart';

import '../harness/workout_app_harness.dart';
import '../helpers/test_fixtures.dart';
import '../robots/workout_robot.dart';

/// Journey: open workout → enter weight → keypad Next → enter reps →
/// log the set → rest timer starts.
void main() {
  late WorkoutAppHarness harness;

  setUp(() async {
    harness = WorkoutAppHarness();
    await harness.initialize();
  });

  tearDown(() async {
    await harness.dispose();
  });

  Future<void> seedActiveCycleWithTodayWorkout() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final TrainingCycleRepository cycleRepo = harness.container.read(trainingCycleRepositoryProvider);
    final WorkoutRepository workoutRepo = harness.container.read(workoutRepositoryProvider);

    final cycle = TestFixtures.createTrainingCycle(
      id: 'cycle-journey',
      name: 'Journey Cycle',
      status: TrainingCycleStatus.current,
      startDate: startOfToday,
      periodsTotal: 4,
      daysPerPeriod: 7,
    );
    await cycleRepo.create(cycle);

    final workout = Workout(
      id: 'workout-journey',
      trainingCycleId: 'cycle-journey',
      periodNumber: 1,
      dayNumber: 1,
      label: 'Chest',
      status: WorkoutStatus.incomplete,
      scheduledDate: startOfToday,
      exercises: [
        TestFixtures.createExercise(
          id: 'ex-journey',
          workoutId: 'workout-journey',
          name: 'Bench Press',
          sets: [
            TestFixtures.createExerciseSet(id: 'set-journey', setNumber: 1, weight: null, reps: ''),
          ],
        ),
      ],
    );
    await workoutRepo.create(workout);
  }

  testWidgets('log a set one-handed: weight → next → reps → log → timer starts', (tester) async {
    await seedActiveCycleWithTodayWorkout();

    final robot = WorkoutRobot(tester, harness);
    await harness.pumpWorkoutTab(tester);

    await robot.enterWeight(0, '100');
    await robot.pressKeyboardNext();
    robot.expectRepsFieldFocused(0);

    await robot.enterReps(0, '8');
    await robot.logSet(0);

    robot.expectRestTimerRunning();
    await robot.stopRestTimer();
  });
}
