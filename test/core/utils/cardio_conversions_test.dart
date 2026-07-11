import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/utils/cardio_conversions.dart';

void main() {
  group('CardioConversions', () {
    // ========== Constants ==========

    group('constants', () {
      test('metersPerMile is correct', () {
        expect(
          CardioConversions.metersPerMile,
          closeTo(1609.344, 0.001),
        );
      });

      test('metersPerKilometer is 1000', () {
        expect(CardioConversions.metersPerKilometer, 1000.0);
      });

      test('metersPerYard is correct', () {
        expect(
          CardioConversions.metersPerYard,
          closeTo(0.9144, 0.0001),
        );
      });
    });

    // ========== Distance ==========

    group('metersToDisplay', () {
      test('converts meters to kilometers (metric)', () {
        expect(
          CardioConversions.metersToDisplay(5000, UnitSystem.metric),
          closeTo(5.0, 0.001),
        );
      });

      test('converts meters to miles (imperial)', () {
        expect(
          CardioConversions.metersToDisplay(
            1609.344,
            UnitSystem.imperial,
          ),
          closeTo(1.0, 0.001),
        );
      });

      test('handles zero', () {
        expect(
          CardioConversions.metersToDisplay(0, UnitSystem.metric),
          0.0,
        );
      });
    });

    group('displayToMeters', () {
      test('converts km to meters (metric)', () {
        expect(
          CardioConversions.displayToMeters(5.0, UnitSystem.metric),
          closeTo(5000.0, 0.1),
        );
      });

      test('converts miles to meters (imperial)', () {
        expect(
          CardioConversions.displayToMeters(1.0, UnitSystem.imperial),
          closeTo(1609.344, 0.1),
        );
      });
    });

    group('metersToDisplay / displayToMeters round-trip', () {
      test('metric round-trip', () {
        const originalMeters = 10000.0;
        final display = CardioConversions.metersToDisplay(
          originalMeters,
          UnitSystem.metric,
        );
        final back = CardioConversions.displayToMeters(
          display,
          UnitSystem.metric,
        );
        expect(back, closeTo(originalMeters, 0.01));
      });

      test('imperial round-trip', () {
        const originalMeters = 8046.72; // ~5 miles
        final display = CardioConversions.metersToDisplay(
          originalMeters,
          UnitSystem.imperial,
        );
        final back = CardioConversions.displayToMeters(
          display,
          UnitSystem.imperial,
        );
        expect(back, closeTo(originalMeters, 0.01));
      });
    });

    group('formatDistance', () {
      test('formats metric distance', () {
        expect(
          CardioConversions.formatDistance(5120.0, UnitSystem.metric),
          '5.12 km',
        );
      });

      test('formats imperial distance', () {
        // 5120 meters ≈ 3.18 miles
        final result = CardioConversions.formatDistance(
          5120.0,
          UnitSystem.imperial,
        );
        expect(result, contains('mi'));
        expect(result, contains('3.18'));
      });

      test('formats zero distance', () {
        expect(
          CardioConversions.formatDistance(0, UnitSystem.metric),
          '0.00 km',
        );
      });
    });

    group('formatSwimDistance', () {
      test('formats metric swim distance in meters', () {
        expect(
          CardioConversions.formatSwimDistance(
            1500.0,
            UnitSystem.metric,
          ),
          '1500 m',
        );
      });

      test('formats imperial swim distance in yards', () {
        // 100 meters ≈ 109 yards
        final result = CardioConversions.formatSwimDistance(
          100.0,
          UnitSystem.imperial,
        );
        expect(result, contains('yd'));
        expect(result, contains('109'));
      });

      test('rounds to whole number (no decimals)', () {
        final result = CardioConversions.formatSwimDistance(
          750.5,
          UnitSystem.metric,
        );
        // toStringAsFixed(0) rounds 750.5 → 751
        expect(result, '751 m');
      });
    });

    // ========== Duration ==========

    group('formatDuration', () {
      test('formats seconds only (< 1 minute)', () {
        expect(CardioConversions.formatDuration(45), '00:45');
      });

      test('formats minutes and seconds', () {
        expect(CardioConversions.formatDuration(330), '05:30');
      });

      test('formats hours, minutes, seconds', () {
        expect(CardioConversions.formatDuration(5025), '1:23:45');
      });

      test('formats exact hour', () {
        expect(CardioConversions.formatDuration(3600), '1:00:00');
      });

      test('formats zero seconds', () {
        expect(CardioConversions.formatDuration(0), '00:00');
      });

      test('handles negative duration', () {
        expect(CardioConversions.formatDuration(-330), '-05:30');
      });

      test('pads single-digit minutes and seconds', () {
        expect(CardioConversions.formatDuration(61), '01:01');
      });
    });

    group('parseDuration', () {
      test('parses MM:SS', () {
        expect(CardioConversions.parseDuration('05:30'), 330);
      });

      test('parses HH:MM:SS', () {
        expect(CardioConversions.parseDuration('1:23:45'), 5025);
      });

      test('parses single number as raw seconds', () {
        expect(CardioConversions.parseDuration('120'), 120);
      });

      test('returns null for empty string', () {
        expect(CardioConversions.parseDuration(''), isNull);
      });

      test('returns null for too many colons', () {
        expect(
          CardioConversions.parseDuration('1:2:3:4'),
          isNull,
        );
      });

      test('returns null for non-numeric parts', () {
        expect(CardioConversions.parseDuration('ab:cd'), isNull);
      });

      test('returns null for negative segments', () {
        expect(CardioConversions.parseDuration('-1:30'), isNull);
      });

      test('returns null for seconds >= 60 in MM:SS', () {
        expect(CardioConversions.parseDuration('5:60'), isNull);
      });

      test('returns null for minutes >= 60 in HH:MM:SS', () {
        expect(CardioConversions.parseDuration('1:60:00'), isNull);
      });

      test('accepts seconds >= 60 in single-number input', () {
        expect(CardioConversions.parseDuration('90'), 90);
      });

      test('handles leading/trailing whitespace', () {
        expect(CardioConversions.parseDuration(' 5:30 '), 330);
      });
    });

    group('formatDuration / parseDuration round-trip', () {
      test('round-trips MM:SS', () {
        const seconds = 330;
        final formatted = CardioConversions.formatDuration(seconds);
        final parsed = CardioConversions.parseDuration(formatted);
        expect(parsed, seconds);
      });

      test('round-trips HH:MM:SS', () {
        const seconds = 5025;
        final formatted = CardioConversions.formatDuration(seconds);
        final parsed = CardioConversions.parseDuration(formatted);
        expect(parsed, seconds);
      });
    });

    // ========== Pace ==========

    group('paceSecPerUnit', () {
      test('converts to sec/km (metric)', () {
        // 0.25 sec/meter = 250 sec/km
        expect(
          CardioConversions.paceSecPerUnit(0.25, UnitSystem.metric),
          closeTo(250.0, 0.1),
        );
      });

      test('converts to sec/mi (imperial)', () {
        // 0.25 sec/meter = 0.25 * 1609.344 = 402.336 sec/mi
        expect(
          CardioConversions.paceSecPerUnit(
            0.25,
            UnitSystem.imperial,
          ),
          closeTo(402.336, 0.1),
        );
      });

      test('returns 0 for zero pace', () {
        expect(
          CardioConversions.paceSecPerUnit(0, UnitSystem.metric),
          0,
        );
      });

      test('returns 0 for negative pace', () {
        expect(
          CardioConversions.paceSecPerUnit(-1, UnitSystem.metric),
          0,
        );
      });

      test('swim pace is per 100m (metric)', () {
        // 0.5 sec/meter = 0.5 * 100 = 50 sec/100m
        expect(
          CardioConversions.paceSecPerUnit(
            0.5,
            UnitSystem.metric,
            swim: true,
          ),
          closeTo(50.0, 0.1),
        );
      });

      test('swim pace is per 100yd (imperial)', () {
        // 0.5 sec/meter = 0.5 * 100 * 0.9144 = 45.72 sec/100yd
        expect(
          CardioConversions.paceSecPerUnit(
            0.5,
            UnitSystem.imperial,
            swim: true,
          ),
          closeTo(45.72, 0.1),
        );
      });
    });

    group('formatPace', () {
      test('formats metric run pace', () {
        // 0.3 sec/m = 300 sec/km = 5:00/km
        final result = CardioConversions.formatPace(0.3, UnitSystem.metric);
        expect(result, contains('/km'));
        expect(result, contains('5:00'));
      });

      test('formats imperial run pace', () {
        final result = CardioConversions.formatPace(0.3, UnitSystem.imperial);
        expect(result, contains('/mi'));
      });

      test('formats swim pace metric', () {
        final result = CardioConversions.formatPace(
          1.0,
          UnitSystem.metric,
          swim: true,
        );
        expect(result, contains('/100m'));
      });

      test('formats swim pace imperial', () {
        final result = CardioConversions.formatPace(
          1.0,
          UnitSystem.imperial,
          swim: true,
        );
        expect(result, contains('/100y'));
      });

      test('returns dash for zero pace', () {
        expect(
          CardioConversions.formatPace(0, UnitSystem.metric),
          '—',
        );
      });

      test('returns dash for negative pace', () {
        expect(
          CardioConversions.formatPace(-0.5, UnitSystem.metric),
          '—',
        );
      });
    });

    // ========== Speed ==========

    group('formatSpeed', () {
      test('formats metric speed in km/h', () {
        // 10 m/s = 36 km/h
        expect(
          CardioConversions.formatSpeed(10, UnitSystem.metric),
          '36.0 km/h',
        );
      });

      test('formats imperial speed in mph', () {
        // 10 m/s = 36 km/h = 22.4 mph
        final result = CardioConversions.formatSpeed(10, UnitSystem.imperial);
        expect(result, contains('mph'));
        expect(result, contains('22.4'));
      });

      test('returns dash for zero speed', () {
        expect(
          CardioConversions.formatSpeed(0, UnitSystem.metric),
          '—',
        );
      });

      test('returns dash for negative speed', () {
        expect(
          CardioConversions.formatSpeed(-5, UnitSystem.metric),
          '—',
        );
      });

      test('formats with one decimal place', () {
        // 2.778 m/s = 10.0008 km/h → "10.0 km/h"
        expect(
          CardioConversions.formatSpeed(2.778, UnitSystem.metric),
          '10.0 km/h',
        );
      });
    });

    // ========== Elevation ==========

    group('formatElevation', () {
      test('formats metric elevation in meters', () {
        expect(
          CardioConversions.formatElevation(142, UnitSystem.metric),
          '142 m',
        );
      });

      test('formats imperial elevation in feet', () {
        // 142 m * 3.281 ≈ 466 ft
        final result = CardioConversions.formatElevation(
          142,
          UnitSystem.imperial,
        );
        expect(result, contains('ft'));
        expect(result, contains('466'));
      });

      test('rounds to whole number', () {
        expect(
          CardioConversions.formatElevation(
            142.7,
            UnitSystem.metric,
          ),
          '143 m',
        );
      });

      test('handles zero elevation', () {
        expect(
          CardioConversions.formatElevation(0, UnitSystem.metric),
          '0 m',
        );
      });
    });
  });
}
