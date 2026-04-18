import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/sports.dart';
import '../../data/models/cardio_feedback.dart';
import '../../data/models/cycle_period.dart';
import '../../data/models/session.dart';
import '../../data/models/sport_zone.dart';
import 'database_providers.dart';

// ---------------------------------------------------------------------------
// Session streams
// ---------------------------------------------------------------------------

/// All sessions (strength + cardio), reactive.
final sessionsProvider = StreamProvider<List<Session>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchAll();
});

/// Sessions for a given training cycle, reactive. Mirrors the existing
/// [workoutsByTrainingCycleProvider] but returns the polymorphic Session
/// type — cardio sessions included.
final sessionsByTrainingCycleProvider = StreamProvider.autoDispose
    .family<List<Session>, String>((ref, trainingCycleId) {
      final repo = ref.watch(sessionRepositoryProvider);
      return repo.watchByTrainingCycleId(trainingCycleId);
    });

/// Sessions filtered by sport (e.g. "all runs in this cycle").
final sessionsBySportProvider = StreamProvider.autoDispose
    .family<List<Session>, ({String? trainingCycleId, Sport sport})>(
  (ref, params) {
    final repo = ref.watch(sessionRepositoryProvider);
    final stream = params.trainingCycleId == null
        ? repo.watchBySport(params.sport)
        : repo
            .watchByTrainingCycleId(params.trainingCycleId!)
            .map((list) => list.where((s) => s.sport == params.sport).toList());
    return stream;
  },
);

/// All cardio sessions (non-strength), reactive. Handy for the Cardio tab
/// of the stats screen.
final cardioSessionsProvider = StreamProvider<List<Session>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchCardio();
});

/// Sessions whose scheduledDate falls within `[start, end]`.
/// Used by the weekly-volume summary widget.
final sessionsInDateRangeProvider = StreamProvider.autoDispose.family<
  List<Session>,
  ({DateTime start, DateTime end})
>((ref, range) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchByDateRange(range.start, range.end);
});

/// Single session by ID. Loads children (exercises / cardio detail /
/// intervals) but not high-resolution samples. Prefer
/// [sessionWithSamplesProvider] for detail screens that need GPS / HR
/// streams.
final sessionProvider = FutureProvider.autoDispose.family<Session?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getById(id);
});

/// Single session by ID with samples loaded. Intended for cardio detail
/// screens that plot GPS / HR traces. Heavy — don't use from lists.
final sessionWithSamplesProvider = FutureProvider.autoDispose
    .family<Session?, String>((ref, id) async {
      final repo = ref.watch(sessionRepositoryProvider);
      return repo.getById(id, includeSamples: true);
    });

// ---------------------------------------------------------------------------
// Cycle periods (cardio periodization)
// ---------------------------------------------------------------------------

/// All [CyclePeriod] rows for a cycle, reactive.
final cyclePeriodsProvider = StreamProvider.autoDispose
    .family<List<CyclePeriod>, String>((ref, cycleId) {
      final repo = ref.watch(cyclePeriodRepositoryProvider);
      return repo.watchByTrainingCycleId(cycleId);
    });

// ---------------------------------------------------------------------------
// Sport zones
// ---------------------------------------------------------------------------

/// Zones configured for a given sport, reactive.
final sportZonesProvider = StreamProvider.autoDispose.family<
  List<SportZone>,
  Sport
>((ref, sport) {
  final repo = ref.watch(sportZoneRepositoryProvider);
  return repo.watchBySport(sport);
});

// ---------------------------------------------------------------------------
// Cardio feedback
// ---------------------------------------------------------------------------

/// Cardio feedback for a single session, reactive.
final cardioFeedbackProvider = StreamProvider.autoDispose
    .family<CardioFeedback?, String>((ref, sessionId) {
      final repo = ref.watch(cardioFeedbackRepositoryProvider);
      return repo.watchForSession(sessionId);
    });
