import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/cloud_backup_service.dart';
import 'auth_providers.dart';
import 'onboarding_providers.dart';
import 'sync_providers.dart';

/// SharedPreferences keys — standalone (cloud backup is not onboarding
/// profile data, it just happens to be offered during onboarding).
const _keyCloudBackupEnabled = 'cloud_backup_enabled';
const _keyCloudBackupLastBackupAt = 'cloud_backup_last_backup_at';

/// How stale the last successful backup must be before the app-launch
/// auto-backup fires again.
const _autoBackupInterval = Duration(hours: 24);

/// Provider for [CloudBackupService].
final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  return CloudBackupService(
    backupService: ref.watch(dataBackupServiceProvider),
    authService: ref.watch(firebaseAuthServiceProvider),
    deviceName: ref.watch(wifiSyncServiceProvider).getDeviceName,
  );
});

/// Local cloud-backup preferences.
class CloudBackupSettings {
  final bool enabled;
  final DateTime? lastBackupAt;

  const CloudBackupSettings({required this.enabled, this.lastBackupAt});
}

class CloudBackupSettingsNotifier extends Notifier<CloudBackupSettings> {
  @override
  CloudBackupSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastMillis = prefs.getInt(_keyCloudBackupLastBackupAt);
    return CloudBackupSettings(
      enabled: prefs.getBool(_keyCloudBackupEnabled) ?? false,
      lastBackupAt: lastMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMillis),
    );
  }

  Future<void> setEnabled(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_keyCloudBackupEnabled, value);
    state = CloudBackupSettings(enabled: value, lastBackupAt: state.lastBackupAt);
  }

  Future<void> markBackedUp(DateTime when) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_keyCloudBackupLastBackupAt, when.millisecondsSinceEpoch);
    state = CloudBackupSettings(enabled: state.enabled, lastBackupAt: when);
  }
}

final cloudBackupSettingsProvider = NotifierProvider<CloudBackupSettingsNotifier, CloudBackupSettings>(
  () => CloudBackupSettingsNotifier(),
);

enum CloudBackupRunState { idle, running, success, error }

class CloudBackupStatus {
  final CloudBackupRunState state;
  final String? errorMessage;

  const CloudBackupStatus({required this.state, this.errorMessage});
}

/// Runs backups/restores and exposes progress to the Sync screen.
class CloudBackupController extends Notifier<CloudBackupStatus> {
  bool _inFlight = false;

  @override
  CloudBackupStatus build() => const CloudBackupStatus(state: CloudBackupRunState.idle);

  /// Uploads a backup now. Returns a failure result (without starting a
  /// second upload) if one is already in flight.
  Future<CloudBackupResult> backupNow() async {
    if (_inFlight) {
      return CloudBackupResult(success: false, error: 'Backup already running');
    }
    _inFlight = true;
    state = const CloudBackupStatus(state: CloudBackupRunState.running);
    try {
      final result = await ref.read(cloudBackupServiceProvider).backupNow();
      if (result.success) {
        await ref.read(cloudBackupSettingsProvider.notifier).markBackedUp(DateTime.now());
        ref.invalidate(cloudBackupMetadataProvider);
        state = const CloudBackupStatus(state: CloudBackupRunState.success);
      } else {
        state = CloudBackupStatus(state: CloudBackupRunState.error, errorMessage: result.error);
      }
      return result;
    } finally {
      _inFlight = false;
    }
  }

  /// Silent app-launch backup: runs only when enabled, signed in with a
  /// verified email, and the last successful backup is older than 24h.
  /// Failures are swallowed (already Sentry-logged by the service) and leave
  /// `lastBackupAt` unchanged so the next launch retries.
  ///
  /// Two guards protect the single cloud slot from being clobbered by a
  /// fresh install that signed in before restoring:
  /// - an empty local database is never auto-backed-up, and
  /// - a device that has never backed up won't overwrite an existing cloud
  ///   backup — on a new device, restore (or an explicit manual backup)
  ///   comes first.
  Future<void> maybeAutoBackup() async {
    final settings = ref.read(cloudBackupSettingsProvider);
    if (!settings.enabled) return;

    final auth = ref.read(firebaseAuthServiceProvider);
    if (auth.currentUser == null || !auth.isEmailVerified) return;

    final stats = await ref.read(dataBackupServiceProvider).getStats();
    if (stats.total == 0) return;

    final last = settings.lastBackupAt;
    if (last == null) {
      final existing = await ref.read(cloudBackupServiceProvider).fetchMetadata();
      if (existing != null) return;
    } else if (DateTime.now().difference(last) < _autoBackupInterval) {
      return;
    }

    await backupNow();
  }

  /// Downloads and merges the latest cloud backup into the local database.
  Future<CloudRestoreResult> restore() async {
    if (_inFlight) {
      return CloudRestoreResult(success: false, error: 'Backup already running');
    }
    _inFlight = true;
    state = const CloudBackupStatus(state: CloudBackupRunState.running);
    try {
      final result = await ref.read(cloudBackupServiceProvider).restore();
      if (result.success) {
        // Record a sync point: the device now holds everything the cloud
        // does, so future auto-backups (which upload a superset) are safe
        // and the never-backed-up guard no longer needs to block them.
        await ref.read(cloudBackupSettingsProvider.notifier).markBackedUp(DateTime.now());
      }
      state = result.success
          ? const CloudBackupStatus(state: CloudBackupRunState.success)
          : CloudBackupStatus(state: CloudBackupRunState.error, errorMessage: result.error);
      return result;
    } finally {
      _inFlight = false;
    }
  }
}

final cloudBackupControllerProvider = NotifierProvider<CloudBackupController, CloudBackupStatus>(
  () => CloudBackupController(),
);

/// Cloud-side metadata for the current user's backup. Refetches when the
/// auth uid changes (e.g. signing in to an existing account on a new device).
final cloudBackupMetadataProvider = FutureProvider.autoDispose<CloudBackupMetadata?>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(cloudBackupServiceProvider).fetchMetadata();
});

/// One-shot app-launch trigger. Watched from the home shell; the provider
/// body runs once per container, so the auto-backup check fires once per
/// session without blocking startup.
final autoCloudBackupTriggerProvider = Provider<void>((ref) {
  Future.microtask(() => ref.read(cloudBackupControllerProvider.notifier).maybeAutoBackup());
});
