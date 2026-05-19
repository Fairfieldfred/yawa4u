import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/domain/providers/session_providers.dart';

void main() {
  // Pure-function unit tests for the day-range helper used by
  // [todaysSessionsProvider]. The provider itself wraps this helper
  // around `DateTime.now()`, so asserting the helper's boundary
  // behavior keeps midnight-rollover logic from silently drifting.
  group('dayRangeContaining', () {
    test('start is midnight of the given day, local time', () {
      final at = DateTime(2026, 4, 22, 14, 37, 12);
      final range = dayRangeContaining(at);
      expect(range.start, DateTime(2026, 4, 22, 0, 0, 0, 0));
    });

    test('end is one microsecond before the next midnight', () {
      final at = DateTime(2026, 4, 22, 14, 37);
      final range = dayRangeContaining(at);
      // Next midnight minus one microsecond.
      final expected = DateTime(2026, 4, 23, 0, 0, 0, 0).subtract(const Duration(microseconds: 1));
      expect(range.end, expected);
    });

    test('range includes midnight of the given day', () {
      final at = DateTime(2026, 4, 22, 12);
      final range = dayRangeContaining(at);
      final midnight = DateTime(2026, 4, 22);
      // Low bound is inclusive — midnight should not be before start.
      expect(midnight.isBefore(range.start), isFalse);
      expect(midnight == range.start, isTrue);
    });

    test('range excludes midnight of the following day', () {
      final at = DateTime(2026, 4, 22, 12);
      final range = dayRangeContaining(at);
      final nextMidnight = DateTime(2026, 4, 23);
      // High bound is inclusive — tomorrow's midnight must be AFTER end.
      expect(nextMidnight.isAfter(range.end), isTrue);
    });

    test('handles the last moment of the day as the same day', () {
      // 23:59:59.999999 on April 22 should still bucket into April 22.
      final at = DateTime(2026, 4, 22, 23, 59, 59, 999, 999);
      final range = dayRangeContaining(at);
      expect(range.start, DateTime(2026, 4, 22));
      // The input is exactly range.end.
      expect(at == range.end, isTrue);
    });

    test('handles a time one microsecond after midnight as the new day', () {
      final at = DateTime(2026, 4, 23, 0, 0, 0, 0, 1);
      final range = dayRangeContaining(at);
      expect(range.start, DateTime(2026, 4, 23));
    });

    test('handles leap-day boundary', () {
      final at = DateTime(2028, 2, 29, 10);
      final range = dayRangeContaining(at);
      expect(range.start, DateTime(2028, 2, 29));
      expect(
        range.end,
        DateTime(2028, 3, 1).subtract(const Duration(microseconds: 1)),
      );
    });
  });
}
