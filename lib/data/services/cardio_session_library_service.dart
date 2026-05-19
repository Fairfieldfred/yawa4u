import 'dart:convert';

import 'package:flutter/services.dart' show AssetManifest, rootBundle;

import '../../core/constants/enums.dart';
import '../../core/constants/sports.dart';
import '../models/cardio_detail.dart';
import '../models/cardio_session_template.dart';
import '../models/session.dart';
import '../models/session_interval.dart';

/// Loads prebuilt cardio sessions from `assets/cardio_sessions/*.json`
/// and turns a selected template into a fresh, editable [CardioSession].
///
/// Convention: the AssetManifest lists every JSON under that directory;
/// we read all of them at first access, cache in memory, and never hit
/// the bundle again. The files are small (~1–3 KB each) so eager loading
/// is fine.
class CardioSessionLibraryService {
  CardioSessionLibraryService._();

  /// Process-wide singleton — templates never change at runtime.
  static final CardioSessionLibraryService instance = CardioSessionLibraryService._();

  List<CardioSessionTemplate>? _cache;

  /// Return every available template, sorted alphabetically by name.
  /// Loaded once on first call.
  Future<List<CardioSessionTemplate>> loadAll() async {
    if (_cache != null) return _cache!;

    var paths = <String>[];
    try {
      // Preferred path (Flutter 3.x+): binary AssetManifest.
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      paths = manifest
          .listAssets()
          .where(
            (k) => k.startsWith('assets/cardio_sessions/') && k.endsWith('.json'),
          )
          .toList();
    } catch (_) {
      // Fallback: legacy AssetManifest.json (still shipped for back-compat
      // with older Flutter versions).
      try {
        final raw = await rootBundle.loadString('AssetManifest.json');
        final legacy = jsonDecode(raw) as Map<String, dynamic>;
        paths = legacy.keys
            .where(
              (k) => k.startsWith('assets/cardio_sessions/') && k.endsWith('.json'),
            )
            .toList();
      } catch (_) {
        // Both failed — treat as empty library rather than crashing.
        paths = const [];
      }
    }

    final templates = <CardioSessionTemplate>[];
    for (final path in paths) {
      try {
        final raw = await rootBundle.loadString(path);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        templates.add(CardioSessionTemplate.fromJson(json));
      } catch (_) {
        // Swallow individual template failures — one bad file shouldn't
        // break the whole library.
      }
    }

    templates.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _cache = templates;
    return templates;
  }

  /// Convenience filter: templates for a given sport.
  Future<List<CardioSessionTemplate>> loadForSport(Sport sport) async {
    final all = await loadAll();
    return all.where((t) => t.sport == sport).toList();
  }

  /// Instantiate a [CardioSession] from a template. The returned session
  /// has a fresh UUID, fresh interval UUIDs, and no persistence — the
  /// caller saves it via [SessionRepository.createCardio].
  CardioSession instantiate(
    CardioSessionTemplate template, {
    required String sessionId,
    required String Function() newIntervalId,
    String? trainingCycleId,
    int? periodNumber,
    int? dayNumber,
    DateTime? scheduledDate,
  }) {
    final now = DateTime.now();
    final planned = template.intervals
        .asMap()
        .entries
        .map(
          (entry) => SessionInterval(
            id: newIntervalId(),
            sessionId: sessionId,
            orderIndex: entry.key,
            intent: entry.value.intent,
            targetKind: entry.value.targetKind,
            targetDurationSec: entry.value.targetDurationSec,
            targetDistanceM: entry.value.targetDistanceM,
            targetHrZone: entry.value.targetHrZone,
            targetPaceZone: entry.value.targetPaceZone,
            targetPowerZone: entry.value.targetPowerZone,
            notes: entry.value.notes,
          ),
        )
        .toList();

    // Aggregate planned distance / duration from intervals so the
    // summary card shows meaningful pre-execution numbers.
    int? plannedDuration;
    double? plannedDistance;
    for (final i in planned) {
      if (i.targetDurationSec != null) {
        plannedDuration = (plannedDuration ?? 0) + i.targetDurationSec!;
      }
      if (i.targetDistanceM != null) {
        plannedDistance = (plannedDistance ?? 0) + i.targetDistanceM!;
      }
    }

    return CardioSession(
      id: sessionId,
      trainingCycleId: trainingCycleId,
      sport: template.sport,
      source: SessionSource.userPlanned,
      status: WorkoutStatus.incomplete,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: template.name,
      label: template.name,
      scheduledDate: scheduledDate ?? now,
      notes: template.description,
      intervals: planned,
      detail: CardioDetail(
        plannedDurationSec: plannedDuration,
        plannedDistanceM: plannedDistance,
      ),
    );
  }
}
