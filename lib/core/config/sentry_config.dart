import 'package:yawa4u/core/env/env.dart';

/// Sentry configuration for crash reporting and error tracking
class SentryConfig {
  /// Sentry DSN (Data Source Name) for the project
  /// Replace this with your actual Sentry DSN from https://sentry.io
  static final String dsn = Env.sentryDsn;

  /// Environment name (development, staging, production)
  static const String environment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Release version for tracking
  static const String release = String.fromEnvironment(
    'SENTRY_RELEASE',
    defaultValue: '1.0.0+1',
  );

  /// Sample rate for traces (0.0 to 1.0)
  /// 1.0 = 100% of transactions are sent to Sentry
  /// 0.2 = 20% of transactions are sent (recommended for production)
  static const double tracesSampleRate = 0.2;

  /// Whether Sentry is enabled
  /// Set to false in development if you don't want to send errors to Sentry
  static const bool enabled = bool.fromEnvironment(
    'SENTRY_ENABLED',
    defaultValue: true,
  );

  /// Check if Sentry should be initialized
  static bool get shouldInitialize => enabled && dsn != 'YOUR_SENTRY_DSN_HERE';
}
