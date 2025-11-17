import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/constants/app_constants.dart';

/// Analytics service wrapper for Firebase Analytics
///
/// This service provides a centralized way to track analytics events
/// while ensuring we never track personal data or workout performance data.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Get the FirebaseAnalytics instance for direct access if needed
  FirebaseAnalytics get instance => _analytics;

  /// Track screen views
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // Mesocycle Events
  // =============================================================================

  /// Track when a mesocycle is created
  Future<void> logMesocycleCreated({
    required int weeks,
    required int daysPerWeek,
    required String gender,
    String? templateName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMesocycleCreated,
        parameters: {
          'weeks': weeks,
          'days_per_week': daysPerWeek,
          'gender': gender,
          if (templateName != null) 'template': templateName,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a mesocycle is started
  Future<void> logMesocycleStarted({
    required int weeks,
    required int daysPerWeek,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMesocycleStarted,
        parameters: {
          'weeks': weeks,
          'days_per_week': daysPerWeek,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a mesocycle is completed
  Future<void> logMesocycleCompleted({
    required int weeks,
    required int workoutsCompleted,
    required int totalWorkouts,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMesocycleCompleted,
        parameters: {
          'weeks': weeks,
          'workouts_completed': workoutsCompleted,
          'total_workouts': totalWorkouts,
          'completion_rate':
              (workoutsCompleted / totalWorkouts * 100).toStringAsFixed(1),
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a mesocycle is deleted
  Future<void> logMesocycleDeleted({
    required int weeks,
    required String status,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMesocycleDeleted,
        parameters: {
          'weeks': weeks,
          'status': status,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // Workout Events
  // =============================================================================

  /// Track when a workout is completed
  Future<void> logWorkoutCompleted({
    required int weekNumber,
    required int dayNumber,
    required int exerciseCount,
    bool hadMyorepSets = false,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventWorkoutCompleted,
        parameters: {
          'week_number': weekNumber,
          'day_number': dayNumber,
          'exercise_count': exerciseCount,
          'had_myorep_sets': hadMyorepSets,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a workout is skipped
  Future<void> logWorkoutSkipped({
    required int weekNumber,
    required int dayNumber,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventWorkoutSkipped,
        parameters: {
          'week_number': weekNumber,
          'day_number': dayNumber,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // Template Events
  // =============================================================================

  /// Track when a template is used
  Future<void> logTemplateUsed({
    required String templateName,
    required int weeks,
    required int daysPerWeek,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTemplateUsed,
        parameters: {
          'template_name': templateName,
          'weeks': weeks,
          'days_per_week': daysPerWeek,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // Feature Usage Events
  // =============================================================================

  /// Track when feedback is logged (joint pain, pump, workload, soreness)
  Future<void> logFeedbackUsed({
    required String feedbackType,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventFeedbackLogged,
        parameters: {
          'feedback_type': feedbackType,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a Myorep set is used
  Future<void> logMyorepSetUsed({
    required String setType,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMyorepSetUsed,
        parameters: {
          'set_type': setType,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when filters are applied
  Future<void> logFilterUsed({
    required String filterType,
    required String filterValue,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventFilterUsed,
        parameters: {
          'filter_type': filterType,
          'filter_value': filterValue,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // Export/Import Events
  // =============================================================================

  /// Track when data is exported
  Future<void> logDataExported({
    required int mesocycleCount,
    required int workoutCount,
    required int exerciseCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventDataExported,
        parameters: {
          'mesocycle_count': mesocycleCount,
          'workout_count': workoutCount,
          'exercise_count': exerciseCount,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when data is imported
  Future<void> logDataImported({
    required int mesocycleCount,
    required int workoutCount,
    required int exerciseCount,
    required String importMode,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventDataImported,
        parameters: {
          'mesocycle_count': mesocycleCount,
          'workout_count': workoutCount,
          'exercise_count': exerciseCount,
          'import_mode': importMode, // 'merge' or 'replace'
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when data is shared
  Future<void> logDataShared() async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventDataShared,
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // =============================================================================
  // User Properties (Non-PII)
  // =============================================================================

  /// Set user properties for analytics segmentation
  /// IMPORTANT: Never set personal data or workout performance data
  Future<void> setUserProperties({
    String? preferredGender,
    String? themeMode,
  }) async {
    try {
      if (preferredGender != null) {
        await _analytics.setUserProperty(
          name: 'preferred_gender',
          value: preferredGender,
        );
      }
      if (themeMode != null) {
        await _analytics.setUserProperty(
          name: 'theme_mode',
          value: themeMode,
        );
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
