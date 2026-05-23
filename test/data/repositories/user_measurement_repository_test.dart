import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/user_measurement_repository.dart';

void main() {
  late AppDatabase db;
  late UserMeasurementRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = UserMeasurementRepository(db.userMeasurementDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD', () {
    test('add generates UUID and returns measurement', () async {
      final result = await repo.add(
        heightCm: 180,
        weightKg: 85,
        notes: 'Morning weigh-in',
      );

      expect(result.id, isNotEmpty);
      expect(result.heightCm, equals(180));
      expect(result.weightKg, equals(85));
      expect(result.notes, equals('Morning weigh-in'));
      expect(result.timestamp, isNotNull);
    });

    test('add with explicit timestamp', () async {
      final ts = DateTime(2024, 6, 15);
      final result = await repo.add(
        heightCm: 175,
        weightKg: 80,
        timestamp: ts,
      );

      expect(result.timestamp, equals(ts));
    });

    test('add with body composition data', () async {
      final result = await repo.add(
        heightCm: 175,
        weightKg: 80,
        bodyFatPercent: 15.0,
        leanMassKg: 68.0,
      );

      expect(result.bodyFatPercent, equals(15.0));
      expect(result.leanMassKg, equals(68.0));
    });

    test('update modifies measurement', () async {
      final created = await repo.add(heightCm: 175, weightKg: 80);
      final updated = created.copyWith(weightKg: 78);
      await repo.update(updated);

      final loaded = await repo.getLatest();
      expect(loaded!.weightKg, equals(78));
    });

    test('delete removes measurement', () async {
      final created = await repo.add(heightCm: 175, weightKg: 80);
      await repo.delete(created.id);

      expect(await repo.getLatest(), isNull);
    });

    test('deleteAll clears all', () async {
      await repo.add(heightCm: 175, weightKg: 80);
      await repo.add(heightCm: 175, weightKg: 82);
      await repo.deleteAll();

      expect(await repo.getAll(), isEmpty);
    });
  });

  group('Queries', () {
    test('getAll returns sorted newest first', () async {
      await repo.add(
        heightCm: 175,
        weightKg: 80,
        timestamp: DateTime(2024, 1, 1),
      );
      await repo.add(
        heightCm: 175,
        weightKg: 82,
        timestamp: DateTime(2024, 6, 1),
      );

      final all = await repo.getAll();
      expect(all, hasLength(2));
      expect(all.first.weightKg, equals(82)); // Newest first
    });

    test('getLatest returns most recent', () async {
      await repo.add(
        heightCm: 175,
        weightKg: 80,
        timestamp: DateTime(2024, 1, 1),
      );
      await repo.add(
        heightCm: 175,
        weightKg: 85,
        timestamp: DateTime(2024, 6, 1),
      );

      final latest = await repo.getLatest();
      expect(latest, isNotNull);
      expect(latest!.weightKg, equals(85));
    });

    test('getLatest returns null when empty', () async {
      expect(await repo.getLatest(), isNull);
    });

    test('getInRange returns measurements within range', () async {
      await repo.add(
        heightCm: 175,
        weightKg: 80,
        timestamp: DateTime(2024, 1, 15),
      );
      await repo.add(
        heightCm: 175,
        weightKg: 82,
        timestamp: DateTime(2024, 3, 15),
      );
      await repo.add(
        heightCm: 175,
        weightKg: 84,
        timestamp: DateTime(2024, 6, 15),
      );

      final inRange = await repo.getInRange(
        DateTime(2024, 2, 1),
        DateTime(2024, 5, 1),
      );
      expect(inRange, hasLength(1));
      expect(inRange.first.weightKg, equals(82));
    });
  });

  group('Convenience methods', () {
    test('isEmpty returns true when empty', () async {
      expect(await repo.isEmpty(), isTrue);
    });

    test('isEmpty returns false when not empty', () async {
      await repo.add(heightCm: 175, weightKg: 80);
      expect(await repo.isEmpty(), isFalse);
    });

    test('isNotEmpty returns false when empty', () async {
      expect(await repo.isNotEmpty(), isFalse);
    });

    test('isNotEmpty returns true when not empty', () async {
      await repo.add(heightCm: 175, weightKg: 80);
      expect(await repo.isNotEmpty(), isTrue);
    });

    test('count returns correct value', () async {
      expect(await repo.count(), equals(0));
      await repo.add(heightCm: 175, weightKg: 80);
      await repo.add(heightCm: 175, weightKg: 82);
      expect(await repo.count(), equals(2));
    });
  });

  group('BMI history', () {
    test('getBmiHistory returns correct data', () async {
      await repo.add(
        heightCm: 180,
        weightKg: 81,
        timestamp: DateTime(2024, 1, 1),
      );

      final history = await repo.getBmiHistory();
      expect(history, hasLength(1));

      final entry = history.first;
      expect(entry['weight'], equals(81));
      expect(entry['height'], equals(180));
      expect(entry['date'], isA<DateTime>());
      // BMI = 81 / (1.80 * 1.80) = 25.0
      expect((entry['bmi'] as double), closeTo(25.0, 0.1));
    });
  });

  group('Stream', () {
    test('watchAll emits on changes', () async {
      final stream = repo.watchAll();
      expect(await stream.first, isEmpty);

      await repo.add(heightCm: 175, weightKg: 80);
      final result = await stream.first;
      expect(result, hasLength(1));
    });
  });
}
