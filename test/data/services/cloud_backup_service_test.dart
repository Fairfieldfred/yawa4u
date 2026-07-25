import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/theme/skins/skin_repository.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/cardio_feedback_repository.dart';
import 'package:yawa4u/data/repositories/custom_exercise_repository.dart';
import 'package:yawa4u/data/repositories/cycle_period_repository.dart';
import 'package:yawa4u/data/repositories/exercise_repository.dart';
import 'package:yawa4u/data/repositories/session_repository.dart';
import 'package:yawa4u/data/repositories/sport_zone_repository.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/data/services/cloud_backup_service.dart';
import 'package:yawa4u/data/services/data_backup_service.dart';
import 'package:yawa4u/data/services/firebase_auth_service.dart';

import '../../helpers/test_fixtures.dart';

class _MockAuthService extends Mock implements FirebaseAuthService {}

class _MockUser extends Mock implements User {}

/// In-memory gateway: `blobs[uid]` holds the uploaded bytes, `metadata[uid]`
/// the metadata map. Set [throwOnUpload]/[throwOnDownload] to simulate
/// network failures.
class _FakeGateway implements CloudBackupGateway {
  final blobs = <String, Uint8List>{};
  final metadata = <String, Map<String, dynamic>>{};
  bool throwOnUpload = false;
  bool throwOnDownload = false;

  @override
  Future<void> upload(String uid, Uint8List bytes, Map<String, dynamic> meta) async {
    if (throwOnUpload) throw Exception('network down');
    blobs[uid] = bytes;
    metadata[uid] = meta;
  }

  @override
  Future<Uint8List?> download(String uid, {required int maxSizeBytes}) async {
    if (throwOnDownload) throw Exception('network down');
    return blobs[uid];
  }

  @override
  Future<Map<String, dynamic>?> readMetadata(String uid) async => metadata[uid];

  @override
  Future<void> delete(String uid) async {
    blobs.remove(uid);
    metadata.remove(uid);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DataBackupService backupService;
  late TrainingCycleRepository cycleRepo;
  late WorkoutRepository workoutRepo;
  late _MockAuthService authService;
  late _FakeGateway gateway;
  late CloudBackupService cloudBackupService;

  void stubAuth({String? uid, bool verified = true}) {
    if (uid == null) {
      when(() => authService.currentUser).thenReturn(null);
      when(() => authService.isEmailVerified).thenReturn(false);
    } else {
      final user = _MockUser();
      when(() => user.uid).thenReturn(uid);
      when(() => authService.currentUser).thenReturn(user);
      when(() => authService.isEmailVerified).thenReturn(verified);
    }
  }

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());

    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
    final sessionRepo = SessionRepository(
      db.sessionDao,
      db.exerciseDao,
      db.exerciseSetDao,
      db.sessionCardioDao,
      db.sessionIntervalDao,
      db.sessionSampleDao,
      db.cardioFeedbackDao,
    );
    workoutRepo = WorkoutRepository(sessionRepo, db.exerciseDao);

    SharedPreferences.setMockInitialValues({});
    final skinRepo = SkinRepository();
    final prefs = await SharedPreferences.getInstance();
    await skinRepo.initialize(prefs);

    backupService = DataBackupService(
      trainingCycleRepository: cycleRepo,
      workoutRepository: workoutRepo,
      exerciseRepository: ExerciseRepository(db.exerciseDao, db.exerciseSetDao),
      customExerciseRepository: CustomExerciseRepository(db.customExerciseDao),
      sessionRepository: sessionRepo,
      cyclePeriodRepository: CyclePeriodRepository(db.cyclePeriodDao),
      sportZoneRepository: SportZoneRepository(db.sportZoneDao),
      cardioFeedbackRepository: CardioFeedbackRepository(db.cardioFeedbackDao),
      skinRepository: skinRepo,
    );

    PackageInfo.setMockInitialValues(
      appName: 'yawa4u',
      packageName: 'test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
      installerStore: null,
    );

    authService = _MockAuthService();
    gateway = _FakeGateway();
    cloudBackupService = CloudBackupService(
      backupService: backupService,
      authService: authService,
      gateway: gateway,
      deviceName: () async => 'Test Device',
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('backupNow', () {
    test('uploads gzipped export with correct metadata', () async {
      stubAuth(uid: 'user-1');
      final cycle = TestFixtures.createTrainingCycle(id: 'cycle-1');
      await cycleRepo.create(cycle);
      await workoutRepo.create(TestFixtures.createWorkout(id: 'w-1', trainingCycleId: 'cycle-1'));

      final result = await cloudBackupService.backupNow();

      expect(result.success, isTrue);
      final bytes = gateway.blobs['user-1']!;
      expect(bytes[0], 0x1f);
      expect(bytes[1], 0x8b);
      expect(result.sizeBytes, bytes.length);

      final json = jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, dynamic>;
      expect(json['version'], 4);
      expect(json['trainingCycles'], hasLength(1));

      final meta = gateway.metadata['user-1']!;
      expect(meta['sizeBytes'], bytes.length);
      expect(meta['backupVersion'], 4);
      expect(meta['deviceName'], 'Test Device');
      expect(meta['appVersion'], '1.0.0+1');
      expect((meta['stats'] as Map)['trainingCycles'], 1);
    });

    test('overwrites the previous backup (single cloud slot)', () async {
      stubAuth(uid: 'user-1');
      await cloudBackupService.backupNow();
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-1'));
      await cloudBackupService.backupNow();

      expect(gateway.blobs, hasLength(1));
      final json = jsonDecode(utf8.decode(gzip.decode(gateway.blobs['user-1']!)));
      expect(json['trainingCycles'], hasLength(1));
    });

    test('fails without a signed-in user', () async {
      stubAuth(uid: null);
      final result = await cloudBackupService.backupNow();
      expect(result.success, isFalse);
      expect(gateway.blobs, isEmpty);
    });

    test('fails when email is unverified', () async {
      stubAuth(uid: 'user-1', verified: false);
      final result = await cloudBackupService.backupNow();
      expect(result.success, isFalse);
      expect(gateway.blobs, isEmpty);
    });

    test('returns failure when the gateway throws', () async {
      stubAuth(uid: 'user-1');
      gateway.throwOnUpload = true;
      final result = await cloudBackupService.backupNow();
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
    });
  });

  group('restore', () {
    test('merges backup into local data without duplicates', () async {
      stubAuth(uid: 'user-1');
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-1'));
      await workoutRepo.create(TestFixtures.createWorkout(id: 'w-1', trainingCycleId: 'cycle-1'));
      await cloudBackupService.backupNow();

      // A second cycle created after the backup must survive the restore.
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-2'));

      final result = await cloudBackupService.restore();
      expect(result.success, isTrue);
      // Everything in the backup already exists locally → nothing re-imported.
      expect(result.importResult!.trainingCyclesImported, 0);
      expect(await cycleRepo.getAll(), hasLength(2));

      // Restoring twice stays duplicate-free.
      final second = await cloudBackupService.restore();
      expect(second.success, isTrue);
      expect(await cycleRepo.getAll(), hasLength(2));
    });

    test('imports missing rows from the backup', () async {
      stubAuth(uid: 'user-1');
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-1'));
      await cloudBackupService.backupNow();

      await cycleRepo.deleteAll();
      expect(await cycleRepo.getAll(), isEmpty);

      final result = await cloudBackupService.restore();
      expect(result.success, isTrue);
      expect(result.importResult!.trainingCyclesImported, 1);
      expect(await cycleRepo.getAll(), hasLength(1));
    });

    test('reports notFound when no backup exists', () async {
      stubAuth(uid: 'user-1');
      final result = await cloudBackupService.restore();
      expect(result.success, isFalse);
      expect(result.notFound, isTrue);
    });

    test('restores an uncompressed blob via magic-byte sniffing', () async {
      stubAuth(uid: 'user-1');
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-1'));
      final json = await backupService.exportToJson();
      gateway.blobs['user-1'] = Uint8List.fromList(utf8.encode(json));

      await cycleRepo.deleteAll();
      final result = await cloudBackupService.restore();
      expect(result.success, isTrue);
      expect(await cycleRepo.getAll(), hasLength(1));
    });

    test('surfaces unsupported-version errors', () async {
      stubAuth(uid: 'user-1');
      final json = jsonEncode({'version': 5});
      gateway.blobs['user-1'] = Uint8List.fromList(gzip.encode(utf8.encode(json)));

      final result = await cloudBackupService.restore();
      expect(result.success, isFalse);
      expect(result.error, contains('Unsupported'));
    });

    test('returns failure when the gateway throws', () async {
      stubAuth(uid: 'user-1');
      gateway.throwOnDownload = true;
      final result = await cloudBackupService.restore();
      expect(result.success, isFalse);
      expect(result.notFound, isFalse);
    });
  });

  group('fetchMetadata', () {
    test('returns parsed metadata after a backup', () async {
      stubAuth(uid: 'user-1');
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'cycle-1'));
      await cloudBackupService.backupNow();

      final metadata = await cloudBackupService.fetchMetadata();
      expect(metadata, isNotNull);
      expect(metadata!.backupVersion, 4);
      expect(metadata.deviceName, 'Test Device');
      expect(metadata.stats['trainingCycles'], 1);
    });

    test('returns null when never backed up', () async {
      stubAuth(uid: 'user-1');
      expect(await cloudBackupService.fetchMetadata(), isNull);
    });

    test('returns null when not signed in', () async {
      stubAuth(uid: null);
      expect(await cloudBackupService.fetchMetadata(), isNull);
    });
  });

  group('deleteBackup', () {
    test('removes blob and metadata', () async {
      stubAuth(uid: 'user-1');
      await cloudBackupService.backupNow();
      expect(gateway.blobs, isNotEmpty);

      await cloudBackupService.deleteBackup();
      expect(gateway.blobs, isEmpty);
      expect(gateway.metadata, isEmpty);
    });
  });
}
