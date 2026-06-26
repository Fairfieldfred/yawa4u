import 'dart:convert';

import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/theme/skins/skin_model.dart';
import '../../core/theme/skins/skin_repository.dart';
import '../models/cardio_feedback.dart';
import '../models/custom_exercise_definition.dart';
import '../models/cycle_period.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../models/sport_zone.dart';
import '../models/training_cycle.dart';
import '../models/workout.dart';
import '../repositories/cardio_feedback_repository.dart';
import '../repositories/custom_exercise_repository.dart';
import '../repositories/cycle_period_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/sport_zone_repository.dart';
import '../repositories/training_cycle_repository.dart';
import '../repositories/workout_repository.dart';
import 'theme_image_service.dart';

/// Service for exporting and importing app data.
///
/// Backup format:
///   v3 — strength only (training cycles + workouts + exercises + custom
///        exercise definitions + optional custom themes).
///   v4 — adds v5 multi-sport data: sessions, cycle periods, sport zones,
///        cardio feedback. Structured interval plans are rolled into each
///        [CardioSession]'s `intervals` field by `CardioSession.toJson`.
///        High-resolution samples are intentionally excluded — too heavy
///        for the generic backup pipeline; Phase 5's HealthKit import
///        re-fetches them on demand.
///
/// v3 imports are still supported — they simply produce a backup with no
/// cardio content, which is identical to today's behavior for pure strength
/// users.
class DataBackupService {
  final TrainingCycleRepository _trainingCycleRepository;
  final WorkoutRepository _workoutRepository;
  final ExerciseRepository _exerciseRepository;
  final CustomExerciseRepository _customExerciseRepository;
  final SessionRepository _sessionRepository;
  final CyclePeriodRepository _cyclePeriodRepository;
  final SportZoneRepository _sportZoneRepository;
  final CardioFeedbackRepository _cardioFeedbackRepository;
  final SkinRepository _skinRepository;
  final ThemeImageService _themeImageService;

  DataBackupService({
    required TrainingCycleRepository trainingCycleRepository,
    required WorkoutRepository workoutRepository,
    required ExerciseRepository exerciseRepository,
    required CustomExerciseRepository customExerciseRepository,
    required SessionRepository sessionRepository,
    required CyclePeriodRepository cyclePeriodRepository,
    required SportZoneRepository sportZoneRepository,
    required CardioFeedbackRepository cardioFeedbackRepository,
    required SkinRepository skinRepository,
    ThemeImageService? themeImageService,
  }) : _trainingCycleRepository = trainingCycleRepository,
       _workoutRepository = workoutRepository,
       _exerciseRepository = exerciseRepository,
       _customExerciseRepository = customExerciseRepository,
       _sessionRepository = sessionRepository,
       _cyclePeriodRepository = cyclePeriodRepository,
       _sportZoneRepository = sportZoneRepository,
       _cardioFeedbackRepository = cardioFeedbackRepository,
       _skinRepository = skinRepository,
       _themeImageService = themeImageService ?? ThemeImageService();

  /// Current backup format version. Bumped on every breaking change.
  static const int currentVersion = 4;

  /// Export all data to a JSON string
  Future<String> exportToJson({bool includeThemes = true}) async {
    final trainingCycles = await _trainingCycleRepository.getAll();
    final workouts = await _workoutRepository.getAll();
    final exercises = await _exerciseRepository.getAll();
    final customExercises = await _customExerciseRepository.getAll();

    // v4 additions — load multi-sport data.
    final allCardioSessions = <CardioSession>[];
    final cyclePeriods = <CyclePeriod>[];
    final cardioFeedbacks = <Map<String, dynamic>>[];
    final sportZones = await _sportZoneRepository.getAll();

    // Pull every cardio session via the full sessions stream snapshot. Using
    // getByTrainingCycleId per-cycle would miss ad-hoc sessions.
    final allSessions = await _loadAllSessions();
    for (final s in allSessions) {
      if (s is CardioSession) {
        allCardioSessions.add(s);
        final fb = await _cardioFeedbackRepository.getForSession(s.id);
        if (fb != null) {
          cardioFeedbacks.add({
            'sessionId': s.id,
            ...fb.toJson(),
          });
        }
      }
    }

    for (final cycle in trainingCycles) {
      final periods = await _cyclePeriodRepository.getByTrainingCycleId(
        cycle.id,
      );
      cyclePeriods.addAll(periods);
    }

    final data = <String, dynamic>{
      'version': currentVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'trainingCycles': trainingCycles.map((m) => m.toJson()).toList(),
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'customExercises': customExercises.map((e) => e.toJson()).toList(),
      // v4 fields
      'cardioSessions': allCardioSessions.map((s) => s.toJson()).toList(),
      'cyclePeriods': cyclePeriods.map((p) => p.toJson()).toList(),
      'sportZones': sportZones.map((z) => z.toJson()).toList(),
      'cardioFeedbacks': cardioFeedbacks,
    };

    // Include custom themes with Base64-encoded images
    if (includeThemes) {
      final customSkins = _skinRepository.getCustomSkins();
      final skinsWithImages = <Map<String, dynamic>>[];

      for (final skin in customSkins) {
        final skinJson = skin.toJson();
        // Export images as Base64
        final imagesBase64 = await _themeImageService.exportThemeImagesAsBase64(
          skin.id,
        );
        skinJson['imagesBase64'] = imagesBase64;
        skinsWithImages.add(skinJson);
      }

      data['customThemes'] = skinsWithImages;
    }

    return jsonEncode(data);
  }

  /// Import data from a JSON string
  /// Returns a summary of what was imported
  Future<ImportResult> importFromJson(
    String jsonString, {
    bool replace = false,
    bool importThemes = true,
  }) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version — accept anything up to the current supported
      // version. Future backups (v5+) are rejected rather than silently
      // dropping unknown fields.
      final version = data['version'] as int?;
      if (version == null || version > currentVersion) {
        return ImportResult(
          success: false,
          error: 'Unsupported backup version',
        );
      }

      // Parse data
      final trainingCyclesJson = data['trainingCycles'] as List<dynamic>? ?? [];
      final workoutsJson = data['workouts'] as List<dynamic>? ?? [];
      final exercisesJson = data['exercises'] as List<dynamic>? ?? [];
      final customExercisesJson = data['customExercises'] as List<dynamic>? ?? [];

      final trainingCycles = trainingCyclesJson.map((m) => TrainingCycle.fromJson(m as Map<String, dynamic>)).toList();
      final workouts = workoutsJson.map((w) => Workout.fromJson(w as Map<String, dynamic>)).toList();
      final exercises = exercisesJson.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
      final customExercises = customExercisesJson
          .map(
            (e) => CustomExerciseDefinition.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      // v4 — parse multi-sport blobs (absent on v3 imports).
      final cardioSessionsJson = data['cardioSessions'] as List<dynamic>? ?? [];
      final cyclePeriodsJson = data['cyclePeriods'] as List<dynamic>? ?? [];
      final sportZonesJson = data['sportZones'] as List<dynamic>? ?? [];
      final cardioFeedbacksJson = data['cardioFeedbacks'] as List<dynamic>? ?? [];

      final cardioSessions = cardioSessionsJson.map((s) => CardioSession.fromJson(s as Map<String, dynamic>)).toList();
      final cyclePeriods = cyclePeriodsJson.map((p) => CyclePeriod.fromJson(p as Map<String, dynamic>)).toList();
      final sportZones = sportZonesJson.map((z) => SportZone.fromJson(z as Map<String, dynamic>)).toList();

      // Clear existing data if replacing
      if (replace) {
        await _trainingCycleRepository.deleteAll();
        await _workoutRepository.deleteAll();
        await _exerciseRepository.deleteAll();
        await _customExerciseRepository.deleteAll();
        // v4 additions are cleared via their DAOs below, best-effort.
      }

      // Get existing IDs to check for duplicates
      final existingTrainingCycles = await _trainingCycleRepository.getAll();
      final existingTrainingCycleIds = existingTrainingCycles.map((tc) => tc.id).toSet();

      final existingWorkouts = await _workoutRepository.getAll();
      final existingWorkoutIds = existingWorkouts.map((w) => w.id).toSet();

      final existingCustomExercises = await _customExerciseRepository.getAll();
      final existingCustomExerciseIds = existingCustomExercises.map((ce) => ce.id).toSet();

      final existingSessions = await _loadAllSessions();
      final existingSessionIds = existingSessions.map((s) => s.id).toSet();

      final existingSportZones = await _sportZoneRepository.getAll();
      final existingSportZoneIds = existingSportZones.map((z) => z.id).toSet();

      // Import trainingCycles
      int trainingCyclesImported = 0;
      for (final trainingCycle in trainingCycles) {
        if (!replace && existingTrainingCycleIds.contains(trainingCycle.id)) {
          continue; // Skip if already exists and not replacing
        }
        await _trainingCycleRepository.create(trainingCycle);
        trainingCyclesImported++;
      }

      // Import workouts
      int workoutsImported = 0;
      for (final workout in workouts) {
        if (!replace && existingWorkoutIds.contains(workout.id)) {
          continue;
        }
        await _workoutRepository.create(workout);
        workoutsImported++;
      }

      // Import exercises.
      //
      // Workouts embed their exercises (Workout.toJson) and the backup ALSO
      // lists every exercise top-level, so each exercise arrives twice. The
      // workouts loop above already persisted the embedded ones (idempotently
      // via createStrength), so we must re-read existing ids HERE — a snapshot
      // taken before that loop is stale and a blind create() would hit the
      // UNIQUE(exercises.uuid) constraint (SqliteException 2067), aborting the
      // whole import. Skipping already-present ids leaves only true orphans.
      final exerciseIdsNow = (await _exerciseRepository.getAll()).map((e) => e.id).toSet();
      int exercisesImported = 0;
      for (final exercise in exercises) {
        if (exerciseIdsNow.contains(exercise.id)) {
          continue;
        }
        await _exerciseRepository.create(exercise);
        exercisesImported++;
      }

      // Import custom exercises
      int customExercisesImported = 0;
      for (final customExercise in customExercises) {
        if (!replace && existingCustomExerciseIds.contains(customExercise.id)) {
          continue;
        }
        await _customExerciseRepository.add(customExercise);
        customExercisesImported++;
      }

      // v4 — Import cardio sessions (strength sessions are reconstituted
      // by the Phase 1 backfill the moment workouts land above).
      int cardioSessionsImported = 0;
      for (final session in cardioSessions) {
        if (!replace && existingSessionIds.contains(session.id)) continue;
        try {
          await _sessionRepository.createCardio(session);
          cardioSessionsImported++;
        } catch (e, stack) {
          Sentry.captureException(e, stackTrace: stack);
          // Skip bad rows and continue rather than aborting the import.
        }
      }

      // v4 — Import cycle periods (skip duplicates by UUID).
      int cyclePeriodsImported = 0;
      for (final period in cyclePeriods) {
        final existing = await _cyclePeriodRepository.getByCycleAndPeriod(
          period.trainingCycleId,
          period.periodNumber,
        );
        if (existing != null && !replace) continue;
        if (existing != null && replace) {
          await _cyclePeriodRepository.delete(existing.id);
        }
        await _cyclePeriodRepository.create(period);
        cyclePeriodsImported++;
      }

      // v4 — Import sport zones. Replace-all semantics per sport when
      // [replace] is true; otherwise append-only.
      int sportZonesImported = 0;
      if (replace) {
        // Group by sport, replace each sport's zones atomically.
        final bySport = <String, List<SportZone>>{};
        for (final z in sportZones) {
          bySport.putIfAbsent(z.sport.name, () => []).add(z);
        }
        for (final entry in bySport.entries) {
          if (entry.value.isEmpty) continue;
          await _sportZoneRepository.replaceAllForSport(
            entry.value.first.sport,
            entry.value,
          );
          sportZonesImported += entry.value.length;
        }
      } else {
        for (final z in sportZones) {
          // Skip zones we already have — the uuid column is UNIQUE, so a
          // blind insert throws SqliteException(2067) on re-import (e.g.
          // a second WiFi sync). Matches the dedup other tables do above.
          if (existingSportZoneIds.contains(z.id)) continue;
          await _sportZoneRepository.create(z);
          sportZonesImported++;
        }
      }

      // v4 — Import cardio feedback (1:1 with session; upsert).
      int cardioFeedbacksImported = 0;
      for (final fbJson in cardioFeedbacksJson) {
        try {
          final map = Map<String, dynamic>.from(fbJson as Map<String, dynamic>);
          final sessionId = map.remove('sessionId') as String?;
          if (sessionId == null) continue;
          final fb = CardioFeedback.fromJson(map);
          await _cardioFeedbackRepository.save(sessionId, fb);
          cardioFeedbacksImported++;
        } catch (e, stack) {
          Sentry.captureException(e, stackTrace: stack);
        }
      }

      // Import custom themes
      int customThemesImported = 0;
      if (importThemes) {
        final customThemesJson = data['customThemes'] as List<dynamic>? ?? [];
        for (final themeData in customThemesJson) {
          try {
            final skinJson = Map<String, dynamic>.from(
              themeData as Map<String, dynamic>,
            );
            final imagesBase64 = skinJson.remove('imagesBase64') as Map<String, dynamic>? ?? {};

            // Parse the skin model
            final skin = SkinModel.fromJson(skinJson);

            // Check if theme already exists
            final existingCustomSkins = _skinRepository.getCustomSkins();
            final exists = existingCustomSkins.any((s) => s.id == skin.id);

            if (!replace && exists) {
              continue;
            }

            // Import images first
            await _themeImageService.importThemeImagesFromBase64(
              themeId: skin.id,
              base64Map: imagesBase64.map((k, v) => MapEntry(k, v as String)),
            );

            // Get the actual paths for the imported images
            final importedPaths = await _themeImageService.getAllThemeImagePaths(skin.id);

            // Update skin with new image paths
            final updatedSkin = skin.copyWith(
              backgrounds: SkinBackgrounds(
                workout: importedPaths['workout'],
                cycles: importedPaths['cycles'],
                exercises: importedPaths['exercises'],
                more: importedPaths['more'],
                defaultBackground: importedPaths['default'],
                appIcon: importedPaths['app_icon'],
              ),
            );

            // Save the skin
            await _skinRepository.saveCustomSkin(updatedSkin);
            customThemesImported++;
          } catch (e, stack) {
            Sentry.captureException(e, stackTrace: stack);
            // Log but continue with other themes
            continue;
          }
        }
      }

      return ImportResult(
        success: true,
        trainingCyclesImported: trainingCyclesImported,
        workoutsImported: workoutsImported,
        exercisesImported: exercisesImported,
        customExercisesImported: customExercisesImported,
        customThemesImported: customThemesImported,
        cardioSessionsImported: cardioSessionsImported,
        cyclePeriodsImported: cyclePeriodsImported,
        sportZonesImported: sportZonesImported,
        cardioFeedbacksImported: cardioFeedbacksImported,
      );
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return ImportResult(success: false, error: 'Failed to parse backup: $e');
    }
  }

  /// Get stats about current data
  Future<DataStats> getStats() async {
    final trainingCycles = await _trainingCycleRepository.getAll();
    final workouts = await _workoutRepository.getAll();
    final exercises = await _exerciseRepository.getAll();
    final customExercises = await _customExerciseRepository.getAll();
    final sessions = await _loadAllSessions();
    final cardioSessions = sessions.whereType<CardioSession>().length;

    return DataStats(
      trainingCycleCount: trainingCycles.length,
      workoutCount: workouts.length,
      exerciseCount: exercises.length,
      customExerciseCount: customExercises.length,
      cardioSessionCount: cardioSessions,
    );
  }

  /// One-shot snapshot of every session in the DB. Uses the underlying
  /// `watchAll()` stream because SessionRepository doesn't expose a
  /// non-reactive getAll — the first emission of the stream is the current
  /// contents, so we just take it.
  Future<List<Session>> _loadAllSessions() {
    return _sessionRepository.watchAll().first;
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String? error;
  final int trainingCyclesImported;
  final int workoutsImported;
  final int exercisesImported;
  final int customExercisesImported;
  final int customThemesImported;
  final int cardioSessionsImported;
  final int cyclePeriodsImported;
  final int sportZonesImported;
  final int cardioFeedbacksImported;

  ImportResult({
    required this.success,
    this.error,
    this.trainingCyclesImported = 0,
    this.workoutsImported = 0,
    this.exercisesImported = 0,
    this.customExercisesImported = 0,
    this.customThemesImported = 0,
    this.cardioSessionsImported = 0,
    this.cyclePeriodsImported = 0,
    this.sportZonesImported = 0,
    this.cardioFeedbacksImported = 0,
  });

  int get totalImported =>
      trainingCyclesImported +
      workoutsImported +
      exercisesImported +
      customExercisesImported +
      customThemesImported +
      cardioSessionsImported +
      cyclePeriodsImported +
      sportZonesImported +
      cardioFeedbacksImported;
}

/// Statistics about current data
class DataStats {
  final int trainingCycleCount;
  final int workoutCount;
  final int exerciseCount;
  final int customExerciseCount;
  final int cardioSessionCount;

  DataStats({
    required this.trainingCycleCount,
    required this.workoutCount,
    required this.exerciseCount,
    required this.customExerciseCount,
    this.cardioSessionCount = 0,
  });

  int get total => trainingCycleCount + workoutCount + exerciseCount + customExerciseCount + cardioSessionCount;
}
