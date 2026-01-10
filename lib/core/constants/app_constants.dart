/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Identity
  static const String appName = 'YAWA4U';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'YAWA';

  // Database
  static const String isarDbName = 'yawa4u';

  // Export/Import
  static const String exportFilePrefix = 'yawa4u_backup';
  static const String exportFileExtension = 'json';

  // TrainingCycle Constraints
  static const int minWeeks = 1;
  static const int maxWeeks = 8;
  static const int minDaysPerPeriod = 1;
  static const int maxDaysPerPeriod = 14;

  // Set Type Definitions (from UI screenshots)
  static const String setTypeDialogTitle = 'Set types';
  static const String setTypeDialogDescription =
      'Keep track of how you performed your sets by specifying a type:';

  static const String regularSetDefinition =
      'Regular: perform sets normally by hitting rep target or week over week RIR target';

  static const String myorepSetDefinition =
      'Myoreps: take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.';

  static const String myorepMatchSetDefinition =
      'Myorep match: take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.';

  // Feedback Dialog Titles
  static const String jointPainTitle = 'JOINT PAIN';
  static const String musclePumpTitle = 'MUSCLE PUMP';
  static const String workloadTitle = 'WORKLOAD';
  static const String sorenessTitle = 'SORENESS';

  // Feedback Questions
  static String jointPainQuestion(String exerciseName) =>
      'How did your joints feel during $exerciseName?';

  static String musclePumpQuestion(String muscleGroup) =>
      'How much of a pump did you get today in your $muscleGroup?';

  static String workloadQuestion(String muscleGroup) =>
      'How would you rate the difficulty of the work you did for your $muscleGroup?';

  static String sorenessQuestion(String muscleGroup) =>
      'How sore did you get in your $muscleGroup AFTER training it LAST TIME?';

  // UI Text
  static const String draftBannerText = 'CONTINUE EDITING DRAFT TRAINING CYCLE';
  static const String noExercisesTitle = 'No exercises';
  static const String noExercisesMessage =
      'Your custom exercises will appear here.';
  static const String noPinnedNotesTitle = 'No pinned notes';
  static const String noPinnedNotesMessage =
      'Your pinned exercise notes will appear here.';

  // Day Names
  static const List<String> dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> dayNamesShort = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  // Bottom Navigation Labels
  static const String navWorkout = 'Workout';
  static const String navTrainingCycles = 'TrainingCycles';
  static const String navExercises = 'Exercises';
  static const String navMore = 'More';

  // More Screen Menu Items
  static const String menuTemplates = 'Templates';
  static const String menuDarkTheme = 'Dark Theme';
  static const String menuExportData = 'Export Data';
  static const String menuImportData = 'Import Data';
  static const String menuShareData = 'Share Data';
  static const String menuHelp = 'Help';
  static const String menuLeaveReview = 'Leave a review';

  // Links
  static const String privacyPolicyUrl =
      'https://www.blairhouseapps.com/yawa4u/privacy_policy.html';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String helpUrl = 'https://example.com/help';

  // Analytics Event Names
  static const String eventTrainingCycleCreated = 'trainingCycle_created';
  static const String eventTrainingCycleStarted = 'trainingCycle_started';
  static const String eventTrainingCycleCompleted = 'trainingCycle_completed';
  static const String eventTrainingCycleDeleted = 'trainingCycle_deleted';
  static const String eventWorkoutCompleted = 'workout_completed';
  static const String eventWorkoutSkipped = 'workout_skipped';
  static const String eventWorkoutReset = 'workout_reset';
  static const String eventExerciseAdded = 'exercise_added_to_workout';
  static const String eventExerciseRemoved = 'exercise_removed_from_workout';
  static const String eventExerciseReplaced = 'exercise_replaced';
  static const String eventSetLogged = 'set_logged';
  static const String eventTemplateViewed = 'template_viewed';
  static const String eventTemplateUsed = 'template_used';
  static const String eventTemplateFilterApplied = 'template_filter_applied';
  static const String eventFeedbackSubmitted = 'feedback_submitted';
  static const String eventJointPainReported = 'joint_pain_reported';
  static const String eventSorenessReported = 'muscle_soreness_reported';
  static const String eventDataExported = 'data_exported';
  static const String eventDataImported = 'data_imported';
  static const String eventDataShared = 'data_shared';
  static const String eventMyorepSetCreated = 'myorep_set_created';
  static const String eventCalendarOpened = 'calendar_opened';
  static const String eventExerciseFiltersApplied = 'exercise_filters_applied';
  static const String eventMusclePrioritiesUpdated =
      'muscle_priorities_updated';
  static const String eventFeedbackLogged = 'feedback_logged';
  static const String eventMyorepSetUsed = 'myorep_set_used';
  static const String eventFilterUsed = 'filter_used';

  // RIR (Reps In Reserve) Patterns
  static final RegExp rirPattern = RegExp(r'^\d+\s*RIR$', caseSensitive: false);

  /// Check if a reps value is in RIR format (e.g., "2 RIR")
  static bool isRIR(String reps) {
    return rirPattern.hasMatch(reps.trim().toUpperCase());
  }

  /// Extract RIR number from string (e.g., "2 RIR" -> 2)
  static int? getRIRValue(String reps) {
    if (!isRIR(reps)) return null;
    final match = RegExp(r'\d+').firstMatch(reps);
    if (match == null) return null;
    return int.tryParse(match.group(0)!);
  }
}
