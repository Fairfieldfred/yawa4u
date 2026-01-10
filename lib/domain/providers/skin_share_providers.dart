import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skins.dart';
import '../../data/services/skin_share_service.dart';
import '../../data/services/theme_image_service.dart';

/// Provider for SkinShareService
final skinShareServiceProvider = Provider<SkinShareService>((ref) {
  final skinRepository = ref.watch(skinRepositoryProvider);
  final themeImageService = ref.watch(themeImageServiceProvider);
  return SkinShareService(skinRepository, themeImageService);
});

/// Notifier for skin share status
class SkinShareStatusNotifier extends Notifier<SkinShareStatus> {
  @override
  SkinShareStatus build() => SkinShareStatus.idle;

  void setStatus(SkinShareStatus status) {
    state = status;
  }
}

final skinShareStatusProvider =
    NotifierProvider<SkinShareStatusNotifier, SkinShareStatus>(
      () => SkinShareStatusNotifier(),
    );

/// Notifier for connected device info during skin sharing
class SkinShareDeviceNotifier extends Notifier<SkinShareDeviceInfo?> {
  @override
  SkinShareDeviceInfo? build() => null;

  void setDevice(SkinShareDeviceInfo? device) {
    state = device;
  }

  void clear() {
    state = null;
  }
}

final skinShareDeviceProvider =
    NotifierProvider<SkinShareDeviceNotifier, SkinShareDeviceInfo?>(
      () => SkinShareDeviceNotifier(),
    );
