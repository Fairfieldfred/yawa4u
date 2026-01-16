import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skin_repository.dart';
import '../../data/services/data_backup_service.dart';
import '../../data/services/wifi_sync_service.dart';
import 'database_providers.dart';

/// Provider for SkinRepository singleton (for data backup)
final skinRepositoryForBackupProvider = Provider<SkinRepository>((ref) {
  return SkinRepository(); // Uses singleton pattern
});

/// Provider for DataBackupService
final dataBackupServiceProvider = Provider<DataBackupService>((ref) {
  return DataBackupService(
    trainingCycleRepository: ref.watch(trainingCycleRepositoryProvider),
    workoutRepository: ref.watch(workoutRepositoryProvider),
    exerciseRepository: ref.watch(exerciseRepositoryProvider),
    customExerciseRepository: ref.watch(customExerciseRepositoryProvider),
    skinRepository: ref.watch(skinRepositoryForBackupProvider),
  );
});

/// Provider for WifiSyncService
final wifiSyncServiceProvider = Provider<WifiSyncService>((ref) {
  final backupService = ref.watch(dataBackupServiceProvider);
  return WifiSyncService(backupService);
});

/// Notifier for sync status
class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  void setStatus(SyncStatus status) {
    state = status;
  }
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(
  () => SyncStatusNotifier(),
);

/// Notifier for connected device info
class ConnectedDeviceNotifier extends Notifier<DeviceInfo?> {
  @override
  DeviceInfo? build() => null;

  void setDevice(DeviceInfo? device) {
    state = device;
  }

  void clear() {
    state = null;
  }
}

final connectedDeviceProvider =
    NotifierProvider<ConnectedDeviceNotifier, DeviceInfo?>(
      () => ConnectedDeviceNotifier(),
    );
