import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';
import '../env/env.dart';

/// Centralized service for Sentry operations with debugging support.
///
/// This service wraps all Sentry operations and provides extensive debug
/// logging to help troubleshoot feedback and error reporting issues.
class SentryService {
  SentryService._();

  static final SentryService _instance = SentryService._();
  static SentryService get instance => _instance;

  bool _isInitialized = false;

  /// Whether Sentry has been successfully initialized.
  bool get isInitialized => _isInitialized;

  /// Initialize Sentry with the configured options.
  ///
  /// Call this once during app startup.
  Future<void> initialize({required Future<void> Function() appRunner}) async {
    _debugPrint('🔧 SentryService.initialize() called');
    _debugPrint('   DSN present: ${Env.hasSentryDsn}');
    _debugPrint('   DSN value: ${_maskDsn(Env.sentryDsn)}');
    _debugPrint('   Environment: ${SentryConfig.environment}');
    _debugPrint('   Should initialize: ${SentryConfig.shouldInitialize}');

    if (!SentryConfig.shouldInitialize) {
      _debugPrint('⚠️ Sentry initialization skipped (DSN not configured)');
      await appRunner();
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = SentryConfig.dsn;
          options.environment = SentryConfig.environment;
          options.release = SentryConfig.release;
          options.tracesSampleRate = SentryConfig.tracesSampleRate;

          // Important: Do not send PII
          options.sendDefaultPii = false;

          // Enable performance monitoring
          options.enableAutoPerformanceTracing = true;

          // Disable automatic breadcrumbs for sensitive data
          options.enableAutoNativeBreadcrumbs = false;

          // Session replay settings
          options.replay.sessionSampleRate = 0.0;
          options.replay.onErrorSampleRate = 0.1;

          // Debug logging callback
          options.beforeSend = (event, hint) {
            _debugPrint('📤 Sentry beforeSend callback:');
            _debugPrint('   Event ID: ${event.eventId}');
            _debugPrint('   Level: ${event.level}');
            _debugPrint('   Message: ${event.message?.formatted}');
            return event;
          };

          _debugPrint('✅ Sentry options configured successfully');
        },
        appRunner: () async {
          _isInitialized = true;
          _debugPrint('✅ Sentry initialized successfully');
          await appRunner();
        },
      );
    } catch (e, stackTrace) {
      _debugPrint('❌ Sentry initialization failed: $e');
      _debugPrint('   Stack: $stackTrace');
      // Still run the app even if Sentry fails
      await appRunner();
    }
  }

  /// Capture an exception with optional stack trace.
  Future<SentryId> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? message,
  }) async {
    _debugPrint('🐛 SentryService.captureException() called');
    _debugPrint('   Initialized: $_isInitialized');
    _debugPrint('   Exception: $exception');
    _debugPrint('   Message: $message');

    if (!_isInitialized) {
      _debugPrint('⚠️ Sentry not initialized, skipping capture');
      return SentryId.empty();
    }

    try {
      final id = await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: message != null
            ? (scope) {
                scope.setExtra('custom_message', message);
              }
            : null,
      );
      _debugPrint('✅ Exception captured with ID: $id');
      return id;
    } catch (e) {
      _debugPrint('❌ Failed to capture exception: $e');
      return SentryId.empty();
    }
  }

  /// Capture a message with optional severity level.
  Future<SentryId> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    _debugPrint('📝 SentryService.captureMessage() called');
    _debugPrint('   Initialized: $_isInitialized');
    _debugPrint('   DSN present: ${Env.hasSentryDsn}');
    _debugPrint('   DSN value: ${_maskDsn(Env.sentryDsn)}');
    _debugPrint('   Message: $message');
    _debugPrint('   Level: ${level.name}');

    if (!_isInitialized) {
      _debugPrint('⚠️ Sentry not initialized, skipping capture');
      return SentryId.empty();
    }

    try {
      final id = await Sentry.captureMessage(message, level: level);
      final isEmpty = id.toString() == SentryId.empty().toString();
      if (isEmpty) {
        _debugPrint('⚠️ Message returned empty ID - event likely NOT sent');
        _debugPrint('   This usually means DSN is empty or invalid');
      } else {
        _debugPrint('✅ Message captured with ID: $id');
      }
      return id;
    } catch (e) {
      _debugPrint('❌ Failed to capture message: $e');
      return SentryId.empty();
    }
  }

  /// Capture user feedback.
  ///
  /// This is typically called after capturing an event.
  Future<void> captureFeedback({
    required String message,
    String? email,
    String? name,
    SentryId? associatedEventId,
  }) async {
    _debugPrint('💬 SentryService.captureFeedback() called');
    _debugPrint('   Initialized: $_isInitialized');
    _debugPrint('   Message: $message');
    _debugPrint('   Email: ${email ?? "not provided"}');
    _debugPrint('   Name: ${name ?? "not provided"}');
    _debugPrint('   Associated Event ID: $associatedEventId');

    if (!_isInitialized) {
      _debugPrint('⚠️ Sentry not initialized, skipping feedback');
      return;
    }

    try {
      // First capture a message event to associate feedback with
      final eventId =
          associatedEventId ??
          await Sentry.captureMessage('User Feedback', level: SentryLevel.info);

      _debugPrint('   Event ID for feedback: $eventId');

      final feedback = SentryFeedback(
        message: message,
        contactEmail: email,
        name: name,
        associatedEventId: eventId,
      );

      await Sentry.captureFeedback(feedback);
      _debugPrint('✅ Feedback captured successfully');
    } catch (e, stackTrace) {
      _debugPrint('❌ Failed to capture feedback: $e');
      _debugPrint('   Stack: $stackTrace');
    }
  }

  /// Send a test event to verify Sentry configuration.
  Future<SentryId> sendTestEvent() async {
    _debugPrint('🧪 SentryService.sendTestEvent() called');

    return captureMessage(
      'Test event from YAWA4U app - ${DateTime.now().toIso8601String()}',
      level: SentryLevel.info,
    );
  }

  /// Add a breadcrumb for context in error reports.
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
    _debugPrint('🍞 Breadcrumb added: $message');
  }

  /// Show BetterFeedback UI and upload to Sentry with debug logging.
  ///
  /// This wraps the BetterFeedback flow with debug output.
  void showBetterFeedback(BuildContext context) {
    _debugPrint('📱 showBetterFeedback() called');
    _debugPrint('   Initialized: $_isInitialized');
    _debugPrint('   DSN present: ${Env.hasSentryDsn}');

    BetterFeedback.of(context).show((feedback) async {
      _debugPrint('📥 BetterFeedback submitted');
      _debugPrint('   Text: ${feedback.text}');
      _debugPrint('   Screenshot size: ${feedback.screenshot.length} bytes');
      _debugPrint('   Extra: ${feedback.extra}');

      await _uploadFeedbackToSentry(feedback.text, feedback.screenshot);
    });
  }

  /// Upload feedback with screenshot to Sentry.
  Future<void> _uploadFeedbackToSentry(
    String feedbackText,
    Uint8List screenshot,
  ) async {
    _debugPrint('📤 Uploading feedback to Sentry...');

    if (!_isInitialized) {
      _debugPrint('⚠️ Sentry not initialized, skipping upload');
      return;
    }

    try {
      // Capture an event to associate the feedback with
      final eventId = await Sentry.captureMessage(
        'User Feedback: $feedbackText',
        level: SentryLevel.info,
        withScope: (scope) {
          scope.addAttachment(
            SentryAttachment.fromUint8List(
              screenshot,
              'screenshot.png',
              contentType: 'image/png',
            ),
          );
        },
      );

      _debugPrint('   Event with screenshot ID: $eventId');

      // Now attach the user feedback
      final sentryFeedback = SentryFeedback(
        message: feedbackText,
        associatedEventId: eventId,
      );

      await Sentry.captureFeedback(sentryFeedback);
      _debugPrint('✅ Feedback with screenshot uploaded successfully');
    } catch (e, stackTrace) {
      _debugPrint('❌ Failed to upload feedback: $e');
      _debugPrint('   Stack: $stackTrace');
    }
  }

  /// Print debug status information.
  void debugPrintStatus() {
    _debugPrint('═══════════════════════════════════════');
    _debugPrint('📊 SENTRY SERVICE STATUS');
    _debugPrint('═══════════════════════════════════════');
    _debugPrint('   Initialized: $_isInitialized');
    _debugPrint('   DSN present: ${Env.hasSentryDsn}');
    _debugPrint('   DSN value: ${_maskDsn(Env.sentryDsn)}');
    _debugPrint('   Environment: ${SentryConfig.environment}');
    _debugPrint('   Release: ${SentryConfig.release}');
    _debugPrint('   Enabled: ${SentryConfig.enabled}');
    _debugPrint('   Should initialize: ${SentryConfig.shouldInitialize}');
    _debugPrint('═══════════════════════════════════════');
  }

  /// Mask DSN for safe logging (shows first/last chars).
  String _maskDsn(String dsn) {
    if (dsn.isEmpty) return '<empty>';
    if (dsn.length < 20) return '<too short>';
    return '${dsn.substring(0, 10)}...${dsn.substring(dsn.length - 10)}';
  }

  /// Debug print helper (only in debug mode).
  void _debugPrint(String message) {
    if (kDebugMode) {
      debugPrint('[SentryService] $message');
    }
  }
}
