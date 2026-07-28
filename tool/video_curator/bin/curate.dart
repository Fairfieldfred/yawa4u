import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:video_curator/emitter.dart';
import 'package:video_curator/pipeline.dart';
import 'package:video_curator/ranker.dart';
import 'package:video_curator/report.dart';
import 'package:video_curator/youtube_client.dart';

Future<void> main(List<String> args) async {
  String? exercise;
  String workout = '';
  var all = false;
  var emit = false;
  var quotaBudget = 9500;
  String? onlyWorkout;
  String? queryOverride;
  final excludeIds = <String>{};
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--exercise':
        exercise = args[++i];
      case '--workout':
        workout = args[++i];
        onlyWorkout = workout;
      case '--query':
        queryOverride = args[++i];
      case '--exclude':
        excludeIds.add(args[++i]);
      case '--all':
        all = true;
      case '--budget':
        quotaBudget = int.parse(args[++i]);
      case '--emit':
        emit = true;
      default:
        stderr.writeln('Unknown argument: ${args[i]}');
        exit(64);
    }
  }

  final toolDir = _toolDir();

  if (emit) {
    final dart = emitDart(toolDir);
    final outFile = File(
      '$toolDir/../../lib/core/constants/exercise_videos.g.dart',
    )..writeAsStringSync(dart);
    stdout.writeln('Wrote ${outFile.path}');
    writeReport(toolDir);
    return;
  }

  final apiKey = _loadApiKey(toolDir);
  if (apiKey == null) {
    stderr.writeln('YOUTUBE_API_KEY not found in environment or .env');
    exit(78);
  }

  if (all || onlyWorkout != null && exercise == null) {
    await runPipeline(
      toolDir: toolDir,
      apiKey: apiKey,
      onlyWorkout: onlyWorkout,
      quotaBudget: quotaBudget,
    );
    writeReport(toolDir);
    return;
  }

  if (exercise == null) {
    stderr.writeln('''
Usage:
  dart run bin/curate.dart --exercise "<name>" [--workout "<name>"] [--query "<search terms>"] [--exclude <videoId>]...
  dart run bin/curate.dart --all [--budget <units>]
  dart run bin/curate.dart --workout "<name>" [--budget <units>]
  dart run bin/curate.dart --emit''');
    exit(64);
  }

  await _curateOne(
    toolDir,
    apiKey,
    exercise,
    workout,
    excludeIds,
    queryOverride,
  );
}

Future<void> _curateOne(
  String toolDir,
  String apiKey,
  String exercise,
  String workout,
  Set<String> excludeIds,
  String? queryOverride,
) async {
  final client = YoutubeClient(apiKey);
  try {
    // The exercise name stays the result key; --query only changes the search.
    final query = queryOverride ?? '$exercise exercise how to proper form';
    stdout.writeln('Searching: "$query"');
    final candidates = await client.searchCandidates(
      query,
      excludeIds: excludeIds,
    );
    if (candidates.isEmpty) {
      stderr.writeln('No embeddable candidates found.');
      exit(1);
    }
    stdout.writeln(
      'Found ${candidates.length} embeddable candidates. '
      'Asking Claude to pick…',
    );

    final pick = await rankCandidates(exercise, candidates, workout: workout);
    final chosen = candidates.firstWhere((c) => c.videoId == pick.videoId);
    final endSeconds = min(chosen.durationSeconds, 300);

    final outFile = File('$toolDir/results/${slugFor(exercise)}.json');
    outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'exercise': exercise,
        'workout': workout,
        'pick': pick.toJson(),
        'startSeconds': 0,
        'endSeconds': endSeconds,
        'chosen': chosen.toJson(),
        'candidates': [for (final c in candidates) c.toJson()],
        'quotaSpent': client.quota.spent,
        'curatedAt': DateTime.now().toIso8601String(),
      }),
    );

    stdout
      ..writeln()
      ..writeln('Picked: ${chosen.title}  (${chosen.channel})')
      ..writeln('  https://www.youtube.com/watch?v=${pick.videoId}')
      ..writeln('  confidence: ${pick.confidence}  source: ${pick.source}')
      ..writeln('  reason: ${pick.reason}')
      ..writeln('  clip: 0-${endSeconds}s of ${chosen.durationSeconds}s')
      ..writeln('  saved: ${outFile.path}')
      ..writeln('  quota spent: ${client.quota.spent} units');
  } on YoutubeApiException catch (e) {
    stderr.writeln(
      e.isQuotaExceeded
          ? 'Daily YouTube quota exceeded — resume tomorrow.'
          : 'YouTube API error: $e',
    );
    exit(1);
  } finally {
    client.close();
  }
}

String _toolDir() {
  // bin/curate.dart lives one level under the tool root.
  final scriptDir = File.fromUri(Platform.script).parent;
  return scriptDir.path.endsWith('bin') ? scriptDir.parent.path : '.';
}

String? _loadApiKey(String toolDir) {
  final fromEnv = Platform.environment['YOUTUBE_API_KEY'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  final envFile = File('$toolDir/.env');
  if (!envFile.existsSync()) return null;
  for (final line in envFile.readAsLinesSync()) {
    final parts = line.split('=');
    if (parts.length >= 2 && parts.first.trim() == 'YOUTUBE_API_KEY') {
      return parts.sublist(1).join('=').trim().replaceAll('"', '');
    }
  }
  return null;
}
