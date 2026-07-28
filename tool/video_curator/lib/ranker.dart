import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'youtube_client.dart';

/// The outcome of ranking candidates for one exercise.
class Pick {
  Pick({
    required this.videoId,
    required this.confidence,
    required this.reason,
    required this.source,
  });

  final String videoId;
  final double confidence;
  final String reason;

  /// 'claude' when the LLM ranked, 'heuristic' on fallback.
  final String source;

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'confidence': confidence,
    'reason': reason,
    'source': source,
  };
}

/// Scores candidates without an LLM: title-token overlap with the exercise
/// name dominates, view count breaks ties.
List<Candidate> heuristicRank(String exercise, List<Candidate> candidates) {
  final exerciseTokens = _tokens(exercise);
  double score(Candidate c) {
    final titleTokens = _tokens(c.title);
    final overlap =
        exerciseTokens.intersection(titleTokens).length /
        max(exerciseTokens.length, 1);
    return overlap * 10 + log(c.viewCount + 1) / 10;
  }

  final sorted = [...candidates]..sort((a, b) => score(b).compareTo(score(a)));
  return sorted;
}

Set<String> _tokens(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .split(RegExp(r'\s+'))
    .where((t) => t.length > 1)
    .toSet();

/// Asks the claude CLI to pick the best demo video for [exercise], reading
/// each candidate's title, channel, and description. Falls back to
/// [heuristicRank] when the CLI is unavailable or returns garbage.
Future<Pick> rankCandidates(
  String exercise,
  List<Candidate> candidates, {
  String workout = '',
}) async {
  if (candidates.isEmpty) {
    throw StateError('No candidates to rank for "$exercise"');
  }

  final prompt = _buildPrompt(exercise, workout, candidates);
  try {
    final result = await Process.run('claude', [
      '-p',
      '--output-format',
      'json',
      prompt,
    ]).timeout(const Duration(minutes: 3));
    if (result.exitCode == 0) {
      final envelope = jsonDecode(result.stdout as String);
      final text = envelope['result'] as String? ?? '';
      final pick = _parsePick(text, candidates);
      if (pick != null) return pick;
    }
    stderr.writeln(
      '  claude ranking failed for "$exercise", '
      'falling back to heuristic',
    );
  } on Exception catch (e) {
    stderr.writeln('  claude CLI unavailable ($e), using heuristic');
  }

  final best = heuristicRank(exercise, candidates).first;
  return Pick(
    videoId: best.videoId,
    confidence: 0.3,
    reason: 'Heuristic fallback: best title match + views',
    source: 'heuristic',
  );
}

String _buildPrompt(
  String exercise,
  String workout,
  List<Candidate> candidates,
) {
  final buffer = StringBuffer()
    ..writeln(
      'You are selecting the single best YouTube demo video for a workout '
      'app. The user is mid-workout and needs a clear demonstration of '
      'correct form for the exercise "$exercise"'
      '${workout.isEmpty ? '' : ' (part of the P90X workout "$workout")'}.',
    )
    ..writeln()
    ..writeln(
      'Prefer: focused exercise demonstrations with good form cues, '
      'reputable fitness channels, reasonable length (1-15 min). '
      'Avoid: compilations, vlogs, music videos, clickbait, or videos '
      'about a different exercise that happens to share words.',
    )
    ..writeln()
    ..writeln('Candidates:');
  for (final c in candidates) {
    final desc = c.description.length > 300
        ? '${c.description.substring(0, 300)}…'
        : c.description;
    buffer
      ..writeln('- id: ${c.videoId}')
      ..writeln('  title: ${c.title}')
      ..writeln('  channel: ${c.channel}')
      ..writeln('  duration: ${c.durationSeconds}s  views: ${c.viewCount}')
      ..writeln('  description: ${desc.replaceAll('\n', ' ')}');
  }
  buffer
    ..writeln()
    ..writeln(
      'Respond with ONLY a JSON object, no markdown fences: '
      '{"videoId": "<id from the list>", "confidence": <0.0-1.0>, '
      '"reason": "<one sentence>"}',
    );
  return buffer.toString();
}

Pick? _parsePick(String text, List<Candidate> candidates) {
  final match = RegExp(r'\{[\s\S]*\}').firstMatch(text);
  if (match == null) return null;
  try {
    final json = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    final videoId = json['videoId'] as String?;
    if (videoId == null || !candidates.any((c) => c.videoId == videoId)) {
      return null;
    }
    return Pick(
      videoId: videoId,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      reason: json['reason'] as String? ?? '',
      source: 'claude',
    );
  } on FormatException {
    return null;
  }
}
