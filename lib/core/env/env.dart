import 'package:flutter/foundation.dart';

/// Helper class to access the environment variables defined with --dart-define
class Env {
  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  /// Whether a Sentry DSN has been configured.
  static bool get hasSentryDsn =>
      sentryDsn.isNotEmpty && sentryDsn != 'YOUR_SENTRY_DSN_HERE';

  // static String get mixpanelProjectToken =>
  //     const String.fromEnvironment('MIXPANEL_PROJECT_TOKEN');

  /// Print environment status for debugging.
  static void debugPrintStatus() {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('📊 ENVIRONMENT STATUS');
      debugPrint('═══════════════════════════════════════');
      debugPrint('   SENTRY_DSN present: $hasSentryDsn');
      debugPrint('   SENTRY_DSN value: ${_maskValue(sentryDsn)}');
      debugPrint('═══════════════════════════════════════');
    }
  }

  /// Mask a value for safe logging.
  static String _maskValue(String value) {
    if (value.isEmpty) return '<empty>';
    if (value.length < 20) return '<configured but short>';
    return '${value.substring(0, 10)}...${value.substring(value.length - 10)}';
  }
}
