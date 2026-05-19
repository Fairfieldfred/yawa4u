import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../database/database.dart';

/// Database service for Drift initialization and management
///
/// Provides singleton access to the Drift database.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  AppDatabase? _database;
  bool _initialized = false;

  /// Check if database is initialized
  bool get isInitialized => _initialized;

  /// Get the database instance
  AppDatabase get database {
    if (_database == null) {
      throw StateError(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
    return _database!;
  }

  /// Initialize the Drift database
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _database = AppDatabase(_openConnection());
      _initialized = true;
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: Failed to initialize database: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Open the database connection
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'yawa4u.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'yawa4u.sqlite');
  }

  /// Clear all data from all tables
  Future<void> clearDatabase() async {
    if (_database == null) return;

    try {
      await _database!.transaction(() async {
        // Delete in order respecting foreign key constraints. Child
        // tables first, parents last.
        await _database!.delete(_database!.exerciseFeedbacks).go();
        await _database!.delete(_database!.exerciseSets).go();
        await _database!.delete(_database!.exercises).go();

        // v5 cardio side-tables hang off sessions — clear them before
        // the parent session rows.
        await _database!.delete(_database!.cardioFeedback).go();
        await _database!.delete(_database!.sessionSamples).go();
        await _database!.delete(_database!.sessionIntervals).go();
        await _database!.delete(_database!.sessionCardio).go();
        await _database!.delete(_database!.sessions).go();
        await _database!.delete(_database!.cyclePeriods).go();
        await _database!.delete(_database!.sportZones).go();

        await _database!.delete(_database!.trainingCycles).go();
        await _database!.delete(_database!.customExerciseDefinitions).go();
        await _database!.delete(_database!.userMeasurements).go();
        await _database!.delete(_database!.skins).go();
      });
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: Failed to clear database: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _initialized = false;
  }

  /// Delete and recreate the database (for corrupted data scenarios)
  Future<void> resetDatabase() async {
    try {
      await close();

      final dbPath = await getDatabasePath();
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }

      await initialize();
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: Failed to reset database: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get database statistics (uses efficient SQL COUNT queries).
  ///
  /// Phase 6d: the legacy `workouts` table was dropped in the v6
  /// migration. The `workouts` stat now counts strength rows in the
  /// `sessions` table — the same number the old query would have
  /// returned, just coming from the canonical source.
  Future<Map<String, int>> getStatistics() async {
    if (_database == null) return {};

    try {
      final trainingCycleCount = await _database!.trainingCycleDao.countRows();
      final strengthSessionCount = await _database!.sessionDao.countBySport(0); // Sport.strength.index
      final exerciseCount = await _database!.exerciseDao.countRows();
      final customExerciseCount = await _database!.customExerciseDao.countRows();
      final userMeasurementCount = await _database!.userMeasurementDao.countRows();

      return {
        'trainingCycles': trainingCycleCount,
        'workouts': strengthSessionCount,
        'exercises': exerciseCount,
        'customExercises': customExerciseCount,
        'userMeasurements': userMeasurementCount,
      };
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: Failed to get statistics: $e');
      Sentry.captureException(e, stackTrace: stackTrace);
      return {};
    }
  }
}
