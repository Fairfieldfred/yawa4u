import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/extensions/string_extensions.dart';

void main() {
  group('Case conversion', () {
    test('capitalize', () {
      expect('hello'.capitalize, 'Hello');
      expect('Hello'.capitalize, 'Hello');
      expect('h'.capitalize, 'H');
      expect(''.capitalize, '');
    });

    test('titleCase', () {
      expect('hello world'.titleCase, 'Hello World');
      expect(''.titleCase, '');
      expect('one'.titleCase, 'One');
    });

    test('sentenceCase', () {
      expect('HELLO WORLD'.sentenceCase, 'Hello world');
      expect('hello'.sentenceCase, 'Hello');
      expect(''.sentenceCase, '');
    });
  });

  group('Validation', () {
    test('isBlank and isNotBlank', () {
      expect(''.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
      expect('a'.isBlank, isFalse);
      expect('a'.isNotBlank, isTrue);
    });

    test('isNumber', () {
      expect('42'.isNumber, isTrue);
      expect('3.14'.isNumber, isTrue);
      expect('-1'.isNumber, isTrue);
      expect('abc'.isNumber, isFalse);
      expect(''.isNumber, isFalse);
    });

    test('isInteger', () {
      expect('42'.isInteger, isTrue);
      expect('3.14'.isInteger, isFalse);
      expect('abc'.isInteger, isFalse);
    });

    test('isEmail', () {
      expect('user@example.com'.isEmail, isTrue);
      expect('user@sub.domain.co'.isEmail, isTrue);
      expect('invalid'.isEmail, isFalse);
      expect('@domain.com'.isEmail, isFalse);
      expect('user@'.isEmail, isFalse);
    });

    test('isUrl', () {
      expect('https://example.com'.isUrl, isTrue);
      expect('http://example.com/path'.isUrl, isTrue);
      expect('not a url'.isUrl, isFalse);
      expect('ftp://example.com'.isUrl, isFalse);
    });

    test('isAlpha', () {
      expect('abc'.isAlpha, isTrue);
      expect('abc123'.isAlpha, isFalse);
      expect(''.isAlpha, isFalse);
    });

    test('isAlphanumeric', () {
      expect('abc123'.isAlphanumeric, isTrue);
      expect('abc'.isAlphanumeric, isTrue);
      expect('abc 123'.isAlphanumeric, isFalse);
    });
  });

  group('Parsing', () {
    test('toIntOrNull', () {
      expect('42'.toIntOrNull, 42);
      expect('abc'.toIntOrNull, isNull);
      expect('3.14'.toIntOrNull, isNull);
    });

    test('toDoubleOrNull', () {
      expect('3.14'.toDoubleOrNull, 3.14);
      expect('42'.toDoubleOrNull, 42.0);
      expect('abc'.toDoubleOrNull, isNull);
    });

    test('toIntOr', () {
      expect('42'.toIntOr(0), 42);
      expect('abc'.toIntOr(99), 99);
    });

    test('toDoubleOr', () {
      expect('3.14'.toDoubleOr(0.0), 3.14);
      expect('abc'.toDoubleOr(1.5), 1.5);
    });
  });

  group('Truncation', () {
    test('truncate within limit returns original', () {
      expect('Hi'.truncate(10), 'Hi');
    });

    test('truncate at exact limit returns original', () {
      expect('Hello'.truncate(5), 'Hello');
    });

    test('truncate beyond limit adds ellipsis', () {
      expect('Hello World'.truncate(8), 'Hello...');
    });

    test('truncate with custom ellipsis', () {
      expect('Hello World'.truncate(9, ellipsis: '…'), 'Hello Wo…');
    });

    test('truncateWords respects word boundaries', () {
      expect('Hello World Foo'.truncateWords(12), 'Hello...');
    });

    test('truncateWords within limit returns original', () {
      expect('Hi'.truncateWords(10), 'Hi');
    });
  });

  group('Removal', () {
    test('removeWhitespace', () {
      expect('hello world'.removeWhitespace, 'helloworld');
      expect('  a  b  '.removeWhitespace, 'ab');
    });

    test('removeNonNumeric', () {
      expect('abc123def456'.removeNonNumeric, '123456');
    });

    test('removeNonAlphanumeric', () {
      expect('hello, world!'.removeNonAlphanumeric, 'helloworld');
    });

    test('removeAll', () {
      expect('banana'.removeAll('a'), 'bnn');
    });
  });

  group('Manipulation', () {
    test('reverse', () {
      expect('hello'.reverse, 'olleh');
      expect(''.reverse, '');
      expect('a'.reverse, 'a');
    });

    test('repeat', () {
      expect('ha'.repeat(3), 'hahaha');
      expect('x'.repeat(1), 'x');
    });

    test('wrap with prefix only', () {
      expect('hello'.wrap('*'), '*hello*');
    });

    test('wrap with prefix and suffix', () {
      expect('hello'.wrap('(', ')'), '(hello)');
    });

    test('quote', () {
      expect('hello'.quote(), '"hello"');
      expect('hello'.quote("'"), "'hello'");
    });
  });

  group('Comparison', () {
    test('equalsIgnoreCase', () {
      expect('Hello'.equalsIgnoreCase('hello'), isTrue);
      expect('Hello'.equalsIgnoreCase('HELLO'), isTrue);
      expect('Hello'.equalsIgnoreCase('world'), isFalse);
    });

    test('containsIgnoreCase', () {
      expect('Hello World'.containsIgnoreCase('world'), isTrue);
      expect('Hello World'.containsIgnoreCase('xyz'), isFalse);
    });

    test('startsWithIgnoreCase', () {
      expect('Hello World'.startsWithIgnoreCase('hello'), isTrue);
      expect('Hello World'.startsWithIgnoreCase('world'), isFalse);
    });

    test('endsWithIgnoreCase', () {
      expect('Hello World'.endsWithIgnoreCase('WORLD'), isTrue);
      expect('Hello World'.endsWithIgnoreCase('hello'), isFalse);
    });
  });

  group('Extraction', () {
    test('extractNumbers', () {
      expect('abc123def456'.extractNumbers(), ['123', '456']);
      expect('no numbers'.extractNumbers(), isEmpty);
    });

    test('first within bounds', () {
      expect('Hello'.first(3), 'Hel');
    });

    test('first exceeds length returns full string', () {
      expect('Hi'.first(10), 'Hi');
    });

    test('last within bounds', () {
      expect('Hello'.last(3), 'llo');
    });

    test('last exceeds length returns full string', () {
      expect('Hi'.last(10), 'Hi');
    });
  });

  group('Utility', () {
    test('initials from two words', () {
      expect('John Doe'.initials, 'JD');
    });

    test('initials from one word', () {
      expect('John'.initials, 'J');
    });

    test('initials from empty', () {
      expect(''.initials, '');
    });

    test('count', () {
      expect('banana'.count('a'), 3);
      expect('banana'.count('na'), 2);
      expect('banana'.count('x'), 0);
      expect('banana'.count(''), 0);
    });

    test('isNumeric', () {
      expect('42'.isNumeric, isTrue);
      expect('3.14'.isNumeric, isTrue);
      expect('abc'.isNumeric, isFalse);
      expect(''.isNumeric, isFalse);
    });

    test('pluralize', () {
      expect('item'.pluralize(1), 'item');
      expect('item'.pluralize(2), 'items');
      expect('item'.pluralize(0), 'items');
      expect('child'.pluralize(2, plural: 'children'), 'children');
    });
  });

  group('Case conversion (snake/camel)', () {
    test('snakeToCamel', () {
      expect('hello_world'.snakeToCamel, 'helloWorld');
      expect('single'.snakeToCamel, 'single');
      expect('a_b_c'.snakeToCamel, 'aBC');
    });

    test('camelToSnake', () {
      expect('helloWorld'.camelToSnake, 'hello_world');
      expect('single'.camelToSnake, 'single');
    });

    test('toSlug', () {
      expect('Hello World!'.toSlug, 'hello-world');
      expect('  Multiple   Spaces  '.toSlug, 'multiple-spaces');
      expect('already-a-slug'.toSlug, 'already-a-slug');
    });
  });

  group('RIR', () {
    test('isRIR valid formats', () {
      expect('2 RIR'.isRIR, isTrue);
      expect('0 rir'.isRIR, isTrue);
      expect('10RIR'.isRIR, isTrue);
    });

    test('isRIR invalid formats', () {
      expect('10'.isRIR, isFalse);
      expect('abc'.isRIR, isFalse);
      expect('RIR 2'.isRIR, isFalse);
    });

    test('rirValue', () {
      expect('2 RIR'.rirValue, 2);
      expect('0 RIR'.rirValue, 0);
      expect('not rir'.rirValue, isNull);
    });
  });

  group('Normalization', () {
    test('normalizeMuscleGroup trims and sentence-cases', () {
      expect('  CHEST '.normalizeMuscleGroup, 'Chest');
      expect('back'.normalizeMuscleGroup, 'Back');
    });

    test('normalizeEquipmentType trims and title-cases', () {
      expect('  bodyweight loadable '.normalizeEquipmentType, 'Bodyweight Loadable');
    });
  });

  group('Defaults', () {
    test('orDefault returns value when not blank', () {
      expect('hello'.orDefault('fallback'), 'hello');
    });

    test('orDefault returns default when blank', () {
      expect(''.orDefault('fallback'), 'fallback');
      expect('  '.orDefault('fallback'), 'fallback');
    });

    test('orNull returns value when not blank', () {
      expect('hello'.orNull, 'hello');
    });

    test('orNull returns null when blank', () {
      expect(''.orNull, isNull);
      expect('  '.orNull, isNull);
    });
  });

  group('NullableStringExtensions', () {
    test('isNullOrBlank', () {
      const String? nullStr = null;
      expect(nullStr.isNullOrBlank, isTrue);
      expect(''.isNullOrBlank, isTrue);
      expect('  '.isNullOrBlank, isTrue);
      expect('a'.isNullOrBlank, isFalse);
    });

    test('isNotNullOrBlank', () {
      const String? nullStr = null;
      expect(nullStr.isNotNullOrBlank, isFalse);
      expect('hello'.isNotNullOrBlank, isTrue);
    });

    test('orDefault', () {
      const String? nullStr = null;
      expect(nullStr.orDefault('fallback'), 'fallback');
      expect(''.orDefault('fallback'), 'fallback');
      expect('hello'.orDefault('fallback'), 'hello');
    });

    test('orEmpty', () {
      const String? nullStr = null;
      expect(nullStr.orEmpty, '');
      expect('hello'.orEmpty, 'hello');
    });
  });
}
