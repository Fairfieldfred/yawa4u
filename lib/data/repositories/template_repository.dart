import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/mesocycle.dart';
import '../models/mesocycle_template.dart';
import '../models/workout.dart';

/// Repository for managing mesocycle templates
class TemplateRepository {
  final _uuid = const Uuid();
  static const String _savedTemplatesBoxName = 'saved_templates';

  /// Load all available templates from assets
  Future<List<MesocycleTemplate>> loadTemplates() async {
    final templates = <MesocycleTemplate>[];
    List<String> templatePaths = [];

    // Try dynamic discovery first
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      templatePaths = manifestMap.keys
          .where(
            (String key) =>
                key.startsWith('assets/templates/') && key.endsWith('.json'),
          )
          .toList();
    } catch (e) {
      print('Error loading AssetManifest: $e');
    }

    // Fallback if dynamic discovery fails or returns empty
    if (templatePaths.isEmpty) {
      print(
        'Dynamic template loading failed or found no files. Using fallback list.',
      );
      templatePaths = [
        'assets/templates/beginner_full_body.json',
        'assets/templates/upper_lower_split.json',
        'assets/templates/freds_full_body.json',
      ];
    }

    for (final path in templatePaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        templates.add(
          MesocycleTemplate.fromJson(
            json.decode(jsonString) as Map<String, dynamic>,
          ),
        );
      } catch (e) {
        print('Error loading template from $path: $e');
      }
    }

    return templates;
  }

  /// Load saved (user-created) templates from Hive
  Future<List<MesocycleTemplate>> loadSavedTemplates() async {
    try {
      final box = await Hive.openBox<String>(_savedTemplatesBoxName);
      final savedTemplates = <MesocycleTemplate>[];

      for (final jsonString in box.values) {
        try {
          final template = MesocycleTemplate.fromJson(
            json.decode(jsonString) as Map<String, dynamic>,
          );
          savedTemplates.add(template);
        } catch (e) {
          print('Error parsing saved template: $e');
        }
      }

      return savedTemplates;
    } catch (e) {
      print('Error loading saved templates: $e');
      return [];
    }
  }

  /// Get all available templates (both built-in and user-saved)
  Future<List<MesocycleTemplate>> getAllTemplates() async {
    final builtInTemplates = await loadTemplates();
    final savedTemplates = await loadSavedTemplates();
    return [...builtInTemplates, ...savedTemplates];
  }

  /// Check if a template is a saved (user-created) template
  Future<bool> isSavedTemplate(String templateId) async {
    try {
      final box = await Hive.openBox<String>(_savedTemplatesBoxName);
      return box.containsKey(templateId);
    } catch (e) {
      print('Error checking if template is saved: $e');
      return false;
    }
  }

  /// Delete a saved template
  Future<void> deleteTemplate(String templateId) async {
    try {
      final box = await Hive.openBox<String>(_savedTemplatesBoxName);
      await box.delete(templateId);
    } catch (e) {
      print('Error deleting template: $e');
      rethrow;
    }
  }

  /// Save a mesocycle as a template
  Future<void> saveAsTemplate(
    Mesocycle mesocycle,
    String name,
    String description,
  ) async {
    final template = _convertMesocycleToTemplate(mesocycle, name, description);
    final box = await Hive.openBox<String>(_savedTemplatesBoxName);
    final jsonString = json.encode(template.toJson());
    await box.put(template.id, jsonString);
  }

  /// Convert a Mesocycle to a MesocycleTemplate
  MesocycleTemplate _convertMesocycleToTemplate(
    Mesocycle mesocycle,
    String name,
    String description,
  ) {
    // Get workouts from week 1 only (template structure)
    final week1Workouts = mesocycle.workouts.where((w) => w.weekNumber == 1);

    print('Converting mesocycle "${mesocycle.name}" to template');
    print('Total workouts in mesocycle: ${mesocycle.workouts.length}');
    print('Week 1 workouts: ${week1Workouts.length}');

    final workoutTemplates = <WorkoutTemplate>[];
    for (final workout in week1Workouts) {
      print(
        'Processing workout: Day ${workout.dayNumber}, ${workout.exercises.length} exercises',
      );
      final exerciseTemplates = workout.exercises.map((exercise) {
        return ExerciseTemplate(
          name: exercise.name,
          muscleGroup: exercise.muscleGroup.name,
          equipmentType: exercise.equipmentType.name,
          sets: exercise.sets.length,
          reps: exercise.sets.isNotEmpty && exercise.sets.first.reps.isNotEmpty
              ? exercise.sets.first.reps
              : '8-12',
          setType: exercise.sets.isNotEmpty
              ? exercise.sets.first.setType.name
              : 'regular',
        );
      }).toList();

      workoutTemplates.add(
        WorkoutTemplate(
          weekNumber: workout.weekNumber,
          dayNumber: workout.dayNumber,
          dayName: workout.dayName,
          exercises: exerciseTemplates,
        ),
      );
    }

    return MesocycleTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      weeksTotal: mesocycle.weeksTotal,
      daysPerWeek: mesocycle.daysPerWeek,
      deloadWeek: mesocycle.deloadWeek,
      workouts: workoutTemplates,
    );
  }

  /// Get a specific template by ID
  Future<MesocycleTemplate?> getTemplateById(String id) async {
    final templates = await loadTemplates();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a mesocycle from a template
  Future<Mesocycle> createMesocycleFromTemplate(
    MesocycleTemplate template,
    String userName,
  ) async {
    final mesocycleId = _uuid.v4();
    final now = DateTime.now();

    // Create workouts from template
    final workouts = <Workout>[];
    for (final workoutTemplate in template.workouts) {
      // Group exercises by muscle group
      final exercisesByMuscleGroup = <MuscleGroup, List<Exercise>>{};

      for (final exerciseTemplate in workoutTemplate.exercises) {
        final exerciseId = _uuid.v4();

        // Parse muscle group
        final muscleGroup = MuscleGroup.values.firstWhere(
          (mg) =>
              mg.name.toLowerCase() ==
              exerciseTemplate.muscleGroup.toLowerCase(),
          orElse: () => MuscleGroup.chest,
        );

        // Parse equipment type
        final equipmentType = EquipmentType.values.firstWhere(
          (et) =>
              et.name.toLowerCase() ==
              exerciseTemplate.equipmentType.toLowerCase(),
          orElse: () => EquipmentType.barbell,
        );

        // Parse set type
        final setType = SetType.values.firstWhere(
          (st) =>
              st.name.toLowerCase() == exerciseTemplate.setType.toLowerCase(),
          orElse: () => SetType.regular,
        );

        // Create sets
        final sets = <ExerciseSet>[];
        for (int i = 0; i < exerciseTemplate.sets; i++) {
          sets.add(
            ExerciseSet(
              id: _uuid.v4(),
              setNumber: i + 1,
              reps: '', // Start empty, user will fill in
              setType: setType,
            ),
          );
        }

        // Create exercise (temporarily without workoutId)
        final exercise = Exercise(
          id: exerciseId,
          workoutId: '', // Will be set later
          name: exerciseTemplate.name,
          muscleGroup: muscleGroup,
          equipmentType: equipmentType,
          sets: sets,
        );

        if (!exercisesByMuscleGroup.containsKey(muscleGroup)) {
          exercisesByMuscleGroup[muscleGroup] = [];
        }
        exercisesByMuscleGroup[muscleGroup]!.add(exercise);
      }

      // Create a workout for each muscle group
      for (final entry in exercisesByMuscleGroup.entries) {
        final muscleGroup = entry.key;
        final groupExercises = entry.value;
        final workoutId = _uuid.v4();

        // Update exercises with correct workoutId
        final updatedExercises = groupExercises
            .map((e) => e.copyWith(workoutId: workoutId))
            .toList();

        workouts.add(
          Workout(
            id: workoutId,
            mesocycleId: mesocycleId,
            weekNumber: workoutTemplate.weekNumber,
            dayNumber: workoutTemplate.dayNumber,
            label: muscleGroup.displayName, // Use muscle group as label
            exercises: updatedExercises,
          ),
        );
      }
    }

    return Mesocycle(
      id: mesocycleId,
      name: '${template.name} - $userName',
      startDate: now,
      weeksTotal: template.weeksTotal,
      daysPerWeek: template.daysPerWeek,
      deloadWeek: template.deloadWeek,
      workouts: workouts,
    );
  }
}
