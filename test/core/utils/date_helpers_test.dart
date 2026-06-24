import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/date_helpers.dart';

void main() {
  group('DateHelpers', () {
    // ========== stripTime ==========

    group('stripTime', () {
      test('removes time component', () {
        final date = DateTime(2025, 6, 15, 14, 30, 45, 123, 456);
        final stripped = DateHelpers.stripTime(date);

        expect(stripped, DateTime(2025, 6, 15));
        expect(stripped.hour, 0);
        expect(stripped.minute, 0);
        expect(stripped.second, 0);
        expect(stripped.millisecond, 0);
        expect(stripped.microsecond, 0);
      });

      test('returns midnight unchanged', () {
        final date = DateTime(2025, 1, 1);
        expect(DateHelpers.stripTime(date), date);
      });
    });

    // ========== isSameDay ==========

    group('isSameDay', () {
      test('returns true for same day with different times', () {
        final d1 = DateTime(2025, 3, 15, 9, 0);
        final d2 = DateTime(2025, 3, 15, 23, 59);
        expect(DateHelpers.isSameDay(d1, d2), isTrue);
      });

      test('returns false for different days', () {
        final d1 = DateTime(2025, 3, 15);
        final d2 = DateTime(2025, 3, 16);
        expect(DateHelpers.isSameDay(d1, d2), isFalse);
      });

      test('returns false for same day in different months', () {
        final d1 = DateTime(2025, 1, 15);
        final d2 = DateTime(2025, 2, 15);
        expect(DateHelpers.isSameDay(d1, d2), isFalse);
      });

      test('returns false for same day in different years', () {
        final d1 = DateTime(2024, 6, 1);
        final d2 = DateTime(2025, 6, 1);
        expect(DateHelpers.isSameDay(d1, d2), isFalse);
      });
    });

    // ========== isToday / isTomorrow / isYesterday ==========

    group('isToday', () {
      test('returns true for now', () {
        expect(DateHelpers.isToday(DateTime.now()), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.isToday(yesterday), isFalse);
      });
    });

    group('isTomorrow', () {
      test('returns true for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(DateHelpers.isTomorrow(tomorrow), isTrue);
      });

      test('returns false for today', () {
        expect(DateHelpers.isTomorrow(DateTime.now()), isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateHelpers.isYesterday(yesterday), isTrue);
      });

      test('returns false for today', () {
        expect(DateHelpers.isYesterday(DateTime.now()), isFalse);
      });
    });

    // ========== isPast / isFuture ==========

    group('isPast', () {
      test('returns true for past date', () {
        expect(DateHelpers.isPast(DateTime(2020, 1, 1)), isTrue);
      });

      test('returns false for today', () {
        expect(DateHelpers.isPast(DateTime.now()), isFalse);
      });

      test('returns false for future date', () {
        final future = DateTime.now().add(const Duration(days: 30));
        expect(DateHelpers.isPast(future), isFalse);
      });
    });

    group('isFuture', () {
      test('returns true for future date', () {
        final future = DateTime.now().add(const Duration(days: 30));
        expect(DateHelpers.isFuture(future), isTrue);
      });

      test('returns false for today at midnight', () {
        // isFuture compares against today (midnight), so midnight
        // itself is not "after" midnight — it returns false.
        final todayMidnight = DateHelpers.stripTime(DateTime.now());
        expect(DateHelpers.isFuture(todayMidnight), isFalse);
      });

      test('returns false for past date', () {
        expect(DateHelpers.isFuture(DateTime(2020, 1, 1)), isFalse);
      });
    });

    // ========== daysBetween ==========

    group('daysBetween', () {
      test('returns 0 for same day', () {
        final date = DateTime(2025, 6, 15, 10, 30);
        expect(DateHelpers.daysBetween(date, date), 0);
      });

      test('returns positive for end after start', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 8);
        expect(DateHelpers.daysBetween(start, end), 7);
      });

      test('returns negative for end before start', () {
        final start = DateTime(2025, 1, 8);
        final end = DateTime(2025, 1, 1);
        expect(DateHelpers.daysBetween(start, end), -7);
      });

      test('ignores time component', () {
        final start = DateTime(2025, 1, 1, 23, 59);
        final end = DateTime(2025, 1, 2, 0, 1);
        expect(DateHelpers.daysBetween(start, end), 1);
      });

      test('handles month boundaries', () {
        final start = DateTime(2025, 1, 30);
        final end = DateTime(2025, 2, 2);
        expect(DateHelpers.daysBetween(start, end), 3);
      });

      test('handles year boundaries', () {
        final start = DateTime(2024, 12, 30);
        final end = DateTime(2025, 1, 2);
        expect(DateHelpers.daysBetween(start, end), 3);
      });
    });

    // ========== periodsBetween ==========

    group('periodsBetween', () {
      test('returns 0 for same day', () {
        final date = DateTime(2025, 1, 1);
        expect(DateHelpers.periodsBetween(date, date, 7), 0);
      });

      test('returns 1 for partial period', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 3); // 2 days < 7-day period
        expect(DateHelpers.periodsBetween(start, end, 7), 1);
      });

      test('returns exact periods for exact multiple', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 15); // 14 days = 2 * 7
        expect(DateHelpers.periodsBetween(start, end, 7), 2);
      });

      test('rounds up partial periods', () {
        final start = DateTime(2025, 1, 1);
        final end = DateTime(2025, 1, 16); // 15 days / 7 = 2.14 → 3
        expect(DateHelpers.periodsBetween(start, end, 7), 3);
      });
    });

    // ========== addDays ==========

    group('addDays', () {
      test('adds positive days', () {
        final date = DateTime(2025, 1, 1);
        expect(DateHelpers.addDays(date, 5), DateTime(2025, 1, 6));
      });

      test('subtracts with negative days', () {
        final date = DateTime(2025, 1, 10);
        expect(DateHelpers.addDays(date, -3), DateTime(2025, 1, 7));
      });

      test('handles month rollover', () {
        final date = DateTime(2025, 1, 30);
        expect(DateHelpers.addDays(date, 3), DateTime(2025, 2, 2));
      });
    });

    // ========== addPeriods ==========

    group('addPeriods', () {
      test('adds one 7-day period', () {
        final date = DateTime(2025, 1, 1);
        expect(
          DateHelpers.addPeriods(date, 1, 7),
          DateTime(2025, 1, 8),
        );
      });

      test('adds multiple periods', () {
        final date = DateTime(2025, 1, 1);
        expect(
          DateHelpers.addPeriods(date, 4, 7),
          DateTime(2025, 1, 29),
        );
      });

      test('handles non-7-day periods', () {
        final date = DateTime(2025, 1, 1);
        // 3 periods of 5 days = 15 days
        expect(
          DateHelpers.addPeriods(date, 3, 5),
          DateTime(2025, 1, 16),
        );
      });
    });

    // ========== addMonths ==========

    group('addMonths', () {
      test('adds one month', () {
        final date = DateTime(2025, 1, 15);
        expect(DateHelpers.addMonths(date, 1), DateTime(2025, 2, 15));
      });

      test('adds multiple months', () {
        final date = DateTime(2025, 1, 15);
        expect(DateHelpers.addMonths(date, 6), DateTime(2025, 7, 15));
      });

      test('handles year rollover', () {
        final date = DateTime(2025, 11, 15);
        expect(DateHelpers.addMonths(date, 3), DateTime(2026, 2, 15));
      });

      test('clamps day overflow — Jan 31 + 1 month = Feb 28', () {
        final date = DateTime(2025, 1, 31);
        expect(DateHelpers.addMonths(date, 1), DateTime(2025, 2, 28));
      });

      test('clamps day overflow — leap year Feb 29', () {
        final date = DateTime(2024, 1, 31);
        // 2024 is a leap year
        expect(DateHelpers.addMonths(date, 1), DateTime(2024, 2, 29));
      });

      test('clamps day overflow — Mar 31 + 1 = Apr 30', () {
        final date = DateTime(2025, 3, 31);
        expect(DateHelpers.addMonths(date, 1), DateTime(2025, 4, 30));
      });

      test('preserves time component', () {
        final date = DateTime(2025, 1, 15, 14, 30, 45);
        final result = DateHelpers.addMonths(date, 1);
        expect(result.hour, 14);
        expect(result.minute, 30);
        expect(result.second, 45);
      });

      test('handles adding 12 months (full year)', () {
        final date = DateTime(2025, 6, 15);
        expect(
          DateHelpers.addMonths(date, 12),
          DateTime(2026, 6, 15),
        );
      });

      test('handles adding 0 months', () {
        final date = DateTime(2025, 6, 15);
        expect(DateHelpers.addMonths(date, 0), DateTime(2025, 6, 15));
      });
    });

    // ========== getTrainingCycleEndDate ==========

    group('getTrainingCycleEndDate', () {
      test('calculates end date for 4 periods of 7 days', () {
        final start = DateTime(2025, 1, 1);
        // 4 * 7 = 28 days, end = start + 27
        final end = DateHelpers.getTrainingCycleEndDate(start, 4, 7);
        expect(end, DateTime(2025, 1, 28));
      });

      test('calculates end date for 1 period of 5 days', () {
        final start = DateTime(2025, 3, 1);
        // 1 * 5 = 5, end = start + 4
        final end = DateHelpers.getTrainingCycleEndDate(start, 1, 5);
        expect(end, DateTime(2025, 3, 5));
      });

      test('end date spans month boundary', () {
        final start = DateTime(2025, 1, 25);
        // 2 * 7 = 14 days, end = start + 13 = Feb 7
        final end = DateHelpers.getTrainingCycleEndDate(start, 2, 7);
        expect(end, DateTime(2025, 2, 7));
      });
    });

    // ========== getWorkoutDate ==========

    group('getWorkoutDate', () {
      test('first day of first period is cycle start', () {
        final start = DateTime(2025, 1, 1);
        expect(
          DateHelpers.getWorkoutDate(start, 1, 1, 7),
          DateTime(2025, 1, 1),
        );
      });

      test('second day of first period', () {
        final start = DateTime(2025, 1, 1);
        expect(
          DateHelpers.getWorkoutDate(start, 1, 2, 7),
          DateTime(2025, 1, 2),
        );
      });

      test('first day of second period', () {
        final start = DateTime(2025, 1, 1);
        // Period 2, day 1, 7-day periods → offset = 7
        expect(
          DateHelpers.getWorkoutDate(start, 2, 1, 7),
          DateTime(2025, 1, 8),
        );
      });

      test('last day of cycle (4 periods, 5 days each)', () {
        final start = DateTime(2025, 1, 1);
        // Period 4, day 5 → offset = 3*5 + 4 = 19
        expect(
          DateHelpers.getWorkoutDate(start, 4, 5, 5),
          DateTime(2025, 1, 20),
        );
      });
    });

    // ========== getCurrentPeriod ==========

    group('getCurrentPeriod', () {
      test('returns null for date before cycle start', () {
        final start = DateTime(2025, 3, 1);
        final before = DateTime(2025, 2, 28);
        expect(
          DateHelpers.getCurrentPeriod(start, before, 7),
          isNull,
        );
      });

      test('returns 1 for cycle start date', () {
        final start = DateTime(2025, 3, 1);
        expect(DateHelpers.getCurrentPeriod(start, start, 7), 1);
      });

      test('returns 1 for within first period', () {
        final start = DateTime(2025, 3, 1);
        final day3 = DateTime(2025, 3, 3);
        expect(DateHelpers.getCurrentPeriod(start, day3, 7), 1);
      });

      test('returns 2 for first day of second period', () {
        final start = DateTime(2025, 3, 1);
        final day8 = DateTime(2025, 3, 8); // offset = 7
        expect(DateHelpers.getCurrentPeriod(start, day8, 7), 2);
      });

      test('returns correct period for 5-day periods', () {
        final start = DateTime(2025, 1, 1);
        // Day 11 → offset = 10 → 10 ~/ 5 + 1 = 3
        final day11 = DateTime(2025, 1, 11);
        expect(DateHelpers.getCurrentPeriod(start, day11, 5), 3);
      });
    });

    // ========== buildPeriodDayDateMap ==========

    group('buildPeriodDayDateMap', () {
      test('builds contiguous map with no overrides', () {
        final start = DateTime(2025, 1, 1);
        final map = DateHelpers.buildPeriodDayDateMap(
          cycleStart: start,
          daysPerPeriod: 3,
          periodsTotal: 2,
        );

        expect(map[(1, 1)], DateTime(2025, 1, 1));
        expect(map[(1, 2)], DateTime(2025, 1, 2));
        expect(map[(1, 3)], DateTime(2025, 1, 3));
        expect(map[(2, 1)], DateTime(2025, 1, 4));
        expect(map[(2, 2)], DateTime(2025, 1, 5));
        expect(map[(2, 3)], DateTime(2025, 1, 6));
        expect(map.length, 6);
      });

      test('respects scheduled date overrides', () {
        final start = DateTime(2025, 1, 1);
        final overrides = <(int, int), DateTime>{
          (1, 2): DateTime(2025, 1, 5), // Shifted from Jan 2 to Jan 5
        };
        final map = DateHelpers.buildPeriodDayDateMap(
          cycleStart: start,
          daysPerPeriod: 3,
          periodsTotal: 1,
          scheduledDates: overrides,
        );

        expect(map[(1, 1)], DateTime(2025, 1, 1)); // Formula
        expect(map[(1, 2)], DateTime(2025, 1, 5)); // Override
        expect(map[(1, 3)], DateTime(2025, 1, 3)); // Formula
      });

      test('strips time from cycle start', () {
        final start = DateTime(2025, 1, 1, 14, 30);
        final map = DateHelpers.buildPeriodDayDateMap(
          cycleStart: start,
          daysPerPeriod: 1,
          periodsTotal: 1,
        );

        expect(map[(1, 1)]!.hour, 0);
        expect(map[(1, 1)]!.minute, 0);
      });
    });

    // ========== extractScheduledDates ==========

    group('extractScheduledDates', () {
      test('extracts non-null scheduled dates', () {
        final items = [
          (
            periodNumber: 1,
            dayNumber: 1,
            scheduledDate: DateTime(2025, 1, 5) as DateTime?,
          ),
          (
            periodNumber: 1,
            dayNumber: 2,
            scheduledDate: null as DateTime?,
          ),
          (
            periodNumber: 2,
            dayNumber: 1,
            scheduledDate: DateTime(2025, 1, 15) as DateTime?,
          ),
        ];

        final result = DateHelpers.extractScheduledDates(items);

        expect(result.length, 2);
        expect(result[(1, 1)], DateTime(2025, 1, 5));
        expect(result[(2, 1)], DateTime(2025, 1, 15));
        expect(result.containsKey((1, 2)), isFalse);
      });

      test('returns empty map for no scheduled dates', () {
        final items = [
          (
            periodNumber: 1,
            dayNumber: 1,
            scheduledDate: null as DateTime?,
          ),
        ];

        final result = DateHelpers.extractScheduledDates(items);
        expect(result, isEmpty);
      });

      test('strips time from extracted dates', () {
        final items = [
          (
            periodNumber: 1,
            dayNumber: 1,
            scheduledDate: DateTime(2025, 1, 5, 14, 30) as DateTime?,
          ),
        ];

        final result = DateHelpers.extractScheduledDates(items);
        expect(result[(1, 1)]!.hour, 0);
      });

      test('uses putIfAbsent — keeps first occurrence for duplicate keys', () {
        final items = [
          (
            periodNumber: 1,
            dayNumber: 1,
            scheduledDate: DateTime(2025, 1, 5) as DateTime?,
          ),
          (
            periodNumber: 1,
            dayNumber: 1,
            scheduledDate: DateTime(2025, 1, 10) as DateTime?,
          ),
        ];

        final result = DateHelpers.extractScheduledDates(items);
        expect(result[(1, 1)], DateTime(2025, 1, 5)); // First wins
      });
    });

    // ========== getDayInfo ==========

    group('getDayInfo', () {
      test('returns correct day name and day of month', () {
        // 2025-01-06 is a Monday
        final dateMap = <(int, int), DateTime>{
          (1, 1): DateTime(2025, 1, 6),
        };

        final info = DateHelpers.getDayInfo(dateMap, 1, 1);
        expect(info.dayName, 'MON');
        expect(info.dayOfMonth, 6);
      });

      test('returns Sunday correctly', () {
        // 2025-01-05 is a Sunday
        final dateMap = <(int, int), DateTime>{
          (1, 1): DateTime(2025, 1, 5),
        };

        final info = DateHelpers.getDayInfo(dateMap, 1, 1);
        expect(info.dayName, 'SUN');
        expect(info.dayOfMonth, 5);
      });

      test('returns fallback when date not in map', () {
        final dateMap = <(int, int), DateTime>{};
        final info = DateHelpers.getDayInfo(dateMap, 1, 3);

        // Fallback: dayOfWeekNames[3 % 7] = 'WED'
        expect(info.dayName, 'WED');
        expect(info.dayOfMonth, 0); // Sentinel value
      });
    });

    // ========== getEffectiveWorkoutDate ==========

    group('getEffectiveWorkoutDate', () {
      test('uses scheduledDate when provided', () {
        final result = DateHelpers.getEffectiveWorkoutDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 7,
          periodNumber: 1,
          dayNumber: 1,
          scheduledDate: DateTime(2025, 2, 15, 10, 30),
        );

        expect(result, DateTime(2025, 2, 15)); // Stripped time
      });

      test('falls back to formula when no scheduledDate', () {
        final result = DateHelpers.getEffectiveWorkoutDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 7,
          periodNumber: 2,
          dayNumber: 3,
          scheduledDate: null,
        );

        // Offset = (2-1)*7 + (3-1) = 9
        expect(result, DateTime(2025, 1, 10));
      });

      test('strips time from cycle start in formula path', () {
        final result = DateHelpers.getEffectiveWorkoutDate(
          cycleStart: DateTime(2025, 1, 1, 18, 45),
          daysPerPeriod: 7,
          periodNumber: 1,
          dayNumber: 1,
        );

        expect(result.hour, 0);
        expect(result.minute, 0);
      });
    });

    // ========== periodDayForDate ==========

    group('periodDayForDate', () {
      test('returns the contiguous slot for an in-cycle date', () {
        final result = DateHelpers.periodDayForDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 7,
          periodsTotal: 4,
          date: DateTime(2025, 1, 10),
        );
        // Offset 9 → period 2, day 3.
        expect(result, (period: 2, day: 3));
      });

      test('round-trips with buildPeriodDayDateMap', () {
        final map = DateHelpers.buildPeriodDayDateMap(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 5,
          periodsTotal: 3,
        );
        for (final entry in map.entries) {
          final result = DateHelpers.periodDayForDate(
            cycleStart: DateTime(2025, 1, 1),
            daysPerPeriod: 5,
            periodsTotal: 3,
            date: entry.value,
          );
          expect(result, (period: entry.key.$1, day: entry.key.$2));
        }
      });

      test('honors schedule shifts (inserted rest day)', () {
        // Period 1 / Day 3 shifted one day later via scheduledDate.
        final scheduled = {
          (1, 3): DateTime(2025, 1, 4),
        };
        final result = DateHelpers.periodDayForDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 3,
          periodsTotal: 2,
          date: DateTime(2025, 1, 4),
          scheduledDates: scheduled,
        );
        expect(result, (period: 1, day: 3));
      });

      test('returns null before the cycle start', () {
        final result = DateHelpers.periodDayForDate(
          cycleStart: DateTime(2025, 1, 10),
          daysPerPeriod: 7,
          periodsTotal: 4,
          date: DateTime(2025, 1, 1),
        );
        expect(result, isNull);
      });

      test('returns null beyond the last period', () {
        final result = DateHelpers.periodDayForDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 7,
          periodsTotal: 2,
          date: DateTime(2025, 3, 1),
        );
        expect(result, isNull);
      });

      test('strips time on the queried date', () {
        final result = DateHelpers.periodDayForDate(
          cycleStart: DateTime(2025, 1, 1),
          daysPerPeriod: 7,
          periodsTotal: 4,
          date: DateTime(2025, 1, 1, 23, 59),
        );
        expect(result, (period: 1, day: 1));
      });
    });

    // ========== maxDayPerPeriod ==========

    group('maxDayPerPeriod', () {
      test('returns max day per period', () {
        final items = [
          (periodNumber: 1, dayNumber: 1),
          (periodNumber: 1, dayNumber: 3),
          (periodNumber: 1, dayNumber: 5),
          (periodNumber: 2, dayNumber: 2),
          (periodNumber: 2, dayNumber: 4),
        ];

        final result = DateHelpers.maxDayPerPeriod(items);
        expect(result[1], 5);
        expect(result[2], 4);
      });

      test('returns empty map for empty input', () {
        final result = DateHelpers.maxDayPerPeriod([]);
        expect(result, isEmpty);
      });

      test('handles single item per period', () {
        final items = [
          (periodNumber: 1, dayNumber: 3),
          (periodNumber: 2, dayNumber: 1),
        ];

        final result = DateHelpers.maxDayPerPeriod(items);
        expect(result[1], 3);
        expect(result[2], 1);
      });
    });

    // ========== getRelativeDateString ==========

    group('getRelativeDateString', () {
      test('returns "Today" for today', () {
        expect(
          DateHelpers.getRelativeDateString(DateTime.now()),
          'Today',
        );
      });

      test('returns "Yesterday" for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(
          DateHelpers.getRelativeDateString(yesterday),
          'Yesterday',
        );
      });

      test('returns "Tomorrow" for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(
          DateHelpers.getRelativeDateString(tomorrow),
          'Tomorrow',
        );
      });

      test('returns "X days ago" for 2-6 days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(
          DateHelpers.getRelativeDateString(threeDaysAgo),
          '3 days ago',
        );
      });

      test('returns "In X days" for 2-6 days in the future', () {
        final inFiveDays = DateTime.now().add(const Duration(days: 5));
        expect(
          DateHelpers.getRelativeDateString(inFiveDays),
          'In 5 days',
        );
      });

      test('returns "X weeks ago" for 1-3 weeks ago', () {
        final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
        expect(
          DateHelpers.getRelativeDateString(twoWeeksAgo),
          '2 weeks ago',
        );
      });

      test('returns "1 week ago" singular', () {
        final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
        expect(
          DateHelpers.getRelativeDateString(oneWeekAgo),
          '1 week ago',
        );
      });

      test('returns formatted date for > 4 weeks', () {
        final longAgo = DateTime.now().subtract(const Duration(days: 60));
        final result = DateHelpers.getRelativeDateString(longAgo);
        // Should be a formatted date string like "Mar 22, 2025"
        expect(result, isNot('Today'));
        expect(result, isNot(contains('ago')));
      });
    });

    // ========== getLastPerformedString ==========

    group('getLastPerformedString', () {
      test('returns empty string for null', () {
        expect(DateHelpers.getLastPerformedString(null), '');
      });

      test('returns formatted string for date', () {
        final date = DateTime(2025, 10, 31);
        expect(
          DateHelpers.getLastPerformedString(date),
          'Last performed 10/31/2025',
        );
      });
    });

    // ========== formatDuration ==========

    group('formatDuration', () {
      test('formats seconds only', () {
        expect(DateHelpers.formatDuration(45), '45s');
      });

      test('formats minutes and seconds', () {
        expect(DateHelpers.formatDuration(330), '5m 30s');
      });

      test('formats hours, minutes, and seconds', () {
        expect(DateHelpers.formatDuration(5025), '1h 23m 45s');
      });

      test('formats exact hours', () {
        expect(DateHelpers.formatDuration(3600), '1h');
      });

      test('formats exact minutes', () {
        expect(DateHelpers.formatDuration(120), '2m');
      });

      test('formats zero seconds', () {
        expect(DateHelpers.formatDuration(0), '0s');
      });

      test('formats hours and seconds with no minutes', () {
        expect(DateHelpers.formatDuration(3605), '1h 5s');
      });
    });

    // ========== formatDurationObject ==========

    group('formatDurationObject', () {
      test('delegates to formatDuration', () {
        expect(
          DateHelpers.formatDurationObject(
            const Duration(hours: 1, minutes: 30),
          ),
          '1h 30m',
        );
      });
    });

    // ========== isValidTrainingCycleStartDate ==========

    group('isValidTrainingCycleStartDate', () {
      test('returns true for today', () {
        expect(
          DateHelpers.isValidTrainingCycleStartDate(DateTime.now()),
          isTrue,
        );
      });

      test('returns true for future date', () {
        final future = DateTime.now().add(const Duration(days: 30));
        expect(
          DateHelpers.isValidTrainingCycleStartDate(future),
          isTrue,
        );
      });

      test('returns false for past date', () {
        expect(
          DateHelpers.isValidTrainingCycleStartDate(
            DateTime(2020, 1, 1),
          ),
          isFalse,
        );
      });
    });

    // ========== isValidDateRange ==========

    group('isValidDateRange', () {
      test('returns true when end is after start', () {
        expect(
          DateHelpers.isValidDateRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 1, 31),
          ),
          isTrue,
        );
      });

      test('returns true for same-day range', () {
        final date = DateTime(2025, 6, 15);
        expect(DateHelpers.isValidDateRange(date, date), isTrue);
      });

      test('returns false when end is before start', () {
        expect(
          DateHelpers.isValidDateRange(
            DateTime(2025, 6, 15),
            DateTime(2025, 6, 1),
          ),
          isFalse,
        );
      });
    });

    // ========== dayOfWeekNames ==========

    group('dayOfWeekNames', () {
      test('has 7 entries', () {
        expect(DateHelpers.dayOfWeekNames.length, 7);
      });

      test('starts with SUN at index 0', () {
        expect(DateHelpers.dayOfWeekNames[0], 'SUN');
      });

      test('ends with SAT at index 6', () {
        expect(DateHelpers.dayOfWeekNames[6], 'SAT');
      });
    });
  });
}
