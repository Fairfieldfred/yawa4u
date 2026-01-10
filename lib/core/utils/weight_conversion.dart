/// Weight conversion utilities for display and storage
///
/// Database stores all weights in pounds (lbs).
/// This utility converts to/from kg for display based on user preference.
library;

const double _lbsToKgFactor = 0.453592;
const double _kgToLbsFactor = 2.20462;

/// Convert a weight from storage (lbs) to display unit
/// Rounds to nearest 0.5
double? convertWeightForDisplay(double? weightInLbs, bool useMetric) {
  if (weightInLbs == null) return null;

  if (useMetric) {
    // Convert lbs to kg
    final kg = weightInLbs * _lbsToKgFactor;
    return _roundToHalf(kg);
  } else {
    // Already in lbs, just round
    return _roundToHalf(weightInLbs);
  }
}

/// Convert a weight from display unit to storage (lbs)
/// Rounds to nearest 0.5
double? convertWeightForStorage(double? displayWeight, bool useMetric) {
  if (displayWeight == null) return null;

  if (useMetric) {
    // Convert kg to lbs
    final lbs = displayWeight * _kgToLbsFactor;
    return _roundToHalf(lbs);
  } else {
    // Already in lbs, just round
    return _roundToHalf(displayWeight);
  }
}

/// Format weight for display (removes trailing zeros)
String formatWeightForDisplay(double? weightInLbs, bool useMetric) {
  final converted = convertWeightForDisplay(weightInLbs, useMetric);
  if (converted == null) return '';

  // Format without unnecessary decimal places
  if (converted == converted.truncate()) {
    return converted.truncate().toString();
  } else {
    return converted.toStringAsFixed(1);
  }
}

/// Round to nearest 0.5
double _roundToHalf(double value) {
  return (value * 2).round() / 2;
}
