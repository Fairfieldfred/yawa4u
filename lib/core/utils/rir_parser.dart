import '../constants/app_constants.dart';

/// RIR (Reps In Reserve) parsing and formatting utilities
///
/// RIR is a method of tracking set difficulty by indicating how many
/// additional reps could have been performed.
/// Example: "2 RIR" means 2 reps in reserve (could have done 2 more reps)
class RIRParser {
  RIRParser._();

  // ========== PARSING ==========

  /// Check if a reps value is in RIR format
  /// Examples: "2 RIR", "0 RIR", "3RIR", "2 rir"
  static bool isRIR(String reps) {
    return AppConstants.isRIR(reps);
  }

  /// Extract the RIR number from a RIR string
  /// Examples:
  /// - "2 RIR" -> 2
  /// - "0 RIR" -> 0
  /// - "5RIR" -> 5
  /// Returns null if not a valid RIR format
  static int? parseRIR(String reps) {
    return AppConstants.getRIRValue(reps);
  }

  /// Parse reps value - returns either an integer or RIR value
  /// Returns (reps: int?, rir: int?)
  /// Examples:
  /// - "8" -> (reps: 8, rir: null)
  /// - "2 RIR" -> (reps: null, rir: 2)
  /// - "invalid" -> (reps: null, rir: null)
  static ({int? reps, int? rir}) parseReps(String value) {
    if (isRIR(value)) {
      return (reps: null, rir: parseRIR(value));
    }

    final reps = int.tryParse(value.trim());
    return (reps: reps, rir: null);
  }

  // ========== FORMATTING ==========

  /// Format RIR value to display string
  /// Examples:
  /// - 2 -> "2 RIR"
  /// - 0 -> "0 RIR"
  static String formatRIR(int rirValue) {
    return '$rirValue RIR';
  }

  /// Format reps value for display
  /// If it's already in RIR format, return as-is (normalized)
  /// If it's a number, return as string
  /// Examples:
  /// - "8" -> "8"
  /// - "2 RIR" -> "2 RIR"
  /// - "2rir" -> "2 RIR" (normalized)
  static String formatRepsDisplay(String value) {
    if (isRIR(value)) {
      final rir = parseRIR(value);
      if (rir != null) {
        return formatRIR(rir);
      }
    }
    return value.trim();
  }

  // ========== CONVERSION ==========

  /// Convert actual reps performed and max reps to RIR
  /// Example: Performed 8 reps, could do 10 max -> 2 RIR
  static int calculateRIR(int repsPerformed, int maxReps) {
    final rir = maxReps - repsPerformed;
    return rir < 0 ? 0 : rir;
  }

  /// Convert RIR to actual reps target
  /// Example: Target is 2 RIR with max 10 reps -> perform 8 reps
  static int rirToRepsTarget(int rir, int maxReps) {
    final target = maxReps - rir;
    return target < 0 ? 0 : target;
  }

  // ========== VALIDATION ==========

  /// Validate RIR value (should be 0-5 typically)
  static bool isValidRIR(int rir) {
    return rir >= 0 && rir <= 10; // Allow 0-10 RIR
  }

  /// Get RIR validation message
  static String? validateRIR(int rir) {
    if (!isValidRIR(rir)) {
      return 'RIR should be between 0 and 10';
    }
    return null;
  }

  // ========== COMPARISON ==========

  /// Compare two reps values
  /// Returns:
  /// - negative if a < b
  /// - 0 if a == b
  /// - positive if a > b
  ///
  /// For RIR values, lower RIR = higher effort (so "0 RIR" > "2 RIR")
  /// Mixed comparisons (number vs RIR) return 0 (can't compare)
  static int compareReps(String a, String b) {
    final parsedA = parseReps(a);
    final parsedB = parseReps(b);

    // Both are regular reps
    if (parsedA.reps != null && parsedB.reps != null) {
      return parsedA.reps!.compareTo(parsedB.reps!);
    }

    // Both are RIR (lower RIR = harder = greater)
    if (parsedA.rir != null && parsedB.rir != null) {
      return parsedB.rir!.compareTo(parsedA.rir!); // Reversed!
    }

    // Mixed or invalid - can't compare
    return 0;
  }

  // ========== HELPER METHODS ==========

  /// Get a display-friendly explanation of RIR
  static String getRIRExplanation(int rir) {
    if (rir == 0) {
      return 'Taken to complete failure (0 reps left)';
    } else if (rir == 1) {
      return 'Could have done 1 more rep';
    } else {
      return 'Could have done $rir more reps';
    }
  }

  /// Get difficulty level from RIR (0 = max difficulty, 5+ = easier)
  static String getRIRDifficulty(int rir) {
    if (rir == 0) return 'Maximum Effort';
    if (rir == 1) return 'Very Hard';
    if (rir == 2) return 'Hard';
    if (rir == 3) return 'Moderate';
    if (rir >= 4) return 'Easy';
    return 'Unknown';
  }

  /// Check if a set was taken close to failure
  /// "Close to failure" typically means 0-2 RIR
  static bool isCloseToFailure(String reps) {
    final rir = parseRIR(reps);
    if (rir == null) return false;
    return rir <= 2;
  }

  /// Get color indicator for RIR value
  /// Returns a string representing effort level:
  /// - "high" for 0-1 RIR (close to failure)
  /// - "medium" for 2-3 RIR
  /// - "low" for 4+ RIR
  static String getRIREffortLevel(int rir) {
    if (rir <= 1) return 'high';
    if (rir <= 3) return 'medium';
    return 'low';
  }

  // ========== WEEK PROGRESSION ==========

  /// Get recommended RIR for a given week in a trainingCycle
  /// Common progression: Period 1 (3 RIR) -> Period 4 (0 RIR)
  /// This implements a linear progression model
  static int getRecommendedRIRForPeriod(int periodNumber, int totalPeriods) {
    // Recovery period (typically last period) - higher RIR
    if (periodNumber == totalPeriods) {
      return 8; // Recovery period - very easy
    }

    // Linear progression from 3 RIR to 0 RIR
    final nonRecoveryPeriods = totalPeriods - 1;
    if (nonRecoveryPeriods <= 1) return 2; // Single period meso

    // Map period to RIR: 3 -> 2 -> 1 -> 0
    final progressionStep = 3.0 / (nonRecoveryPeriods - 1);
    final rir = 3 - ((periodNumber - 1) * progressionStep);

    return rir.round().clamp(0, 3);
  }

  /// Get RIR target as a display string for a given period
  /// Examples: "3 RIR", "0 RIR", "8 RIR" (recovery)
  static String getRIRTargetForPeriod(int periodNumber, int totalPeriods) {
    final rir = getRecommendedRIRForPeriod(periodNumber, totalPeriods);
    return formatRIR(rir);
  }

  // ========== INPUT HELPERS ==========

  /// Suggest RIR input format for text field hint
  static const String rirInputHint = 'e.g., "8" or "2 RIR"';

  /// Get example RIR values for UI
  static const List<String> rirExamples = [
    '0 RIR',
    '1 RIR',
    '2 RIR',
    '3 RIR',
    '4 RIR',
    '5 RIR',
  ];

  /// Convert user input to standardized format
  /// Handles various input formats:
  /// - "2" -> "2"
  /// - "2 rir" -> "2 RIR"
  /// - "2rir" -> "2 RIR"
  /// - "rir2" -> "2 RIR"
  /// - "R2" -> "2 RIR"
  static String normalizeRepsInput(String input) {
    final trimmed = input.trim().toUpperCase();

    // Already in correct format
    if (isRIR(trimmed)) {
      final rir = parseRIR(trimmed);
      return rir != null ? formatRIR(rir) : trimmed;
    }

    // Check for number followed by RIR
    final match = RegExp(
      r'(\d+)\s*RIR',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match != null) {
      final rir = int.tryParse(match.group(1)!);
      return rir != null ? formatRIR(rir) : trimmed;
    }

    // Check for "R" followed by number (shorthand)
    final rMatch = RegExp(
      r'R\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (rMatch != null) {
      final rir = int.tryParse(rMatch.group(1)!);
      return rir != null ? formatRIR(rir) : trimmed;
    }

    // Just a number - return as-is
    return input.trim();
  }
}
