import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:video_curator/emitter.dart';
import 'package:video_curator/pipeline.dart';

void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('curator_test');
    Directory('${tmp.path}/config').createSync();
    Directory('${tmp.path}/results').createSync();
    File('${tmp.path}/config/exercises.json').writeAsStringSync(
      jsonEncode([
        {'workout': 'Chest and Back', 'exercise': 'Standard Push-Ups'},
        {'workout': 'Chest and Back', 'exercise': 'Standard Push-Ups 2'},
      ]),
    );
  });

  tearDown(() => tmp.deleteSync(recursive: true));

  void writeResult(String exercise, String videoId) {
    File('${tmp.path}/results/${slugFor(exercise)}.json').writeAsStringSync(
      jsonEncode({
        'exercise': exercise,
        'workout': 'Chest and Back',
        'pick': {'videoId': videoId, 'confidence': 0.9, 'reason': ''},
        'startSeconds': 0,
        'endSeconds': 120,
        'chosen': {},
        'candidates': [],
      }),
    );
  }

  test('slugFor and baseName', () {
    expect(slugFor('Wide Fly Push-Ups 2'), 'wide-fly-push-ups-2');
    expect(baseName('Wide Fly Push-Ups 2'), 'Wide Fly Push-Ups');
    expect(baseName('Wall Squat'), 'Wall Squat');
  });

  test('emitter maps curated names to watch URLs and omits uncurated ones', () {
    writeResult('Standard Push-Ups', 'vid_round1');
    final dart = emitDart(tmp.path, now: DateTime(2026));
    expect(
      dart,
      contains(
        "'Standard Push-Ups': 'https://www.youtube.com/watch?v=vid_round1',",
      ),
    );
    expect(dart, isNot(contains("'Standard Push-Ups 2':")));
    expect(dart, contains('// - Standard Push-Ups 2'));
    expect(dart, contains('const Map<String, String> generatedExerciseVideos'));
  });

  test('emitter escapes Dart string metacharacters in names', () {
    File('${tmp.path}/config/exercises.json').writeAsStringSync(
      jsonEncode([
        {'workout': 'Back', 'exercise': "Dumbbell Farmer's Walk"},
      ]),
    );
    writeResult("Dumbbell Farmer's Walk", 'vid_1');
    final dart = emitDart(tmp.path, now: DateTime(2026));
    expect(
      dart,
      contains(
        r"'Dumbbell Farmer\'s Walk': 'https://www.youtube.com/watch?v=vid_1',",
      ),
    );
  });
}
