import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/data/database/database.dart' hide UserMeasurement;
import 'package:yawa4u/data/models/user_measurement.dart';
import 'package:yawa4u/data/repositories/user_measurement_repository.dart';
import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/measurement_providers.dart';

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

  group('latestMeasurementProvider', () {
    test('returns null when no measurements', () async {
      final container = ProviderContainer(
        overrides: [
          userMeasurementRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(latestMeasurementProvider.future);
      expect(result, isNull);
    });

    test('returns most recent measurement', () async {
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

      final container = ProviderContainer(
        overrides: [
          userMeasurementRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(latestMeasurementProvider.future);
      expect(result, isNotNull);
      expect(result!.weightKg, equals(82));
    });
  });

  group('userMeasurementsProvider', () {
    test('emits empty list when no measurements', () {
      final container = ProviderContainer(
        overrides: [
          userMeasurementsProvider.overrideWithValue(
            const AsyncValue.data([]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(userMeasurementsProvider);
      expect(result.value, isEmpty);
    });

    test('emits list of measurements', () {
      final measurements = [
        UserMeasurement(
          id: 'm1',
          heightCm: 175,
          weightKg: 80,
          timestamp: DateTime(2024, 6, 1),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          userMeasurementsProvider.overrideWithValue(
            AsyncValue.data(measurements),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = container.read(userMeasurementsProvider);
      expect(result.value, hasLength(1));
      expect(result.value!.first.weightKg, equals(80));
    });
  });
}
