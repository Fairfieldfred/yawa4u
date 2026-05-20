import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/validators.dart';

void main() {
  group('Validators', () {
    // ========== GENERAL VALIDATORS ==========

    group('required', () {
      test('returns error for null', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('returns null for valid input', () {
        expect(Validators.required('hello'), isNull);
      });

      test('uses custom field name in error message', () {
        expect(
          Validators.required(null, fieldName: 'Name'),
          'Name is required',
        );
      });

      test('uses default field name', () {
        expect(Validators.required(null), 'This field is required');
      });
    });

    group('minLength', () {
      test('returns null for null input', () {
        expect(Validators.minLength(null, 3), isNull);
      });

      test('returns null for empty input', () {
        expect(Validators.minLength('', 3), isNull);
      });

      test('returns error when too short', () {
        expect(Validators.minLength('ab', 3), isNotNull);
      });

      test('returns null for exact length', () {
        expect(Validators.minLength('abc', 3), isNull);
      });

      test('returns null for longer than min', () {
        expect(Validators.minLength('abcdef', 3), isNull);
      });
    });

    group('maxLength', () {
      test('returns null for null input', () {
        expect(Validators.maxLength(null, 5), isNull);
      });

      test('returns null for empty input', () {
        expect(Validators.maxLength('', 5), isNull);
      });

      test('returns null for exact length', () {
        expect(Validators.maxLength('abcde', 5), isNull);
      });

      test('returns error when too long', () {
        expect(Validators.maxLength('abcdef', 5), isNotNull);
      });

      test('returns null for shorter than max', () {
        expect(Validators.maxLength('ab', 5), isNull);
      });
    });

    group('combine', () {
      test('returns null when all validators pass', () {
        final result = Validators.combine('hello', [
          (v) => Validators.required(v),
          (v) => Validators.minLength(v, 3),
        ]);
        expect(result, isNull);
      });

      test('returns first error when multiple fail', () {
        final result = Validators.combine('', [
          (v) => Validators.required(v),
          (v) => Validators.minLength(v, 3),
        ]);
        // required fails first
        expect(result, contains('required'));
      });

      test('returns second error when first passes', () {
        final result = Validators.combine('ab', [
          (v) => Validators.required(v),
          (v) => Validators.minLength(v, 5),
        ]);
        expect(result, contains('at least 5'));
      });

      test('returns null for empty validator list', () {
        expect(Validators.combine('anything', []), isNull);
      });
    });

    // ========== NUMBER VALIDATORS ==========

    group('isNumber', () {
      test('returns null for null input', () {
        expect(Validators.isNumber(null), isNull);
      });

      test('returns null for empty input', () {
        expect(Validators.isNumber(''), isNull);
      });

      test('accepts integers', () {
        expect(Validators.isNumber('42'), isNull);
      });

      test('accepts decimals', () {
        expect(Validators.isNumber('3.14'), isNull);
      });

      test('accepts negative numbers', () {
        expect(Validators.isNumber('-5'), isNull);
      });

      test('rejects non-numeric strings', () {
        expect(Validators.isNumber('abc'), isNotNull);
      });

      test('rejects mixed strings', () {
        expect(Validators.isNumber('12abc'), isNotNull);
      });
    });

    group('isInteger', () {
      test('returns null for null input', () {
        expect(Validators.isInteger(null), isNull);
      });

      test('accepts integers', () {
        expect(Validators.isInteger('42'), isNull);
      });

      test('rejects decimals', () {
        expect(Validators.isInteger('3.14'), isNotNull);
      });

      test('rejects non-numeric strings', () {
        expect(Validators.isInteger('abc'), isNotNull);
      });
    });

    group('numberRange', () {
      test('returns null for null input', () {
        expect(Validators.numberRange(null, 1, 10), isNull);
      });

      test('returns null for value in range', () {
        expect(Validators.numberRange('5', 1, 10), isNull);
      });

      test('returns null for value at min boundary', () {
        expect(Validators.numberRange('1', 1, 10), isNull);
      });

      test('returns null for value at max boundary', () {
        expect(Validators.numberRange('10', 1, 10), isNull);
      });

      test('returns error for value below min', () {
        expect(Validators.numberRange('0', 1, 10), isNotNull);
      });

      test('returns error for value above max', () {
        expect(Validators.numberRange('11', 1, 10), isNotNull);
      });

      test('returns error for non-numeric value', () {
        expect(Validators.numberRange('abc', 1, 10), isNotNull);
      });
    });

    group('isPositive', () {
      test('returns null for positive number', () {
        expect(Validators.isPositive('5'), isNull);
      });

      test('returns error for zero', () {
        expect(Validators.isPositive('0'), isNotNull);
      });

      test('returns error for negative number', () {
        expect(Validators.isPositive('-1'), isNotNull);
      });

      test('returns null for null input', () {
        expect(Validators.isPositive(null), isNull);
      });

      test('returns error for non-numeric string', () {
        expect(Validators.isPositive('abc'), isNotNull);
      });
    });

    group('isNonNegative', () {
      test('returns null for positive number', () {
        expect(Validators.isNonNegative('5'), isNull);
      });

      test('returns null for zero', () {
        expect(Validators.isNonNegative('0'), isNull);
      });

      test('returns error for negative number', () {
        expect(Validators.isNonNegative('-1'), isNotNull);
      });

      test('returns null for null input', () {
        expect(Validators.isNonNegative(null), isNull);
      });
    });

    // ========== TRAINING CYCLE VALIDATORS ==========

    group('trainingCycleName', () {
      test('returns error for empty name', () {
        expect(Validators.trainingCycleName(''), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.trainingCycleName('My Cycle'), isNull);
      });

      test('returns error for name exceeding 100 chars', () {
        final longName = 'A' * 101;
        expect(Validators.trainingCycleName(longName), isNotNull);
      });

      test('returns null for 100-char name', () {
        final exactName = 'A' * 100;
        expect(Validators.trainingCycleName(exactName), isNull);
      });
    });

    group('weeks', () {
      test('returns error for empty value', () {
        expect(Validators.weeks(''), isNotNull);
      });

      test('returns null for valid week count', () {
        expect(Validators.weeks('4'), isNull);
      });

      test('returns error for 0 weeks', () {
        expect(Validators.weeks('0'), isNotNull);
      });

      test('returns error for more than 8 weeks', () {
        expect(Validators.weeks('9'), isNotNull);
      });

      test('returns null for min (1) weeks', () {
        expect(Validators.weeks('1'), isNull);
      });

      test('returns null for max (8) weeks', () {
        expect(Validators.weeks('8'), isNull);
      });

      test('returns error for non-integer', () {
        expect(Validators.weeks('3.5'), isNotNull);
      });
    });

    group('daysPerPeriod', () {
      test('returns null for valid value', () {
        expect(Validators.daysPerPeriod('7'), isNull);
      });

      test('returns error for 0', () {
        expect(Validators.daysPerPeriod('0'), isNotNull);
      });

      test('returns error for more than 14', () {
        expect(Validators.daysPerPeriod('15'), isNotNull);
      });

      test('returns null for min (1)', () {
        expect(Validators.daysPerPeriod('1'), isNull);
      });

      test('returns null for max (14)', () {
        expect(Validators.daysPerPeriod('14'), isNull);
      });
    });

    group('recoveryPeriod', () {
      test('returns null for valid recovery within total', () {
        expect(Validators.recoveryPeriod('2', 4), isNull);
      });

      test('returns error for recovery exceeding total', () {
        expect(Validators.recoveryPeriod('5', 4), isNotNull);
      });

      test('returns null for empty value (optional)', () {
        expect(Validators.recoveryPeriod('', 4), isNull);
      });

      test('returns null for null value (optional)', () {
        expect(Validators.recoveryPeriod(null, 4), isNull);
      });

      test('returns error for non-integer', () {
        expect(Validators.recoveryPeriod('2.5', 4), isNotNull);
      });
    });

    // ========== EXERCISE VALIDATORS ==========

    group('exerciseName', () {
      test('returns error for empty name', () {
        expect(Validators.exerciseName(''), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.exerciseName('Bench Press'), isNull);
      });

      test('returns error for name exceeding 200 chars', () {
        final longName = 'A' * 201;
        expect(Validators.exerciseName(longName), isNotNull);
      });
    });

    group('weight', () {
      test('returns null for null (optional)', () {
        expect(Validators.weight(null), isNull);
      });

      test('returns null for empty (optional)', () {
        expect(Validators.weight(''), isNull);
      });

      test('returns null for zero (bodyweight)', () {
        expect(Validators.weight('0'), isNull);
      });

      test('returns null for positive number', () {
        expect(Validators.weight('135.5'), isNull);
      });

      test('returns error for negative number', () {
        expect(Validators.weight('-10'), isNotNull);
      });

      test('returns error for non-numeric', () {
        expect(Validators.weight('heavy'), isNotNull);
      });
    });

    group('reps', () {
      test('returns error for empty', () {
        expect(Validators.reps(''), isNotNull);
      });

      test('returns error for null', () {
        expect(Validators.reps(null), isNotNull);
      });

      test('returns null for positive integer', () {
        expect(Validators.reps('10'), isNull);
      });

      test('returns error for zero', () {
        expect(Validators.reps('0'), isNotNull);
      });

      test('returns error for negative', () {
        expect(Validators.reps('-5'), isNotNull);
      });

      test('returns null for RIR format', () {
        expect(Validators.reps('2 RIR'), isNull);
      });

      test('returns null for RIR format case insensitive', () {
        expect(Validators.reps('3 rir'), isNull);
      });

      test('returns error for non-numeric non-RIR string', () {
        expect(Validators.reps('many'), isNotNull);
      });
    });

    group('bodyweight', () {
      test('returns error for empty', () {
        expect(Validators.bodyweight(''), isNotNull);
      });

      test('returns null for valid weight', () {
        expect(Validators.bodyweight('75'), isNull);
      });

      test('returns error for below range (< 20)', () {
        expect(Validators.bodyweight('10'), isNotNull);
      });

      test('returns error for above range (> 500)', () {
        expect(Validators.bodyweight('600'), isNotNull);
      });

      test('returns null for boundary min (20)', () {
        expect(Validators.bodyweight('20'), isNull);
      });

      test('returns null for boundary max (500)', () {
        expect(Validators.bodyweight('500'), isNull);
      });
    });

    // ========== URL VALIDATORS ==========

    group('youtubeUrl', () {
      test('returns null for null (optional)', () {
        expect(Validators.youtubeUrl(null), isNull);
      });

      test('returns null for empty (optional)', () {
        expect(Validators.youtubeUrl(''), isNull);
      });

      test('accepts standard watch URL', () {
        expect(
          Validators.youtubeUrl(
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          ),
          isNull,
        );
      });

      test('accepts short youtu.be URL', () {
        expect(
          Validators.youtubeUrl('https://youtu.be/dQw4w9WgXcQ'),
          isNull,
        );
      });

      test('accepts embed URL', () {
        expect(
          Validators.youtubeUrl(
            'https://www.youtube.com/embed/dQw4w9WgXcQ',
          ),
          isNull,
        );
      });

      test('accepts http (non-https) URL', () {
        expect(
          Validators.youtubeUrl(
            'http://www.youtube.com/watch?v=dQw4w9WgXcQ',
          ),
          isNull,
        );
      });

      test('rejects non-YouTube URL', () {
        expect(
          Validators.youtubeUrl('https://vimeo.com/12345'),
          isNotNull,
        );
      });

      test('rejects plain text', () {
        expect(Validators.youtubeUrl('not a url'), isNotNull);
      });
    });

    group('url', () {
      test('returns null for null (optional)', () {
        expect(Validators.url(null), isNull);
      });

      test('returns null for empty (optional)', () {
        expect(Validators.url(''), isNull);
      });

      test('accepts https URL', () {
        expect(Validators.url('https://example.com'), isNull);
      });

      test('accepts http URL', () {
        expect(Validators.url('http://example.com/path'), isNull);
      });

      test('rejects URL without protocol', () {
        expect(Validators.url('example.com'), isNotNull);
      });

      test('rejects plain text', () {
        expect(Validators.url('not a url at all'), isNotNull);
      });
    });

    // ========== WORKOUT VALIDATORS ==========

    group('workoutLabel', () {
      test('returns null for null (optional)', () {
        expect(Validators.workoutLabel(null), isNull);
      });

      test('returns null for empty (optional)', () {
        expect(Validators.workoutLabel(''), isNull);
      });

      test('returns null for valid label', () {
        expect(Validators.workoutLabel('Push Day'), isNull);
      });

      test('returns error for label exceeding 50 chars', () {
        final longLabel = 'A' * 51;
        expect(Validators.workoutLabel(longLabel), isNotNull);
      });
    });

    group('workoutNote', () {
      test('returns null for null (optional)', () {
        expect(Validators.workoutNote(null), isNull);
      });

      test('returns null for valid note', () {
        expect(Validators.workoutNote('Felt strong today'), isNull);
      });

      test('returns error for note exceeding 1000 chars', () {
        final longNote = 'A' * 1001;
        expect(Validators.workoutNote(longNote), isNotNull);
      });
    });

    group('exerciseNote', () {
      test('returns null for null (optional)', () {
        expect(Validators.exerciseNote(null), isNull);
      });

      test('returns null for valid note', () {
        expect(Validators.exerciseNote('Wide grip'), isNull);
      });

      test('returns error for note exceeding 500 chars', () {
        final longNote = 'A' * 501;
        expect(Validators.exerciseNote(longNote), isNotNull);
      });
    });

    // ========== HELPER METHODS ==========

    group('parsePositiveInt', () {
      test('returns null for null', () {
        expect(Validators.parsePositiveInt(null), isNull);
      });

      test('returns null for empty', () {
        expect(Validators.parsePositiveInt(''), isNull);
      });

      test('parses positive integer', () {
        expect(Validators.parsePositiveInt('42'), 42);
      });

      test('returns null for zero', () {
        expect(Validators.parsePositiveInt('0'), isNull);
      });

      test('returns null for negative', () {
        expect(Validators.parsePositiveInt('-5'), isNull);
      });

      test('returns null for decimal', () {
        expect(Validators.parsePositiveInt('3.14'), isNull);
      });

      test('returns null for non-numeric', () {
        expect(Validators.parsePositiveInt('abc'), isNull);
      });
    });

    group('parseNonNegativeInt', () {
      test('returns null for null', () {
        expect(Validators.parseNonNegativeInt(null), isNull);
      });

      test('parses zero', () {
        expect(Validators.parseNonNegativeInt('0'), 0);
      });

      test('parses positive integer', () {
        expect(Validators.parseNonNegativeInt('42'), 42);
      });

      test('returns null for negative', () {
        expect(Validators.parseNonNegativeInt('-1'), isNull);
      });
    });

    group('parsePositiveDouble', () {
      test('returns null for null', () {
        expect(Validators.parsePositiveDouble(null), isNull);
      });

      test('parses positive double', () {
        expect(Validators.parsePositiveDouble('3.14'), 3.14);
      });

      test('parses positive integer as double', () {
        expect(Validators.parsePositiveDouble('42'), 42.0);
      });

      test('returns null for zero', () {
        expect(Validators.parsePositiveDouble('0'), isNull);
      });

      test('returns null for negative', () {
        expect(Validators.parsePositiveDouble('-1.5'), isNull);
      });
    });

    group('parseNonNegativeDouble', () {
      test('returns null for null', () {
        expect(Validators.parseNonNegativeDouble(null), isNull);
      });

      test('parses zero', () {
        expect(Validators.parseNonNegativeDouble('0'), 0.0);
      });

      test('parses positive double', () {
        expect(Validators.parseNonNegativeDouble('3.14'), 3.14);
      });

      test('returns null for negative', () {
        expect(Validators.parseNonNegativeDouble('-0.5'), isNull);
      });
    });

    group('isEmpty', () {
      test('returns true for null', () {
        expect(Validators.isEmpty(null), isTrue);
      });

      test('returns true for empty string', () {
        expect(Validators.isEmpty(''), isTrue);
      });

      test('returns true for whitespace only', () {
        expect(Validators.isEmpty('   '), isTrue);
      });

      test('returns false for non-empty string', () {
        expect(Validators.isEmpty('hello'), isFalse);
      });
    });

    group('isNotEmpty', () {
      test('returns false for null', () {
        expect(Validators.isNotEmpty(null), isFalse);
      });

      test('returns true for non-empty string', () {
        expect(Validators.isNotEmpty('hello'), isTrue);
      });

      test('returns false for whitespace only', () {
        expect(Validators.isNotEmpty('   '), isFalse);
      });
    });
  });
}
