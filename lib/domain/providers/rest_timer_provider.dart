import 'dart:async';
import 'dart:developer';
import 'dart:math' show max;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';
import '../../data/services/notification_service.dart';
import 'onboarding_providers.dart';

/// Injectable wall clock so tests can control time.
final restTimerClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Injectable completion haptic so tests can observe it firing.
final restTimerHapticProvider = Provider<Future<void> Function()>((ref) => HapticFeedback.heavyImpact);

/// Provider for the [NotificationService] singleton.
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

/// State for the rest timer between sets.
class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;

  /// ID of the exercise that triggered this timer (for editing rest duration).
  final String? exerciseId;

  /// ID of the workout containing the exercise.
  final String? workoutId;

  const RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.exerciseId,
    this.workoutId,
  });

  double get progress => totalSeconds > 0 ? remainingSeconds / totalSeconds : 0;

  String get displayTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isPaused,
    String? exerciseId,
    String? workoutId,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutId: workoutId ?? this.workoutId,
    );
  }
}

/// Default rest durations in seconds per set type.
int defaultRestSeconds(SetType setType) {
  return switch (setType) {
    SetType.regular => 60,
    SetType.myorep => 10,
    SetType.myorepMatch => 10,
    SetType.maxReps => 90,
    SetType.endWithPartials => 60,
    SetType.dropSet => 0,
  };
}

/// Manages the rest timer countdown between sets.
///
/// The source of truth is a wall-clock deadline persisted to
/// SharedPreferences, so the countdown survives phone lock, app backgrounding
/// and even process death. The 1s [Timer] only refreshes the display; each
/// tick re-derives the remaining time from the persisted deadline. An OS
/// notification is scheduled at the deadline so the user is alerted with the
/// screen off.
class RestTimerNotifier extends Notifier<RestTimerState> {
  static const _endMsKey = 'rest_timer_end_ms';
  static const _totalKey = 'rest_timer_total_seconds';
  static const _pausedRemainingKey = 'rest_timer_paused_remaining';
  static const _exerciseIdKey = 'rest_timer_exercise_id';
  static const _workoutIdKey = 'rest_timer_workout_id';
  static const _titleKey = 'rest_timer_notification_title';
  static const _bodyKey = 'rest_timer_notification_body';

  /// Notification id reserved for the rest timer.
  static const notificationId = 9001;

  static const _defaultNotificationTitle = 'Rest over';
  static const _defaultNotificationBody = 'Time for your next set';

  Timer? _timer;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);
  NotificationService get _notifications => ref.read(notificationServiceProvider);
  DateTime Function() get _now => ref.read(restTimerClockProvider);

  @override
  RestTimerState build() {
    ref.onDispose(() => _timer?.cancel());
    return _rehydrate();
  }

  /// Start a countdown for the given set type.
  /// If [exerciseRestSeconds] is provided, it overrides the default.
  /// Optionally stores [exerciseId] and [workoutId] so the timer banner
  /// can open the rest-timer settings for the triggering exercise.
  /// [notificationTitle] and [notificationBody] localize the OS notification
  /// shown at zero.
  void start(
    SetType setType, {
    int? exerciseRestSeconds,
    String? exerciseId,
    String? workoutId,
    String? notificationTitle,
    String? notificationBody,
  }) {
    final seconds = exerciseRestSeconds ?? defaultRestSeconds(setType);
    if (seconds <= 0) return; // No rest for drop sets

    _begin(
      seconds,
      exerciseId: exerciseId,
      workoutId: workoutId,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
    );
  }

  /// Start with a custom duration in seconds.
  void startCustom(
    int seconds, {
    String? notificationTitle,
    String? notificationBody,
  }) {
    if (seconds <= 0) return;
    _begin(seconds, notificationTitle: notificationTitle, notificationBody: notificationBody);
  }

  /// Pause the timer.
  void pause() {
    if (!state.isRunning || state.isPaused) return;
    _timer?.cancel();
    final endMs = _prefs.getInt(_endMsKey);
    final remaining = endMs != null ? _remainingUntil(endMs) : state.remainingSeconds;
    if (remaining <= 0) {
      _complete();
      return;
    }
    _prefs.setInt(_pausedRemainingKey, remaining);
    _prefs.remove(_endMsKey);
    unawaited(_cancelNotification());
    state = state.copyWith(isPaused: true, remainingSeconds: remaining);
  }

  /// Resume a paused timer.
  void resume() {
    if (!state.isPaused || state.remainingSeconds <= 0) return;
    final remaining = _prefs.getInt(_pausedRemainingKey) ?? state.remainingSeconds;
    final end = _now().add(Duration(seconds: remaining));
    _prefs.setInt(_endMsKey, end.millisecondsSinceEpoch);
    _prefs.remove(_pausedRemainingKey);
    unawaited(_scheduleNotification(end));
    state = state.copyWith(isPaused: false, remainingSeconds: remaining);
    _startTicking();
  }

  /// Shift the current timer by [seconds] (negative subtracts).
  /// Shifting a running timer past zero completes it immediately.
  void addTime([int seconds = 30]) {
    if (!state.isRunning) return;

    if (state.isPaused) {
      final remaining = state.remainingSeconds + seconds;
      if (remaining <= 0) {
        cancel();
        return;
      }
      _prefs.setInt(_pausedRemainingKey, remaining);
      final newTotal = max(state.totalSeconds + seconds, remaining);
      _prefs.setInt(_totalKey, newTotal);
      state = state.copyWith(remainingSeconds: remaining, totalSeconds: newTotal);
      return;
    }

    final endMs = _prefs.getInt(_endMsKey);
    if (endMs == null) return;
    final newEndMs = endMs + seconds * 1000;
    final remaining = _remainingUntil(newEndMs);
    if (remaining <= 0) {
      _complete();
      return;
    }
    _prefs.setInt(_endMsKey, newEndMs);
    final newTotal = max(state.totalSeconds + seconds, remaining);
    _prefs.setInt(_totalKey, newTotal);
    unawaited(_scheduleNotification(DateTime.fromMillisecondsSinceEpoch(newEndMs)));
    state = state.copyWith(remainingSeconds: remaining, totalSeconds: newTotal);
  }

  /// Cancel the timer and reset state.
  void cancel() {
    _timer?.cancel();
    _clearPersisted();
    unawaited(_cancelNotification());
    state = const RestTimerState();
  }

  /// Re-derives the timer from the persisted deadline. Call when the app
  /// returns to the foreground: display timers don't fire in background, so
  /// the shown remaining time may have drifted or the deadline passed.
  void resync() {
    if (_prefs.getInt(_pausedRemainingKey) != null) return; // paused: no drift
    final endMs = _prefs.getInt(_endMsKey);
    if (endMs == null) return;
    final remaining = _remainingUntil(endMs);
    if (remaining <= 0) {
      _complete();
    } else {
      state = state.copyWith(remainingSeconds: remaining, isRunning: true);
      _startTicking();
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  void _begin(
    int seconds, {
    String? exerciseId,
    String? workoutId,
    String? notificationTitle,
    String? notificationBody,
  }) {
    _timer?.cancel();
    final end = _now().add(Duration(seconds: seconds));
    _prefs.setInt(_endMsKey, end.millisecondsSinceEpoch);
    _prefs.setInt(_totalKey, seconds);
    _prefs.remove(_pausedRemainingKey);
    _setOrRemove(_exerciseIdKey, exerciseId);
    _setOrRemove(_workoutIdKey, workoutId);
    _setOrRemove(_titleKey, notificationTitle);
    _setOrRemove(_bodyKey, notificationBody);

    unawaited(_requestPermissionAndSchedule(end));

    state = RestTimerState(
      remainingSeconds: seconds,
      totalSeconds: seconds,
      isRunning: true,
      exerciseId: exerciseId,
      workoutId: workoutId,
    );
    _startTicking();
  }

  RestTimerState _rehydrate() {
    final total = _prefs.getInt(_totalKey) ?? 0;
    final exerciseId = _prefs.getString(_exerciseIdKey);
    final workoutId = _prefs.getString(_workoutIdKey);

    final pausedRemaining = _prefs.getInt(_pausedRemainingKey);
    if (pausedRemaining != null && pausedRemaining > 0) {
      return RestTimerState(
        remainingSeconds: pausedRemaining,
        totalSeconds: max(total, pausedRemaining),
        isRunning: true,
        isPaused: true,
        exerciseId: exerciseId,
        workoutId: workoutId,
      );
    }

    final endMs = _prefs.getInt(_endMsKey);
    if (endMs == null) return const RestTimerState();

    final remaining = _remainingUntil(endMs);
    if (remaining <= 0) {
      _clearPersisted();
      return const RestTimerState();
    }

    _startTicking();
    return RestTimerState(
      remainingSeconds: remaining,
      totalSeconds: max(total, remaining),
      isRunning: true,
      exerciseId: exerciseId,
      workoutId: workoutId,
    );
  }

  int _remainingUntil(int endMs) => ((endMs - _now().millisecondsSinceEpoch) / 1000).ceil();

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final endMs = _prefs.getInt(_endMsKey);
      if (endMs == null) {
        _timer?.cancel();
        return;
      }
      final remaining = _remainingUntil(endMs);
      if (remaining <= 0) {
        _complete();
      } else {
        state = state.copyWith(remainingSeconds: remaining);
      }
    });
  }

  /// Fires the completion haptic and resets state. Guarded so completion
  /// happens exactly once even if a tick and a lifecycle resync race.
  void _complete() {
    _timer?.cancel();
    if (!state.isRunning) return;
    _clearPersisted();
    unawaited(ref.read(restTimerHapticProvider)());
    state = const RestTimerState();
  }

  void _clearPersisted() {
    _prefs.remove(_endMsKey);
    _prefs.remove(_totalKey);
    _prefs.remove(_pausedRemainingKey);
    _prefs.remove(_exerciseIdKey);
    _prefs.remove(_workoutIdKey);
    _prefs.remove(_titleKey);
    _prefs.remove(_bodyKey);
  }

  void _setOrRemove(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }

  Future<void> _requestPermissionAndSchedule(DateTime end) async {
    try {
      await _notifications.requestPermission();
      await _scheduleNotification(end);
    } catch (e, st) {
      log('Failed to schedule rest-timer notification', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  Future<void> _scheduleNotification(DateTime end) async {
    try {
      await _notifications.scheduleAt(
        id: notificationId,
        when: end,
        title: _prefs.getString(_titleKey) ?? _defaultNotificationTitle,
        body: _prefs.getString(_bodyKey) ?? _defaultNotificationBody,
      );
    } catch (e, st) {
      log('Failed to schedule rest-timer notification', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  Future<void> _cancelNotification() async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e, st) {
      log('Failed to cancel rest-timer notification', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }
}

/// Global rest timer provider.
final restTimerProvider = NotifierProvider<RestTimerNotifier, RestTimerState>(
  RestTimerNotifier.new,
);
