import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:yawa4u/data/database/database.dart';

/// Helper for creating an in-memory AppDatabase for tests.
///
/// Usage:
/// ```dart
/// late TestAppDatabase testDb;
///
/// setUp(() async {
///   testDb = TestAppDatabase();
///   await testDb.initialize();
/// });
///
/// tearDown(() async {
///   await testDb.close();
/// });
/// ```
class TestAppDatabase {
  late AppDatabase _db;
  bool _initialized = false;

  AppDatabase get database {
    if (!_initialized) {
      throw StateError('TestAppDatabase not initialized. Call initialize().');
    }
    return _db;
  }

  Future<void> initialize() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    _db = AppDatabase.forTesting(NativeDatabase.memory());
    _initialized = true;
  }

  Future<void> close() async {
    if (_initialized) {
      await _db.close();
      _initialized = false;
    }
  }
}
