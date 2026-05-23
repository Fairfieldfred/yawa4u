import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/day_sequence.dart';

void main() {
  group('DayPosition', () {
    test('equal positions are equal', () {
      expect(const DayPosition(1, 2), equals(const DayPosition(1, 2)));
    });

    test('different positions are not equal', () {
      expect(const DayPosition(1, 2), isNot(equals(const DayPosition(1, 3))));
      expect(const DayPosition(1, 2), isNot(equals(const DayPosition(2, 2))));
    });

    test('hashCode is consistent with equality', () {
      expect(
        const DayPosition(1, 2).hashCode,
        equals(const DayPosition(1, 2).hashCode),
      );
    });

    test('toString returns P{period}D{day}', () {
      expect(const DayPosition(1, 2).toString(), 'P1D2');
      expect(const DayPosition(3, 5).toString(), 'P3D5');
    });
  });

  group('buildDaySequence', () {
    test('builds correct number of positions', () {
      final seq = buildDaySequence(2, 3);
      expect(seq, hasLength(6));
    });

    test('single period returns correct sequence', () {
      final seq = buildDaySequence(1, 3);
      expect(seq, [
        const DayPosition(1, 1),
        const DayPosition(1, 2),
        const DayPosition(1, 3),
      ]);
    });

    test('order is period-major', () {
      final seq = buildDaySequence(2, 2);
      expect(seq, [
        const DayPosition(1, 1),
        const DayPosition(1, 2),
        const DayPosition(2, 1),
        const DayPosition(2, 2),
      ]);
    });

    test('first and last positions are correct', () {
      final seq = buildDaySequence(3, 4);
      expect(seq.first, const DayPosition(1, 1));
      expect(seq.last, const DayPosition(3, 4));
    });
  });

  group('findDayIndex', () {
    final sequence = buildDaySequence(2, 3);

    test('finds existing position', () {
      expect(findDayIndex(sequence, 1, 1), 0);
      expect(findDayIndex(sequence, 1, 3), 2);
      expect(findDayIndex(sequence, 2, 1), 3);
    });

    test('returns null for non-existent position', () {
      expect(findDayIndex(sequence, 3, 1), isNull);
      expect(findDayIndex(sequence, 1, 4), isNull);
    });

    test('last position has correct index', () {
      expect(findDayIndex(sequence, 2, 3), 5);
    });
  });
}
