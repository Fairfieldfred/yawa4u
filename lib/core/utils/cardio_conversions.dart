import '../constants/enums.dart';

/// Unit-aware formatting and conversion helpers for cardio metrics.
///
/// Canonical storage units across the app:
///   * distance: meters
///   * duration: seconds
///   * speed: meters/second
///   * pace: seconds/meter
///
/// All display helpers take [UnitSystem] explicitly — callers that want
/// per-sport units should ask [OnboardingService.unitsFor] first.
class CardioConversions {
  const CardioConversions._();

  // ---------------------------------------------------------------------------
  // Distance
  // ---------------------------------------------------------------------------

  static const double metersPerMile = 1609.344;
  static const double metersPerKilometer = 1000.0;
  static const double metersPerYard = 0.9144;

  /// Convert meters to the display unit (km or mi).
  static double metersToDisplay(double meters, UnitSystem units) {
    return units.isMetric ? meters / metersPerKilometer : meters / metersPerMile;
  }

  /// Convert a display-unit distance back to meters.
  static double displayToMeters(double display, UnitSystem units) {
    return units.isMetric ? display * metersPerKilometer : display * metersPerMile;
  }

  /// "5.12 km" / "3.18 mi" — 2-decimal precision suits runs and rides.
  static String formatDistance(double meters, UnitSystem units) {
    final v = metersToDisplay(meters, units);
    final label = units.isMetric ? 'km' : 'mi';
    return '${v.toStringAsFixed(2)} $label';
  }

  /// Dedicated swim distance formatter — pools are measured in meters or
  /// yards (not kilometers/miles) regardless of the user's overall pref.
  static String formatSwimDistance(double meters, UnitSystem units) {
    if (units.isMetric) return '${meters.toStringAsFixed(0)} m';
    final yards = meters / metersPerYard;
    return '${yards.toStringAsFixed(0)} yd';
  }

  // ---------------------------------------------------------------------------
  // Duration
  // ---------------------------------------------------------------------------

  /// "1:23:45" or "23:45" — HH:MM:SS when > 1h, otherwise MM:SS.
  static String formatDuration(int totalSeconds) {
    final negative = totalSeconds < 0;
    final s = totalSeconds.abs();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    final sign = negative ? '-' : '';
    return h > 0 ? '$sign$h:$mm:$ss' : '$sign$mm:$ss';
  }

  /// Parse "MM:SS" or "HH:MM:SS" into total seconds. Returns null if the
  /// input isn't a valid duration string.
  static int? parseDuration(String text) {
    final parts = text.trim().split(':');
    if (parts.isEmpty || parts.length > 3) return null;
    try {
      final ints = parts.map(int.parse).toList();
      if (ints.any((v) => v < 0)) return null;
      // Enforce mm < 60 / ss < 60 only when we actually have multiple
      // segments; a single-number input is treated as raw seconds.
      if (ints.length >= 2 && ints[ints.length - 1] >= 60) return null;
      if (ints.length == 3 && ints[1] >= 60) return null;
      switch (ints.length) {
        case 1:
          return ints[0];
        case 2:
          return ints[0] * 60 + ints[1];
        case 3:
          return ints[0] * 3600 + ints[1] * 60 + ints[2];
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Pace
  // ---------------------------------------------------------------------------

  /// Convert a seconds-per-meter pace to seconds-per-km or seconds-per-mile.
  /// Returns 0 for non-positive input to avoid division spam in UIs.
  static double paceSecPerUnit(
    double secPerMeter,
    UnitSystem units, {
    bool swim = false,
  }) {
    if (secPerMeter <= 0) return 0;
    if (swim) {
      // Swim pace is universally reported per-100m (metric) or per-100y
      // (imperial).
      return units.isMetric ? secPerMeter * 100 : secPerMeter * 100 * metersPerYard;
    }
    return units.isMetric ? secPerMeter * metersPerKilometer : secPerMeter * metersPerMile;
  }

  /// "4:12 /km" / "6:45 /mi" / "1:42 /100m" (swim).
  static String formatPace(
    double secPerMeter,
    UnitSystem units, {
    bool swim = false,
  }) {
    final seconds = paceSecPerUnit(secPerMeter, units, swim: swim);
    if (seconds <= 0) return '—';
    final mm = seconds ~/ 60;
    final ss = (seconds % 60).round();
    final ssStr = ss.toString().padLeft(2, '0');
    String unitLabel;
    if (swim) {
      unitLabel = units.isMetric ? '/100m' : '/100y';
    } else {
      unitLabel = units.isMetric ? '/km' : '/mi';
    }
    return '$mm:$ssStr $unitLabel';
  }

  // ---------------------------------------------------------------------------
  // Speed
  // ---------------------------------------------------------------------------

  /// "32.4 km/h" / "20.1 mph".
  static String formatSpeed(double metersPerSecond, UnitSystem units) {
    if (metersPerSecond <= 0) return '—';
    final kph = metersPerSecond * 3.6;
    if (units.isMetric) return '${kph.toStringAsFixed(1)} km/h';
    final mph = kph / 1.609344;
    return '${mph.toStringAsFixed(1)} mph';
  }

  // ---------------------------------------------------------------------------
  // Elevation
  // ---------------------------------------------------------------------------

  /// "142 m" / "466 ft".
  static String formatElevation(double meters, UnitSystem units) {
    if (units.isMetric) return '${meters.toStringAsFixed(0)} m';
    final feet = meters * 3.280839895;
    return '${feet.toStringAsFixed(0)} ft';
  }
}
