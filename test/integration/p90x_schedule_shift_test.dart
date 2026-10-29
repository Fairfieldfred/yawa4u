import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/training_cycle_template.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/repositories/template_repository.dart';
import 'package:yawa4u/data/services/schedule_service.dart';
import 'package:yawa4u/domain/providers/calendar_providers.dart';

import 'helpers/integration_test_helpers.dart';

/// Inserting a rest day before a cardio-only day (P90X's Plyometrics) must shift it, and the
/// Workout screen's date → (period, day) lookup must follow the shift.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late IntegrationTestContext ctx;
  late ScheduleService service;
  late String cycleId;

  // Week 1 starts Monday 19 Oct 2026: Chest and Back (strength), Plyometrics (cardio), Shoulders and Arms…
  final start = DateTime(2026, 10, 19);

  setUp(() async {
    ctx = IntegrationTestContext();
    await ctx.initialize();
    service = ScheduleService(
      cycleRepository: ctx.cycleRepo,
      workoutRepository: ctx.workoutRepo,
      sessionRepository: ctx.sessionRepo,
    );

    final template = TrainingCycleTemplate.fromJson(
      json.decode(await rootBundle.loadString('assets/templates/p90x.json')) as Map<String, dynamic>,
    );
    final result = await TemplateRepository().createTrainingCycleFromTemplate(template);
    await ctx.cycleRepo.create(result.trainingCycle.copyWith(startDate: start));
    for (final workout in result.trainingCycle.workouts) {
      await ctx.workoutRepo.create(workout);
    }
    for (final cardio in result.cardioSessions) {
      await ctx.sessionRepo.createCardio(cardio);
    }
    cycleId = result.trainingCycle.id;
  });

  tearDown(() => ctx.dispose());

  Future<(TrainingCycle, List<Workout>, List<Session>)> load() async => (
    (await ctx.cycleRepo.getById(cycleId))!,
    await ctx.workoutRepo.getByTrainingCycleId(cycleId),
    await ctx.sessionRepo.watchByTrainingCycleId(cycleId).first,
  );

  Future<CalendarDayData> calendarDay(DateTime date) async {
    final (cycle, workouts, sessions) = await load();
    return buildCalendarData(
      cycle: cycle,
      allWorkouts: workouts,
      month: date,
      cycleSessions: sessions,
    ).firstWhere((d) => d.date == date);
  }

  test('a cardio-only day is a planned day, not a rest day', () async {
    final plyo = await calendarDay(DateTime(2026, 10, 20));
    expect(plyo.hasWorkout, isFalse);
    expect(plyo.hasPlannedSession, isTrue);
    expect((plyo.periodNumber, plyo.dayNumber), (1, 2));
  });

  test('inserting a day before Plyometrics shifts it and everything after it', () async {
    await service.insertDayBeforeDate(cycleId: cycleId, restDayDate: DateTime(2026, 10, 20));

    final restDay = await calendarDay(DateTime(2026, 10, 20));
    expect(restDay.hasPlannedSession, isFalse);

    final plyo = await calendarDay(DateTime(2026, 10, 21));
    expect(plyo.cardioSessions.map((s) => s.label), ['Plyometrics']);
    expect((plyo.periodNumber, plyo.dayNumber), (1, 2));

    final shouldersAndArms = await calendarDay(DateTime(2026, 10, 22));
    expect(shouldersAndArms.workouts.map((w) => w.dayName).toSet(), {'Shoulders and Arms'});

    // Workout screen: the shifted date opens the Plyometrics slot, and that slot maps back to it.
    final (cycle, workouts, sessions) = await load();
    expect(selectedPeriodDay(cycle, workouts, DateTime(2026, 10, 21), sessions: sessions), (period: 1, day: 2));
    expect(dateForPeriodDay(cycle, workouts, 1, 2, sessions: sessions), DateTime(2026, 10, 21));
    expect(selectedPeriodDay(cycle, workouts, DateTime(2026, 10, 25), sessions: sessions), (period: 1, day: 6));
  });

  test('undo puts Plyometrics back on its original day', () async {
    final snapshot = await service.insertDayBeforeDate(cycleId: cycleId, restDayDate: DateTime(2026, 10, 20));
    await service.restoreSnapshot(cycleId, snapshot!);

    final plyo = await calendarDay(DateTime(2026, 10, 20));
    expect(plyo.cardioSessions.map((s) => s.label), ['Plyometrics']);
    final (cycle, workouts, sessions) = await load();
    expect(selectedPeriodDay(cycle, workouts, DateTime(2026, 10, 20), sessions: sessions), (period: 1, day: 2));
  });
}
