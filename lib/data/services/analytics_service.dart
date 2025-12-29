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
  // TrainingCycle Events
  // =============================================================================

  /// Track when a trainingCycle is created
  Future<void> logTrainingCycleCreated({
    required int periods,
    required int daysPerPeriod,
    required String gender,
    String? templateName,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTrainingCycleCreated,
        parameters: {
          'periods': periods,
          'days_per_period': daysPerPeriod,
          'gender': gender,
          if (templateName != null) 'template': templateName,
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a trainingCycle is started
  Future<void> logTrainingCycleStarted({
    required int periods,
    required int daysPerPeriod,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTrainingCycleStarted,
        parameters: {'periods': periods, 'days_per_period': daysPerPeriod},
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a trainingCycle is completed
  Future<void> logTrainingCycleCompleted({
    required int periods,
    required int workoutsCompleted,
    required int totalWorkouts,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTrainingCycleCompleted,
        parameters: {
          'periods': periods,
          'workouts_completed': workoutsCompleted,
          'total_workouts': totalWorkouts,
          'completion_rate': (workoutsCompleted / totalWorkouts * 100)
              .toStringAsFixed(1),
        },
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a trainingCycle is deleted
  Future<void> logTrainingCycleDeleted({
    required int periods,
    required String status,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTrainingCycleDeleted,
        parameters: {'periods': periods, 'status': status},
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
    required int periodNumber,
    required int dayNumber,
    required int exerciseCount,
    bool hadMyorepSets = false,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventWorkoutCompleted,
        parameters: {
          'period_number': periodNumber,
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
    required int periodNumber,
    required int dayNumber,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventWorkoutSkipped,
        parameters: {'period_number': periodNumber, 'day_number': dayNumber},
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
    required int periods,
    required int daysPerPeriod,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventTemplateUsed,
        parameters: {
          'template_name': templateName,
          'periods': periods,
          'days_per_period': daysPerPeriod,
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
  Future<void> logFeedbackUsed({required String feedbackType}) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventFeedbackLogged,
        parameters: {'feedback_type': feedbackType},
      );
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  /// Track when a Myorep set is used
  Future<void> logMyorepSetUsed({required String setType}) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventMyorepSetUsed,
        parameters: {'set_type': setType},
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
        parameters: {'filter_type': filterType, 'filter_value': filterValue},
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
    required int trainingCycleCount,
    required int workoutCount,
    required int exerciseCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventDataExported,
        parameters: {
          'trainingCycle_count': trainingCycleCount,
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
    required int trainingCycleCount,
    required int workoutCount,
    required int exerciseCount,
    required String importMode,
  }) async {
    try {
      await _analytics.logEvent(
        name: AppConstants.eventDataImported,
        parameters: {
          'trainingCycle_count': trainingCycleCount,
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
      await _analytics.logEvent(name: AppConstants.eventDataShared);
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
        await _analytics.setUserProperty(name: 'theme_mode', value: themeMode);
      }
    } catch (e, stackTrace) {
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
