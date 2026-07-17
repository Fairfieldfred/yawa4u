import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:math' show max;
import 'dart:ui' show IsolateNameServer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/rest_timer_contract.dart';
import '../../data/models/live_set_info.dart';
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
/// screen off, and (Android) a live ongoing notification shows the countdown
/// with +/-/skip actions on the lock screen. Those actions run in a
/// background isolate that mutates the same persisted keys
/// (see `handleRestTimerAction`) and pings [RestTimerContract.resyncPortName].
class RestTimerNotifier extends Notifier<RestTimerState> {
  static const _endMsKey = RestTimerContract.endMsKey;
  static const _totalKey = RestTimerContract.totalKey;
  static const _pausedRemainingKey = RestTimerContract.pausedRemainingKey;
  static const _exerciseIdKey = RestTimerContract.exerciseIdKey;
  static const _workoutIdKey = RestTimerContract.workoutIdKey;
  static const _titleKey = RestTimerContract.titleKey;
  static const _bodyKey = RestTimerContract.bodyKey;
  static const _liveInfoKey = RestTimerContract.liveInfoKey;

  /// Notification id for the "rest over" alert at the deadline.
  static const notificationId = RestTimerContract.notificationId;

  /// Notification id for the live countdown card (distinct from
  /// [notificationId] — sharing one id silenced the alert).
  static const liveCardId = RestTimerContract.liveCardId;

  static const _defaultNotificationTitle = 'Rest over';
  static const _defaultNotificationBody = 'Time for your next set';

  Timer? _timer;
  ReceivePort? _resyncPort;

  /// Bumped on every timer transition that changes what the live card should
  /// show. Card posts deferred behind async work (permission request,
  /// notification cancel) check it before posting so a stale card can't
  /// overwrite a newer one — or resurface after cancel as an undismissable
  /// orphan.
  int _liveCardEpoch = 0;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);
  NotificationService get _notifications => ref.read(notificationServiceProvider);
  DateTime Function() get _now => ref.read(restTimerClockProvider);

  @override
  RestTimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _disposeResyncPort();
    });
    _registerResyncPort();
    return _rehydrate();
  }

  /// Start a countdown for the given set type.
  /// If [exerciseRestSeconds] is provided, it overrides the default.
  /// Optionally stores [exerciseId] and [workoutId] so the timer banner
  /// can open the rest-timer settings for the triggering exercise.
  /// [notificationTitle] and [notificationBody] localize the OS notification
  /// shown at zero. When [liveInfo] is provided, a live countdown card with
  /// quick actions is shown on the lock screen while the rest runs (Android).
  void start(
    SetType setType, {
    int? exerciseRestSeconds,
    String? exerciseId,
    String? workoutId,
    String? notificationTitle,
    String? notificationBody,
    LiveSetInfo? liveInfo,
  }) {
    final seconds = exerciseRestSeconds ?? defaultRestSeconds(setType);
    if (seconds <= 0) return; // No rest for drop sets

    _begin(
      seconds,
      exerciseId: exerciseId,
      workoutId: workoutId,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      liveInfo: liveInfo,
    );
  }

  /// Start with a custom duration in seconds.
  void startCustom(
    int seconds, {
    String? notificationTitle,
    String? notificationBody,
    LiveSetInfo? liveInfo,
  }) {
    if (seconds <= 0) return;
    _begin(
      seconds,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      liveInfo: liveInfo,
    );
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
    final epoch = ++_liveCardEpoch;
    // Only the alert is dropped: the card stays, restyled as paused.
    unawaited(
      _cancelAlert().then((_) async {
        if (epoch == _liveCardEpoch) await _showPausedCard(remaining);
      }),
    );
    state = state.copyWith(isPaused: true, remainingSeconds: remaining);
  }

  /// Resume a paused timer.
  void resume() {
    if (!state.isPaused || state.remainingSeconds <= 0) return;
    final remaining = _prefs.getInt(_pausedRemainingKey) ?? state.remainingSeconds;
    final end = _now().add(Duration(seconds: remaining));
    _prefs.setInt(_endMsKey, end.millisecondsSinceEpoch);
    _prefs.remove(_pausedRemainingKey);
    _liveCardEpoch++;
    unawaited(_scheduleNotification(end));
    unawaited(_showLiveCard(end));
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
      _liveCardEpoch++;
      unawaited(_showPausedCard(remaining));
      state = state.copyWith(remainingSeconds: remaining, totalSeconds: newTotal);
      return;
    }

    final endMs = _prefs.getInt(_endMsKey);
    if (endMs == null) return;
    final newEndMs = endMs + seconds * 1000;
    final remaining = _remainingUntil(newEndMs);
    if (remaining <= 0) {
      _complete(cancelNotifications: true);
      return;
    }
    _prefs.setInt(_endMsKey, newEndMs);
    final newTotal = max(state.totalSeconds + seconds, remaining);
    _prefs.setInt(_totalKey, newTotal);
    final end = DateTime.fromMillisecondsSinceEpoch(newEndMs);
    _liveCardEpoch++;
    unawaited(_scheduleNotification(end));
    unawaited(_showLiveCard(end));
    state = state.copyWith(remainingSeconds: remaining, totalSeconds: newTotal);
  }

  /// Cancel the timer and reset state.
  void cancel() {
    _timer?.cancel();
    _liveCardEpoch++;
    _clearPersisted();
    unawaited(_cancelNotification());
    state = const RestTimerState();
  }

  /// Re-derives the timer from the persisted deadline. Call when the app
  /// returns to the foreground (display timers don't fire in background) or
  /// when a background notification action mutated the persisted state.
  /// Reloads SharedPreferences first: the background isolate writes through
  /// to disk, but this isolate's cache would otherwise stay stale.
  Future<void> resync() async {
    try {
      await _prefs.reload();
    } catch (e, st) {
      log('Failed to reload prefs on resync', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }

    final pausedRemaining = _prefs.getInt(_pausedRemainingKey);
    if (pausedRemaining != null) {
      // Paused: no clock drift, but a background action may have shifted it.
      if (state.isPaused && pausedRemaining != state.remainingSeconds) {
        state = state.copyWith(
          remainingSeconds: pausedRemaining,
          totalSeconds: max(_prefs.getInt(_totalKey) ?? state.totalSeconds, pausedRemaining),
        );
      }
      return;
    }

    final endMs = _prefs.getInt(_endMsKey);
    if (endMs == null) {
      // A background skip cleared the timer while we weren't looking.
      if (state.isRunning) {
        _timer?.cancel();
        state = const RestTimerState();
      }
      return;
    }

    final remaining = _remainingUntil(endMs);
    if (remaining <= 0) {
      _complete();
    } else {
      state = state.copyWith(
        remainingSeconds: remaining,
        totalSeconds: max(_prefs.getInt(_totalKey) ?? state.totalSeconds, remaining),
        isRunning: true,
        isPaused: false,
      );
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
    LiveSetInfo? liveInfo,
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
    _setOrRemove(_liveInfoKey, liveInfo?.toJsonString());

    final epoch = ++_liveCardEpoch;
    unawaited(
      _requestPermissionAndSchedule(end).then((_) async {
        if (epoch == _liveCardEpoch) await _showLiveCard(end);
      }),
    );

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
  ///
  /// On natural completion the deadline alert (which shares the live card's
  /// notification id) fires at the same moment and replaces the card, so
  /// nothing needs cancelling. When completion is forced early (subtracting
  /// past zero, pausing an elapsed timer) pass [cancelNotifications] to
  /// remove the now-stale pending alert and live card.
  void _complete({bool cancelNotifications = false}) {
    _timer?.cancel();
    if (!state.isRunning) return;
    _liveCardEpoch++;
    _clearPersisted();
    if (cancelNotifications) {
      unawaited(_cancelNotification());
    } else {
      // Natural completion: the deadline alert fires (don't cancel it), but the
      // live card must still go. On Android it self-retires via timeoutAfter;
      // on iOS a Live Activity has no such timeout, so end it explicitly or it
      // lingers on the Lock Screen.
      unawaited(_cancelLiveCard());
    }
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
    _prefs.remove(_liveInfoKey);
  }

  void _setOrRemove(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }

  LiveSetInfo? get _persistedLiveInfo => LiveSetInfo.fromJsonString(_prefs.getString(_liveInfoKey));

  Future<void> _showLiveCard(DateTime end) async {
    try {
      final info = _persistedLiveInfo;
      if (info == null) return;
      await _notifications.showRestCountdown(id: liveCardId, until: end, info: info);
    } catch (e, st) {
      // Includes ref-after-dispose when the notifier goes away mid-flight.
      log('Failed to show rest countdown card', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  Future<void> _showPausedCard(int remainingSeconds) async {
    try {
      final info = _persistedLiveInfo;
      if (info == null) return;
      await _notifications.showRestPaused(
        id: liveCardId,
        info: info,
        remainingDisplay: RestTimerState(remainingSeconds: remainingSeconds).displayTime,
      );
    } catch (e, st) {
      log('Failed to show paused rest card', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  void _registerResyncPort() {
    if (kIsWeb) return;
    try {
      final port = ReceivePort();
      IsolateNameServer.removePortNameMapping(RestTimerContract.resyncPortName);
      IsolateNameServer.registerPortWithName(port.sendPort, RestTimerContract.resyncPortName);
      port.listen((_) => unawaited(resync()));
      _resyncPort = port;
    } catch (e, st) {
      log('Failed to register rest-timer resync port', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  void _disposeResyncPort() {
    if (_resyncPort == null) return;
    IsolateNameServer.removePortNameMapping(RestTimerContract.resyncPortName);
    _resyncPort?.close();
    _resyncPort = null;
  }

  Future<void> _requestPermissionAndSchedule(DateTime end) async {
    try {
      await _notifications.requestPermission();
      // Drop any previous "Rest over" still sitting on screen first. Posting
      // the next alert to the same id while one is visible is an *update*,
      // and an update doesn't re-alert — so back-to-back sets would go
      // silent from the second rest onwards unless the user dismissed each
      // one by hand.
      await _cancelAlert();
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

  /// Drops the pending deadline alert, leaving the live card alone.
  Future<void> _cancelAlert() async {
    try {
      await _notifications.cancel(notificationId);
    } catch (e, st) {
      log('Failed to cancel rest-timer notification', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  /// Drops the live card (Android notification / iOS Live Activity), leaving
  /// the deadline alert alone.
  Future<void> _cancelLiveCard() async {
    try {
      await _notifications.cancel(liveCardId);
    } catch (e, st) {
      log('Failed to cancel rest countdown card', error: e, stackTrace: st, name: 'yawa4u.restTimer');
    }
  }

  /// Drops both the live card and the pending deadline alert. Used whenever
  /// the rest ends early (skip, or shifted past zero).
  Future<void> _cancelNotification() async {
    await _cancelAlert();
    await _cancelLiveCard();
  }
}

/// Global rest timer provider.
final restTimerProvider = NotifierProvider<RestTimerNotifier, RestTimerState>(
  RestTimerNotifier.new,
);
