import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One button on a live card.
class LiveCardAction {
  /// Action id delivered back to the app's notification-action handler.
  final String id;
  final String label;

  /// Whether tapping it dismisses the card (true for a terminal action).
  final bool cancelNotification;

  const LiveCardAction({
    required this.id,
    required this.label,
    this.cancelNotification = false,
  });

  Map<String, Object?> _toMap() => {
    'id': id,
    'label': label,
    'cancelNotification': cancelNotification,
  };
}

/// Posts an ongoing notification as an Android 16 **Live Update** — a promoted
/// notification that earns a status-bar chip, a pinned lock-screen card, and a
/// slot in Samsung's Now Bar.
///
/// This exists because a plain `IMPORTANCE_LOW` ongoing notification is demoted
/// to a bare icon on the One UI lock screen, and raising importance to fix that
/// would make it audible on every update. Promotion is the sanctioned way to be
/// both silent and visible.
///
/// [isSupported] is feature-detected via `canPostPromotedNotifications()` — not
/// an API-level check — because users can revoke Live Updates per app and OEMs
/// add their own criteria. Callers must fall back to an ordinary notification
/// when it returns false.
class LiveCard {
  static const MethodChannel _channel = MethodChannel('yawa4u/live_card');

  const LiveCard();

  /// Whether this device can post promoted notifications right now.
  Future<bool> isSupported() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Shows a card counting down to [until], rendered by the OS.
  ///
  /// [chipText] is the short status-bar chip label (Android caps the chip at
  /// ~96dp, so keep it to a few characters).
  Future<void> showCountdown({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required DateTime until,
    String? channelDescription,
    String? chipText,
    List<LiveCardAction> actions = const [],
  }) async {
    await _invoke('showCountdown', {
      'id': id,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'title': title,
      'body': body,
      'untilMs': until.millisecondsSinceEpoch,
      'chipText': chipText,
      'actions': actions.map((a) => a._toMap()).toList(),
    });
  }

  /// Shows a static (non-counting) card — used while the timer is paused.
  Future<void> showPaused({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    String? channelDescription,
    List<LiveCardAction> actions = const [],
  }) async {
    await _invoke('showPaused', {
      'id': id,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'title': title,
      'body': body,
      'actions': actions.map((a) => a._toMap()).toList(),
    });
  }

  Future<void> cancel(int id) => _invoke('cancel', {'id': id});

  Future<void> _invoke(String method, Map<String, Object?> args) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Engine without the plugin registered — caller falls back.
    } on PlatformException {
      // Never let a cosmetic card take down a rest timer.
    }
  }
}
