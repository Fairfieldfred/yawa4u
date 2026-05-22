import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/sports.dart';
import '../models/cardio_session_template.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/session.dart';
import '../models/training_cycle.dart';
import '../models/training_cycle_template.dart';
import '../models/workout.dart';
import '../services/cardio_session_library_service.dart';

/// Repository for managing trainingCycle templates
class TemplateRepository {
  final _uuid = const Uuid();
  static const String _savedTemplatesKey = 'saved_templates';

  SharedPreferences? _prefs;

  /// Initialize the repository with SharedPreferences
  void initialize(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// Load all available templates from assets
  Future<List<TrainingCycleTemplate>> loadTemplates() async {
    final templates = <TrainingCycleTemplate>[];
    List<String> templatePaths = [];

    // Try dynamic discovery using AssetManifest
    try {
      // First try the newer binary manifest format (Flutter 3.x+)
      final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = assetManifest.listAssets();

      templatePaths = allAssets
          .where(
            (String key) => key.startsWith('assets/templates/') && key.endsWith('.json'),
          )
          .toList();

      debugPrint(
        'Found ${templatePaths.length} templates via AssetManifest: $templatePaths',
      );
    } catch (e) {
      debugPrint('Error loading AssetManifest: $e');

      // Fallback: try legacy JSON manifest
      try {
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);

        templatePaths = manifestMap.keys
            .where(
              (String key) => key.startsWith('assets/templates/') && key.endsWith('.json'),
            )
            .toList();
        debugPrint(
          'Found ${templatePaths.length} templates via legacy manifest: $templatePaths',
        );
      } catch (e2) {
        debugPrint('Error loading legacy AssetManifest: $e2');
      }
    }

    // Fallback if dynamic discovery fails or returns empty
    if (templatePaths.isEmpty) {
      debugPrint(
        'Dynamic template loading failed or found no files. Using fallback list.',
      );
      templatePaths = [
        'assets/templates/beginner_full_body.json',
        'assets/templates/upper_lower_split.json',
        'assets/templates/freds_full_body.json',
        'assets/templates/5_day_full_body.json',
        'assets/templates/short_test.json',
      ];
    }

    for (final path in templatePaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        templates.add(
          TrainingCycleTemplate.fromJson(
            json.decode(jsonString) as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        debugPrint('Error loading template from $path: $e');
      }
    }

    return templates;
  }

  /// Load saved (user-created) templates from SharedPreferences
  Future<List<TrainingCycleTemplate>> loadSavedTemplates() async {
    debugPrint('=== loadSavedTemplates called ===');
    try {
      final savedTemplatesJson = _prefs?.getString(_savedTemplatesKey);
      if (savedTemplatesJson == null || savedTemplatesJson.isEmpty) {
        debugPrint('No saved templates found');
        return [];
      }

      final savedTemplatesMap = json.decode(savedTemplatesJson) as Map<String, dynamic>;
      debugPrint(
        'Saved templates map contains ${savedTemplatesMap.length} items',
      );
      final savedTemplates = <TrainingCycleTemplate>[];

      for (final jsonString in savedTemplatesMap.values) {
        try {
          final template = TrainingCycleTemplate.fromJson(
            json.decode(jsonString as String) as Map<String, dynamic>,
          );
          debugPrint('Loaded saved template: ${template.name}');
          savedTemplates.add(template);
        } catch (e) {
          debugPrint('Error parsing saved template: $e');
        }
      }

      debugPrint('Total saved templates loaded: ${savedTemplates.length}');
      return savedTemplates;
    } catch (e) {
      debugPrint('Error loading saved templates: $e');
      return [];
    }
  }

  /// Get all available templates (both built-in and user-saved)
  Future<List<TrainingCycleTemplate>> getAllTemplates() async {
    final builtInTemplates = await loadTemplates();
    final savedTemplates = await loadSavedTemplates();
    return [...builtInTemplates, ...savedTemplates];
  }

  /// Check if a template is a saved (user-created) template
  Future<bool> isSavedTemplate(String templateId) async {
    try {
      final savedTemplatesJson = _prefs?.getString(_savedTemplatesKey);
      if (savedTemplatesJson == null || savedTemplatesJson.isEmpty) {
        return false;
      }
      final savedTemplatesMap = json.decode(savedTemplatesJson) as Map<String, dynamic>;
      return savedTemplatesMap.containsKey(templateId);
    } catch (e) {
      debugPrint('Error checking if template is saved: $e');
      return false;
    }
  }

  /// Delete a saved template
  Future<void> deleteTemplate(String templateId) async {
    try {
      final savedTemplatesJson = _prefs?.getString(_savedTemplatesKey);
      if (savedTemplatesJson == null || savedTemplatesJson.isEmpty) {
        return;
      }
      final savedTemplatesMap = json.decode(savedTemplatesJson) as Map<String, dynamic>;
      savedTemplatesMap.remove(templateId);
      await _prefs?.setString(
        _savedTemplatesKey,
        json.encode(savedTemplatesMap),
      );
    } catch (e) {
      debugPrint('Error deleting template: $e');
      rethrow;
    }
  }

  /// Save a template directly (used for importing shared templates)
  Future<void> saveTemplateDirectly(TrainingCycleTemplate template) async {
    debugPrint('=== saveTemplateDirectly called ===');
    debugPrint('Template name: ${template.name}');

    try {
      // Get existing templates map
      final savedTemplatesJson = _prefs?.getString(_savedTemplatesKey);
      final savedTemplatesMap = savedTemplatesJson != null && savedTemplatesJson.isNotEmpty
          ? json.decode(savedTemplatesJson) as Map<String, dynamic>
          : <String, dynamic>{};

      // Generate a new ID to avoid conflicts
      final newId = _uuid.v4();
      final templateWithNewId = TrainingCycleTemplate(
        id: newId,
        name: template.name,
        description: template.description,
        periodsTotal: template.periodsTotal,
        daysPerPeriod: template.daysPerPeriod,
        recoveryPeriod: template.recoveryPeriod,
        workouts: template.workouts,
      );

      savedTemplatesMap[newId] = json.encode(templateWithNewId.toJson());
      await _prefs?.setString(
        _savedTemplatesKey,
        json.encode(savedTemplatesMap),
      );
      debugPrint('Template saved with ID: $newId');
      debugPrint('Map now contains ${savedTemplatesMap.length} templates');
    } catch (e) {
      debugPrint('Error saving template directly: $e');
      rethrow;
    }
  }

  /// Save a trainingCycle as a template
  /// Returns the ID of the saved template
  Future<String> saveAsTemplate(
    TrainingCycle trainingCycle,
    String name,
    String description,
  ) async {
    debugPrint('=== saveAsTemplate called ===');
    debugPrint('TrainingCycle name: ${trainingCycle.name}');
    debugPrint('Template name: $name');
    debugPrint('Description: $description');
    debugPrint('Workouts count: ${trainingCycle.workouts.length}');

    final template = _convertTrainingCycleToTemplate(
      trainingCycle,
      name,
      description,
    );
    debugPrint(
      'Template created with ${template.workouts.length} workout templates',
    );

    // Get existing templates map
    final savedTemplatesJson = _prefs?.getString(_savedTemplatesKey);
    final savedTemplatesMap = savedTemplatesJson != null && savedTemplatesJson.isNotEmpty
        ? json.decode(savedTemplatesJson) as Map<String, dynamic>
        : <String, dynamic>{};

    final jsonString = json.encode(template.toJson());
    debugPrint('JSON string length: ${jsonString.length}');

    savedTemplatesMap[template.id] = jsonString;
    await _prefs?.setString(_savedTemplatesKey, json.encode(savedTemplatesMap));
    debugPrint('Template saved with ID: ${template.id}');
    debugPrint('Map now contains ${savedTemplatesMap.length} templates');

    return template.id;
  }

  /// Convert a TrainingCycle to a TrainingCycleTemplate
  TrainingCycleTemplate _convertTrainingCycleToTemplate(
    TrainingCycle trainingCycle,
    String name,
    String description,
  ) {
    debugPrint('Converting trainingCycle "${trainingCycle.name}" to template');
    debugPrint(
      'Total workouts in trainingCycle: ${trainingCycle.workouts.length}',
    );

    final workoutTemplates = <WorkoutTemplate>[];
    for (final workout in trainingCycle.workouts) {
      debugPrint(
        'Processing workout: P${workout.periodNumber}D${workout.dayNumber}, '
        '${workout.exercises.length} exercises',
      );
      final exerciseTemplates = workout.exercises.map((exercise) {
        return ExerciseTemplate(
          name: exercise.name,
          muscleGroup: exercise.muscleGroup.name,
          equipmentType: exercise.equipmentType.name,
          sets: exercise.sets.length,
          reps: exercise.sets.isNotEmpty && exercise.sets.first.reps.isNotEmpty ? exercise.sets.first.reps : '8-12',
          setType: exercise.sets.isNotEmpty ? exercise.sets.first.setType.name : 'regular',
          notes: exercise.notes,
        );
      }).toList();

      workoutTemplates.add(
        WorkoutTemplate(
          periodNumber: workout.periodNumber,
          dayNumber: workout.dayNumber,
          dayName: workout.dayName,
          exercises: exerciseTemplates,
        ),
      );
    }

    return TrainingCycleTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      periodsTotal: trainingCycle.periodsTotal,
      daysPerPeriod: trainingCycle.daysPerPeriod,
      recoveryPeriod: trainingCycle.recoveryPeriod,
      workouts: workoutTemplates,
    );
  }

  /// Get a specific template by ID
  Future<TrainingCycleTemplate?> getTemplateById(String id) async {
    final templates = await loadTemplates();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a trainingCycle from a template.
  ///
  /// v6-compatible. Strength workouts turn into [Workout] objects (same
  /// as v5); cardio workouts with a `cardioTemplateId` are resolved
  /// against the cardio session library and returned as a side list of
  /// [CardioSession]s that the caller must write via [SessionRepository].
  ///
  /// Splitting the return lets us keep the legacy [TrainingCycle.workouts]
  /// strength-shaped until Phase 6's main strength-UI migration lands.
  Future<TemplateInstantiation> createTrainingCycleFromTemplate(
    TrainingCycleTemplate template,
  ) async {
    final trainingCycleId = _uuid.v4();
    final now = DateTime.now();
    final workouts = <Workout>[];
    final cardioSessions = <CardioSession>[];

    // Cache the cardio library once per call — if any workout has a
    // cardioTemplateId we'll reuse it.
    List<CardioSessionTemplate>? cardioLibrary;
    Future<List<CardioSessionTemplate>> ensureLibrary() async {
      cardioLibrary ??= await CardioSessionLibraryService.instance.loadAll();
      return cardioLibrary!;
    }

    for (final workoutTemplate in template.workouts) {
      if (workoutTemplate.isCardio && workoutTemplate.cardioTemplateId != null) {
        final sport = Sports.parse(workoutTemplate.sport) ?? Sport.other;
        final library = await ensureLibrary();
        final cardioTemplate = library.where((t) => t.id == workoutTemplate.cardioTemplateId).firstOrNull;
        if (cardioTemplate != null) {
          final session = CardioSessionLibraryService.instance.instantiate(
            cardioTemplate,
            sessionId: _uuid.v4(),
            newIntervalId: () => _uuid.v4(),
            trainingCycleId: trainingCycleId,
            periodNumber: workoutTemplate.periodNumber,
            dayNumber: workoutTemplate.dayNumber,
          );
          // Override sport in case the JSON's explicit sport differs
          // (it shouldn't, but we respect the template's intent).
          cardioSessions.add(
            session.copyWith(
              sport: sport,
              label: workoutTemplate.dayName ?? cardioTemplate.name,
              notes: workoutTemplate.notes ?? cardioTemplate.description,
            ),
          );
        }
        // Fall through — a cardio day produces zero Workouts.
        continue;
      }

      // Cardio day without a cardioTemplateId — create a bare-bones
      // CardioSession with just the name and notes from the template.
      if (workoutTemplate.isCardio) {
        final sport = Sports.parse(workoutTemplate.sport) ?? Sport.other;
        cardioSessions.add(
          CardioSession(
            id: _uuid.v4(),
            trainingCycleId: trainingCycleId,
            sport: sport,
            source: SessionSource.userPlanned,
            status: WorkoutStatus.incomplete,
            periodNumber: workoutTemplate.periodNumber,
            dayNumber: workoutTemplate.dayNumber,
            dayName: workoutTemplate.dayName,
            label: workoutTemplate.dayName,
            notes: workoutTemplate.notes,
            intervals: const [],
          ),
        );
        continue;
      }

      // Strength path (existing logic).
      final exercisesByMuscleGroup = <MuscleGroup, List<Exercise>>{};

      for (final exerciseTemplate in workoutTemplate.exercises) {
        final exerciseId = _uuid.v4();

        final muscleGroup = MuscleGroup.values.firstWhere(
          (mg) => mg.name.toLowerCase() == exerciseTemplate.muscleGroup.toLowerCase(),
          orElse: () => MuscleGroup.chest,
        );

        final equipmentType = EquipmentType.values.firstWhere(
          (et) => et.name.toLowerCase() == exerciseTemplate.equipmentType.toLowerCase(),
          orElse: () => EquipmentType.barbell,
        );

        final setType = SetType.values.firstWhere(
          (st) => st.name.toLowerCase() == exerciseTemplate.setType.toLowerCase(),
          orElse: () => SetType.regular,
        );

        final sets = <ExerciseSet>[];
        for (int i = 0; i < exerciseTemplate.sets; i++) {
          sets.add(
            ExerciseSet(
              id: _uuid.v4(),
              setNumber: i + 1,
              reps: '',
              setType: setType,
            ),
          );
        }

        final exercise = Exercise(
          id: exerciseId,
          workoutId: '',
          name: exerciseTemplate.name,
          muscleGroup: muscleGroup,
          equipmentType: equipmentType,
          sets: sets,
          notes: exerciseTemplate.notes,
        );

        if (!exercisesByMuscleGroup.containsKey(muscleGroup)) {
          exercisesByMuscleGroup[muscleGroup] = [];
        }
        exercisesByMuscleGroup[muscleGroup]!.add(exercise);
      }

      for (final entry in exercisesByMuscleGroup.entries) {
        final muscleGroup = entry.key;
        final groupExercises = entry.value;
        final workoutId = _uuid.v4();

        final updatedExercises = groupExercises.map((e) => e.copyWith(workoutId: workoutId)).toList();

        workouts.add(
          Workout(
            id: workoutId,
            trainingCycleId: trainingCycleId,
            periodNumber: workoutTemplate.periodNumber,
            dayNumber: workoutTemplate.dayNumber,
            label: muscleGroup.displayName,
            exercises: updatedExercises,
          ),
        );
      }
    }

    final primarySport = template.primarySport != null ? Sports.parse(template.primarySport!) : null;

    final cycle = TrainingCycle(
      id: trainingCycleId,
      name: template.name,
      startDate: now,
      periodsTotal: template.periodsTotal,
      daysPerPeriod: template.daysPerPeriod,
      recoveryPeriod: template.recoveryPeriod,
      workouts: workouts,
      primarySport: primarySport,
    );

    return TemplateInstantiation(
      trainingCycle: cycle,
      cardioSessions: cardioSessions,
    );
  }
}

/// Bundle returned by [TemplateRepository.createTrainingCycleFromTemplate].
///
/// The caller is responsible for writing the strength cycle via
/// [TrainingCycleRepository.create] AND writing each cardio session via
/// [SessionRepository.createCardio]. Splitting the two keeps the
/// repositories cleanly separated — template creation doesn't reach
/// across into SessionRepository directly.
class TemplateInstantiation {
  final TrainingCycle trainingCycle;
  final List<CardioSession> cardioSessions;

  const TemplateInstantiation({
    required this.trainingCycle,
    required this.cardioSessions,
  });
}
