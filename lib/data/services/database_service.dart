import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

    _database = AppDatabase(_openConnection());
    _initialized = true;
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
    
    await _database!.transaction(() async {
      // Delete in order respecting foreign key constraints
      await _database!.delete(_database!.exerciseFeedbacks).go();
      await _database!.delete(_database!.exerciseSets).go();
      await _database!.delete(_database!.exercises).go();
      await _database!.delete(_database!.workouts).go();
      await _database!.delete(_database!.trainingCycles).go();
      await _database!.delete(_database!.customExerciseDefinitions).go();
      await _database!.delete(_database!.userMeasurements).go();
      await _database!.delete(_database!.skins).go();
    });
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _initialized = false;
  }

  /// Delete and recreate the database (for corrupted data scenarios)
  Future<void> resetDatabase() async {
    await close();
    
    final dbPath = await getDatabasePath();
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
    }
    
    await initialize();
  }

  /// Get database statistics
  Future<Map<String, int>> getStatistics() async {
    if (_database == null) return {};
    
    final trainingCycleCount = await _database!.trainingCycleDao.getAllSorted().then((list) => list.length);
    final workoutCount = await _database!.workoutDao.getAll().then((list) => list.length);
    final exerciseCount = await _database!.exerciseDao.getAll().then((list) => list.length);
    final exerciseSetCount = await _database!.exerciseSetDao.getAll().then((list) => list.length);
    final customExerciseCount = await _database!.customExerciseDao.getAllSorted().then((list) => list.length);
    final userMeasurementCount = await _database!.userMeasurementDao.getAllSorted().then((list) => list.length);
    final skinCount = await _database!.skinDao.getAllSorted().then((list) => list.length);
    
    return {
      'trainingCycles': trainingCycleCount,
      'workouts': workoutCount,
      'exercises': exerciseCount,
      'exerciseSets': exerciseSetCount,
      'customExercises': customExerciseCount,
      'userMeasurements': userMeasurementCount,
      'skins': skinCount,
    };
  }
}
