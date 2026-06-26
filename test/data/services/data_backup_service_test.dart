import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/core/theme/skins/skin_repository.dart';
import 'package:yawa4u/data/models/session.dart';
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

  group('Export - exercises', () {
    test('exports exercises with their sets', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'cycle-ex');
      await cycleRepo.create(cycle);

      final workout = TestFixtures.createWorkout(
        id: 'w-ex',
        trainingCycleId: 'cycle-ex',
        exercises: [
          TestFixtures.createExercise(
            id: 'e-1',
            workoutId: 'w-ex',
            name: 'Bench Press',
            sets: [
              TestFixtures.createExerciseSet(
                id: 'set-1',
                setNumber: 1,
                weight: 100,
                reps: '8',
              ),
              TestFixtures.createExerciseSet(
                id: 'set-2',
                setNumber: 2,
                weight: 105,
                reps: '6',
              ),
            ],
          ),
        ],
      );
      await workoutRepo.create(workout);

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['workouts'], hasLength(1));
      expect(data['exercises'], hasLength(1));

      final exerciseData = data['exercises'][0] as Map<String, dynamic>;
      expect(exerciseData['name'], 'Bench Press');
      final sets = exerciseData['sets'] as List;
      expect(sets, hasLength(2));
    });

    test('exports custom exercise definitions', () async {
      await customExerciseRepo.add(
        TestFixtures.createCustomExerciseDefinition(
          id: 'ce-1',
          name: 'Custom Pull',
        ),
      );

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['customExercises'], hasLength(1));
      final ce = data['customExercises'][0] as Map<String, dynamic>;
      expect(ce['name'], 'Custom Pull');
    });
  });

  group('Export - multi-sport', () {
    test('exports cycle periods with phase', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'cycle-cp');
      await cycleRepo.create(cycle);

      await cyclePeriodRepo.create(
        TestFixtures.createCyclePeriod(
          id: 'cp-1',
          trainingCycleId: 'cycle-cp',
          periodNumber: 1,
          phase: TrainingPhase.base,
        ),
      );

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['cyclePeriods'], hasLength(1));
    });

    test('exports cardio feedback linked to session', () async {
      final session = TestFixtures.createCardioSession(
        id: 'cs-fb',
        sport: Sport.run,
      );
      await sessionRepo.createCardio(session);

      await cardioFeedbackRepo.save(
        'cs-fb',
        TestFixtures.createCardioFeedback(rpe: 7, breathing: 4),
      );

      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['cardioFeedbacks'], hasLength(1));
      final fb = data['cardioFeedbacks'][0] as Map<String, dynamic>;
      expect(fb['sessionId'], 'cs-fb');
      expect(fb['rpe'], 7);
    });
  });

  group('Import - exercises', () {
    test('workout import brings in exercises with sets', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'imp-cycle');

      final workout = TestFixtures.createWorkout(
        id: 'imp-w',
        trainingCycleId: 'imp-cycle',
        exercises: [
          TestFixtures.createExercise(
            id: 'imp-e',
            workoutId: 'imp-w',
            sets: [
              TestFixtures.createExerciseSet(id: 'imp-s1', weight: 80),
            ],
          ),
        ],
      );

      // Only include exercises in the workouts array — not in the
      // standalone exercises array — to avoid duplicate-key errors.
      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [cycle.toJson()],
        'workouts': [workout.toJson()],
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
      expect(result.workoutsImported, equals(1));

      // Verify exercises were created as part of the workout
      final loaded = await workoutRepo.getById('imp-w');
      expect(loaded, isNotNull);
      expect(loaded!.exercises, hasLength(1));
      expect(loaded.exercises.first.sets, hasLength(1));
      expect(loaded.exercises.first.sets.first.weight, 80);
    });

    test('append import of real export shape does not double-insert exercises', () async {
      // Reproduces the WiFi-sync crash: the real exportToJson embeds each
      // exercise inside its workout AND lists it again top-level. The workout
      // import writes the embedded copy, so a blind insert of the top-level
      // copy used to throw UNIQUE(exercises.uuid) (SqliteException 2067) and
      // abort the import — only "succeeding" on a second attempt.
      final cycle = TestFixtures.createTrainingCycle(id: 'dup-cycle');
      final exercise = TestFixtures.createExercise(
        id: 'dup-e',
        workoutId: 'dup-w',
        sets: [TestFixtures.createExerciseSet(id: 'dup-s1', weight: 100)],
      );
      final workout = TestFixtures.createWorkout(
        id: 'dup-w',
        trainingCycleId: 'dup-cycle',
        exercises: [exercise],
      );

      // Exercise appears in BOTH arrays, exactly like exportToJson emits.
      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [cycle.toJson()],
        'workouts': [workout.toJson()],
        'exercises': [exercise.toJson()],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        replace: false,
        importThemes: false,
      );

      expect(result.success, isTrue);
      // Exactly one exercise, written once via the workout — not duplicated.
      final loaded = await workoutRepo.getById('dup-w');
      expect(loaded, isNotNull);
      expect(loaded!.exercises, hasLength(1));
      expect(loaded.exercises.first.sets, hasLength(1));
    });

    test('imports custom exercise definitions', () async {
      final ce = TestFixtures.createCustomExerciseDefinition(
        id: 'imp-ce',
        name: 'Imported Custom',
      );

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [ce.toJson()],
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
      expect(result.customExercisesImported, equals(1));

      final loaded = await customExerciseRepo.getById('imp-ce');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Imported Custom');
    });
  });

  group('Import - multi-sport', () {
    test('imports cycle periods', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'cp-cycle');
      await cycleRepo.create(cycle);

      final period = TestFixtures.createCyclePeriod(
        id: 'cp-imp',
        trainingCycleId: 'cp-cycle',
        periodNumber: 1,
        phase: TrainingPhase.build,
      );

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [period.toJson()],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.cyclePeriodsImported, equals(1));
    });

    test('imports cardio feedback', () async {
      final session = TestFixtures.createCardioSession(
        id: 'cs-imp-fb',
        sport: Sport.bike,
      );
      await sessionRepo.createCardio(session);

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [
          {
            'sessionId': 'cs-imp-fb',
            'rpe': 8,
            'breathing': 3,
          },
        ],
      });

      final result = await backupService.importFromJson(
        exportJson,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.cardioFeedbacksImported, equals(1));

      final loaded = await cardioFeedbackRepo.getForSession('cs-imp-fb');
      expect(loaded, isNotNull);
      expect(loaded!.rpe, 8);
    });

    test('imports sport zones with replace semantics', () async {
      // Seed an existing zone
      await sportZoneRepo.create(
        TestFixtures.createSportZone(
          id: 'old-z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 120,
        ),
      );

      final newZone = TestFixtures.createSportZone(
        id: 'new-z1',
        sport: Sport.run,
        zoneNumber: 1,
        minValue: 110,
        maxValue: 130,
      );

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [newZone.toJson()],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.sportZonesImported, equals(1));
    });

    test('append import skips an already-present sport zone by id', () async {
      // WiFi sync uses replace: false. Re-importing a backup that contains a
      // zone the device already has must not throw on the UNIQUE(uuid)
      // constraint — it should be skipped, like every other table.
      final existing = TestFixtures.createSportZone(
        id: 'z-dup',
        sport: Sport.bike,
        zoneNumber: 1,
        minValue: 100,
        maxValue: 150,
      );
      await sportZoneRepo.create(existing);

      final exportJson = jsonEncode({
        'version': 4,
        'trainingCycles': [],
        'workouts': [],
        'exercises': [],
        'customExercises': [],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [existing.toJson()],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        exportJson,
        replace: false,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.sportZonesImported, equals(0));
      // Still exactly one zone for the sport — no duplicate, no crash.
      final zones = await sportZoneRepo.getBySport(Sport.bike);
      expect(zones, hasLength(1));
    });

    test('cardio session with detail round-trips', () async {
      final session = TestFixtures.createCardioSession(
        id: 'cs-rt',
        sport: Sport.swim,
        detail: TestFixtures.createCardioDetail(
          actualDistanceM: 2000,
          actualDurationSec: 2400,
          poolLengthM: 25,
          strokeType: StrokeType.freestyle,
        ),
        intervals: [
          TestFixtures.createSessionInterval(
            id: 'int-1',
            sessionId: 'cs-rt',
            orderIndex: 0,
            intent: IntervalIntent.warmup,
            targetDurationSec: 300,
          ),
        ],
      );
      await sessionRepo.createCardio(session);

      // Export
      final json = await backupService.exportToJson(includeThemes: false);
      final data = jsonDecode(json) as Map<String, dynamic>;
      expect(data['cardioSessions'], hasLength(1));

      // Wipe and re-import
      await sessionRepo.delete('cs-rt');

      final result = await backupService.importFromJson(
        json,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.cardioSessionsImported, equals(1));

      // Verify restored
      final loaded = await sessionRepo.getById('cs-rt');
      expect(loaded, isNotNull);
      expect(loaded, isA<CardioSession>());
      final cardio = loaded as CardioSession;
      expect(cardio.detail?.actualDistanceM, 2000);
    });
  });

  group('Import - error handling', () {
    test('corrupted JSON returns error result', () async {
      final result = await backupService.importFromJson(
        'not valid json {{{',
        importThemes: false,
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Failed to parse backup'));
    });

    test('missing lists default to empty', () async {
      // Minimal valid v4 with no list keys
      final minimalJson = jsonEncode({
        'version': 4,
      });

      final result = await backupService.importFromJson(
        minimalJson,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.totalImported, equals(0));
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

    test('full strength chain round-trips via manual JSON', () async {
      // Build import JSON manually to avoid the duplicate-exercise issue
      // that occurs when exportToJson writes exercises in both the
      // "workouts" and "exercises" arrays.
      final cycle = TestFixtures.createTrainingCycle(id: 'rt-str');
      final workout = TestFixtures.createWorkout(
        id: 'rt-w',
        trainingCycleId: 'rt-str',
        exercises: [
          TestFixtures.createExercise(
            id: 'rt-e',
            workoutId: 'rt-w',
            sets: [
              TestFixtures.createExerciseSet(
                id: 'rt-s',
                weight: 100,
                reps: '10',
              ),
            ],
          ),
        ],
      );
      final ce = TestFixtures.createCustomExerciseDefinition(
        id: 'rt-ce2',
        name: 'RT Custom',
      );

      final importJson = jsonEncode({
        'version': 4,
        'trainingCycles': [cycle.toJson()],
        'workouts': [workout.toJson()],
        'exercises': [], // exercises come via workouts
        'customExercises': [ce.toJson()],
        'cardioSessions': [],
        'cyclePeriods': [],
        'sportZones': [],
        'cardioFeedbacks': [],
      });

      final result = await backupService.importFromJson(
        importJson,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(1));
      expect(result.workoutsImported, equals(1));
      expect(result.customExercisesImported, equals(1));

      // Verify data integrity
      final loadedCycle = await cycleRepo.getById('rt-str');
      expect(loadedCycle, isNotNull);

      final loadedWorkout = await workoutRepo.getById('rt-w');
      expect(loadedWorkout, isNotNull);
      expect(loadedWorkout!.exercises, hasLength(1));
      expect(loadedWorkout.exercises.first.sets.first.weight, 100);

      final loadedCe = await customExerciseRepo.getById('rt-ce2');
      expect(loadedCe, isNotNull);
      expect(loadedCe!.name, 'RT Custom');
    });

    test('full multi-sport chain round-trips', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'rt-ms');
      await cycleRepo.create(cycle);

      await cyclePeriodRepo.create(
        TestFixtures.createCyclePeriod(
          id: 'rt-cp',
          trainingCycleId: 'rt-ms',
          periodNumber: 1,
          phase: TrainingPhase.peak,
        ),
      );

      final cardio = TestFixtures.createCardioSession(
        id: 'rt-cs',
        trainingCycleId: 'rt-ms',
        sport: Sport.bike,
        detail: TestFixtures.createCardioDetail(actualDistanceM: 40000),
      );
      await sessionRepo.createCardio(cardio);

      await cardioFeedbackRepo.save(
        'rt-cs',
        TestFixtures.createCardioFeedback(rpe: 6),
      );

      await sportZoneRepo.create(
        TestFixtures.createSportZone(
          id: 'rt-z',
          sport: Sport.bike,
          zoneNumber: 2,
          minValue: 130,
          maxValue: 155,
        ),
      );

      // Export
      final json = await backupService.exportToJson(includeThemes: false);

      // Wipe
      await cycleRepo.deleteAll();
      await sessionRepo.delete('rt-cs');

      // Re-import
      final result = await backupService.importFromJson(
        json,
        replace: true,
        importThemes: false,
      );

      expect(result.success, isTrue);
      expect(result.trainingCyclesImported, equals(1));
      expect(result.cardioSessionsImported, equals(1));
      expect(result.cyclePeriodsImported, equals(1));
      expect(result.cardioFeedbacksImported, equals(1));
      expect(result.sportZonesImported, equals(1));
    });
  });
}
