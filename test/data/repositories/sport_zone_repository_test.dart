import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/sport_zone_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late SportZoneRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SportZoneRepository(db.sportZoneDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('CRUD', () {
    test('create and getBySport', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 120,
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z2',
          sport: Sport.run,
          zoneNumber: 2,
          minValue: 120,
          maxValue: 140,
        ),
      );

      final zones = await repo.getBySport(Sport.run);
      expect(zones, hasLength(2));
    });

    test('getAll returns all zones across sports', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z2',
          sport: Sport.bike,
          zoneNumber: 1,
        ),
      );

      final all = await repo.getAll();
      expect(all, hasLength(2));
    });

    test('update modifies zone', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 120,
        ),
      );

      final zones = await repo.getBySport(Sport.run);
      final updated = zones.first.copyWith(maxValue: 130);
      await repo.update(updated);

      final loaded = await repo.getBySport(Sport.run);
      expect(loaded.first.maxValue, equals(130));
    });

    test('delete removes zone', () async {
      await repo.create(TestFixtures.createSportZone(id: 'z1'));
      await repo.delete('z1');

      final all = await repo.getAll();
      expect(all, isEmpty);
    });
  });

  group('Zone lookup', () {
    test('zoneFor returns correct zone number', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 130,
          unit: 'bpm',
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z2',
          sport: Sport.run,
          zoneNumber: 2,
          minValue: 130,
          maxValue: 150,
          unit: 'bpm',
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z3',
          sport: Sport.run,
          zoneNumber: 3,
          minValue: 150,
          maxValue: 170,
          unit: 'bpm',
        ),
      );

      expect(await repo.zoneFor(Sport.run, 115), equals(1));
      expect(await repo.zoneFor(Sport.run, 140), equals(2));
      expect(await repo.zoneFor(Sport.run, 155), equals(3));
    });

    test('zoneFor returns null when no zones configured', () async {
      expect(await repo.zoneFor(Sport.run, 140), isNull);
    });

    test('zoneFor returns null when value is outside all zones', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 130,
        ),
      );

      expect(await repo.zoneFor(Sport.run, 200), isNull);
    });
  });

  group('Bulk replace', () {
    test('replaceAllForSport replaces existing zones', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 100,
          maxValue: 120,
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z2',
          sport: Sport.run,
          zoneNumber: 2,
          minValue: 120,
          maxValue: 140,
        ),
      );

      // Replace with new zones
      final newZones = [
        TestFixtures.createSportZone(
          id: 'z3',
          sport: Sport.run,
          zoneNumber: 1,
          minValue: 90,
          maxValue: 110,
        ),
      ];
      await repo.replaceAllForSport(Sport.run, newZones);

      final zones = await repo.getBySport(Sport.run);
      expect(zones, hasLength(1));
      expect(zones.first.minValue, equals(90));
    });

    test('replaceAllForSport does not affect other sports', () async {
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
        ),
      );
      await repo.create(
        TestFixtures.createSportZone(
          id: 'z2',
          sport: Sport.bike,
          zoneNumber: 1,
        ),
      );

      await repo.replaceAllForSport(Sport.run, []);

      expect(await repo.getBySport(Sport.run), isEmpty);
      expect(await repo.getBySport(Sport.bike), hasLength(1));
    });
  });

  group('Stream', () {
    test('watchBySport emits on changes', () async {
      final stream = repo.watchBySport(Sport.run);
      expect(await stream.first, isEmpty);

      await repo.create(
        TestFixtures.createSportZone(
          id: 'z1',
          sport: Sport.run,
          zoneNumber: 1,
        ),
      );

      final result = await stream.first;
      expect(result, hasLength(1));
    });
  });
}
