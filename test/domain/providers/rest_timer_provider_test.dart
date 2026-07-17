import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/rest_timer_contract.dart';
import 'package:yawa4u/data/models/live_set_info.dart';
import 'package:yawa4u/data/services/notification_service.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';

/// Records scheduling calls instead of touching platform channels.
class FakeNotificationService implements NotificationService {
  final List<({int id, DateTime when, String title, String body})> scheduled = [];
  final List<({int id, DateTime until, LiveSetInfo info})> countdownCards = [];
  final List<({int id, LiveSetInfo info, String remainingDisplay})> pausedCards = [];
  final List<({int id, String title, String body})> shownNow = [];
  final List<int> cancelled = [];
  int permissionRequests = 0;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    scheduled.add((id: id, when: when, title: title, body: body));
  }

  @override
  Future<void> showNow({required int id, required String title, required String body}) async {
    shownNow.add((id: id, title: title, body: body));
  }

  @override
  Future<void> showRestCountdown({required int id, required DateTime until, required LiveSetInfo info}) async {
    countdownCards.add((id: id, until: until, info: info));
  }

  @override
  Future<void> showRestPaused({required int id, required LiveSetInfo info, required String remainingDisplay}) async {
    pausedCards.add((id: id, info: info, remainingDisplay: remainingDisplay));
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}

const _liveInfo = LiveSetInfo(
  title: 'Bench Press',
  body: 'Next: set 2 of 4 · 80 kg × 8',
  addLabel: '+30s',
  subtractLabel: '−30s',
  skipLabel: 'Skip',
);

/// Drains the microtask chain behind the timer's deferred notification work
/// (permission → schedule → live card) by yielding a full event-loop turn.
Future<void> flushAsyncWork() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late FakeNotificationService notifications;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    notifications = FakeNotificationService();
    now = DateTime(2026, 1, 1, 10, 0, 0);
  });

  ProviderContainer makeContainer({List<String> hapticLog = const []}) {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        restTimerClockProvider.overrideWithValue(() => now),
        notificationServiceProvider.overrideWithValue(notifications),
        restTimerHapticProvider.overrideWithValue(() async => hapticLog.add('haptic')),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('running timer state survives provider rebuild via persisted end-timestamp', () async {
    final container = makeContainer();
    container.read(restTimerProvider.notifier).startCustom(60);
    expect(container.read(restTimerProvider).remainingSeconds, 60);
    expect(container.read(restTimerProvider).isRunning, true);
    container.dispose();

    // 20 wall-clock seconds pass while no provider exists (e.g. app killed).
    now = now.add(const Duration(seconds: 20));

    final rebuilt = makeContainer();
    final state = rebuilt.read(restTimerProvider);
    expect(state.isRunning, true);
    expect(state.isPaused, false);
    expect(state.remainingSeconds, 40);
    expect(state.totalSeconds, 60);
  });

  test('start schedules a notification at the deadline; skip cancels it', () async {
    final container = makeContainer();
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(90, notificationTitle: 'Rest over', notificationBody: 'Next set');
    await flushAsyncWork();

    expect(notifications.scheduled, hasLength(1));
    expect(notifications.scheduled.single.when, now.add(const Duration(seconds: 90)));
    expect(notifications.scheduled.single.title, 'Rest over');
    expect(notifications.scheduled.single.id, RestTimerNotifier.notificationId);

    notifier.cancel();
    await flushAsyncWork();

    expect(notifications.cancelled, containsAll([RestTimerNotifier.notificationId, RestTimerNotifier.liveCardId]));
    expect(container.read(restTimerProvider).isRunning, false);
  });

  test('starting a rest clears a lingering "Rest over" so the next alert can sound', () async {
    final container = makeContainer(hapticLog: <String>[]);
    final notifier = container.read(restTimerProvider.notifier);

    // Rest 1 runs to its deadline; the alert it posted stays on screen
    // because the user never tapped it.
    notifier.startCustom(60);
    now = now.add(const Duration(seconds: 61));
    await notifier.resync();
    await flushAsyncWork();
    notifications.cancelled.clear();

    // Rest 2 must drop that stale alert before scheduling, otherwise the new
    // alert is an update to a visible notification and never makes a sound.
    notifier.startCustom(60);
    await flushAsyncWork();

    expect(notifications.cancelled, contains(RestTimerNotifier.notificationId));
    notifier.cancel();
  });

  test('the alert and the live card never share a notification id', () {
    // Sharing one id let the card's low-importance silent channel own the id,
    // so the deadline alert updated it instead of alerting — it went silent.
    expect(RestTimerNotifier.notificationId, isNot(RestTimerNotifier.liveCardId));
  });

  test('addTime reschedules the notification and shifts the deadline both ways', () async {
    final container = makeContainer();
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(60);
    await flushAsyncWork();
    expect(notifications.scheduled, hasLength(1));

    notifier.addTime(30);
    await flushAsyncWork();
    expect(notifications.scheduled, hasLength(2));
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 90)));
    expect(container.read(restTimerProvider).remainingSeconds, 90);

    notifier.addTime(-30);
    await flushAsyncWork();
    expect(notifications.scheduled, hasLength(3));
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 60)));
    expect(container.read(restTimerProvider).remainingSeconds, 60);

    notifier.cancel();
  });

  test('subtracting past zero completes the timer immediately and clears notifications', () async {
    final hapticLog = <String>[];
    final container = makeContainer(hapticLog: hapticLog);
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(20);
    notifier.addTime(-30);
    await container.pump();

    expect(container.read(restTimerProvider).isRunning, false);
    expect(hapticLog, ['haptic']);
    // The pending alert for the old (now stale) deadline must not fire later,
    // and the card must not outlive the rest it was counting down.
    expect(notifications.cancelled, containsAll([RestTimerNotifier.notificationId, RestTimerNotifier.liveCardId]));
  });

  test('completion fires haptic and resets state exactly once', () async {
    final hapticLog = <String>[];
    final container = makeContainer(hapticLog: hapticLog);
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(10);
    now = now.add(const Duration(seconds: 11));

    // Both a tick-driven check and a lifecycle resync observe the elapsed
    // deadline; completion must only fire once.
    await notifier.resync();
    await notifier.resync();
    await container.pump();

    expect(container.read(restTimerProvider).isRunning, false);
    expect(container.read(restTimerProvider).remainingSeconds, 0);
    expect(hapticLog, ['haptic']);
  });

  test('pause cancels the notification, resume reschedules from the new deadline', () async {
    final container = makeContainer();
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(60);
    now = now.add(const Duration(seconds: 20));
    notifier.pause();
    await flushAsyncWork();

    // Only the alert is dropped; the card must survive to show as paused.
    expect(notifications.cancelled, contains(RestTimerNotifier.notificationId));
    expect(notifications.cancelled, isNot(contains(RestTimerNotifier.liveCardId)));
    expect(container.read(restTimerProvider).isPaused, true);
    expect(container.read(restTimerProvider).remainingSeconds, 40);

    now = now.add(const Duration(minutes: 5));
    notifier.resume();
    await flushAsyncWork();

    expect(container.read(restTimerProvider).isPaused, false);
    expect(container.read(restTimerProvider).remainingSeconds, 40);
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 40)));

    notifier.cancel();
  });

  group('live countdown card', () {
    test('start with liveInfo shows the card and persists the payload', () async {
      final container = makeContainer();
      container.read(restTimerProvider.notifier).startCustom(60, liveInfo: _liveInfo);
      await flushAsyncWork();

      expect(notifications.countdownCards, hasLength(1));
      expect(notifications.countdownCards.single.id, RestTimerNotifier.liveCardId);
      expect(notifications.countdownCards.single.until, now.add(const Duration(seconds: 60)));
      expect(notifications.countdownCards.single.info.title, 'Bench Press');
      expect(
        LiveSetInfo.fromJsonString(prefs.getString(RestTimerContract.liveInfoKey))?.body,
        'Next: set 2 of 4 · 80 kg × 8',
      );
    });

    test('start without liveInfo shows no card', () async {
      final container = makeContainer();
      container.read(restTimerProvider.notifier).startCustom(60);
      await flushAsyncWork();

      expect(notifications.countdownCards, isEmpty);
      expect(prefs.getString(RestTimerContract.liveInfoKey), isNull);
    });

    test('addTime reposts the card with the shifted deadline', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);
      await flushAsyncWork();
      notifier.addTime(30);
      await flushAsyncWork();

      expect(notifications.countdownCards, hasLength(2));
      expect(notifications.countdownCards.last.until, now.add(const Duration(seconds: 90)));

      notifier.cancel();
    });

    test('a card deferred behind the permission request never posts after a newer transition', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      // Cancel lands before the deferred start card does: no orphaned
      // ongoing notification may surface afterwards.
      notifier.startCustom(60, liveInfo: _liveInfo);
      notifier.cancel();
      await flushAsyncWork();
      expect(notifications.countdownCards, isEmpty);

      // An immediate addTime repost wins over the stale deferred start card.
      notifier.startCustom(60, liveInfo: _liveInfo);
      notifier.addTime(30);
      await flushAsyncWork();
      expect(notifications.countdownCards, hasLength(1));
      expect(notifications.countdownCards.single.until, now.add(const Duration(seconds: 90)));

      notifier.cancel();
    });

    test('pause shows the paused card, resume reposts the countdown', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);
      now = now.add(const Duration(seconds: 20));
      notifier.pause();
      await flushAsyncWork();

      expect(notifications.pausedCards, hasLength(1));
      expect(notifications.pausedCards.single.id, RestTimerNotifier.liveCardId);
      expect(notifications.pausedCards.single.remainingDisplay, '00:40');
      // Pausing drops only the alert — the card stays, restyled as paused.
      expect(notifications.cancelled, isNot(contains(RestTimerNotifier.liveCardId)));

      notifier.resume();
      await flushAsyncWork();

      expect(notifications.countdownCards.last.until, now.add(const Duration(seconds: 40)));

      notifier.cancel();
      await flushAsyncWork();
      expect(notifications.cancelled, containsAll([RestTimerNotifier.notificationId, RestTimerNotifier.liveCardId]));
    });

    test('cancel clears the persisted payload', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);
      notifier.cancel();
      await container.pump();

      expect(prefs.getString(RestTimerContract.liveInfoKey), isNull);
    });
  });

  group('resync after background notification actions', () {
    test('picks up a deadline shifted by a background action', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);

      // Simulate the background isolate's +30s mutation.
      final endMs = prefs.getInt(RestTimerContract.endMsKey)!;
      await prefs.setInt(RestTimerContract.endMsKey, endMs + 30 * 1000);
      await prefs.setInt(RestTimerContract.totalKey, 90);

      await notifier.resync();

      expect(container.read(restTimerProvider).remainingSeconds, 90);
      expect(container.read(restTimerProvider).totalSeconds, 90);

      notifier.cancel();
    });

    test('resets running state after a background skip cleared the timer', () async {
      final hapticLog = <String>[];
      final container = makeContainer(hapticLog: hapticLog);
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);
      expect(container.read(restTimerProvider).isRunning, true);

      // Simulate the background isolate's skip: all keys removed.
      await prefs.remove(RestTimerContract.endMsKey);
      await prefs.remove(RestTimerContract.totalKey);
      await prefs.remove(RestTimerContract.liveInfoKey);

      await notifier.resync();

      expect(container.read(restTimerProvider).isRunning, false);
      // A deliberate skip is not a completion: no haptic.
      expect(hapticLog, isEmpty);
    });

    test('picks up a paused remaining shifted by a background action', () async {
      final container = makeContainer();
      final notifier = container.read(restTimerProvider.notifier);

      notifier.startCustom(60, liveInfo: _liveInfo);
      notifier.pause();
      expect(container.read(restTimerProvider).remainingSeconds, 60);

      await prefs.setInt(RestTimerContract.pausedRemainingKey, 90);
      await prefs.setInt(RestTimerContract.totalKey, 90);

      await notifier.resync();

      expect(container.read(restTimerProvider).isPaused, true);
      expect(container.read(restTimerProvider).remainingSeconds, 90);

      notifier.cancel();
    });
  });

  group('handleRestTimerAction (background isolate logic)', () {
    Future<void> seedRunningTimer({int seconds = 60}) async {
      await prefs.setInt(RestTimerContract.endMsKey, now.add(Duration(seconds: seconds)).millisecondsSinceEpoch);
      await prefs.setInt(RestTimerContract.totalKey, seconds);
      await prefs.setString(RestTimerContract.titleKey, 'Rest over');
      await prefs.setString(RestTimerContract.bodyKey, 'Next set');
      await prefs.setString(RestTimerContract.liveInfoKey, _liveInfo.toJsonString());
    }

    test('add shifts the deadline, reposts the card and reschedules the alert', () async {
      await seedRunningTimer();

      await handleRestTimerAction(
        actionId: RestTimerContract.actionAdd,
        prefs: prefs,
        notifications: notifications,
        now: () => now,
      );

      final expectedEnd = now.add(const Duration(seconds: 90));
      expect(prefs.getInt(RestTimerContract.endMsKey), expectedEnd.millisecondsSinceEpoch);
      expect(prefs.getInt(RestTimerContract.totalKey), 90);
      expect(notifications.countdownCards.single.until, expectedEnd);
      expect(notifications.countdownCards.single.id, RestTimerContract.liveCardId);
      expect(notifications.scheduled.single.when, expectedEnd);
      expect(notifications.scheduled.single.title, 'Rest over');
      // The rescheduled alert must keep its own id, or it lands on the card's
      // silent channel and never sounds.
      expect(notifications.scheduled.single.id, RestTimerContract.notificationId);
    });

    test('subtract past zero clears state and fires the alert immediately', () async {
      await seedRunningTimer(seconds: 20);

      await handleRestTimerAction(
        actionId: RestTimerContract.actionSubtract,
        prefs: prefs,
        notifications: notifications,
        now: () => now,
      );

      expect(prefs.getInt(RestTimerContract.endMsKey), isNull);
      expect(prefs.getString(RestTimerContract.liveInfoKey), isNull);
      expect(
        notifications.cancelled,
        containsAll([RestTimerContract.notificationId, RestTimerContract.liveCardId]),
      );
      expect(notifications.shownNow.single.title, 'Rest over');
      expect(notifications.shownNow.single.id, RestTimerContract.notificationId);
    });

    test('skip clears everything and cancels the notification', () async {
      await seedRunningTimer();

      await handleRestTimerAction(
        actionId: RestTimerContract.actionSkip,
        prefs: prefs,
        notifications: notifications,
        now: () => now,
      );

      expect(prefs.getInt(RestTimerContract.endMsKey), isNull);
      expect(prefs.getInt(RestTimerContract.totalKey), isNull);
      expect(prefs.getString(RestTimerContract.liveInfoKey), isNull);
      expect(
        notifications.cancelled,
        containsAll([RestTimerContract.notificationId, RestTimerContract.liveCardId]),
      );
      expect(notifications.shownNow, isEmpty);
      expect(notifications.scheduled, isEmpty);
    });

    test('add while paused updates the paused remaining and reposts the paused card', () async {
      await prefs.setInt(RestTimerContract.pausedRemainingKey, 40);
      await prefs.setInt(RestTimerContract.totalKey, 60);
      await prefs.setString(RestTimerContract.liveInfoKey, _liveInfo.toJsonString());

      await handleRestTimerAction(
        actionId: RestTimerContract.actionAdd,
        prefs: prefs,
        notifications: notifications,
        now: () => now,
      );

      expect(prefs.getInt(RestTimerContract.pausedRemainingKey), 70);
      expect(prefs.getInt(RestTimerContract.totalKey), 90);
      expect(notifications.pausedCards.single.remainingDisplay, '01:10');
      expect(notifications.pausedCards.single.id, RestTimerContract.liveCardId);
      expect(notifications.scheduled, isEmpty);
    });
  });
}
