import 'dart:async';
import 'dart:convert';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
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

/// Connection status for the Strava integration — exposed so the
/// Integrations screen can render the right state without reaching into
/// service internals.
enum StravaSyncStatus {
  /// Strava credentials aren't configured (missing client_id).
  unconfigured,

  /// Client credentials are present but the user hasn't connected yet.
  notConnected,

  /// Connected — ready to sync.
  ready,

  /// A sync is in progress.
  syncing,
}

/// Outcome of a single sync attempt.
class StravaSyncResult {
  final int imported;
  final int skippedDuplicate;
  final int skippedUnsupportedType;
  final int failed;
  final String? error;
  final DateTime syncedAt;

  const StravaSyncResult({
    required this.imported,
    required this.skippedDuplicate,
    required this.skippedUnsupportedType,
    required this.failed,
    required this.syncedAt,
    this.error,
  });

  StravaSyncResult.errorOnly({required this.error})
      : imported = 0,
        skippedDuplicate = 0,
        skippedUnsupportedType = 0,
        failed = 0,
        syncedAt = DateTime.now();

  bool get isSuccess => error == null;
}

/// Strava integration.
///
/// Flow:
///   1. [connect] opens Strava's OAuth consent page in a secure in-app
///      browser (via `flutter_web_auth_2`). On success the redirect URI
///      embeds an auth code in its query string.
///   2. The service exchanges the code for an access token + refresh
///      token via Strava's `/oauth/token` endpoint. Tokens live in
///      SharedPreferences.
///   3. [syncNow] pulls activities updated since the persisted cursor,
///      filters to cardio, maps each one to a [CardioSession], and
///      writes via [SessionRepository]. Dedupe by `externalId`.
///   4. Access tokens are 6 hours — [_refreshIfNeeded] transparently
///      swaps in the refresh token when needed.
///
/// Requires client credentials supplied via `--dart-define` (so secrets
/// never ship in source):
///
/// ```
/// flutter run --dart-define=STRAVA_CLIENT_ID=xxx \
///             --dart-define=STRAVA_CLIENT_SECRET=yyy
/// ```
///
/// Register the redirect URI (`yawa4u://strava-callback`) at
/// https://www.strava.com/settings/api.
class StravaIntegrationService {
  StravaIntegrationService({
    required SessionRepository sessionRepository,
    required SharedPreferences prefs,
    required AnalyticsService analytics,
    http.Client? httpClient,
  })  : _sessionRepository = sessionRepository,
        _prefs = prefs,
        _analytics = analytics,
        _httpClient = httpClient ?? http.Client();

  static const String clientId = String.fromEnvironment('STRAVA_CLIENT_ID');
  static const String clientSecret = String.fromEnvironment(
    'STRAVA_CLIENT_SECRET',
  );
  static const String redirectScheme = 'yawa4u';
  static const String redirectUri = '$redirectScheme://strava-callback';
  static const String callbackUrlScheme = redirectScheme;

  static const String _authBase = 'https://www.strava.com/oauth/authorize';
  static const String _tokenUrl = 'https://www.strava.com/oauth/token';
  static const String _apiBase = 'https://www.strava.com/api/v3';
  static const String _scope = 'read,activity:read_all';

  static const String _kAccessToken = 'strava_access_token';
  static const String _kRefreshToken = 'strava_refresh_token';
  static const String _kExpiresAt = 'strava_expires_at_unix';
  static const String _kAthleteId = 'strava_athlete_id';
  static const String _kLastSyncAt = 'strava_last_sync_unix';

  static const Duration _initialLookback = Duration(days: 60);

  final SessionRepository _sessionRepository;
  final SharedPreferences _prefs;
  final AnalyticsService _analytics;
  final http.Client _httpClient;
  final Uuid _uuid = const Uuid();

  static final Logger _log = Logger('StravaIntegrationService');

  /// Whether client credentials are present at build time. When false,
  /// the UI card should guide the user toward a note about configuring
  /// the app, not toward a Connect button that will fail.
  bool get isConfigured => clientId.isNotEmpty && clientSecret.isNotEmpty;

  bool get hasTokens => _prefs.getString(_kAccessToken) != null;

  DateTime? get lastSyncAt {
    final ms = _prefs.getInt(_kLastSyncAt);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<StravaSyncStatus> currentStatus() async {
    if (!isConfigured) return StravaSyncStatus.unconfigured;
    if (!hasTokens) return StravaSyncStatus.notConnected;
    return StravaSyncStatus.ready;
  }

  // ---------------------------------------------------------------------------
  // Connect / disconnect
  // ---------------------------------------------------------------------------

  /// Launch the OAuth flow. Returns true on success.
  ///
  /// Strava rejects auth attempts without a registered client_id, so we
  /// short-circuit gracefully when [isConfigured] is false.
  Future<bool> connect() async {
    if (!isConfigured) return false;

    final uri = Uri.parse(_authBase).replace(queryParameters: {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'approval_prompt': 'auto',
      'scope': _scope,
    });

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: uri.toString(),
        callbackUrlScheme: callbackUrlScheme,
      );
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return false;

      final exchanged = await _exchangeCodeForToken(code);
      await _analytics.instance.logEvent(
        name: exchanged
            ? 'strava_connected'
            : 'strava_connect_failed',
      );
      return exchanged;
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return false;
    }
  }

  /// Disconnect by dropping tokens locally. The user can also revoke at
  /// Strava's side via https://www.strava.com/settings/apps, which would
  /// make the refresh token 401 on next use — handled in [_refreshIfNeeded].
  Future<void> disconnect() async {
    await _prefs.remove(_kAccessToken);
    await _prefs.remove(_kRefreshToken);
    await _prefs.remove(_kExpiresAt);
    await _prefs.remove(_kAthleteId);
    await _prefs.remove(_kLastSyncAt);
  }

  Future<bool> _exchangeCodeForToken(String code) async {
    final response = await _httpClient.post(
      Uri.parse(_tokenUrl),
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'grant_type': 'authorization_code',
      },
    );
    if (response.statusCode != 200) {
      _log.warning('Token exchange failed: ${response.statusCode}');
      return false;
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _persistTokens(data);
    return true;
  }

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    await _prefs.setString(_kAccessToken, data['access_token'] as String);
    await _prefs.setString(_kRefreshToken, data['refresh_token'] as String);
    await _prefs.setInt(
      _kExpiresAt,
      DateTime.fromMillisecondsSinceEpoch(
        (data['expires_at'] as int) * 1000,
      ).millisecondsSinceEpoch,
    );
    final athlete = data['athlete'];
    if (athlete is Map<String, dynamic> && athlete['id'] != null) {
      await _prefs.setInt(_kAthleteId, athlete['id'] as int);
    }
  }

  Future<String?> _refreshIfNeeded() async {
    final expiresAtMs = _prefs.getInt(_kExpiresAt);
    final access = _prefs.getString(_kAccessToken);
    final refresh = _prefs.getString(_kRefreshToken);
    if (access == null || refresh == null || expiresAtMs == null) {
      return null;
    }
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    // Refresh 5 minutes early to avoid races on slow connections.
    if (expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return access;
    }
    final response = await _httpClient.post(
      Uri.parse(_tokenUrl),
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refresh,
      },
    );
    if (response.statusCode != 200) {
      // Refresh token is dead — force the user back through connect.
      await disconnect();
      return null;
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await _persistTokens(data);
    return _prefs.getString(_kAccessToken);
  }

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  Future<StravaSyncResult> syncNow() async {
    if (!isConfigured) {
      return StravaSyncResult.errorOnly(
        error: 'Strava is not configured on this build.',
      );
    }
    await _analytics.instance.logEvent(name: 'strava_sync_started');
    final token = await _refreshIfNeeded();
    if (token == null) {
      await _analytics.instance.logEvent(
        name: 'strava_sync_failed',
        parameters: {'error_category': 'no_token'},
      );
      return StravaSyncResult.errorOnly(
        error: 'Not connected to Strava. Please reconnect.',
      );
    }

    try {
      final now = DateTime.now();
      final lastSyncMs = _prefs.getInt(_kLastSyncAt);
      final after = lastSyncMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
          : now.subtract(_initialLookback);

      final activities = await _fetchActivitiesSince(token, after);
      var imported = 0;
      var duplicates = 0;
      var unsupported = 0;
      var failed = 0;

      for (final a in activities) {
        final sport = _mapSport(a['type'] as String? ?? '');
        if (sport == null) {
          unsupported++;
          continue;
        }
        final activityId = a['id'];
        if (activityId == null) {
          failed++;
          continue;
        }
        final externalId = 'strava-$activityId';
        final existing =
            await _sessionRepository.getByExternalId(externalId);
        if (existing != null) {
          duplicates++;
          continue;
        }
        try {
          final session = _buildSession(
            activity: a,
            sport: sport,
            externalId: externalId,
          );
          await _sessionRepository.createCardio(session);
          imported++;
        } catch (e, stack) {
          Sentry.captureException(e, stackTrace: stack);
          failed++;
        }
      }

      await _prefs.setInt(_kLastSyncAt, now.millisecondsSinceEpoch);
      await _analytics.instance.logEvent(
        name: 'strava_sync_completed',
        parameters: {
          'imported': imported,
          'duplicates': duplicates,
          'unsupported': unsupported,
          'failed': failed,
        },
      );
      return StravaSyncResult(
        imported: imported,
        skippedDuplicate: duplicates,
        skippedUnsupportedType: unsupported,
        failed: failed,
        syncedAt: now,
      );
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      await _analytics.instance.logEvent(
        name: 'strava_sync_failed',
        parameters: {'error_category': 'fetch_error'},
      );
      return StravaSyncResult.errorOnly(error: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> _fetchActivitiesSince(
    String token,
    DateTime after,
  ) async {
    final activities = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final uri = Uri.parse('$_apiBase/athlete/activities').replace(
        queryParameters: {
          'after': (after.millisecondsSinceEpoch ~/ 1000).toString(),
          'per_page': '50',
          'page': '$page',
        },
      );
      final response = await _httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        throw StateError(
          'Strava activities fetch failed: ${response.statusCode}',
        );
      }
      final list = jsonDecode(response.body) as List;
      if (list.isEmpty) break;
      activities.addAll(list.cast<Map<String, dynamic>>());
      if (list.length < 50) break;
      page++;
      // Safety ceiling — Strava rate-limits at 100 requests / 15 min.
      if (page > 20) break;
    }
    return activities;
  }

  /// Map Strava's activity `type` string to our [Sport] enum. Returns
  /// null for unsupported types so callers count them as "skipped
  /// unsupported" rather than failing.
  Sport? _mapSport(String type) {
    final normalized = type.toUpperCase();
    if (normalized.contains('RUN') ||
        normalized == 'TRAILRUN' ||
        normalized == 'VIRTUALRUN' ||
        normalized == 'WALK' ||
        normalized == 'HIKE') {
      return Sport.run;
    }
    if (normalized.contains('RIDE') ||
        normalized.contains('CYCL') ||
        normalized == 'EBIKERIDE' ||
        normalized == 'MOUNTAINBIKERIDE' ||
        normalized == 'GRAVELRIDE' ||
        normalized == 'VIRTUALRIDE') {
      return Sport.bike;
    }
    if (normalized.contains('SWIM')) {
      return Sport.swim;
    }
    return null;
  }

  CardioSession _buildSession({
    required Map<String, dynamic> activity,
    required Sport sport,
    required String externalId,
  }) {
    DateTime? parseStart() {
      final raw = activity['start_date_local'] ?? activity['start_date'];
      if (raw is String) {
        try {
          return DateTime.parse(raw);
        } on FormatException {
          return null;
        }
      }
      return null;
    }

    final startTime = parseStart();
    final movingSec = (activity['moving_time'] as num?)?.toInt();
    final elapsedSec = (activity['elapsed_time'] as num?)?.toInt();
    final distanceM = (activity['distance'] as num?)?.toDouble();
    final elevationGainM = (activity['total_elevation_gain'] as num?)?.toDouble();
    final avgHr = (activity['average_heartrate'] as num?)?.toInt();
    final maxHr = (activity['max_heartrate'] as num?)?.toInt();
    final avgWatts = (activity['average_watts'] as num?)?.toDouble();
    final avgSpeedMps = (activity['average_speed'] as num?)?.toDouble();

    final detail = CardioDetail(
      actualDurationSec: movingSec ?? elapsedSec,
      actualDistanceM: distanceM,
      averageHr: avgHr,
      maxHr: maxHr,
      averagePowerWatts: avgWatts,
      averageSpeedMps: avgSpeedMps,
      elevationGainM: elevationGainM,
    );

    final endTime = startTime != null && movingSec != null
        ? startTime.add(Duration(seconds: movingSec))
        : null;

    return CardioSession(
      id: _uuid.v4(),
      trainingCycleId: null,
      sport: sport,
      source: SessionSource.strava,
      status: WorkoutStatus.completed,
      scheduledDate: startTime,
      completedDate: endTime ?? startTime,
      startTime: startTime,
      endTime: endTime,
      externalId: externalId,
      label: activity['name'] as String?,
      notes: activity['description'] as String?,
      detail: detail,
    );
  }
}
