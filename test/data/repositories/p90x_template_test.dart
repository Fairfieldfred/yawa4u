import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/training_cycle_template.dart';
import 'package:yawa4u/data/repositories/template_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TrainingCycleTemplate template;

  setUpAll(() async {
    final jsonString = await rootBundle.loadString('assets/templates/p90x.json');
    template = TrainingCycleTemplate.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  });

  group('P90X template structure', () {
    test('has the six P90X resistance days in order', () {
      expect(template.workouts, hasLength(6));
      expect(
        template.workouts.map((w) => w.dayName).toList(),
        [
          'Chest and Back',
          'Shoulders and Arms',
          'Legs and Back',
          'Chest, Shoulders, and Triceps',
          'Back and Biceps',
          'Core Synergistics',
        ],
      );
    });

    test('every exercise references valid enums', () {
      for (final workout in template.workouts) {
        for (final exercise in workout.exercises) {
          expect(
            MuscleGroup.values.any((m) => m.name.toLowerCase() == exercise.muscleGroup.toLowerCase()),
            isTrue,
            reason: 'invalid muscleGroup "${exercise.muscleGroup}" (${exercise.name})',
          );
          expect(
            EquipmentType.values.any((e) => e.name.toLowerCase() == exercise.equipmentType.toLowerCase()),
            isTrue,
            reason: 'invalid equipmentType "${exercise.equipmentType}" (${exercise.name})',
          );
          expect(
            SetType.values.any((s) => s.name.toLowerCase() == exercise.setType.toLowerCase()),
            isTrue,
            reason: 'invalid setType "${exercise.setType}" (${exercise.name})',
          );
          expect(exercise.sets, greaterThan(0));
          expect(exercise.reps, isNotEmpty);
        }
      }
    });
  });

  group('P90X set-type classification', () {
    ExerciseTemplate find(String dayName, String exerciseName) {
      final workout = template.workouts.firstWhere((w) => w.dayName == dayName);
      return workout.exercises.firstWhere((e) => e.name == exerciseName);
    }

    test('maxRepSets exercises get maxReps setType', () {
      expect(find('Chest and Back', 'Pushup').setType, 'maxReps');
      expect(find('Chest and Back', 'Pullup (Wide Grip)').setType, 'maxReps');
      expect(find('Back and Biceps', 'Pullup (Corn Cob)').setType, 'maxReps');
      expect(find('Core Synergistics', 'Pushup (Prison Cell)').setType, 'maxReps');
    });

    test('fixedRepSets exercises keep fixed rep counts', () {
      expect(find('Back and Biceps', 'Twenty Ones').reps, '21');
      expect(find('Legs and Back', '80-20 Siebers Speed Squat').reps, '30');
      expect(find('Legs and Back', 'Calf Raise').reps, '25');
      expect(find('Legs and Back', 'Step Back Lunge').reps, '15');
      expect(find('Legs and Back', 'Balance Lunge').setType, 'regular');
    });

    test('doneOrNotSets exercises are marked Done with a hint note', () {
      final superman = find('Back and Biceps', 'Superman');
      expect(superman.reps, 'Done');
      expect(superman.notes, isNotNull);

      final groucho = find('Legs and Back', 'Groucho Walk');
      expect(groucho.reps, 'Done');
      expect(groucho.notes, isNotNull);
    });

    test('round-2 duplicates merge into 2 sets', () {
      // Standard Push-Ups appears twice in Chest and Back.
      expect(find('Chest and Back', 'Pushup').sets, 2);
      // Switch Grip Chin-Ups 2 pairs with Switch Grip Pull-Ups.
      expect(find('Legs and Back', 'Pullup (Switch Grip)').sets, 2);
      // Single-appearance exercises stay at 1 set.
      expect(find('Legs and Back', 'Groucho Walk').sets, 1);
    });
  });

  group('P90X instantiation', () {
    test('creates a cycle whose workouts carry the template set types', () async {
      final repo = TemplateRepository();
      final result = await repo.createTrainingCycleFromTemplate(template);

      expect(result.cardioSessions, isEmpty);
      expect(result.trainingCycle.workouts, isNotEmpty);
      expect(result.trainingCycle.name, template.name);

      // Every exercise keeps its set count and setType through instantiation.
      var maxRepSets = 0;
      for (final workout in result.trainingCycle.workouts) {
        final templateWorkout = template.workouts.firstWhere(
          (w) => w.periodNumber == workout.periodNumber && w.dayNumber == workout.dayNumber,
        );
        for (final exercise in workout.exercises) {
          expect(exercise.sets, isNotEmpty);
          // Same name can recur across days with different set counts —
          // match within the same day only.
          final templateExercise = templateWorkout.exercises
              .firstWhere((e) => e.name == exercise.name);
          expect(exercise.sets.length, templateExercise.sets);
          for (final set in exercise.sets) {
            expect(set.setType.name.toLowerCase(), templateExercise.setType.toLowerCase());
            if (set.setType == SetType.maxReps) {
              maxRepSets++;
            }
          }
        }
      }
      expect(maxRepSets, greaterThan(0), reason: 'maxReps sets must survive instantiation');
    });
  });
}
