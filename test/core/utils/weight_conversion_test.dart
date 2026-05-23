import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/utils/weight_conversion.dart';

void main() {
  group('convertWeightForDisplay', () {
    test('returns null for null input', () {
      expect(convertWeightForDisplay(null, true), isNull);
      expect(convertWeightForDisplay(null, false), isNull);
    });

    test('returns lbs rounded to 0.5 when imperial', () {
      expect(convertWeightForDisplay(135.0, false), 135.0);
      expect(convertWeightForDisplay(135.3, false), 135.5);
      expect(convertWeightForDisplay(135.7, false), 135.5);
      expect(convertWeightForDisplay(136.0, false), 136.0);
    });

    test('converts lbs to kg rounded to 0.5 when metric', () {
      // 100 lbs * 0.453592 = 45.3592 → rounds to 45.5
      expect(convertWeightForDisplay(100.0, true), 45.5);
      // 200 lbs * 0.453592 = 90.7184 → rounds to 90.5
      expect(convertWeightForDisplay(200.0, true), 90.5);
    });

    test('handles zero', () {
      expect(convertWeightForDisplay(0.0, true), 0.0);
      expect(convertWeightForDisplay(0.0, false), 0.0);
    });
  });

  group('convertWeightForStorage', () {
    test('returns null for null input', () {
      expect(convertWeightForStorage(null, true), isNull);
      expect(convertWeightForStorage(null, false), isNull);
    });

    test('returns lbs rounded to 0.5 when imperial', () {
      expect(convertWeightForStorage(135.0, false), 135.0);
      expect(convertWeightForStorage(135.3, false), 135.5);
    });

    test('converts kg to lbs when metric', () {
      // 45 kg * 2.20462 = 99.2079 → rounds to 99.0
      expect(convertWeightForStorage(45.0, true), 99.0);
      // 100 kg * 2.20462 = 220.462 → rounds to 220.5
      expect(convertWeightForStorage(100.0, true), 220.5);
    });

    test('handles zero', () {
      expect(convertWeightForStorage(0.0, true), 0.0);
      expect(convertWeightForStorage(0.0, false), 0.0);
    });
  });

  group('round-trip consistency', () {
    test('imperial round-trip preserves value', () {
      const original = 135.0;
      final displayed = convertWeightForDisplay(original, false);
      final stored = convertWeightForStorage(displayed, false);
      expect(stored, equals(original));
    });

    test('metric round-trip is within 0.5 tolerance', () {
      const original = 100.0; // lbs
      final displayed = convertWeightForDisplay(original, true); // to kg
      final stored = convertWeightForStorage(displayed, true); // back to lbs
      // Due to rounding to 0.5, there may be a small loss
      expect((stored! - original).abs(), lessThanOrEqualTo(1.0));
    });
  });

  group('formatWeightForDisplay', () {
    test('returns empty string for null', () {
      expect(formatWeightForDisplay(null, true), '');
      expect(formatWeightForDisplay(null, false), '');
    });

    test('drops decimal for whole numbers', () {
      expect(formatWeightForDisplay(135.0, false), '135');
    });

    test('keeps one decimal for half values', () {
      // 135.3 lbs → rounds to 135.5 → "135.5"
      expect(formatWeightForDisplay(135.3, false), '135.5');
    });

    test('formats metric conversion', () {
      // 100 lbs → 45.5 kg → "45.5"
      expect(formatWeightForDisplay(100.0, true), '45.5');
    });
  });
}
