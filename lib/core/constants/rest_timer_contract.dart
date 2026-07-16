/// Identifiers shared between the rest timer notifier (main isolate) and the
/// notification action handler (background isolate).
///
/// The rest timer's source of truth is a wall-clock deadline persisted to
/// SharedPreferences. Notification action buttons (+/-/skip) run in a
/// background isolate that mutates the same keys, so both sides must agree on
/// them without importing each other.
class RestTimerContract {
  RestTimerContract._();

  /// Notification id shared by the live countdown card and the "rest over"
  /// alert: the alert scheduled at the deadline replaces the countdown card
  /// even when the app process is dead.
  static const int notificationId = 9001;

  static const String endMsKey = 'rest_timer_end_ms';
  static const String totalKey = 'rest_timer_total_seconds';
  static const String pausedRemainingKey = 'rest_timer_paused_remaining';
  static const String exerciseIdKey = 'rest_timer_exercise_id';
  static const String workoutIdKey = 'rest_timer_workout_id';
  static const String titleKey = 'rest_timer_notification_title';
  static const String bodyKey = 'rest_timer_notification_body';
  static const String liveInfoKey = 'rest_timer_live_info';

  static const String actionAdd = 'rest_timer_add';
  static const String actionSubtract = 'rest_timer_subtract';
  static const String actionSkip = 'rest_timer_skip';

  /// Seconds shifted by the notification +/- actions (matches the in-app
  /// rest-timer banner buttons).
  static const int actionShiftSeconds = 30;

  /// IsolateNameServer port name the main isolate listens on so a background
  /// notification action can trigger a state resync while the app is alive.
  static const String resyncPortName = 'yawa4u_rest_timer_resync';
}
