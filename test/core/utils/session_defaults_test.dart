import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/core/utils/session_defaults.dart';

void main() {
  group('defaultDaysPerPeriodForSport', () {
    test('strength returns 4', () {
      expect(defaultDaysPerPeriodForSport(Sport.strength), 4);
    });

    test('run returns 5', () {
      expect(defaultDaysPerPeriodForSport(Sport.run), 5);
    });

    test('bike returns 5', () {
      expect(defaultDaysPerPeriodForSport(Sport.bike), 5);
    });

    test('swim returns 3', () {
      expect(defaultDaysPerPeriodForSport(Sport.swim), 3);
    });

    test('other returns 7', () {
      expect(defaultDaysPerPeriodForSport(Sport.other), 7);
    });

    test('null returns 7', () {
      expect(defaultDaysPerPeriodForSport(null), 7);
    });

    test('every Sport value returns a positive integer', () {
      for (final sport in Sport.values) {
        final result = defaultDaysPerPeriodForSport(sport);
        expect(result, greaterThan(0), reason: '$sport should return > 0');
      }
    });
  });
}
