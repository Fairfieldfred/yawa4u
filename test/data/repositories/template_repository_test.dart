import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/training_cycle_template.dart';
import 'package:yawa4u/data/repositories/template_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TemplateRepository repo;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = TemplateRepository();
    repo.initialize(prefs);
  });

  // ── Helper to build a simple template ──────────────────────────────
  TrainingCycleTemplate makeTemplate({
    String id = 'tpl-1',
    String name = 'Test Template',
    String description = 'A test template',
    int periodsTotal = 4,
    int daysPerPeriod = 3,
    int? recoveryPeriod,
    List<WorkoutTemplate>? workouts,
  }) {
    return TrainingCycleTemplate(
      id: id,
      name: name,
      description: description,
      periodsTotal: periodsTotal,
      daysPerPeriod: daysPerPeriod,
      recoveryPeriod: recoveryPeriod,
      workouts: workouts ?? [],
    );
  }

  // ── saveAsTemplate ─────────────────────────────────────────────────
  group('saveAsTemplate', () {
    test('converts trainingCycle to template and persists it', () async {
      final cycle = TestFixtures.createTrainingCycle(
        name: 'My Cycle',
        periodsTotal: 4,
        daysPerPeriod: 3,
        recoveryPeriod: 1,
      );

      final templateId = await repo.saveAsTemplate(
        cycle,
        'Saved Template',
        'Description here',
      );

      expect(templateId, isNotEmpty);

      final saved = await repo.loadSavedTemplates();
      expect(saved, hasLength(1));
      expect(saved.first.name, 'Saved Template');
      expect(saved.first.description, 'Description here');
      expect(saved.first.periodsTotal, 4);
      expect(saved.first.daysPerPeriod, 3);
      expect(saved.first.recoveryPeriod, 1);
    });

    test('preserves exercise structure in workout templates', () async {
      final exercise = TestFixtures.createExercise(
        name: 'Squat',
        muscleGroup: MuscleGroup.quads,
        equipmentType: EquipmentType.barbell,
        sets: [
          TestFixtures.createExerciseSet(reps: '5', setType: SetType.regular),
          TestFixtures.createExerciseSet(reps: '5', setType: SetType.regular),
          TestFixtures.createExerciseSet(reps: '5', setType: SetType.regular),
        ],
        notes: 'ATG depth',
      );

      final workout = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        exercises: [exercise],
      );

      final cycle = TestFixtures.createTrainingCycle(
        workouts: [workout],
      );

      await repo.saveAsTemplate(cycle, 'Strength', 'desc');

      final saved = await repo.loadSavedTemplates();
      final wt = saved.first.workouts.first;
      final et = wt.exercises.first;

      expect(et.name, 'Squat');
      expect(et.muscleGroup, 'quads');
      expect(et.equipmentType, 'barbell');
      expect(et.sets, 3);
      expect(et.reps, '5');
      expect(et.setType, 'regular');
      expect(et.notes, 'ATG depth');
    });

    test('preserves period and day metadata', () async {
      final w1 = TestFixtures.createWorkout(
        periodNumber: 2,
        dayNumber: 3,
        dayName: 'Pull Day',
      );
      final cycle = TestFixtures.createTrainingCycle(workouts: [w1]);

      await repo.saveAsTemplate(cycle, 'Meta', 'desc');

      final saved = await repo.loadSavedTemplates();
      final wt = saved.first.workouts.first;
      expect(wt.periodNumber, 2);
      expect(wt.dayNumber, 3);
    });

    test('uses fallback reps when exercise sets are empty', () async {
      final exercise = TestFixtures.createExercise(sets: []);
      final workout = TestFixtures.createWorkout(exercises: [exercise]);
      final cycle = TestFixtures.createTrainingCycle(workouts: [workout]);

      await repo.saveAsTemplate(cycle, 'Fallback', 'desc');

      final saved = await repo.loadSavedTemplates();
      final et = saved.first.workouts.first.exercises.first;
      expect(et.reps, '8-12');
      expect(et.setType, 'regular');
    });
  });

  // ── loadSavedTemplates ─────────────────────────────────────────────
  group('loadSavedTemplates', () {
    test('returns empty list when no templates saved', () async {
      final result = await repo.loadSavedTemplates();
      expect(result, isEmpty);
    });

    test('returns empty list when prefs key has empty string', () async {
      await prefs.setString('saved_templates', '');
      final result = await repo.loadSavedTemplates();
      expect(result, isEmpty);
    });

    test('loads multiple saved templates', () async {
      final t1 = makeTemplate(id: 'a', name: 'First');
      final t2 = makeTemplate(id: 'b', name: 'Second');

      await repo.saveTemplateDirectly(t1);
      await repo.saveTemplateDirectly(t2);

      final result = await repo.loadSavedTemplates();
      expect(result, hasLength(2));
      final names = result.map((t) => t.name).toSet();
      expect(names, containsAll(['First', 'Second']));
    });
  });

  // ── saveTemplateDirectly ───────────────────────────────────────────
  group('saveTemplateDirectly', () {
    test('generates a new UUID to avoid conflicts', () async {
      final template = makeTemplate(id: 'original-id');
      await repo.saveTemplateDirectly(template);

      final saved = await repo.loadSavedTemplates();
      expect(saved, hasLength(1));
      // The saved template should have a new ID, not the original
      expect(saved.first.id, isNot('original-id'));
    });

    test('appends to existing templates', () async {
      await repo.saveTemplateDirectly(
        makeTemplate(name: 'First'),
      );
      await repo.saveTemplateDirectly(
        makeTemplate(name: 'Second'),
      );

      final saved = await repo.loadSavedTemplates();
      expect(saved, hasLength(2));
    });
  });

  // ── deleteTemplate ─────────────────────────────────────────────────
  group('deleteTemplate', () {
    test('removes template by ID', () async {
      // Use saveAsTemplate to get the actual persisted ID
      final cycle = TestFixtures.createTrainingCycle();
      final templateId = await repo.saveAsTemplate(cycle, 'ToDelete', 'desc');

      var saved = await repo.loadSavedTemplates();
      expect(saved, hasLength(1));

      await repo.deleteTemplate(templateId);

      saved = await repo.loadSavedTemplates();
      expect(saved, isEmpty);
    });

    test('no-op when template ID does not exist', () async {
      final cycle = TestFixtures.createTrainingCycle();
      await repo.saveAsTemplate(cycle, 'Keep', 'desc');

      await repo.deleteTemplate('nonexistent-id');

      final saved = await repo.loadSavedTemplates();
      expect(saved, hasLength(1));
      expect(saved.first.name, 'Keep');
    });
  });

  // ── isSavedTemplate ────────────────────────────────────────────────
  group('isSavedTemplate', () {
    test('returns true for existing template', () async {
      final cycle = TestFixtures.createTrainingCycle();
      final templateId = await repo.saveAsTemplate(cycle, 'Exists', 'desc');

      final result = await repo.isSavedTemplate(templateId);
      expect(result, isTrue);
    });

    test('returns false for missing template', () async {
      final result = await repo.isSavedTemplate('does-not-exist');
      expect(result, isFalse);
    });
  });

  // ── createTrainingCycleFromTemplate (strength) ─────────────────────
  group('createTrainingCycleFromTemplate - strength', () {
    test('creates cycle with correct metadata', () async {
      final template = makeTemplate(
        name: 'Push Pull Legs',
        periodsTotal: 6,
        daysPerPeriod: 4,
        recoveryPeriod: 1,
      );

      final result = await repo.createTrainingCycleFromTemplate(template);
      final cycle = result.trainingCycle;

      expect(cycle.name, 'Push Pull Legs');
      expect(cycle.periodsTotal, 6);
      expect(cycle.daysPerPeriod, 4);
      expect(cycle.recoveryPeriod, 1);
      expect(cycle.id, isNotEmpty);
      expect(cycle.startDate, isNotNull);
      expect(result.cardioSessions, isEmpty);
    });

    test('splits exercises into workouts by muscle group', () async {
      final template = TrainingCycleTemplate(
        id: 'split-test',
        name: 'Split',
        description: 'desc',
        periodsTotal: 1,
        daysPerPeriod: 1,
        workouts: [
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 1,
            exercises: [
              ExerciseTemplate(
                name: 'Bench Press',
                muscleGroup: 'chest',
                equipmentType: 'barbell',
                sets: 3,
                reps: '8',
              ),
              ExerciseTemplate(
                name: 'Incline Press',
                muscleGroup: 'chest',
                equipmentType: 'dumbbell',
                sets: 3,
                reps: '10',
              ),
              ExerciseTemplate(
                name: 'Barbell Row',
                muscleGroup: 'back',
                equipmentType: 'barbell',
                sets: 3,
                reps: '8',
              ),
            ],
          ),
        ],
      );

      final result = await repo.createTrainingCycleFromTemplate(template);
      final workouts = result.trainingCycle.workouts;

      // Two muscle groups → two Workout objects
      expect(workouts, hasLength(2));

      final labels = workouts.map((w) => w.label).toSet();
      expect(labels, contains(MuscleGroup.chest.displayName));
      expect(labels, contains(MuscleGroup.back.displayName));

      final chestWorkout = workouts.firstWhere(
        (w) => w.label == MuscleGroup.chest.displayName,
      );
      expect(chestWorkout.exercises, hasLength(2));
      expect(chestWorkout.exercises[0].name, 'Bench Press');
      expect(chestWorkout.exercises[1].name, 'Incline Press');
    });

    test('preserves setType from template', () async {
      final template = TrainingCycleTemplate(
        id: 'settype-test',
        name: 'SetType',
        description: 'desc',
        periodsTotal: 1,
        daysPerPeriod: 1,
        workouts: [
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 1,
            exercises: [
              ExerciseTemplate(
                name: 'Leg Press',
                muscleGroup: 'quads',
                equipmentType: 'machine',
                sets: 2,
                reps: '12',
                setType: 'myorep',
              ),
            ],
          ),
        ],
      );

      final result = await repo.createTrainingCycleFromTemplate(template);
      final exercises = result.trainingCycle.workouts.first.exercises;

      expect(exercises.first.sets, hasLength(2));
      expect(exercises.first.sets[0].setType, SetType.myorep);
      expect(exercises.first.sets[1].setType, SetType.myorep);
    });
  });

  // ── createTrainingCycleFromTemplate (cardio) ───────────────────────
  group('createTrainingCycleFromTemplate - cardio', () {
    test('creates bare-bones CardioSession for cardio day without '
        'cardioTemplateId', () async {
      final template = TrainingCycleTemplate(
        id: 'cardio-bare',
        name: 'Hybrid Block',
        description: 'desc',
        periodsTotal: 1,
        daysPerPeriod: 2,
        workouts: [
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 1,
            sport: 'run',
            dayName: 'Easy Run',
            notes: 'Zone 2 effort',
          ),
        ],
      );

      final result = await repo.createTrainingCycleFromTemplate(template);

      // No strength workouts
      expect(result.trainingCycle.workouts, isEmpty);

      // One cardio session
      expect(result.cardioSessions, hasLength(1));
      final session = result.cardioSessions.first;
      expect(session.sport.name, 'run');
      expect(session.dayName, 'Easy Run');
      expect(session.label, 'Easy Run');
      expect(session.notes, 'Zone 2 effort');
      expect(session.periodNumber, 1);
      expect(session.dayNumber, 1);
    });

    test('mixed strength + cardio template produces both', () async {
      final template = TrainingCycleTemplate(
        id: 'mixed-test',
        name: 'Mixed Block',
        description: 'desc',
        periodsTotal: 1,
        daysPerPeriod: 3,
        workouts: [
          // Day 1: Strength
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 1,
            exercises: [
              ExerciseTemplate(
                name: 'Squat',
                muscleGroup: 'quads',
                equipmentType: 'barbell',
                sets: 3,
                reps: '5',
              ),
            ],
          ),
          // Day 2: Cardio (bare-bones)
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 2,
            sport: 'bike',
            dayName: 'Recovery Ride',
          ),
          // Day 3: Another strength
          WorkoutTemplate(
            periodNumber: 1,
            dayNumber: 3,
            exercises: [
              ExerciseTemplate(
                name: 'Deadlift',
                muscleGroup: 'back',
                equipmentType: 'barbell',
                sets: 3,
                reps: '5',
              ),
            ],
          ),
        ],
      );

      final result = await repo.createTrainingCycleFromTemplate(template);

      // Two strength workouts (one per muscle group, both are unique)
      expect(result.trainingCycle.workouts, hasLength(2));

      // One cardio session
      expect(result.cardioSessions, hasLength(1));
      expect(result.cardioSessions.first.sport.name, 'bike');
      expect(result.cardioSessions.first.dayName, 'Recovery Ride');
    });
  });
}
