import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/utils/date_helpers.dart';
import 'package:yawa4u/domain/providers/calendar_providers.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('buildCalendarData', () {
    test('maps workouts to correct calendar dates', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 2,
        daysPerPeriod: 3,
        startDate: DateTime(2024, 6, 1),
      );

      final workouts = [
        TestFixtures.createWorkout(
          id: 'w1',
          trainingCycleId: 'c1',
          periodNumber: 1,
          dayNumber: 1,
          scheduledDate: DateTime(2024, 6, 1),
        ),
        TestFixtures.createWorkout(
          id: 'w2',
          trainingCycleId: 'c1',
          periodNumber: 1,
          dayNumber: 2,
          scheduledDate: DateTime(2024, 6, 2),
        ),
      ];

      final data = buildCalendarData(
        cycle: cycle,
        allWorkouts: workouts,
        month: DateTime(2024, 6),
      );

      // June has 30 days
      expect(data, hasLength(30));

      // Day 1 should have a workout
      final june1 = data.firstWhere(
        (d) => d.date == DateTime(2024, 6, 1),
      );
      expect(june1.hasWorkout, isTrue);
      expect(june1.workouts, hasLength(1));
      expect(june1.workouts.first.id, 'w1');
    });

    test('marks completed days correctly', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 1,
        daysPerPeriod: 3,
        startDate: DateTime(2024, 6, 1),
      );

      final workouts = [
        TestFixtures.createWorkout(
          id: 'w1',
          trainingCycleId: 'c1',
          periodNumber: 1,
          dayNumber: 1,
          scheduledDate: DateTime(2024, 6, 1),
          status: WorkoutStatus.completed,
        ),
        TestFixtures.createWorkout(
          id: 'w2',
          trainingCycleId: 'c1',
          periodNumber: 1,
          dayNumber: 2,
          scheduledDate: DateTime(2024, 6, 2),
          status: WorkoutStatus.incomplete,
        ),
      ];

      final data = buildCalendarData(
        cycle: cycle,
        allWorkouts: workouts,
        month: DateTime(2024, 6),
      );

      final june1 = data.firstWhere(
        (d) => d.date == DateTime(2024, 6, 1),
      );
      expect(june1.isCompleted, isTrue);

      final june2 = data.firstWhere(
        (d) => d.date == DateTime(2024, 6, 2),
      );
      expect(june2.isCompleted, isFalse);
    });

    test('days before cycle start have no period info', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 1,
        daysPerPeriod: 3,
        startDate: DateTime(2024, 6, 15),
      );

      final data = buildCalendarData(
        cycle: cycle,
        allWorkouts: [],
        month: DateTime(2024, 6),
      );

      final june1 = data.firstWhere(
        (d) => d.date == DateTime(2024, 6, 1),
      );
      // Day before cycle start should have no period/day info
      expect(june1.periodNumber, isNull);
      expect(june1.hasWorkout, isFalse);
    });

    test('returns empty map when no active cycle in calendarMonthDataProvider', () {
      // Test the provider with no current cycle
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final data = container.read(
        calendarMonthDataProvider(DateTime(2024, 6)),
      );
      expect(data, isEmpty);
    });
  });

  group('CalendarDayData', () {
    test('hasAnySession is true with workouts', () {
      final day = CalendarDayData(
        date: DateTime(2024, 6, 1),
        workouts: [TestFixtures.createWorkout()],
      );
      expect(day.hasAnySession, isTrue);
      expect(day.hasWorkout, isTrue);
      expect(day.hasCardio, isFalse);
    });

    test('hasAnySession is true with cardio sessions', () {
      final day = CalendarDayData(
        date: DateTime(2024, 6, 1),
        cardioSessions: [TestFixtures.createCardioSession()],
      );
      expect(day.hasAnySession, isTrue);
      expect(day.hasCardio, isTrue);
      expect(day.hasWorkout, isFalse);
    });

    test('hasAnySession is false when empty', () {
      final day = CalendarDayData(date: DateTime(2024, 6, 1));
      expect(day.hasAnySession, isFalse);
    });
  });

  group('CalendarScreenNotifier', () {
    test('initial state has today as focused month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(calendarScreenProvider);
      expect(state.focusedMonth.year, DateTime.now().year);
      expect(state.focusedMonth.month, DateTime.now().month);
    });

    test('setFocusedMonth updates month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(calendarScreenProvider.notifier)
          .setFocusedMonth(
            DateTime(2024, 3),
          );

      final state = container.read(calendarScreenProvider);
      expect(state.focusedMonth.year, 2024);
      expect(state.focusedMonth.month, 3);
    });

    test('setSelectedDate updates date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(calendarScreenProvider.notifier)
          .setSelectedDate(
            DateTime(2024, 6, 15),
          );

      final state = container.read(calendarScreenProvider);
      expect(state.selectedDate, DateTime(2024, 6, 15));
    });

    test('setSelectedDate(null) clears date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(calendarScreenProvider.notifier).setSelectedDate(null);

      final state = container.read(calendarScreenProvider);
      expect(state.selectedDate, isNull);
    });

    test('previousMonth decrements month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(calendarScreenProvider.notifier)
          .setFocusedMonth(
            DateTime(2024, 6),
          );
      container.read(calendarScreenProvider.notifier).previousMonth();

      final state = container.read(calendarScreenProvider);
      expect(state.focusedMonth.month, 5);
    });

    test('nextMonth increments month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(calendarScreenProvider.notifier)
          .setFocusedMonth(
            DateTime(2024, 6),
          );
      container.read(calendarScreenProvider.notifier).nextMonth();

      final state = container.read(calendarScreenProvider);
      expect(state.focusedMonth.month, 7);
    });

    test('goToToday resets to current date', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Move to different month
      container
          .read(calendarScreenProvider.notifier)
          .setFocusedMonth(
            DateTime(2020, 1),
          );
      container.read(calendarScreenProvider.notifier).goToToday();

      final state = container.read(calendarScreenProvider);
      expect(state.focusedMonth.year, DateTime.now().year);
      expect(state.focusedMonth.month, DateTime.now().month);
    });
  });

  group('CalendarUndoState', () {
    test('hasRecentSnapshot is false when no snapshot', () {
      const state = CalendarUndoState();
      expect(state.hasRecentSnapshot, isFalse);
    });

    test('clear returns empty state', () {
      const state = CalendarUndoState();
      final cleared = state.clear();
      expect(cleared.entries, isEmpty);
      expect(cleared.snapshot, isNull);
    });
  });

  group('selectedPeriodDay / currentPeriodDay', () {
    test('selectedPeriodDay maps a date to the cycle slot', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 4,
        daysPerPeriod: 7,
        startDate: DateTime(2025, 1, 1),
      );
      expect(
        selectedPeriodDay(cycle, const [], DateTime(2025, 1, 10)),
        (period: 2, day: 3),
      );
    });

    test('selectedPeriodDay returns null outside the cycle', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 1,
        daysPerPeriod: 7,
        startDate: DateTime(2025, 1, 1),
      );
      expect(selectedPeriodDay(cycle, const [], DateTime(2025, 6, 1)), isNull);
    });

    test('selectedPeriodDay returns null when cycle has no start date', () {
      final cycle = TestFixtures.createTrainingCycle(id: 'c1');
      expect(selectedPeriodDay(cycle, const [], DateTime(2025, 1, 1)), isNull);
    });

    test('currentPeriodDay returns today\'s slot', () {
      final today = DateHelpers.stripTime(DateTime.now());
      final start = today.subtract(const Duration(days: 9));
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 4,
        daysPerPeriod: 7,
        startDate: start,
      );
      expect(currentPeriodDay(cycle, const []), (period: 2, day: 3));
    });
  });

  group('dateForPeriodDay', () {
    test('inverts a slot via the contiguous formula', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 4,
        daysPerPeriod: 7,
        startDate: DateTime(2025, 1, 1),
      );
      expect(dateForPeriodDay(cycle, const [], 2, 3), DateTime(2025, 1, 10));
    });

    test('uses a workout scheduledDate override when present', () {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'c1',
        periodsTotal: 4,
        daysPerPeriod: 7,
        startDate: DateTime(2025, 1, 1),
      );
      final workouts = [
        TestFixtures.createWorkout(
          id: 'w1',
          trainingCycleId: 'c1',
          periodNumber: 1,
          dayNumber: 2,
          scheduledDate: DateTime(2025, 1, 5),
        ),
      ];
      expect(dateForPeriodDay(cycle, workouts, 1, 2), DateTime(2025, 1, 5));
    });
  });

  group('mergeDayData', () {
    test('appends one segment per cycle preserving each period/day', () {
      final primary = CalendarDayData(
        date: DateTime(2025, 1, 10),
        periodNumber: 2,
        dayNumber: 3,
        segments: const [
          CycleDaySegment(
            cycleId: 'c1',
            cycleName: 'A',
            periodNumber: 2,
            dayNumber: 3,
          ),
        ],
      );
      final secondary = CalendarDayData(
        date: DateTime(2025, 1, 10),
        periodNumber: 1,
        dayNumber: 5,
        segments: const [
          CycleDaySegment(
            cycleId: 'c2',
            cycleName: 'B',
            periodNumber: 1,
            dayNumber: 5,
          ),
        ],
      );

      final merged = mergeDayData(primary, secondary);

      expect(merged.segments, hasLength(2));
      // Primary's label is kept for the month-grid cell.
      expect(merged.periodNumber, 2);
      expect(merged.segments[0].cycleName, 'A');
      expect(merged.segments[1].cycleName, 'B');
      expect(merged.segments[1].periodNumber, 1);
      expect(merged.segments[1].dayNumber, 5);
    });

    test('does not duplicate a segment for the same cycle', () {
      final segment = const CycleDaySegment(
        cycleId: 'c1',
        cycleName: 'A',
        periodNumber: 1,
        dayNumber: 1,
      );
      final primary = CalendarDayData(
        date: DateTime(2025, 1, 1),
        segments: [segment],
      );
      final secondary = CalendarDayData(
        date: DateTime(2025, 1, 1),
        segments: [segment],
      );

      final merged = mergeDayData(primary, secondary);

      expect(merged.segments, hasLength(1));
    });
  });
}
