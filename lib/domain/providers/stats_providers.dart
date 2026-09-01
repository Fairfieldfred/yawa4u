import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/sports.dart';
import '../../data/models/cardio_stats.dart';
import '../../data/models/session.dart';
import '../../data/models/stats_data.dart';
import '../../data/models/workout.dart';
import 'database_providers.dart';
import 'session_providers.dart';

// ---------------------------------------------------------------------------
// Strength-focused stats.
//
// Phase 6b migration: these providers now read from [sessionRepository]
// (filtered to StrengthSession) so they reflect any strength data in
// the sessions table — both backfilled rows and future writes after the
// workouts table drops. WorkoutStats.fromWorkouts still expects the
// legacy Workout shape, so we convert on the fly via [_toLegacyWorkout].
// ---------------------------------------------------------------------------

Workout _toLegacyWorkout(StrengthSession s) {
  return Workout(
    id: s.id,
    trainingCycleId: s.trainingCycleId ?? '',
    periodNumber: s.periodNumber ?? 1,
    dayNumber: s.dayNumber ?? 1,
    dayName: s.dayName,
    label: s.label,
    status: s.status,
    scheduledDate: s.scheduledDate,
    completedDate: s.completedDate,
    startTime: s.startTime,
    endTime: s.endTime,
    notes: s.notes,
    exercises: s.exercises,
  );
}

List<Workout> _strengthWorkouts(List<Session> sessions) {
  return sessions.whereType<StrengthSession>().map(_toLegacyWorkout).toList();
}

/// Stats for a specific training cycle.
final cycleStatsProvider = FutureProvider.autoDispose.family<WorkoutStats, String>((ref, cycleId) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final sessions = await repo.watchByTrainingCycleId(cycleId).first;
  return WorkoutStats.fromWorkouts(_strengthWorkouts(sessions));
});

/// Stats across all training cycles (lifetime).
///
/// Watches the reactive [sessionsProvider] stream so a sync (cloud or
/// WiFi) landing new sessions updates All Time stats without a manual
/// refresh.
final lifetimeStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final sessions = await ref.watch(sessionsProvider.future);
  return WorkoutStats.fromWorkouts(_strengthWorkouts(sessions));
});

/// All workouts for a specific training cycle (async, non-stream).
final cycleWorkoutsProvider = FutureProvider.autoDispose.family<List<Workout>, String>((ref, cycleId) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final sessions = await repo.watchByTrainingCycleId(cycleId).first;
  return _strengthWorkouts(sessions);
});

// ---------------------------------------------------------------------------
// v5 — Cardio stats.
// ---------------------------------------------------------------------------

/// Lifetime cardio stats (across every cycle + ad-hoc sessions).
///
/// Reactive — rebuilds whenever the underlying [sessionsProvider] stream
/// emits. Prefer [cardioStatsForCycleProvider] when scoping to a cycle.
final cardioStatsProvider = Provider<CardioStats>((ref) {
  final async = ref.watch(sessionsProvider);
  return async.when(
    data: CardioStats.fromSessions,
    loading: () => const CardioStats.empty(),
    error: (_, _) => const CardioStats.empty(),
  );
});

/// Cardio stats for a specific training cycle (reactive).
final cardioStatsForCycleProvider = Provider.autoDispose.family<CardioStats, String>((ref, cycleId) {
  final async = ref.watch(sessionsByTrainingCycleProvider(cycleId));
  return async.when(
    data: CardioStats.fromSessions,
    loading: () => const CardioStats.empty(),
    error: (_, _) => const CardioStats.empty(),
  );
});

/// Cardio stats scoped to a single sport (lifetime).
final cardioStatsBySportProvider = Provider.autoDispose.family<CardioStats, Sport>((ref, sport) {
  final async = ref.watch(sessionsProvider);
  return async.when(
    data: (sessions) => CardioStats.fromSessions(
      sessions.where((s) => s.sport == sport).toList(),
    ),
    loading: () => const CardioStats.empty(),
    error: (_, _) => const CardioStats.empty(),
  );
});

/// The last N calendar weeks of cardio, padded with empty weeks so
/// charts can render a continuous X-axis. Default is 12 weeks.
final recentCardioWeeksProvider = Provider.autoDispose.family<List<WeeklyVolumeBucket>, int>((ref, weeks) {
  final stats = ref.watch(cardioStatsProvider);
  return stats.recentWeeks(weeks);
});

/// Convenience — current-week totals across every sport. Used by the
/// home-screen weekly summary widget.
final thisWeekVolumeProvider = Provider<WeeklyVolumeBucket>((ref) {
  final stats = ref.watch(cardioStatsProvider);
  final weeks = stats.recentWeeks(1);
  return weeks.isEmpty ? WeeklyVolumeBucket.empty(DateTime.now()) : weeks.first;
});

/// Strength sessions logged this week — exposed here (not in
/// workout_providers) so the weekly summary widget can read both paths
/// from one place without depending on the entire workout stack.
final thisWeekStrengthCountProvider = Provider<int>((ref) {
  final async = ref.watch(sessionsProvider);
  return async.when(
    data: (sessions) {
      final start = CardioStats.startOfWeekPublic(DateTime.now());
      final end = start.add(const Duration(days: 7));
      return sessions.where((s) => s.sport == Sport.strength).where(
        (s) {
          final anchor = s.scheduledDate ?? s.completedDate ?? s.startTime;
          return anchor != null && anchor.isAfter(start.subtract(const Duration(seconds: 1))) && anchor.isBefore(end);
        },
      ).length;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});
