import 'dart:io';

import 'emitter.dart';
import 'pipeline.dart';

/// Writes results/review.html — a human review page with thumbnails,
/// confidence, and the picked clip for every exercise.
void writeReport(String toolDir) {
  final entries = loadConfig(toolDir);
  final buffer = StringBuffer()
    ..writeln(
      '<!doctype html><meta charset="utf-8">'
      '<title>Video curation review</title>'
      '<style>'
      'body{font-family:system-ui;margin:2rem;max-width:70rem}'
      'h2{margin-top:2.5rem}'
      '.card{display:flex;gap:1rem;border:1px solid #ccc;border-radius:8px;'
      'padding:.6rem;margin:.5rem 0;align-items:center}'
      '.card img{border-radius:4px}'
      '.low{border-color:#d33;background:#fff5f5}'
      '.missing{border-color:#d90;background:#fffaf0}'
      '.meta{font-size:.85rem;color:#555}'
      '</style>',
    )
    ..writeln('<h1>Video curation review</h1>')
    ..writeln(
      '<p>Red cards are low-confidence picks; orange cards have no '
      'curated video yet. Re-pick with:<br>'
      '<code>dart run bin/curate.dart --exercise "&lt;name&gt;" '
      '--exclude &lt;badVideoId&gt;</code></p>',
    );

  String? currentWorkout;
  for (final e in entries) {
    if (e.workout != currentWorkout) {
      currentWorkout = e.workout;
      buffer.writeln('<h2>${_esc(e.workout)}</h2>');
    }
    final result = loadResult(toolDir, e.exercise);
    if (result == null) {
      buffer.writeln(
        '<div class="card missing"><div>'
        '<b>${_esc(e.exercise)}</b><br>'
        '<span class="meta">No curated video yet</span></div></div>',
      );
      continue;
    }
    final pick = result['pick'] as Map<String, dynamic>;
    final chosen = result['chosen'] as Map<String, dynamic>;
    final id = pick['videoId'] as String;
    final confidence = (pick['confidence'] as num).toDouble();
    final cls = confidence < 0.6 ? 'card low' : 'card';
    buffer.writeln(
      '<div class="$cls">'
      '<a href="https://www.youtube.com/watch?v=$id" target="_blank">'
      '<img src="https://img.youtube.com/vi/$id/mqdefault.jpg" width="160">'
      '</a><div>'
      '<b>${_esc(e.exercise)}</b><br>'
      '${_esc(chosen['title'] as String)} — '
      '${_esc(chosen['channel'] as String)}<br>'
      '<span class="meta">clip 0–${result['endSeconds']}s · '
      'confidence ${confidence.toStringAsFixed(2)} (${pick['source']}) · '
      '${_esc(pick['reason'] as String)}</span>'
      '</div></div>',
    );
  }

  final out = File('$toolDir/results/review.html')
    ..writeAsStringSync(buffer.toString());
  stdout.writeln('Review page: ${out.path}');
}

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
