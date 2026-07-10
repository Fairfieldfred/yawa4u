import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around [FlutterLocalNotificationsPlugin] for one-shot local
/// notifications (currently only the rest timer).
///
/// Injectable via `notificationServiceProvider`; tests substitute a fake that
/// records calls. All methods are safe no-ops on platforms without local
/// notification support (web, Windows without setup, Linux).
class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  static const _channelId = 'rest_timer';
  static const _channelName = 'Rest timer';
  static const _channelDescription = 'Alerts when the rest between sets is over';

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }

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

    const details = NotificationDetails(
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
    final scheduledDate = tz.TZDateTime.from(when.toUtc(), tz.UTC);

    try {
      await plugin.zonedSchedule(
        id: id,
        scheduledDate: scheduledDate,
        title: title,
        body: body,
        notificationDetails: details,
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
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } else {
        log('Failed to schedule notification', error: e, stackTrace: st, name: 'yawa4u.notifications');
      }
    }
  }

  /// Cancels a scheduled or shown notification by [id].
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin?.cancel(id: id);
  }
}
