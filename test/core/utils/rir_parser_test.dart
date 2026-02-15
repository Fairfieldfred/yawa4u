import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/rir_parser.dart';

void main() {
  group('RIRParser', () {
    group('isRIR', () {
      test('recognizes standard RIR format', () {
        expect(RIRParser.isRIR('2 RIR'), isTrue);
        expect(RIRParser.isRIR('0 RIR'), isTrue);
        expect(RIRParser.isRIR('5 RIR'), isTrue);
        expect(RIRParser.isRIR('10 RIR'), isTrue);
      });

      test('is case insensitive', () {
        expect(RIRParser.isRIR('2 rir'), isTrue);
        expect(RIRParser.isRIR('2 Rir'), isTrue);
        expect(RIRParser.isRIR('2 rIR'), isTrue);
      });

      test('handles no space between number and RIR', () {
        expect(RIRParser.isRIR('2RIR'), isTrue);
        expect(RIRParser.isRIR('0RIR'), isTrue);
      });

      test('handles leading/trailing whitespace', () {
        expect(RIRParser.isRIR(' 2 RIR '), isTrue);
        expect(RIRParser.isRIR('  3 RIR  '), isTrue);
      });

      test('rejects plain numbers', () {
        expect(RIRParser.isRIR('8'), isFalse);
        expect(RIRParser.isRIR('12'), isFalse);
        expect(RIRParser.isRIR('0'), isFalse);
      });

      test('rejects invalid formats', () {
        expect(RIRParser.isRIR('RIR'), isFalse);
        expect(RIRParser.isRIR('RIR 2'), isFalse);
        expect(RIRParser.isRIR('abc'), isFalse);
        expect(RIRParser.isRIR(''), isFalse);
      });
    });

    group('parseRIR', () {
      test('extracts RIR value from valid format', () {
        expect(RIRParser.parseRIR('2 RIR'), equals(2));
        expect(RIRParser.parseRIR('0 RIR'), equals(0));
        expect(RIRParser.parseRIR('5 RIR'), equals(5));
        expect(RIRParser.parseRIR('10 RIR'), equals(10));
      });

      test('returns null for non-RIR strings', () {
        expect(RIRParser.parseRIR('8'), isNull);
        expect(RIRParser.parseRIR('abc'), isNull);
        expect(RIRParser.parseRIR(''), isNull);
      });
    });

    group('parseReps', () {
      test('parses plain numbers as reps', () {
        final result = RIRParser.parseReps('8');
        expect(result.reps, equals(8));
        expect(result.rir, isNull);
      });

      test('parses RIR format', () {
        final result = RIRParser.parseReps('2 RIR');
        expect(result.reps, isNull);
        expect(result.rir, equals(2));
      });

      test('returns both null for invalid input', () {
        final result = RIRParser.parseReps('abc');
        expect(result.reps, isNull);
        expect(result.rir, isNull);
      });
    });

    group('formatRIR', () {
      test('formats RIR value correctly', () {
        expect(RIRParser.formatRIR(0), equals('0 RIR'));
        expect(RIRParser.formatRIR(2), equals('2 RIR'));
        expect(RIRParser.formatRIR(5), equals('5 RIR'));
      });
    });

    group('formatRepsDisplay', () {
      test('passes through plain numbers', () {
        expect(RIRParser.formatRepsDisplay('8'), equals('8'));
        expect(RIRParser.formatRepsDisplay('12'), equals('12'));
      });

      test('normalizes RIR format', () {
        expect(RIRParser.formatRepsDisplay('2 RIR'), equals('2 RIR'));
        expect(RIRParser.formatRepsDisplay('2rir'), equals('2 RIR'));
        expect(RIRParser.formatRepsDisplay('2RIR'), equals('2 RIR'));
      });

      test('trims whitespace', () {
        expect(RIRParser.formatRepsDisplay('  8  '), equals('8'));
      });
    });

    group('calculateRIR', () {
      test('calculates RIR from reps and max', () {
        expect(RIRParser.calculateRIR(8, 10), equals(2));
        expect(RIRParser.calculateRIR(10, 10), equals(0));
        expect(RIRParser.calculateRIR(5, 10), equals(5));
      });

      test('clamps negative RIR to 0', () {
        expect(RIRParser.calculateRIR(12, 10), equals(0));
      });
    });

    group('rirToRepsTarget', () {
      test('converts RIR to reps target', () {
        expect(RIRParser.rirToRepsTarget(2, 10), equals(8));
        expect(RIRParser.rirToRepsTarget(0, 10), equals(10));
      });

      test('clamps negative target to 0', () {
        expect(RIRParser.rirToRepsTarget(15, 10), equals(0));
      });
    });

    group('isValidRIR', () {
      test('accepts 0-10', () {
        expect(RIRParser.isValidRIR(0), isTrue);
        expect(RIRParser.isValidRIR(5), isTrue);
        expect(RIRParser.isValidRIR(10), isTrue);
      });

      test('rejects out of range', () {
        expect(RIRParser.isValidRIR(-1), isFalse);
        expect(RIRParser.isValidRIR(11), isFalse);
      });
    });

    group('validateRIR', () {
      test('returns null for valid RIR', () {
        expect(RIRParser.validateRIR(0), isNull);
        expect(RIRParser.validateRIR(5), isNull);
      });

      test('returns error message for invalid RIR', () {
        expect(RIRParser.validateRIR(-1), isNotNull);
        expect(RIRParser.validateRIR(11), isNotNull);
      });
    });

    group('compareReps', () {
      test('compares regular reps', () {
        expect(RIRParser.compareReps('8', '10'), lessThan(0));
        expect(RIRParser.compareReps('10', '8'), greaterThan(0));
        expect(RIRParser.compareReps('8', '8'), equals(0));
      });

      test('compares RIR values (lower RIR = harder = greater)', () {
        expect(RIRParser.compareReps('0 RIR', '2 RIR'), greaterThan(0));
        expect(RIRParser.compareReps('2 RIR', '0 RIR'), lessThan(0));
        expect(RIRParser.compareReps('2 RIR', '2 RIR'), equals(0));
      });

      test('returns 0 for mixed types', () {
        expect(RIRParser.compareReps('8', '2 RIR'), equals(0));
        expect(RIRParser.compareReps('2 RIR', '8'), equals(0));
      });
    });

    group('getRIRExplanation', () {
      test('returns failure explanation for 0', () {
        expect(RIRParser.getRIRExplanation(0), contains('failure'));
      });

      test('returns singular for 1', () {
        expect(RIRParser.getRIRExplanation(1), contains('1 more rep'));
      });

      test('returns plural for 2+', () {
        expect(RIRParser.getRIRExplanation(3), contains('3 more reps'));
      });
    });

    group('getRIRDifficulty', () {
      test('returns correct difficulty labels', () {
        expect(RIRParser.getRIRDifficulty(0), equals('Maximum Effort'));
        expect(RIRParser.getRIRDifficulty(1), equals('Very Hard'));
        expect(RIRParser.getRIRDifficulty(2), equals('Hard'));
        expect(RIRParser.getRIRDifficulty(3), equals('Moderate'));
        expect(RIRParser.getRIRDifficulty(4), equals('Easy'));
        expect(RIRParser.getRIRDifficulty(5), equals('Easy'));
      });
    });

    group('isCloseToFailure', () {
      test('returns true for 0-2 RIR', () {
        expect(RIRParser.isCloseToFailure('0 RIR'), isTrue);
        expect(RIRParser.isCloseToFailure('1 RIR'), isTrue);
        expect(RIRParser.isCloseToFailure('2 RIR'), isTrue);
      });

      test('returns false for 3+ RIR', () {
        expect(RIRParser.isCloseToFailure('3 RIR'), isFalse);
        expect(RIRParser.isCloseToFailure('5 RIR'), isFalse);
      });

      test('returns false for non-RIR', () {
        expect(RIRParser.isCloseToFailure('8'), isFalse);
      });
    });

    group('getRIREffortLevel', () {
      test('returns correct effort levels', () {
        expect(RIRParser.getRIREffortLevel(0), equals('high'));
        expect(RIRParser.getRIREffortLevel(1), equals('high'));
        expect(RIRParser.getRIREffortLevel(2), equals('medium'));
        expect(RIRParser.getRIREffortLevel(3), equals('medium'));
        expect(RIRParser.getRIREffortLevel(4), equals('low'));
      });
    });

    group('getRecommendedRIRForPeriod', () {
      test('progresses from 3 to 0 across non-recovery periods', () {
        // 5 periods total, last is recovery
        expect(RIRParser.getRecommendedRIRForPeriod(1, 5), equals(3));
        expect(RIRParser.getRecommendedRIRForPeriod(4, 5), equals(0));
      });

      test('returns high RIR for recovery period', () {
        expect(RIRParser.getRecommendedRIRForPeriod(5, 5), equals(8));
      });

      test('handles single period cycle', () {
        // When nonRecoveryPeriods <= 1, returns 2
        expect(RIRParser.getRecommendedRIRForPeriod(1, 2), equals(2));
      });
    });

    group('normalizeRepsInput', () {
      test('passes through plain numbers', () {
        expect(RIRParser.normalizeRepsInput('8'), equals('8'));
        expect(RIRParser.normalizeRepsInput('12'), equals('12'));
      });

      test('normalizes standard RIR format', () {
        expect(RIRParser.normalizeRepsInput('2 RIR'), equals('2 RIR'));
        expect(RIRParser.normalizeRepsInput('2rir'), equals('2 RIR'));
        expect(RIRParser.normalizeRepsInput('2RIR'), equals('2 RIR'));
      });

      test('handles R-prefix shorthand', () {
        expect(RIRParser.normalizeRepsInput('R2'), equals('2 RIR'));
        expect(RIRParser.normalizeRepsInput('r3'), equals('3 RIR'));
      });

      test('trims whitespace', () {
        expect(RIRParser.normalizeRepsInput('  8  '), equals('8'));
      });
    });
  });
}
