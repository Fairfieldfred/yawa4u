import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'ranker.dart';
import 'youtube_client.dart';

String slugFor(String exercise) => exercise
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

String baseName(String exercise) => exercise.replaceAll(RegExp(r' 2$'), '');

class ExerciseEntry {
  ExerciseEntry(this.workout, this.exercise);
  final String workout;
  final String exercise;
}

List<ExerciseEntry> loadConfig(String toolDir) {
  final json =
      jsonDecode(File('$toolDir/config/exercises.json').readAsStringSync())
          as List;
  return [
    for (final e in json)
      ExerciseEntry(e['workout'] as String, e['exercise'] as String),
  ];
}

/// Curates every not-yet-curated exercise, stopping before [quotaBudget]
/// YouTube units are exceeded. Safe to re-run: existing results are kept.
Future<void> runPipeline({
  required String toolDir,
  required String apiKey,
  String? onlyWorkout,
  int quotaBudget = 9500,
}) async {
  final entries = loadConfig(toolDir);
  final resultsDir = Directory('$toolDir/results')..createSync(recursive: true);

  // Unique exercises, preserving first-seen workout for prompt context.
  final unique = <String, ExerciseEntry>{};
  for (final e in entries) {
    if (onlyWorkout != null && e.workout != onlyWorkout) continue;
    unique.putIfAbsent(e.exercise, () => e);
  }

  final client = YoutubeClient(apiKey);
  var curated = 0, skipped = 0, remaining = 0;
  try {
    for (final entry in unique.values) {
      final slug = slugFor(entry.exercise);
      final outFile = File('${resultsDir.path}/$slug.json');
      if (outFile.existsSync()) {
        skipped++;
        continue;
      }

      // "X 2" reuses the base exercise's stored candidates: no new search,
      // and it must pick a different clip than round 1.
      final base = baseName(entry.exercise);
      final baseFile = File('${resultsDir.path}/${slugFor(base)}.json');
      List<Candidate> candidates;
      final excludeIds = <String>{};
      if (base != entry.exercise && baseFile.existsSync()) {
        final baseJson =
            jsonDecode(baseFile.readAsStringSync()) as Map<String, dynamic>;
        excludeIds.add(baseJson['pick']['videoId'] as String);
        candidates = [
          for (final c in baseJson['candidates'] as List)
            Candidate(
              videoId: c['videoId'] as String,
              title: c['title'] as String,
              channel: c['channel'] as String,
              description: c['description'] as String,
              durationSeconds: c['durationSeconds'] as int,
              viewCount: c['viewCount'] as int,
              embeddable: c['embeddable'] as bool,
            ),
        ].where((c) => !excludeIds.contains(c.videoId)).toList();
        stdout.writeln(
          '[$slug] reusing "${slugFor(base)}" candidates '
          '(no quota)',
        );
      } else {
        if (client.quota.spent + 101 > quotaBudget) {
          remaining++;
          continue;
        }
        stdout.writeln(
          '[$slug] searching…  '
          '(quota ${client.quota.spent}/$quotaBudget)',
        );
        candidates = await client.searchCandidates(
          '${entry.exercise} exercise how to proper form',
        );
      }

      if (candidates.isEmpty) {
        stderr.writeln(
          '[$slug] no embeddable candidates — flagged for '
          'manual pick',
        );
        outFile.writeAsStringSync(
          jsonEncode({
            'exercise': entry.exercise,
            'workout': entry.workout,
            'pick': null,
            'candidates': [],
            'curatedAt': DateTime.now().toIso8601String(),
          }),
        );
        continue;
      }

      final pick = await rankCandidates(
        entry.exercise,
        candidates,
        workout: entry.workout,
      );
      final chosen = candidates.firstWhere((c) => c.videoId == pick.videoId);
      outFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'exercise': entry.exercise,
          'workout': entry.workout,
          'pick': pick.toJson(),
          'startSeconds': 0,
          'endSeconds': min(chosen.durationSeconds, 300),
          'chosen': chosen.toJson(),
          'candidates': [for (final c in candidates) c.toJson()],
          'curatedAt': DateTime.now().toIso8601String(),
        }),
      );
      curated++;
      stdout.writeln(
        '[$slug] ✓ ${chosen.title} '
        '(${pick.source}, ${pick.confidence})',
      );
    }
  } on YoutubeApiException catch (e) {
    if (e.isQuotaExceeded) {
      stderr.writeln(
        'Daily YouTube quota exceeded — re-run tomorrow to '
        'resume.',
      );
    } else {
      rethrow;
    }
  } finally {
    client.close();
  }

  stdout
    ..writeln()
    ..writeln(
      'Done: $curated curated, $skipped already done, '
      '$remaining left for next run (quota spent: ${client.quota.spent}).',
    );
}
