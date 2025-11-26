import 'dart:convert';

import 'package:flutter/services.dart';
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

  /// Load all available templates from assets
  Future<List<MesocycleTemplate>> loadTemplates() async {
    final templates = <MesocycleTemplate>[];

    try {
      // Load beginner full body template
      final beginnerJson = await rootBundle.loadString(
        'assets/templates/beginner_full_body.json',
      );
      templates.add(
        MesocycleTemplate.fromJson(
          json.decode(beginnerJson) as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      print('Error loading beginner_full_body template: $e');
    }

    try {
      // Load upper/lower split template
      final upperLowerJson = await rootBundle.loadString(
        'assets/templates/upper_lower_split.json',
      );
      templates.add(
        MesocycleTemplate.fromJson(
          json.decode(upperLowerJson) as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      print('Error loading upper_lower_split template: $e');
    }

    return templates;
  }

  /// Get all available templates
  Future<List<MesocycleTemplate>> getAllTemplates() async {
    return await loadTemplates();
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
            dayName: workoutTemplate.dayName,
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
