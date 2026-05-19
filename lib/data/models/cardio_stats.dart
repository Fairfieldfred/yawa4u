import '../../core/constants/sports.dart';
import 'session.dart';

/// Aggregated cardio statistics for a list of [CardioSession]s.
///
/// Built once via the factory and then consumed by the Stats screen and
/// any home-screen summary widgets. All totals are in the canonical storage
/// units (meters, seconds, bpm); formatting to km/mi/mm:ss happens in the
/// presentation layer via [CardioConversions].
class CardioStats {
  final int totalSessions;
  final int totalDurationSec;
  final double totalDistanceM;
  final int completedSessions;
  final int skippedSessions;
  final Map<Sport, SportAggregate> perSport;
  final List<WeeklyVolumeBucket> weeklyBuckets;

  const CardioStats({
    required this.totalSessions,
    required this.totalDurationSec,
    required this.totalDistanceM,
    required this.completedSessions,
    required this.skippedSessions,
    required this.perSport,
    required this.weeklyBuckets,
  });

  /// Empty stats — handy placeholder while data loads.
  const CardioStats.empty()
    : totalSessions = 0,
      totalDurationSec = 0,
      totalDistanceM = 0,
      completedSessions = 0,
      skippedSessions = 0,
      perSport = const {},
      weeklyBuckets = const [];

  bool get isEmpty => totalSessions == 0;

  /// Build stats from a full list of cardio sessions. Strength sessions are
  /// ignored (filtered out up front) so it's safe to pass a mixed list.
  factory CardioStats.fromSessions(List<Session> input) {
    final sessions = input.whereType<CardioSession>().toList();
    if (sessions.isEmpty) return const CardioStats.empty();

    int completed = 0;
    int skipped = 0;
    int totalDuration = 0;
    double totalDistance = 0;

    // Per-sport aggregation accumulators
    final perSportAgg = <Sport, _SportAggregateBuilder>{};
    // Week buckets: key is the weekStart DateTime (midnight Monday)
    final weekMap = <DateTime, _WeeklyVolumeBucketBuilder>{};

    for (final s in sessions) {
      if (s.isCompleted) completed++;
      if (s.isSkipped) skipped++;

      final duration = s.detail?.actualDurationSec ?? 0;
      final distance = s.detail?.actualDistanceM ?? 0.0;

      totalDuration += duration;
      totalDistance += distance;

      // Per-sport rollup
      final sportAgg = perSportAgg.putIfAbsent(
        s.sport,
        () => _SportAggregateBuilder(sport: s.sport),
      );
      sportAgg.add(s);

      // Weekly rollup — only for sessions with a known date
      final anchor = s.scheduledDate ?? s.completedDate ?? s.startTime;
      if (anchor != null) {
        final weekStart = _startOfWeek(anchor);
        final bucket = weekMap.putIfAbsent(
          weekStart,
          () => _WeeklyVolumeBucketBuilder(weekStart: weekStart),
        );
        bucket.add(s.sport, duration, distance);
      }
    }

    final weekly = weekMap.values.map((b) => b.build()).toList()..sort((a, b) => a.weekStart.compareTo(b.weekStart));

    final perSport = <Sport, SportAggregate>{
      for (final e in perSportAgg.entries) e.key: e.value.build(),
    };

    return CardioStats(
      totalSessions: sessions.length,
      totalDurationSec: totalDuration,
      totalDistanceM: totalDistance,
      completedSessions: completed,
      skippedSessions: skipped,
      perSport: perSport,
      weeklyBuckets: weekly,
    );
  }

  /// Return the weekly buckets trimmed to the last [n] calendar weeks,
  /// padding missing weeks with empty buckets so the chart X-axis is
  /// continuous.
  List<WeeklyVolumeBucket> recentWeeks(int n) {
    if (n <= 0) return const [];
    final today = DateTime.now();
    final thisWeek = _startOfWeek(today);
    final startWeek = thisWeek.subtract(Duration(days: 7 * (n - 1)));
    final byStart = {for (final b in weeklyBuckets) b.weekStart: b};

    final out = <WeeklyVolumeBucket>[];
    for (var i = 0; i < n; i++) {
      final week = startWeek.add(Duration(days: 7 * i));
      out.add(byStart[week] ?? WeeklyVolumeBucket.empty(week));
    }
    return out;
  }

  /// Midnight Monday of the ISO week containing [date]. Kept static + pure
  /// so the Stats screen can use it without pulling in the full model.
  static DateTime _startOfWeek(DateTime date) => startOfWeekPublic(date);

  /// Public wrapper around [_startOfWeek] — handy for callers that need
  /// the same week-bucketing logic without going through a full stats
  /// computation (e.g., current-week strength session count).
  static DateTime startOfWeekPublic(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    // DateTime.weekday: Monday = 1, Sunday = 7.
    final daysFromMonday = local.weekday - 1;
    return local.subtract(Duration(days: daysFromMonday));
  }
}

/// Per-sport aggregate within a [CardioStats].
class SportAggregate {
  final Sport sport;
  final int sessions;
  final int totalDurationSec;
  final double totalDistanceM;
  final int? avgHr;
  final double bestDistanceM;
  final int bestDurationSec;

  const SportAggregate({
    required this.sport,
    required this.sessions,
    required this.totalDurationSec,
    required this.totalDistanceM,
    required this.avgHr,
    required this.bestDistanceM,
    required this.bestDurationSec,
  });
}

class _SportAggregateBuilder {
  _SportAggregateBuilder({required this.sport});

  final Sport sport;
  int sessions = 0;
  int totalDurationSec = 0;
  double totalDistanceM = 0;
  double bestDistanceM = 0;
  int bestDurationSec = 0;
  int _hrTotal = 0;
  int _hrCount = 0;

  void add(CardioSession s) {
    sessions++;
    final duration = s.detail?.actualDurationSec ?? 0;
    final distance = s.detail?.actualDistanceM ?? 0.0;
    totalDurationSec += duration;
    totalDistanceM += distance;
    if (distance > bestDistanceM) bestDistanceM = distance;
    if (duration > bestDurationSec) bestDurationSec = duration;
    final hr = s.detail?.averageHr;
    if (hr != null) {
      _hrTotal += hr;
      _hrCount++;
    }
  }

  SportAggregate build() {
    return SportAggregate(
      sport: sport,
      sessions: sessions,
      totalDurationSec: totalDurationSec,
      totalDistanceM: totalDistanceM,
      avgHr: _hrCount > 0 ? (_hrTotal / _hrCount).round() : null,
      bestDistanceM: bestDistanceM,
      bestDurationSec: bestDurationSec,
    );
  }
}

/// One week's cardio volume, broken down per sport.
class WeeklyVolumeBucket {
  final DateTime weekStart;
  final Map<Sport, WeeklySportVolume> perSport;

  const WeeklyVolumeBucket({
    required this.weekStart,
    required this.perSport,
  });

  WeeklyVolumeBucket.empty(this.weekStart) : perSport = const {};

  /// Total duration across all sports for this week.
  int get totalDurationSec => perSport.values.fold(0, (sum, v) => sum + v.durationSec);

  /// Total distance across all sports for this week.
  double get totalDistanceM => perSport.values.fold(0, (sum, v) => sum + v.distanceM);

  /// Total session count across all sports for this week.
  int get totalSessions => perSport.values.fold(0, (sum, v) => sum + v.sessions);

  bool get isEmpty => totalSessions == 0;
}

/// Volume for a single sport in a single week.
class WeeklySportVolume {
  final Sport sport;
  final int sessions;
  final int durationSec;
  final double distanceM;

  const WeeklySportVolume({
    required this.sport,
    required this.sessions,
    required this.durationSec,
    required this.distanceM,
  });
}

class _WeeklyVolumeBucketBuilder {
  _WeeklyVolumeBucketBuilder({required this.weekStart});

  final DateTime weekStart;
  final Map<Sport, _WeeklySportVolumeBuilder> _perSport = {};

  void add(Sport sport, int durationSec, double distanceM) {
    final builder = _perSport.putIfAbsent(
      sport,
      () => _WeeklySportVolumeBuilder(sport: sport),
    );
    builder.sessions++;
    builder.durationSec += durationSec;
    builder.distanceM += distanceM;
  }

  WeeklyVolumeBucket build() {
    final map = <Sport, WeeklySportVolume>{
      for (final e in _perSport.entries) e.key: e.value.build(),
    };
    return WeeklyVolumeBucket(weekStart: weekStart, perSport: map);
  }
}

class _WeeklySportVolumeBuilder {
  _WeeklySportVolumeBuilder({required this.sport});

  final Sport sport;
  int sessions = 0;
  int durationSec = 0;
  double distanceM = 0;

  WeeklySportVolume build() {
    return WeeklySportVolume(
      sport: sport,
      sessions: sessions,
      durationSec: durationSec,
      distanceM: distanceM,
    );
  }
}
