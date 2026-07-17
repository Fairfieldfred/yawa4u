import 'dart:developer';
import 'dart:math' show max;
import 'dart:ui' show IsolateNameServer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live_card/live_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/rest_timer_contract.dart';
import '../models/live_set_info.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin] for the rest timer:
/// a one-shot alert scheduled at the deadline, plus (Android only) a live
/// ongoing notification with a system-rendered countdown and quick actions.
///
/// Injectable via `notificationServiceProvider`; tests substitute a fake that
/// records calls. All methods are safe no-ops on platforms without local
/// notification support (web, Windows without setup, Linux).
class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  /// Android 16 Live Update renderer for the countdown card. Falls back to a
  /// plain notification when the OS can't promote (pre-16, or the user
  /// revoked Live Updates for the app).
  final LiveCard _liveCard;
  bool? _canPromote;

  NotificationService({LiveCard liveCard = const LiveCard()}) : _liveCard = liveCard;

  static const _channelId = 'rest_timer';
  static const _channelName = 'Rest timer';
  static const _channelDescription = 'Alerts when the rest between sets is over';

  static const _liveChannelId = 'rest_timer_live';
  static const _liveChannelName = 'Rest countdown';
  static const _liveChannelDescription = 'Live countdown for the rest between sets';

  static const _alertDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    macOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }

  /// The live countdown card is a promoted-style ongoing notification —
  /// Android only. iOS gets a Live Activity in a later phase.
  bool get _supportsLiveCard => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Initializes the plugin and timezone database. Idempotent.
  Future<void> ensureInitialized() async {
    if (_initialized || !_isSupportedPlatform) return;
    tz_data.initializeTimeZones();
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse: restTimerBackgroundActionHandler,
    );
    _plugin = plugin;
    _initialized = true;
  }

  /// Requests notification permission (Android 13+ / iOS / macOS).
  /// Returns true when granted or not required on this platform.
  Future<bool> requestPermission() async {
    await ensureInitialized();
    final plugin = _plugin;
    if (plugin == null) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final granted = await plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? false;
      case TargetPlatform.iOS:
        final granted = await plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, sound: true);
        return granted ?? false;
      case TargetPlatform.macOS:
        final granted = await plugin
            .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, sound: true);
        return granted ?? false;
      default:
        return false;
    }
  }

  /// Schedules a one-shot notification at [when]. Replaces any prior
  /// notification with the same [id]. Skips silently if [when] is not in
  /// the future.
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    await ensureInitialized();
    final plugin = _plugin;
    if (plugin == null) return;
    if (!when.isAfter(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(when.toUtc(), tz.UTC);

    try {
      await plugin.zonedSchedule(
        id: id,
        scheduledDate: scheduledDate,
        title: title,
        body: body,
        notificationDetails: _alertDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (e, st) {
      // Android 14+ may deny exact alarms by default; fall back to inexact
      // (delivery may be delayed a few minutes, better than nothing).
      if (e.code == 'exact_alarms_not_permitted') {
        log(
          'Exact alarms not permitted, scheduling inexact rest-timer notification',
          name: 'yawa4u.notifications',
        );
        await plugin.zonedSchedule(
          id: id,
          scheduledDate: scheduledDate,
          title: title,
          body: body,
          notificationDetails: _alertDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        log('Failed to schedule notification', error: e, stackTrace: st, name: 'yawa4u.notifications');
      }
    }
  }

  /// Shows an alert notification immediately (e.g. when a background action
  /// shortens the rest past zero and the scheduled alert must fire now).
  Future<void> showNow({required int id, required String title, required String body}) async {
    await ensureInitialized();
    await _plugin?.show(id: id, title: title, body: body, notificationDetails: _alertDetails);
  }

  /// Shows the live rest countdown card: an ongoing, silent notification
  /// whose chronometer counts down to [until] rendered by the OS — it keeps
  /// ticking on the lock screen with no app involvement, even if the process
  /// dies. Quick actions (+/-/skip) are handled in a background isolate.
  ///
  /// `timeoutAfter` retires the card at the deadline without any Dart code
  /// running, which is the only thing that can clear it once the app process
  /// is gone.
  Future<void> showRestCountdown({
    required int id,
    required DateTime until,
    required LiveSetInfo info,
  }) async {
    if (!_supportsLiveCard) return;
    await ensureInitialized();
    final remainingMs = until.difference(DateTime.now()).inMilliseconds;
    if (remainingMs <= 0) return;

    if (await _promotionAvailable()) {
      await _liveCard.showCountdown(
        id: id,
        channelId: _liveChannelId,
        channelName: _liveChannelName,
        channelDescription: _liveChannelDescription,
        title: info.title,
        body: info.body,
        until: until,
        chipText: _formatMmSs((remainingMs / 1000).ceil()),
        actions: _liveCardActions(info),
      );
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _liveChannelId,
        _liveChannelName,
        channelDescription: _liveChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.workout,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        showWhen: true,
        when: until.millisecondsSinceEpoch,
        usesChronometer: true,
        chronometerCountDown: true,
        timeoutAfter: remainingMs,
        actions: _restActions(info),
      ),
    );
    await _plugin?.show(id: id, title: info.title, body: info.body, notificationDetails: details);
  }

  /// Replaces the countdown card with a static paused card. [remainingDisplay]
  /// is a pre-formatted "MM:SS" string (locale-neutral).
  Future<void> showRestPaused({
    required int id,
    required LiveSetInfo info,
    required String remainingDisplay,
  }) async {
    if (!_supportsLiveCard) return;
    await ensureInitialized();
    final body = '⏸ $remainingDisplay · ${info.body}';

    if (await _promotionAvailable()) {
      await _liveCard.showPaused(
        id: id,
        channelId: _liveChannelId,
        channelName: _liveChannelName,
        channelDescription: _liveChannelDescription,
        title: info.title,
        body: body,
        actions: _liveCardActions(info),
      );
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _liveChannelId,
        _liveChannelName,
        channelDescription: _liveChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.workout,
        visibility: NotificationVisibility.public,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        showWhen: false,
        actions: _restActions(info),
      ),
    );
    await _plugin?.show(id: id, title: info.title, body: body, notificationDetails: details);
  }

  /// Cancels a scheduled or shown notification by [id].
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin?.cancel(id: id);
  }

  static List<AndroidNotificationAction> _restActions(LiveSetInfo info) => [
    AndroidNotificationAction(RestTimerContract.actionSubtract, info.subtractLabel, cancelNotification: false),
    AndroidNotificationAction(RestTimerContract.actionAdd, info.addLabel, cancelNotification: false),
    AndroidNotificationAction(RestTimerContract.actionSkip, info.skipLabel),
  ];

  /// Same three actions as [_restActions], for the promoted renderer. Both
  /// route to the same Dart handler via flutter_local_notifications' receiver,
  /// so the action ids must stay identical.
  static List<LiveCardAction> _liveCardActions(LiveSetInfo info) => [
    LiveCardAction(id: RestTimerContract.actionSubtract, label: info.subtractLabel),
    LiveCardAction(id: RestTimerContract.actionAdd, label: info.addLabel),
    LiveCardAction(id: RestTimerContract.actionSkip, label: info.skipLabel, cancelNotification: true),
  ];

  /// Cached per process: the answer only changes when the user toggles the
  /// app's Live Updates permission, which restarts nothing but is rare enough
  /// that a stale `false` for one session is acceptable.
  Future<bool> _promotionAvailable() async {
    if (!_supportsLiveCard) return false;
    return _canPromote ??= await _liveCard.isSupported();
  }
}

/// Entry point invoked by the plugin in a background isolate when the user
/// taps a notification action (the app may be backgrounded or dead).
@pragma('vm:entry-point')
Future<void> restTimerBackgroundActionHandler(NotificationResponse response) async {
  final actionId = response.actionId;
  if (actionId == null) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await handleRestTimerAction(actionId: actionId, prefs: prefs, notifications: NotificationService());
    // Wake the main isolate (if the app is alive) so the in-app banner
    // re-derives its state from the mutated preferences.
    IsolateNameServer.lookupPortByName(RestTimerContract.resyncPortName)?.send('resync');
  } catch (e, st) {
    log('Rest-timer notification action failed', error: e, stackTrace: st, name: 'yawa4u.notifications');
  }
}

/// Applies a +/-/skip notification action to the persisted rest-timer state
/// and refreshes the notifications accordingly. Runs without any access to
/// the app's providers: SharedPreferences is the shared substrate between
/// this isolate and the main isolate's `RestTimerNotifier`.
@visibleForTesting
Future<void> handleRestTimerAction({
  required String actionId,
  required SharedPreferences prefs,
  required NotificationService notifications,
  DateTime Function() now = DateTime.now,
}) async {
  const alertId = RestTimerContract.notificationId;
  const cardId = RestTimerContract.liveCardId;

  Future<void> clearAll() async {
    for (final key in [
      RestTimerContract.endMsKey,
      RestTimerContract.totalKey,
      RestTimerContract.pausedRemainingKey,
      RestTimerContract.exerciseIdKey,
      RestTimerContract.workoutIdKey,
      RestTimerContract.titleKey,
      RestTimerContract.bodyKey,
      RestTimerContract.liveInfoKey,
    ]) {
      await prefs.remove(key);
    }
    await notifications.cancel(cardId);
    await notifications.cancel(alertId);
  }

  if (actionId == RestTimerContract.actionSkip) {
    await clearAll();
    return;
  }

  final delta = switch (actionId) {
    RestTimerContract.actionAdd => RestTimerContract.actionShiftSeconds,
    RestTimerContract.actionSubtract => -RestTimerContract.actionShiftSeconds,
    _ => 0,
  };
  if (delta == 0) return;

  final info = LiveSetInfo.fromJsonString(prefs.getString(RestTimerContract.liveInfoKey));

  final pausedRemaining = prefs.getInt(RestTimerContract.pausedRemainingKey);
  if (pausedRemaining != null) {
    final remaining = pausedRemaining + delta;
    if (remaining <= 0) {
      await clearAll();
      return;
    }
    await prefs.setInt(RestTimerContract.pausedRemainingKey, remaining);
    await prefs.setInt(
      RestTimerContract.totalKey,
      max((prefs.getInt(RestTimerContract.totalKey) ?? 0) + delta, remaining),
    );
    if (info != null) {
      await notifications.showRestPaused(id: cardId, info: info, remainingDisplay: _formatMmSs(remaining));
    }
    return;
  }

  final endMs = prefs.getInt(RestTimerContract.endMsKey);
  if (endMs == null) return;
  final newEndMs = endMs + delta * 1000;
  final remaining = ((newEndMs - now().millisecondsSinceEpoch) / 1000).ceil();
  final title = prefs.getString(RestTimerContract.titleKey) ?? 'Rest over';
  final body = prefs.getString(RestTimerContract.bodyKey) ?? 'Time for your next set';

  if (remaining <= 0) {
    await clearAll();
    await notifications.showNow(id: alertId, title: title, body: body);
    return;
  }

  await prefs.setInt(RestTimerContract.endMsKey, newEndMs);
  await prefs.setInt(
    RestTimerContract.totalKey,
    max((prefs.getInt(RestTimerContract.totalKey) ?? 0) + delta, remaining),
  );
  final end = DateTime.fromMillisecondsSinceEpoch(newEndMs);
  if (info != null) {
    await notifications.showRestCountdown(id: cardId, until: end, info: info);
  }
  await notifications.scheduleAt(id: alertId, when: end, title: title, body: body);
}

String _formatMmSs(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
