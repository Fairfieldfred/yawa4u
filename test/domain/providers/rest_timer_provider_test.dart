import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/data/services/notification_service.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';

/// Records scheduling calls instead of touching platform channels.
class FakeNotificationService implements NotificationService {
  final List<({int id, DateTime when, String title, String body})> scheduled = [];
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
  Future<void> cancel(int id) async {
    cancelled.add(id);
  }
}

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
    await container.pump();

    expect(notifications.scheduled, hasLength(1));
    expect(notifications.scheduled.single.when, now.add(const Duration(seconds: 90)));
    expect(notifications.scheduled.single.title, 'Rest over');
    expect(notifications.scheduled.single.id, RestTimerNotifier.notificationId);

    notifier.cancel();
    await container.pump();

    expect(notifications.cancelled, [RestTimerNotifier.notificationId]);
    expect(container.read(restTimerProvider).isRunning, false);
  });

  test('addTime reschedules the notification and shifts the deadline both ways', () async {
    final container = makeContainer();
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(60);
    await container.pump();
    expect(notifications.scheduled, hasLength(1));

    notifier.addTime(30);
    await container.pump();
    expect(notifications.scheduled, hasLength(2));
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 90)));
    expect(container.read(restTimerProvider).remainingSeconds, 90);

    notifier.addTime(-30);
    await container.pump();
    expect(notifications.scheduled, hasLength(3));
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 60)));
    expect(container.read(restTimerProvider).remainingSeconds, 60);

    notifier.cancel();
  });

  test('subtracting past zero completes the timer immediately', () async {
    final hapticLog = <String>[];
    final container = makeContainer(hapticLog: hapticLog);
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(20);
    notifier.addTime(-30);
    await container.pump();

    expect(container.read(restTimerProvider).isRunning, false);
    expect(hapticLog, ['haptic']);
  });

  test('completion fires haptic and resets state exactly once', () async {
    final hapticLog = <String>[];
    final container = makeContainer(hapticLog: hapticLog);
    final notifier = container.read(restTimerProvider.notifier);

    notifier.startCustom(10);
    now = now.add(const Duration(seconds: 11));

    // Both a tick-driven check and a lifecycle resync observe the elapsed
    // deadline; completion must only fire once.
    notifier.resync();
    notifier.resync();
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
    await container.pump();

    expect(notifications.cancelled, [RestTimerNotifier.notificationId]);
    expect(container.read(restTimerProvider).isPaused, true);
    expect(container.read(restTimerProvider).remainingSeconds, 40);

    now = now.add(const Duration(minutes: 5));
    notifier.resume();
    await container.pump();

    expect(container.read(restTimerProvider).isPaused, false);
    expect(container.read(restTimerProvider).remainingSeconds, 40);
    expect(notifications.scheduled.last.when, now.add(const Duration(seconds: 40)));

    notifier.cancel();
  });
}
