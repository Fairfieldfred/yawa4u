import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/sports.dart';
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
import 'package:yawa4u/data/services/data_backup_service.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late DataBackupService backupService;
  late TrainingCycleRepository cycleRepo;
  late SessionRepository sessionRepo;
  late WorkoutRepository workoutRepo;
  late ExerciseRepository exerciseRepo;
  late CustomExerciseRepository customExerciseRepo;
  late CyclePeriodRepository cyclePeriodRepo;
  late SportZoneRepository sportZoneRepo;
  late CardioFeedbackRepository cardioFeedbackRepo;

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());

    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
    sessionRepo = SessionRepository(
      db.sessionDao,
      db.exerciseDao,
      db.exerciseSetDao,
      db.sessionCardioDao,
      db.sessionIntervalDao,
      db.sessionSampleDao,
      db.cardioFeedbackDao,
    );
    workoutRepo = WorkoutRepository(sessionRepo, db.exerciseDao);
    exerciseRepo = ExerciseRepository(db.exerciseDao, db.exerciseSetDao);
    customExerciseRepo = CustomExerciseRepository(db.customExerciseDao);
    cyclePeriodRepo = CyclePeriodRepository(db.cyclePeriodDao);
    sportZoneRepo = SportZoneRepository(db.sportZoneDao);
    cardioFeedbackRepo = CardioFeedbackRepository(db.cardioFeedbackDao);

    SharedPreferences.setMockInitialValues({});
    final skinRepo = SkinRepository();
    final prefs = await SharedPreferences.getInstance();
    await skinRepo.initialize(prefs);

    backupService = DataBackupService(
      trainingCycleRepository: cycleRepo,
      workoutRepository: workoutRepo,
      exerciseRepository: exerciseRepo,
      customExerciseRepository: customExerciseRepo,
      sessionRepository: sessionRepo,
      cyclePeriodRepository: cyclePeriodRepo,
      sportZoneRepository: sportZoneRepo,
      cardioFeedbackRepository: cardioFeedbackRepo,
      skinRepository: skinRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Export', () {
    test('exportToJson produces valid JSON with version 4', () async {
      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['version'], equals(4));
      expect(data['exportedAt'], isNotNull);
      expect(data['trainingCycles'], isA<List>());
      expect(data['workouts'], isA<List>());
      expect(data['exercises'], isA<List>());
      expect(data['customExercises'], isA<List>());
      expect(data['cardioSessions'], isA<List>());
      expect(data['cyclePeriods'], isA<List>());
      expect(data['sportZones'], isA<List>());
      expect(data['cardioFeedbacks'], isA<List>());
    });

    test('export includes training cycles and workouts', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'cycle-1');
      await cycleRepo.create(cycle);

      final workout = TestFixtures.createWorkout(
        id: 'w-1',
        trainingCycleId: 'cycle-1',
      );
      await workoutRepo.create(workout);

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['trainingCycles'], hasLength(1));
      expect(data['workouts'], hasLength(1));
    });

    test('export includes cardio sessions', () async {
      final session = TestFixtures.createCardioSession(
        id: 'cs-1',
        sport: Sport.run,
        detail: TestFixtures.createCardioDetail(actualDistanceM: 5000.0),
      );
      await sessionRepo.createCardio(session);

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['cardioSessions'], hasLength(1));
    });

    test('export includes sport zones', () async {
      await sportZoneRepo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
        ),
      );

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['sportZones'], hasLength(1));
    });
  });

  group('Import', () {
    test('import rejects future version', () async {
      final futureJson = jsonEncode({'version': 99});
      final result = await backupService.importFromJson(
        futureJson,
        importThemes: false,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Unsupported backup version'));
    });

    test('import rejects null version', () async {
      final noVersionJson = jsonEncode({'trainingCycles': []});
      final result = await backupService.importFromJson(
        noVersionJson,
        importThemes: false,
      );

      expect(result.success, isFalse);
    });

    test('import accepts v3 JSON with no cardio content', () async {
      final v3Json = jsonEncode({
        'version': 3,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
      });

      final result = await backupService.importFromJson(
        v3Json,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.cardioSessionsImported, equals(0));
    });

    test('import creates training cycles', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'cycle-imp');
      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [cycle.toJson()],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(1));

      final loaded = await cycleRepo.getById('cycle-imp');
      expect(loaded, isNotNull);
    });

    test('import skips duplicates when replace=false', () async {
      // Create existing data
      await cycleRepo.create(
        TestFixtures.createTrainingCycle(id: 'cycle-dup'),
      );

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [
          TestFixtures.createTrainingCycle(id: 'cycle-dup').toJson(),
        ],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(0));
    });

    test('import with replace=true clears existing data', () async {
      // Create existing data
      await cycleRepo.create(
        TestFixtures.createTrainingCycle(id: 'old-cycle'),
      );

      final newCycle = TestFixtures.createTrainingCycle(
        id: 'new-cycle',
        name: 'Replaced',
      );
      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [newCycle.toJson()],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(1));

      // Old data should be gone
      final old = await cycleRepo.getById('old-cycle');
      expect(old, isNull);

      // New data should exist
      final loaded = await cycleRepo.getById('new-cycle');
      expect(loaded, isNotNull);
    });
  });

  group('Stats', () {
    test('getStats returns correct counts', () async {
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'c1'));
      await cycleRepo.create(TestFixtures.createTrainingCycle(id: 'c2'));

      final workout = TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: 'c1',
      );
      await workoutRepo.create(workout);

      await customExerciseRepo.add(
        TestFixtures.createCustomExerciseDefinition(id: 'ce1'),
      );

      final stats = await backupService.getStats();
      expect(stats.trainingCycleCount, equals(2));
      expect(stats.workoutCount, equals(1));
      expect(stats.customExerciseCount, equals(1));
      expect(stats.total, greaterThan(0));
    });

    test('getStats counts cardio sessions', () async {
      await sessionRepo.createCardio(
        TestFixtures.createCardioSession(id: 'cs1', sport: Sport.run),
      );

      final stats = await backupService.getStats();
      expect(stats.cardioSessionCount, equals(1));
    });
  });

  group('Round-trip', () {
    test('export then import on fresh DB produces equivalent data', () async {
      // Populate with data
      await cycleRepo.create(
        TestFixtures.createTrainingCycle(id: 'rt-cycle'),
      );
      await customExerciseRepo.add(
        TestFixtures.createCustomExerciseDefinition(id: 'rt-ce'),
      );

      // Export
      final json = await backupService.exportToJson(includeThemes: false);

      // Wipe
      await cycleRepo.deleteAll();
      await customExerciseRepo.deleteAll();

      // Re-import
      final result = await backupService.importFromJson(
        json,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(1));
      expect(result.customExercisesImported, equals(1));

      // Verify data restored
      final cycle = await cycleRepo.getById('rt-cycle');
      expect(cycle, isNotNull);

      final ce = await customExerciseRepo.getById('rt-ce');
      expect(ce, isNotNull);
    });
  });
}
