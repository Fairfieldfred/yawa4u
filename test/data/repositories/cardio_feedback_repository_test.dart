import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/cardio_feedback_repository.dart';
import 'package:yawa4u/data/repositories/session_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late CardioFeedbackRepository repo;
  late SessionRepository sessionRepo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CardioFeedbackRepository(db.cardioFeedbackDao);
    sessionRepo = SessionRepository(
      db.sessionDao,
      db.exerciseDao,
      db.exerciseSetDao,
      db.sessionCardioDao,
      db.sessionIntervalDao,
      db.sessionSampleDao,
      db.cardioFeedbackDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertCardioSession(String id) async {
    await sessionRepo.createCardio(
      TestFixtures.createCardioSession(id: id, sport: Sport.run),
    );
  }

  group('CRUD', () {
    test('save creates feedback and getForSession retrieves it', () async {
      await insertCardioSession('cs1');

      final feedback = TestFixtures.createCardioFeedback(
        rpe: 7,
        breathing: 3,
        giComfort: 5,
        weather: 'Sunny',
        notes: 'Felt great',
      );
      await repo.save('cs1', feedback);

      final loaded = await repo.getForSession('cs1');
      expect(loaded, isNotNull);
      expect(loaded!.rpe, equals(7));
      expect(loaded.breathing, equals(3));
      expect(loaded.giComfort, equals(5));
      expect(loaded.weather, equals('Sunny'));
      expect(loaded.notes, equals('Felt great'));
    });

    test('save upserts when feedback already exists', () async {
      await insertCardioSession('cs1');

      await repo.save('cs1', TestFixtures.createCardioFeedback(rpe: 5));
      await repo.save('cs1', TestFixtures.createCardioFeedback(rpe: 8));

      final loaded = await repo.getForSession('cs1');
      expect(loaded!.rpe, equals(8));
    });

    test('getForSession returns null when no feedback', () async {
      await insertCardioSession('cs1');

      final loaded = await repo.getForSession('cs1');
      expect(loaded, isNull);
    });

    test('delete removes feedback', () async {
      await insertCardioSession('cs1');

      await repo.save('cs1', TestFixtures.createCardioFeedback());
      await repo.delete('cs1');

      expect(await repo.getForSession('cs1'), isNull);
    });
  });

  group('Stream', () {
    test('watchForSession emits feedback', () async {
      await insertCardioSession('cs1');

      final stream = repo.watchForSession('cs1');
      expect(await stream.first, isNull);

      await repo.save('cs1', TestFixtures.createCardioFeedback(rpe: 6));
      final result = await stream.first;
      expect(result, isNotNull);
      expect(result!.rpe, equals(6));
    });

    test('watchForSession emits null after delete', () async {
      await insertCardioSession('cs1');

      await repo.save('cs1', TestFixtures.createCardioFeedback());

      // Verify it exists
      final before = await repo.watchForSession('cs1').first;
      expect(before, isNotNull);

      await repo.delete('cs1');

      final after = await repo.watchForSession('cs1').first;
      expect(after, isNull);
    });
  });
}
