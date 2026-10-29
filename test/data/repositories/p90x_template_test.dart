import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/core/utils/day_exercise_order.dart';
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
    test('follows the 13-week Classic calendar', () {
      const phaseA = [
        'Chest and Back',
        'Plyometrics',
        'Shoulders and Arms',
        'Yoga X',
        'Legs and Back',
        'Kenpo X',
        'X Stretch',
      ];
      const phaseB = [
        'Chest, Shoulders, and Triceps',
        'Plyometrics',
        'Back and Biceps',
        'Yoga X',
        'Legs and Back',
        'Kenpo X',
        'X Stretch',
      ];
      const recovery = [
        'Yoga X',
        'Core Synergistics',
        'Kenpo X',
        'X Stretch',
        'Core Synergistics',
        'Yoga X',
        'X Stretch',
      ];
      const expected = {
        1: phaseA, 2: phaseA, 3: phaseA, 4: recovery, //
        5: phaseB, 6: phaseB, 7: phaseB, 8: recovery, //
        9: phaseA, 10: phaseB, 11: phaseA, 12: phaseB, 13: recovery,
      };

      expect(template.periodsTotal, 13);
      expect(template.daysPerPeriod, 7);
      for (final entry in expected.entries) {
        final week = template.workouts.where((w) => w.periodNumber == entry.key).toList()
          ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
        expect(week.map((w) => w.dayName).toList(), entry.value, reason: 'week ${entry.key}');
      }
    });

    test('flags weeks 4, 8 and 13 as recovery', () {
      expect(template.recoveryPeriod, 13);
      expect(template.additionalRecoveryPeriods, [4, 8]);
    });

    test('only resistance days are strength; Ab Ripper X opens days 1, 3 and 5', () {
      for (final workout in template.workouts) {
        final isResistance = workout.exercises.isNotEmpty;
        expect(workout.isCardio, !isResistance, reason: '${workout.dayName} sport');
        if (isResistance && workout.dayName != 'Core Synergistics') {
          expect(
            workout.exercises.first.name,
            'Ab Ripper X',
            reason: '${workout.dayName} week ${workout.periodNumber}',
          );
          expect(workout.exercises.where((e) => e.name == 'Ab Ripper X'), hasLength(1));
        }
      }
    });

    test('every Chest and Back day repeats the week 1 workout', () {
      final days = template.workouts.where((w) => w.dayName == 'Chest and Back').toList();
      final week1 = days.firstWhere((w) => w.periodNumber == 1).toJson()['exercises'];

      expect(days.map((w) => w.periodNumber), [1, 2, 3, 9, 11]);
      for (final day in days) {
        expect(day.toJson()['exercises'], week1, reason: 'week ${day.periodNumber}');
      }
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

    test('round 2 is listed out in Chest and Back, merged into 2 sets elsewhere', () {
      // Chest and Back runs the circuit twice as separate 1-set entries.
      final chestAndBack = template.workouts.firstWhere((w) => w.dayName == 'Chest and Back');
      final pushups = chestAndBack.exercises.where((e) => e.name == 'Pushup');
      expect(pushups.map((e) => e.sets), [1, 1]);
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

      expect(result.cardioSessions.map((s) => s.label).toSet(), {'Plyometrics', 'Yoga X', 'Kenpo X', 'X Stretch'});
      expect(result.cardioSessions.map((s) => s.sport.name).toSet(), {'other'});
      expect(result.trainingCycle.workouts, isNotEmpty);
      expect(result.trainingCycle.recoveryPeriods, [4, 8, 13]);
      expect(
        result.trainingCycle.workouts
            .where((w) => w.periodNumber == 1 && w.dayNumber == 1)
            .map((w) => w.dayName)
            .toSet(),
        {'Chest and Back'},
      );
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
          final templateExercise = templateWorkout.exercises.firstWhere((e) => e.name == exercise.name);
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

    test('every strength day displays its exercises in template order', () async {
      final result = await TemplateRepository().createTrainingCycleFromTemplate(template);

      for (final day in template.workouts.where((w) => w.exercises.isNotEmpty)) {
        final dayWorkouts = result.trainingCycle.workouts.where(
          (w) => w.periodNumber == day.periodNumber && w.dayNumber == day.dayNumber,
        );
        expect(
          orderedDayExercises(dayWorkouts).map((e) => e.name),
          day.exercises.map((e) => e.name),
          reason: 'week ${day.periodNumber} day ${day.dayNumber}',
        );
      }
    });
  });
}
