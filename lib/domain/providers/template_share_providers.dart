import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/template_share_service.dart';
import 'template_providers.dart';

/// Provider for TemplateShareService
final templateShareServiceProvider = Provider<TemplateShareService>((ref) {
  final templateRepository = ref.watch(templateRepositoryProvider);
  return TemplateShareService(templateRepository);
});

/// Notifier for template share status
class TemplateShareStatusNotifier extends Notifier<TemplateShareStatus> {
  @override
  TemplateShareStatus build() => TemplateShareStatus.idle;

  void setStatus(TemplateShareStatus status) {
    state = status;
  }
}

final templateShareStatusProvider =
    NotifierProvider<TemplateShareStatusNotifier, TemplateShareStatus>(
      () => TemplateShareStatusNotifier(),
    );

/// Notifier for connected device info during template sharing
class TemplateShareDeviceNotifier extends Notifier<TemplateShareDeviceInfo?> {
  @override
  TemplateShareDeviceInfo? build() => null;

  void setDevice(TemplateShareDeviceInfo? device) {
    state = device;
  }

  void clear() {
    state = null;
  }
}

final templateShareDeviceProvider =
    NotifierProvider<TemplateShareDeviceNotifier, TemplateShareDeviceInfo?>(
      () => TemplateShareDeviceNotifier(),
    );
