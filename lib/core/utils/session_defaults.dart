import '../constants/sports.dart';

/// Sport-aware default for `daysPerPeriod` on a training cycle.
///
/// Used by the cycle creator when the user picks a primary sport and
/// hasn't manually overridden the days slider. Users can always adjust
/// within the overall min/max bounds; these are only the starting points.
///
/// Defaults reflect typical training prescriptions:
///   * strength → 4 (matches existing behavior for lifting cycles)
///   * run     → 5 (easy / quality / long / recovery / cross)
///   * bike    → 5 (time-crunched cyclist standard)
///   * swim    → 3 (pool access + recovery dictate a lower baseline)
///   * null / other / mixed → 7 (multi-sport plans often include double days)
int defaultDaysPerPeriodForSport(Sport? primary) {
  switch (primary) {
    case Sport.strength:
      return 4;
    case Sport.run:
      return 5;
    case Sport.bike:
      return 5;
    case Sport.swim:
      return 3;
    case Sport.other:
    case null:
      return 7;
  }
}
