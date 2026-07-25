import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/data/services/cloud_backup_service.dart';
import 'package:yawa4u/data/services/data_backup_service.dart';
import 'package:yawa4u/data/services/firebase_auth_service.dart';
import 'package:yawa4u/domain/providers/auth_providers.dart';
import 'package:yawa4u/domain/providers/cloud_backup_providers.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/sync_providers.dart';

class _MockCloudBackupService extends Mock implements CloudBackupService {}

class _MockDataBackupService extends Mock implements DataBackupService {}

class _MockAuthService extends Mock implements FirebaseAuthService {}

class _MockUser extends Mock implements User {}

DataStats _stats(int trainingCycles) => DataStats(
  trainingCycleCount: trainingCycles,
  workoutCount: 0,
  exerciseCount: 0,
  customExerciseCount: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCloudBackupService service;
  late _MockDataBackupService dataBackupService;
  late _MockAuthService authService;

  void stubAuth({required bool signedIn, bool verified = true}) {
    if (!signedIn) {
      when(() => authService.currentUser).thenReturn(null);
      when(() => authService.isEmailVerified).thenReturn(false);
    } else {
      final user = _MockUser();
      when(() => user.uid).thenReturn('user-1');
      when(() => authService.currentUser).thenReturn(user);
      when(() => authService.isEmailVerified).thenReturn(verified);
    }
  }

  Future<ProviderContainer> createContainer({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        cloudBackupServiceProvider.overrideWithValue(service),
        dataBackupServiceProvider.overrideWithValue(dataBackupService),
        firebaseAuthServiceProvider.overrideWithValue(authService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    service = _MockCloudBackupService();
    dataBackupService = _MockDataBackupService();
    authService = _MockAuthService();
    stubAuth(signedIn: true);
    when(() => service.backupNow()).thenAnswer((_) async => CloudBackupResult(success: true));
    when(() => service.fetchMetadata()).thenAnswer((_) async => null);
    when(() => dataBackupService.getStats()).thenAnswer((_) async => _stats(1));
  });

  group('cloudBackupSettingsProvider', () {
    test('defaults to disabled with no last backup', () async {
      final container = await createContainer();
      final settings = container.read(cloudBackupSettingsProvider);
      expect(settings.enabled, isFalse);
      expect(settings.lastBackupAt, isNull);
    });

    test('setEnabled persists to SharedPreferences', () async {
      final container = await createContainer();
      await container.read(cloudBackupSettingsProvider.notifier).setEnabled(true);

      expect(container.read(cloudBackupSettingsProvider).enabled, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('cloud_backup_enabled'), isTrue);
    });

    test('markBackedUp persists the timestamp', () async {
      final container = await createContainer();
      final when_ = DateTime(2026, 7, 22, 12);
      await container.read(cloudBackupSettingsProvider.notifier).markBackedUp(when_);

      expect(container.read(cloudBackupSettingsProvider).lastBackupAt, when_);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('cloud_backup_last_backup_at'), when_.millisecondsSinceEpoch);
    });

    test('reads persisted values on build', () async {
      final stamp = DateTime(2026, 7, 20).millisecondsSinceEpoch;
      final container = await createContainer(
        prefs: {'cloud_backup_enabled': true, 'cloud_backup_last_backup_at': stamp},
      );
      final settings = container.read(cloudBackupSettingsProvider);
      expect(settings.enabled, isTrue);
      expect(settings.lastBackupAt, DateTime.fromMillisecondsSinceEpoch(stamp));
    });
  });

  group('CloudBackupController.backupNow', () {
    test('updates lastBackupAt and status on success', () async {
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      final result = await container.read(cloudBackupControllerProvider.notifier).backupNow();

      expect(result.success, isTrue);
      expect(container.read(cloudBackupControllerProvider).state, CloudBackupRunState.success);
      expect(container.read(cloudBackupSettingsProvider).lastBackupAt, isNotNull);
    });

    test('leaves lastBackupAt unchanged and reports error on failure', () async {
      when(() => service.backupNow()).thenAnswer((_) async => CloudBackupResult(success: false, error: 'offline'));
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      final result = await container.read(cloudBackupControllerProvider.notifier).backupNow();

      expect(result.success, isFalse);
      final status = container.read(cloudBackupControllerProvider);
      expect(status.state, CloudBackupRunState.error);
      expect(status.errorMessage, 'offline');
      expect(container.read(cloudBackupSettingsProvider).lastBackupAt, isNull);
    });

    test('rejects a second call while one is in flight', () async {
      final completer = Completer<CloudBackupResult>();
      when(() => service.backupNow()).thenAnswer((_) => completer.future);
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      final controller = container.read(cloudBackupControllerProvider.notifier);

      final first = controller.backupNow();
      final second = await controller.backupNow();
      expect(second.success, isFalse);

      completer.complete(CloudBackupResult(success: true));
      expect((await first).success, isTrue);
      verify(() => service.backupNow()).called(1);
    });
  });

  group('CloudBackupController.maybeAutoBackup', () {
    test('skips when disabled', () async {
      final container = await createContainer();
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });

    test('skips when not signed in', () async {
      stubAuth(signedIn: false);
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });

    test('skips when email is unverified', () async {
      stubAuth(signedIn: true, verified: false);
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });

    test('skips when the last backup is fresh', () async {
      final recent = DateTime.now().subtract(const Duration(hours: 1));
      final container = await createContainer(
        prefs: {
          'cloud_backup_enabled': true,
          'cloud_backup_last_backup_at': recent.millisecondsSinceEpoch,
        },
      );
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });

    test('runs when the last backup is stale', () async {
      final stale = DateTime.now().subtract(const Duration(hours: 25));
      final container = await createContainer(
        prefs: {
          'cloud_backup_enabled': true,
          'cloud_backup_last_backup_at': stale.millisecondsSinceEpoch,
        },
      );
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verify(() => service.backupNow()).called(1);
    });

    test('runs when never backed up and the cloud slot is empty', () async {
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verify(() => service.backupNow()).called(1);
    });

    test('skips when the local database is empty', () async {
      // Regression: a fresh device must never overwrite the cloud slot with
      // an empty database.
      when(() => dataBackupService.getStats()).thenAnswer((_) async => _stats(0));
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });

    test('skips when never backed up but a cloud backup already exists', () async {
      // Regression: a new device with local data but no backup history must
      // not silently overwrite an existing cloud backup — restore or an
      // explicit manual backup comes first.
      when(() => service.fetchMetadata()).thenAnswer(
        (_) async => CloudBackupMetadata(backupVersion: 4, stats: const {'trainingCycles': 3}),
      );
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).maybeAutoBackup();
      verifyNever(() => service.backupNow());
    });
  });

  group('CloudBackupController.restore', () {
    test('marks a sync point on success so auto-backup resumes safely', () async {
      when(() => service.restore()).thenAnswer(
        (_) async => CloudRestoreResult(success: true),
      );
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).restore();
      expect(container.read(cloudBackupSettingsProvider).lastBackupAt, isNotNull);
    });

    test('does not mark a sync point on failure', () async {
      when(() => service.restore()).thenAnswer(
        (_) async => CloudRestoreResult(success: false, notFound: true),
      );
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});
      await container.read(cloudBackupControllerProvider.notifier).restore();
      expect(container.read(cloudBackupSettingsProvider).lastBackupAt, isNull);
    });
  });

  group('autoCloudBackupTriggerProvider', () {
    test('fires the auto-backup check once per container', () async {
      final container = await createContainer(prefs: {'cloud_backup_enabled': true});

      container.read(autoCloudBackupTriggerProvider);
      container.read(autoCloudBackupTriggerProvider);
      await Future<void>.delayed(Duration.zero);

      verify(() => service.backupNow()).called(1);
    });
  });
}
