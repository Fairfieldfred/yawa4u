import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/template_exporter.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String? lastClipboardText;

  setUp(() {
    lastClipboardText = null;
    // Mock the clipboard platform channel so setData captures the text
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          lastClipboardText = (call.arguments as Map<Object?, Object?>)['text'] as String?;
          return null;
        }
        if (call.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': lastClipboardText};
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  group('exportToClipboard', () {
    test('produces valid JSON on clipboard', () async {
      final cycle = TestFixtures.createTrainingCycle(
        name: 'Test Cycle',
        periodsTotal: 1,
        daysPerPeriod: 2,
      );

      await TemplateExporter.exportToClipboard(cycle);

      expect(lastClipboardText, isNotNull);
      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      expect(json['name'], 'Test Cycle');
      expect(json['periodsTotal'], 1);
      expect(json['daysPerPeriod'], 2);
      expect(json['id'], 'test_cycle');
      expect(json['description'], contains('Test Cycle'));
    });

    test('sorts workouts by period then day', () async {
      final cycle = TestFixtures.createTrainingCycle(
        name: 'Sorted',
        periodsTotal: 2,
        daysPerPeriod: 2,
        workouts: [
          TestFixtures.createWorkout(periodNumber: 2, dayNumber: 1),
          TestFixtures.createWorkout(periodNumber: 1, dayNumber: 2),
          TestFixtures.createWorkout(periodNumber: 1, dayNumber: 1),
        ],
      );

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      final workouts = json['workouts'] as List<dynamic>;
      expect(workouts[0]['periodNumber'], 1);
      expect(workouts[0]['dayNumber'], 1);
      expect(workouts[1]['periodNumber'], 1);
      expect(workouts[1]['dayNumber'], 2);
      expect(workouts[2]['periodNumber'], 2);
      expect(workouts[2]['dayNumber'], 1);
    });

    test('extracts reps from first set', () async {
      final exercise = TestFixtures.createExercise(
        sets: [
          TestFixtures.createExerciseSet(reps: '10'),
          TestFixtures.createExerciseSet(reps: '8'),
        ],
      );

      final cycle = TestFixtures.createTrainingCycle(
        workouts: [
          TestFixtures.createWorkout(exercises: [exercise]),
        ],
      );

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      final exercises = (json['workouts'] as List).first['exercises'] as List<dynamic>;
      expect(exercises.first['reps'], '10');
    });

    test('defaults reps to "8-12" when no sets', () async {
      final exercise = TestFixtures.createExercise(sets: []);

      final cycle = TestFixtures.createTrainingCycle(
        workouts: [
          TestFixtures.createWorkout(exercises: [exercise]),
        ],
      );

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      final exercises = (json['workouts'] as List).first['exercises'] as List<dynamic>;
      expect(exercises.first['reps'], '8-12');
      expect(exercises.first['sets'], 0);
    });

    test('cycle with no workouts exports empty list', () async {
      final cycle = TestFixtures.createTrainingCycle(workouts: []);

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      expect(json['workouts'], isEmpty);
    });

    test('preserves exercise notes', () async {
      final exercise = TestFixtures.createExercise(notes: 'Go slow');

      final cycle = TestFixtures.createTrainingCycle(
        workouts: [
          TestFixtures.createWorkout(exercises: [exercise]),
        ],
      );

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      final exercises = (json['workouts'] as List).first['exercises'] as List<dynamic>;
      expect(exercises.first['notes'], 'Go slow');
    });

    test('serializes enums as name strings', () async {
      final exercise = TestFixtures.createExercise();

      final cycle = TestFixtures.createTrainingCycle(
        workouts: [
          TestFixtures.createWorkout(exercises: [exercise]),
        ],
      );

      await TemplateExporter.exportToClipboard(cycle);

      final json = jsonDecode(lastClipboardText!) as Map<String, dynamic>;
      final ex = (json['workouts'] as List).first['exercises'] as List<dynamic>;
      expect(ex.first['muscleGroup'], isA<String>());
      expect(ex.first['equipmentType'], isA<String>());
      expect(ex.first['setType'], isA<String>());
    });
  });
}
