import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/data/models/training_cycle_template.dart';
import 'package:yawa4u/data/repositories/template_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Template Creation Tests', () {
    test(
      'createTrainingCycleFromTemplate splits workouts by muscle group',
      () async {
        final repository = TemplateRepository();

        // Create a mock template with mixed muscle groups
        final template = TrainingCycleTemplate(
          id: 'test_template',
          name: 'Test Template',
          description: 'Test Description',
          daysPerWeek: 4,
          weeksTotal: 6,
          workouts: [
            WorkoutTemplate(
              weekNumber: 1,
              dayNumber: 1,
              exercises: [
                ExerciseTemplate(
                  name: 'Bench Press',
                  muscleGroup: 'Chest',
                  equipmentType: 'Barbell',
                  sets: 3,
                  reps: '8-12',
                  setType: 'Regular',
                ),
                ExerciseTemplate(
                  name: 'Barbell Row',
                  muscleGroup: 'Back',
                  equipmentType: 'Barbell',
                  sets: 3,
                  reps: '8-12',
                  setType: 'Regular',
                ),
              ],
            ),
          ],
        );

        final trainingCycle = await repository.createTrainingCycleFromTemplate(
          template,
          'Test User',
        );

        // Should create 2 workouts (one for Chest, one for Back)
        expect(trainingCycle.workouts.length, 2);

        final chestWorkout = trainingCycle.workouts.firstWhere(
          (w) => w.label == 'Chest',
        );
        expect(chestWorkout.exercises.length, 1);
        expect(chestWorkout.exercises.first.name, 'Bench Press');

        final backWorkout = trainingCycle.workouts.firstWhere(
          (w) => w.label == 'Back',
        );
        expect(backWorkout.exercises.length, 1);
        expect(backWorkout.exercises.first.name, 'Barbell Row');
      },
    );
  });
}
