import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/sports.dart';
import '../models/cardio_detail.dart';
import '../models/session.dart';
import '../repositories/session_repository.dart';
import 'analytics_service.dart';

/// Health Sync status — exposed so the Integrations screen can render the
/// right state without poking at [HealthSyncService] internals.
enum HealthSyncStatus {
  /// The platform doesn't support this integration (web / desktop).
  unavailable,

  /// Supported but the user hasn't granted permissions yet.
  notAuthorized,

  /// Granted — ready to sync.
  ready,

  /// A sync is in progress.
  syncing,
}

/// Outcome of a single [HealthSyncService.syncNow] call. Consumers use
/// this to render "Synced N sessions, M skipped" without needing to
/// inspect individual items.
class HealthSyncResult {
  final int imported;
  final int skippedDuplicate;
  final int skippedUnsupportedType;
  final int failed;

  /// Total health data points returned by the health store before any
  /// filtering. Useful for diagnosing "connected but nothing imported"
  /// issues — a zero here means the health store isn't returning data
  /// for this app at all (permissions or source-app config problem).
  final int totalPoints;

  /// Sessions inferred from raw data streams (DISTANCE_DELTA + HR)
  /// rather than from WORKOUT / ExerciseSessionRecord entries. This
  /// happens on Android when a third-party app (e.g. Peloton) writes
  /// distance and HR but not exercise session records to Health Connect.
  final int inferred;

  final String? error;
  final DateTime syncedAt;

  const HealthSyncResult({
    required this.imported,
    required this.skippedDuplicate,
    required this.skippedUnsupportedType,
    required this.failed,
    required this.totalPoints,
    this.inferred = 0,
    required this.syncedAt,
    this.error,
  });

  /// Build an error-only result. [syncedAt] is the instant the error was
  /// produced — kept so the Integrations screen can show "Last attempt at
  /// HH:MM" regardless of success.
  HealthSyncResult.errorOnly({required this.error})
    : imported = 0,
      skippedDuplicate = 0,
      skippedUnsupportedType = 0,
      failed = 0,
      totalPoints = 0,
      inferred = 0,
      syncedAt = DateTime.now();

  bool get isSuccess => error == null;
}

/// Integration with Apple HealthKit (iOS) and Google Health Connect
/// (Android). Unified by the `health` plugin.
///
/// Scope v1: one-way read of cardio workouts (run / bike / swim) into
/// [CardioSession]s. Strength sessions from Health are ignored — the user
/// logs strength in-app. Writes back to Health are deliberately out of
/// scope for v1 but the permissions + entitlements are requested so a
/// future "publish to Health" toggle is additive.
///
/// Peloton workouts reach YAWA4U through this service: on iOS they appear
/// in Apple Health when the user pairs the Peloton app; on Android they
/// appear in Health Connect. There's no Peloton-specific code path.
///
/// Idempotency: every imported session is stamped with the HealthKit /
/// Health Connect workout UUID as `externalId`. Re-syncs check this via
/// [SessionRepository.getByExternalId] before inserting. A "last synced
/// at" cursor in SharedPreferences narrows each query to the delta since
/// the previous run.
class HealthSyncService {
  HealthSyncService({
    required SessionRepository sessionRepository,
    required SharedPreferences prefs,
    required AnalyticsService analytics,
    Health? health,
  }) : _sessionRepository = sessionRepository,
       _prefs = prefs,
       _analytics = analytics,
       _health = health ?? Health();

  static const String _kLastSyncKey = 'health_sync_last_run_at';
  // Apple HealthKit does not expose read-permission status to apps —
  // [_health.hasPermissions] returns null on iOS even after the user has
  // fully granted access. We persist this flag when
  // [requestPermissions] returns true so [currentStatus] has something
  // trustworthy to read on iOS. Android's Health Connect exposes live
  // status, so the flag is iOS-only by design.
  static const String _kGrantedKey = 'health_permissions_granted';
  static const Duration _initialLookback = Duration(days: 90);

  /// Data types we request read access to. Kept narrow — anything we
  /// don't plan to consume in v1 is omitted to reduce the scope of the
  /// permission prompt.
  static const List<HealthDataType> _readTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static final List<HealthDataAccess> _readPermissions = List.filled(
    _readTypes.length,
    HealthDataAccess.READ,
  );

  static final Logger _log = Logger('HealthSyncService');

  final SessionRepository _sessionRepository;
  final SharedPreferences _prefs;
  final AnalyticsService _analytics;
  final Health _health;
  final Uuid _uuid = const Uuid();

  bool _configured = false;

  /// Whether the `health` plugin can run at all on this platform. Web +
  /// macOS / Windows / Linux return false — the Integrations screen uses
  /// this to show an "unsupported platform" card.
  bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Platform-appropriate display name for the data store.
  String get providerName {
    if (!isSupported) return 'Health';
    if (kIsWeb) return 'Health';
    return Platform.isIOS ? 'Apple Health' : 'Health Connect';
  }

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Current authorization status. Returns [HealthSyncStatus.unavailable]
  /// on unsupported platforms so UI can render a single, consistent path.
  ///
  /// iOS nuance: [_health.hasPermissions] returns null on iOS for
  /// read-only permissions even when access is fully granted (Apple
  /// privacy design — apps can't detect what the user chose). On iOS we
  /// fall back to the [_kGrantedKey] flag set by [requestPermissions];
  /// if the user revokes in Settings later, the next sync still works
  /// (Apple silently returns empty results), so the UX degrades to
  /// "connected but no new data" rather than "stuck as disconnected."
  Future<HealthSyncStatus> currentStatus() async {
    if (!isSupported) return HealthSyncStatus.unavailable;
    try {
      await _ensureConfigured();
      final granted = await _health.hasPermissions(
        _readTypes,
        permissions: _readPermissions,
      );
      if (granted == true) return HealthSyncStatus.ready;
      if (!kIsWeb && Platform.isIOS && (_prefs.getBool(_kGrantedKey) ?? false)) {
        return HealthSyncStatus.ready;
      }
      return HealthSyncStatus.notAuthorized;
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return HealthSyncStatus.notAuthorized;
    }
  }

  /// Request read permissions. Returns true if every requested type is
  /// authorized after the prompt. Logs an analytics event with the outcome
  /// (no PII — just granted/denied).
  ///
  /// On success, persists [_kGrantedKey] so [currentStatus] can report
  /// ready on iOS without needing Apple to tell us anything (see notes
  /// in [currentStatus]).
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(
        _readTypes,
        permissions: _readPermissions,
      );
      await _analytics.logHealthPermissions(
        provider: providerName,
        granted: granted,
      );
      if (granted) {
        await _prefs.setBool(_kGrantedKey, true);
      }
      return granted;
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return false;
    }
  }

  /// Pull workouts from the health store and import any new ones as
  /// [CardioSession]s. Narrowed by a persisted "last synced at" cursor; on
  /// first run it looks back [_initialLookback].
  Future<HealthSyncResult> syncNow() async {
    if (!isSupported) {
      return HealthSyncResult.errorOnly(
        error: 'Health integration is not supported on this platform.',
      );
    }

    await _analytics.logHealthSyncStarted(provider: providerName);

    try {
      await _ensureConfigured();
      final status = await currentStatus();
      if (status != HealthSyncStatus.ready) {
        await _analytics.logHealthSyncFailed(
          provider: providerName,
          errorCategory: 'not_authorized',
        );
        return HealthSyncResult.errorOnly(
          error: 'Health permissions are not granted.',
        );
      }

      // On Android, log SDK status for diagnostics. A status other than
      // sdkAvailable typically means Health Connect is missing or outdated.
      if (!kIsWeb && Platform.isAndroid) {
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        _log.info('Health Connect SDK status: ${sdkStatus?.name ?? 'null'}');
      }

      final now = DateTime.now();
      final lastSyncMillis = _prefs.getInt(_kLastSyncKey);
      final since = lastSyncMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis)
          : now.subtract(_initialLookback);

      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WORKOUT],
        startTime: since,
        endTime: now,
      );

      _log.info(
        'Health sync: ${points.length} data point(s) returned '
        'from ${since.toIso8601String()} to ${now.toIso8601String()}',
      );

      // Log a breakdown of activity types and sources for diagnostics.
      // This is critical for debugging "connected but nothing imported"
      // issues — e.g. Peloton workouts arriving as an unmapped type.
      if (points.isNotEmpty) {
        final typeCounts = <String, int>{};
        final sourceCounts = <String, int>{};
        for (final p in points) {
          final v = p.value;
          if (v is WorkoutHealthValue) {
            final typeName = v.workoutActivityType.name;
            typeCounts[typeName] = (typeCounts[typeName] ?? 0) + 1;
          }
          final src = p.sourceName;
          if (src.isNotEmpty) {
            sourceCounts[src] = (sourceCounts[src] ?? 0) + 1;
          }
        }
        _log.info('Health sync activity types: $typeCounts');
        _log.info('Health sync sources: $sourceCounts');
      }

      var imported = 0;
      var duplicates = 0;
      var unsupported = 0;
      var failed = 0;
      var inferred = 0;

      for (final p in points) {
        final value = p.value;
        if (value is! WorkoutHealthValue) continue;

        final sport = _mapSport(value.workoutActivityType);
        if (sport == null) {
          _log.fine(
            'Skipping unsupported type: ${value.workoutActivityType.name} '
            'from ${p.sourceName}',
          );
          unsupported++;
          continue;
        }

        // Dedupe: if a session with this externalId already exists, skip.
        final externalId = _externalIdFor(p);
        final existing = await _sessionRepository.getByExternalId(externalId);
        if (existing != null) {
          duplicates++;
          continue;
        }

        try {
          final session = await _buildSession(
            point: p,
            value: value,
            sport: sport,
            externalId: externalId,
            rangeStart: p.dateFrom,
            rangeEnd: p.dateTo,
          );
          await _sessionRepository.createCardio(session);
          imported++;
        } catch (e, stack) {
          Sentry.captureException(e, stackTrace: stack);
          failed++;
        }
      }

      // ── Android supplement: infer sessions from raw data streams ──
      //
      // Some third-party apps (notably Peloton) write distance and HR
      // data to Health Connect but DO NOT write ExerciseSessionRecord
      // entries. Always attempt stream inference on Android so we catch
      // these apps regardless of whether other sources contributed
      // WORKOUT records. Deduplication via getByExternalId prevents
      // double-imports when an app writes both record types.
      if (!kIsWeb && Platform.isAndroid) {
        _log.info(
          'Android stream inference: checking for data-stream-only '
          'apps (e.g. Peloton).',
        );
        try {
          final inferredSessions = await _inferSessionsFromStreams(
            since: since,
            until: now,
          );
          for (final session in inferredSessions) {
            try {
              await _sessionRepository.createCardio(session);
              inferred++;
            } catch (e, stack) {
              Sentry.captureException(e, stackTrace: stack);
              failed++;
            }
          }
          if (inferredSessions.isEmpty) {
            _log.info('Stream inference produced 0 sessions.');
          } else {
            _log.info(
              'Stream inference: ${inferredSessions.length} candidate(s), '
              '$inferred imported, $failed failed.',
            );
          }
        } catch (e, stack) {
          _log.warning('Stream inference failed: $e', e, stack);
          Sentry.captureException(e, stackTrace: stack);
        }
      }

      await _prefs.setInt(_kLastSyncKey, now.millisecondsSinceEpoch);

      await _analytics.logHealthSyncCompleted(
        provider: providerName,
        imported: imported + inferred,
        duplicates: duplicates,
        unsupported: unsupported,
        failed: failed,
      );

      return HealthSyncResult(
        imported: imported,
        skippedDuplicate: duplicates,
        skippedUnsupportedType: unsupported,
        failed: failed,
        totalPoints: points.length,
        inferred: inferred,
        syncedAt: now,
      );
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      await _analytics.logHealthSyncFailed(
        provider: providerName,
        errorCategory: 'fetch_error',
      );
      return HealthSyncResult.errorOnly(error: e.toString());
    }
  }

  /// Map the health-plugin [HealthWorkoutActivityType] enum onto our own
  /// [Sport] enum. Matching by the enum's string name keeps us resilient
  /// across minor plugin versions — HealthKit + Health Connect both
  /// periodically add new specific sub-types (e.g. RUNNING_SAND,
  /// BIKING_SPINNING) and we'd rather classify them broadly than fail
  /// to compile when the plugin adds one we didn't list.
  ///
  /// Strength / weight-training / mind-body activities intentionally
  /// return null — the user logs strength in-app, and yoga / meditation
  /// / stretching aren't training sessions YAWA tracks.
  Sport? _mapSport(HealthWorkoutActivityType type) {
    final name = type.name.toUpperCase();

    // Run — includes treadmill variants from Health Connect.
    // Use contains('WALKING') to catch WALKING, WALKING_TREADMILL, etc.
    if (name.contains('RUNNING') || name.contains('WALKING') || name == 'HIKING' || name == 'JOGGING') {
      return Sport.run;
    }

    // Bike — includes stationary / spinning variants. ELLIPTICAL is
    // close enough to cycling for cardio-tracking purposes.
    if (name.contains('BIKING') || name.contains('CYCLING') || name == 'SPINNING' || name == 'ELLIPTICAL') {
      return Sport.bike;
    }

    // Swim.
    if (name.contains('SWIMMING') || name == 'SWIM') {
      return Sport.swim;
    }

    // Cardio activities that don't map to run / bike / swim but are
    // still valid training sessions the user would expect to see.
    // Peloton bootcamps, HIIT classes, rowing, etc. commonly arrive
    // under these types from Health Connect.
    if (name == 'HIGH_INTENSITY_INTERVAL_TRAINING' ||
        name == 'ROWING' ||
        name == 'ROWING_MACHINE' ||
        name == 'STAIR_CLIMBING' ||
        name == 'STAIR_CLIMBING_MACHINE' ||
        name == 'CARDIO_DANCE' ||
        name == 'JUMP_ROPE' ||
        name == 'SKATING' ||
        name == 'CROSS_COUNTRY_SKIING' ||
        name == 'DOWNHILL_SKIING' ||
        name == 'SKIING' ||
        name == 'SNOWBOARDING' ||
        name == 'SURFING' ||
        name == 'SAILING' ||
        name == 'OTHER') {
      return Sport.other;
    }

    return null;
  }

  /// Stable identifier for a workout that survives re-sync. The health
  /// plugin exposes [HealthDataPoint.sourceId] and
  /// [HealthDataPoint.uuid] on iOS; on Android it's the record's id. We
  /// concatenate `source|uuid|start` as a defensive compound key so
  /// identical records across sources don't collide.
  String _externalIdFor(HealthDataPoint p) {
    final parts = <String>[
      'health',
      p.sourceName,
      p.sourceId,
      p.uuid,
      p.dateFrom.toIso8601String(),
    ];
    return parts.where((s) => s.isNotEmpty).join('|');
  }

  Future<CardioSession> _buildSession({
    required HealthDataPoint point,
    required WorkoutHealthValue value,
    required Sport sport,
    required String externalId,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final durationSec = rangeEnd.difference(rangeStart).inSeconds;

    // Aggregate HR across this workout's window.
    int? avgHr;
    int? maxHr;
    try {
      final hrPoints = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.HEART_RATE],
        startTime: rangeStart,
        endTime: rangeEnd,
      );
      final numericBeats = <int>[];
      for (final hp in hrPoints) {
        final v = hp.value;
        if (v is NumericHealthValue) {
          final beats = v.numericValue.toInt();
          if (beats > 0) numericBeats.add(beats);
        }
      }
      if (numericBeats.isNotEmpty) {
        numericBeats.sort();
        avgHr = numericBeats.reduce((a, b) => a + b) ~/ numericBeats.length;
        maxHr = numericBeats.last;
      }
    } catch (e, stack) {
      // HR is a bonus — don't fail the import on a HR-sub-query error.
      _log.fine('HR aggregation failed: $e', e, stack);
    }

    final detail = CardioDetail(
      actualDurationSec: durationSec > 0 ? durationSec : null,
      // health 13.x exposes totalDistance as an int (same underlying
      // meters value); our CardioDetail stores it as double for
      // consistency with manually-entered distance.
      actualDistanceM: value.totalDistance?.toDouble(),
      averageHr: avgHr,
      maxHr: maxHr,
    );

    final provider = !kIsWeb && Platform.isIOS ? SessionSource.healthKit : SessionSource.healthConnect;

    return CardioSession(
      id: _uuid.v4(),
      trainingCycleId: null,
      sport: sport,
      source: provider,
      status: WorkoutStatus.completed,
      scheduledDate: rangeStart,
      completedDate: rangeEnd,
      startTime: rangeStart,
      endTime: rangeEnd,
      externalId: externalId,
      detail: detail,
    );
  }

  /// Timestamp of the last completed sync, for the Integrations screen.
  DateTime? get lastSyncAt {
    final ms = _prefs.getInt(_kLastSyncKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Reset the cursor so the next sync looks back over [_initialLookback].
  Future<void> resetCursor() async {
    await _prefs.remove(_kLastSyncKey);
  }

  /// On Android, some third-party apps (notably Peloton) write individual
  /// data streams (distance, HR, calories) to Health Connect but do NOT
  /// write `ExerciseSessionRecord` entries. This method clusters
  /// `DISTANCE_DELTA` records into sessions and enriches each with HR
  /// data from the same time window.
  ///
  /// Returns a list of ready-to-persist [CardioSession]s. Callers must
  /// still call [SessionRepository.createCardio] for each. Duplicates
  /// are filtered here via [SessionRepository.getByExternalId].
  Future<List<CardioSession>> _inferSessionsFromStreams({
    required DateTime since,
    required DateTime until,
  }) async {
    final distancePoints = await _health.getHealthDataFromTypes(
      types: const [HealthDataType.DISTANCE_DELTA],
      startTime: since,
      endTime: until,
    );

    if (distancePoints.isEmpty) return [];

    _log.info(
      'Stream inference: ${distancePoints.length} DISTANCE_DELTA '
      'point(s) to cluster.',
    );

    // Sort by start time for clustering.
    final sorted = List<HealthDataPoint>.from(distancePoints)..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    // Cluster into sessions: a gap of > 30 minutes between consecutive
    // distance points signals a new session. This threshold accommodates
    // brief rest periods within a workout while splitting truly separate
    // activities.
    const gapThreshold = Duration(minutes: 30);
    final clusters = <List<HealthDataPoint>>[];
    var current = <HealthDataPoint>[sorted.first];

    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].dateFrom.difference(current.last.dateTo);
      if (gap > gapThreshold) {
        clusters.add(current);
        current = <HealthDataPoint>[sorted[i]];
      } else {
        current.add(sorted[i]);
      }
    }
    clusters.add(current);

    _log.info('Stream inference: ${clusters.length} cluster(s) formed.');

    final sessions = <CardioSession>[];
    for (final cluster in clusters) {
      final rangeStart = cluster.first.dateFrom;
      final rangeEnd = cluster.last.dateTo;
      final durationSec = rangeEnd.difference(rangeStart).inSeconds;

      // Skip clusters shorter than 1 minute — likely noise.
      if (durationSec < 60) continue;

      // Sum distance from all points in the cluster.
      var totalDistanceM = 0.0;
      for (final p in cluster) {
        final v = p.value;
        if (v is NumericHealthValue) {
          totalDistanceM += v.numericValue.toDouble();
        }
      }

      // Build a stable external ID from source + time range so
      // re-syncs don't create duplicates.
      final sources = <String>{};
      for (final p in cluster) {
        if (p.sourceName.isNotEmpty) sources.add(p.sourceName);
      }
      final externalId =
          'health_inferred|'
          '${sources.join(',')}|'
          '${rangeStart.millisecondsSinceEpoch}|'
          '${rangeEnd.millisecondsSinceEpoch}';

      // Dedupe check.
      final existing = await _sessionRepository.getByExternalId(externalId);
      if (existing != null) continue;

      // Aggregate HR for this time window.
      int? avgHr;
      int? maxHr;
      try {
        final hrPoints = await _health.getHealthDataFromTypes(
          types: const [HealthDataType.HEART_RATE],
          startTime: rangeStart,
          endTime: rangeEnd,
        );
        final beats = <int>[];
        for (final hp in hrPoints) {
          final v = hp.value;
          if (v is NumericHealthValue) {
            final b = v.numericValue.toInt();
            if (b > 0) beats.add(b);
          }
        }
        if (beats.isNotEmpty) {
          beats.sort();
          avgHr = beats.reduce((a, b) => a + b) ~/ beats.length;
          maxHr = beats.last;
        }
      } catch (_) {
        // HR is a bonus — don't fail the import on a sub-query error.
      }

      final sport = _inferSportFromSpeed(totalDistanceM, durationSec);
      final sourceLabel = sources.isNotEmpty ? sources.join(', ') : 'Health Connect';

      final detail = CardioDetail(
        actualDurationSec: durationSec > 0 ? durationSec : null,
        actualDistanceM: totalDistanceM > 0 ? totalDistanceM : null,
        averageHr: avgHr,
        maxHr: maxHr,
      );

      sessions.add(
        CardioSession(
          id: _uuid.v4(),
          trainingCycleId: null,
          sport: sport,
          source: SessionSource.healthConnect,
          status: WorkoutStatus.completed,
          scheduledDate: rangeStart,
          completedDate: rangeEnd,
          startTime: rangeStart,
          endTime: rangeEnd,
          externalId: externalId,
          detail: detail,
          label: 'Imported from $sourceLabel',
        ),
      );
    }

    return sessions;
  }

  /// Rough sport classification from average speed. Used only by the
  /// stream-inference fallback where no explicit activity type exists.
  Sport _inferSportFromSpeed(double distanceM, int durationSec) {
    if (durationSec <= 0 || distanceM <= 0) return Sport.other;
    final speedKmh = (distanceM / 1000) / (durationSec / 3600);
    // > 15 km/h → likely cycling / Peloton ride
    if (speedKmh > 15) return Sport.bike;
    // 3–15 km/h → run or walk
    if (speedKmh >= 3) return Sport.run;
    // < 3 km/h → too slow for locomotion, classify as other
    return Sport.other;
  }

  /// Run a connectivity diagnostic against the health store. Returns a
  /// human-readable report showing SDK status, per-type data availability,
  /// and any errors encountered. Designed to surface on the Integrations
  /// screen when the user taps "Run diagnostics" so we can tell whether
  /// the health store is actually returning data.
  Future<String> runDiagnostics() async {
    final buf = StringBuffer();
    try {
      await _ensureConfigured();
      buf.writeln('Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');

      // Health Connect SDK status (Android only).
      if (!kIsWeb && Platform.isAndroid) {
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        buf.writeln('HC SDK status: ${sdkStatus?.name ?? 'null'}');
      }

      // Permission status.
      final hasPerms = await _health.hasPermissions(
        _readTypes,
        permissions: _readPermissions,
      );
      buf.writeln('hasPermissions: $hasPerms');

      // Probe each data type individually over the last 7 days.
      final now = DateTime.now();
      final since = now.subtract(const Duration(days: 7));
      buf.writeln(
        'Query window: ${since.toIso8601String()} → '
        '${now.toIso8601String()}',
      );

      for (final type in _readTypes) {
        try {
          final points = await _health.getHealthDataFromTypes(
            types: [type],
            startTime: since,
            endTime: now,
          );
          // For WORKOUT, also log source names to verify third-party data.
          if (type == HealthDataType.WORKOUT && points.isNotEmpty) {
            final sources = <String>{};
            for (final p in points) {
              if (p.sourceName.isNotEmpty) sources.add(p.sourceName);
            }
            buf.writeln(
              '  ${type.name}: ${points.length} point(s) '
              'sources=$sources',
            );
          } else {
            buf.writeln('  ${type.name}: ${points.length} point(s)');
          }
        } catch (e) {
          buf.writeln('  ${type.name}: ERROR $e');
        }
      }
    } catch (e) {
      buf.writeln('Diagnostics failed: $e');
    }
    _log.info('Health diagnostics:\n$buf');
    return buf.toString();
  }
}
