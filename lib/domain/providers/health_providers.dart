import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/analytics_service.dart';
import '../../data/services/health_sync_service.dart';
import '../../data/services/strava_integration_service.dart';
import 'database_providers.dart';
import 'onboarding_providers.dart';

/// Provider for [HealthSyncService]. Depends on [sessionRepositoryProvider]
/// for writes, [sharedPreferencesProvider] for the last-sync cursor, and
/// an [AnalyticsService] for event reporting.
final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    analytics: AnalyticsService(),
  );
});

/// Reactive status provider. Re-evaluates whenever the Integrations screen
/// invalidates it (e.g. after a permission prompt).
final healthSyncStatusProvider = FutureProvider.autoDispose<HealthSyncStatus>((
  ref,
) {
  final service = ref.watch(healthSyncServiceProvider);
  return service.currentStatus();
});

/// Provider for [StravaIntegrationService]. Shares the same deps pattern
/// as the Health service.
final stravaIntegrationServiceProvider =
    Provider<StravaIntegrationService>((ref) {
  return StravaIntegrationService(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    analytics: AnalyticsService(),
  );
});

final stravaSyncStatusProvider =
    FutureProvider.autoDispose<StravaSyncStatus>((ref) {
  return ref.watch(stravaIntegrationServiceProvider).currentStatus();
});
