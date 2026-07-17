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

/// A glanceable, self-ticking card on the lock screen.
///
/// One API over two native mechanisms that solve the same problem:
///
/// * **Android 16+** — a *Live Update*: a promoted ongoing notification with a
///   status-bar chip, a pinned lock-screen card, and a Samsung Now Bar slot.
///   Needed because a plain `IMPORTANCE_LOW` ongoing notification is demoted
///   to a bare icon on One UI, and raising importance to fix that would make
///   it audible on every update.
/// * **iOS 16.2+** — an ActivityKit *Live Activity* on the Lock Screen and
///   Dynamic Island.
///
/// Both render the countdown from a wall-clock deadline in their own process,
/// so a running timer costs zero updates — only real state transitions are
/// pushed.
///
/// [isSupported] is always feature-detected, never inferred from an OS
/// version: Android users can revoke Live Updates per app (and OEMs add their
/// own criteria), and iOS users can disable Live Activities. Callers must have
/// a fallback for false.
class LiveCard {
  static const MethodChannel _channel = MethodChannel('yawa4u/live_card');

  const LiveCard();

  static bool get _platformSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Whether this device can show a live card right now.
  Future<bool> isSupported() async {
    if (!_platformSupported) return false;
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
  /// Shows a static (non-counting) card — used while the timer is paused.
  ///
  /// [pausedDisplay] is the frozen "MM:SS" value: a system timer view can only
  /// count, so a paused card has to render pre-formatted text instead.
  Future<void> showPaused({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    String? pausedDisplay,
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
      'pausedDisplay': pausedDisplay,
      'actions': actions.map((a) => a._toMap()).toList(),
    });
  }

  Future<void> cancel(int id) => _invoke('cancel', {'id': id});

  Future<void> _invoke(String method, Map<String, Object?> args) async {
    if (!_platformSupported) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Engine without the plugin registered — caller falls back.
    } on PlatformException {
      // Never let a cosmetic card take down a rest timer.
    }
  }
}
