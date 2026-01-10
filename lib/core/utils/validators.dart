import '../constants/app_constants.dart';

/// Validation utility functions for Yawa4u app
class Validators {
  Validators._();

  // ========== GENERAL VALIDATORS ==========

  /// Validate that a string is not empty
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(
    String? value,
    int min, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(
    String? value,
    int max, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  // ========== NUMBER VALIDATORS ==========

  /// Validate that a string is a valid number
  static String? isNumber(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Validate that a string is a valid integer
  static String? isInteger(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid integer';
    }
    return null;
  }

  /// Validate that a number is within a range
  static String? numberRange(
    String? value,
    double min,
    double max, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Validate that a number is positive
  static String? isPositive(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be positive';
    }
    return null;
  }

  /// Validate that a number is non-negative (>= 0)
  static String? isNonNegative(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  // ========== TRAINING CYCLE VALIDATORS ==========

  /// Validate trainingCycle name
  static String? trainingCycleName(String? value) {
    return combine(value, [
      (v) => required(v, fieldName: 'TrainingCycle name'),
      (v) => minLength(v, 1, fieldName: 'TrainingCycle name'),
      (v) => maxLength(v, 100, fieldName: 'TrainingCycle name'),
    ]);
  }

  /// Validate number of weeks (1-8)
  static String? weeks(String? value) {
    return combine(value, [
      (v) => required(v, fieldName: 'Number of weeks'),
      (v) => isInteger(v, fieldName: 'Number of weeks'),
      (v) => numberRange(
        v,
        AppConstants.minWeeks.toDouble(),
        AppConstants.maxWeeks.toDouble(),
        fieldName: 'Number of weeks',
      ),
    ]);
  }

  /// Validate days per period (1-14)
  static String? daysPerPeriod(String? value) {
    return combine(value, [
      (v) => required(v, fieldName: 'Days per period'),
      (v) => isInteger(v, fieldName: 'Days per period'),
      (v) => numberRange(
        v,
        AppConstants.minDaysPerPeriod.toDouble(),
        AppConstants.maxDaysPerPeriod.toDouble(),
        fieldName: 'Days per period',
      ),
    ]);
  }

  /// Validate recovery period (1 to total periods)
  static String? recoveryPeriod(String? value, int totalPeriods) {
    return combine(value, [
      (v) => isInteger(v, fieldName: 'Recovery period'),
      (v) => numberRange(
        v,
        1,
        totalPeriods.toDouble(),
        fieldName: 'Recovery period',
      ),
    ]);
  }

  // ========== EXERCISE VALIDATORS ==========

  /// Validate exercise name
  static String? exerciseName(String? value) {
    return combine(value, [
      (v) => required(v, fieldName: 'Exercise name'),
      (v) => minLength(v, 1, fieldName: 'Exercise name'),
      (v) => maxLength(v, 200, fieldName: 'Exercise name'),
    ]);
  }

  /// Validate weight (positive number or zero for bodyweight)
  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return combine(value, [
      (v) => isNumber(v, fieldName: 'Weight'),
      (v) => isNonNegative(v, fieldName: 'Weight'),
    ]);
  }

  /// Validate reps (number or RIR format like "2 RIR")
  static String? reps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Reps is required';
    }

    // Check if it's RIR format
    if (AppConstants.isRIR(value)) {
      return null; // Valid RIR format
    }

    // Check if it's a valid positive number
    final number = int.tryParse(value);
    if (number == null) {
      return 'Reps must be a number or in "X RIR" format';
    }
    if (number <= 0) {
      return 'Reps must be positive';
    }

    return null;
  }

  /// Validate bodyweight (positive number)
  static String? bodyweight(String? value) {
    return combine(value, [
      (v) => required(v, fieldName: 'Bodyweight'),
      (v) => isNumber(v, fieldName: 'Bodyweight'),
      (v) => isPositive(v, fieldName: 'Bodyweight'),
      (v) =>
          numberRange(v, 20, 500, fieldName: 'Bodyweight'), // Reasonable range
    ]);
  }

  // ========== URL VALIDATORS ==========

  /// Validate YouTube URL (optional)
  static String? youtubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional

    // Basic YouTube URL patterns
    final patterns = [
      RegExp(r'^https?://(?:www\.)?youtube\.com/watch\?v=[\w-]+'),
      RegExp(r'^https?://(?:www\.)?youtu\.be/[\w-]+'),
      RegExp(r'^https?://(?:www\.)?youtube\.com/embed/[\w-]+'),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(value)) {
        return null; // Valid
      }
    }

    return 'Please enter a valid YouTube URL';
  }

  /// Validate generic URL (optional)
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional

    final urlPattern = RegExp(
      r'^https?://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );

    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // ========== WORKOUT VALIDATORS ==========

  /// Validate workout label (optional, max length)
  static String? workoutLabel(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    return maxLength(value, 50, fieldName: 'Workout label');
  }

  /// Validate workout note (optional, max length)
  static String? workoutNote(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    return maxLength(value, 1000, fieldName: 'Workout note');
  }

  /// Validate exercise note (optional, max length)
  static String? exerciseNote(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional
    return maxLength(value, 500, fieldName: 'Exercise note');
  }

  // ========== HELPER METHODS ==========

  /// Parse and validate a positive integer
  static int? parsePositiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null || number <= 0) return null;
    return number;
  }

  /// Parse and validate a non-negative integer
  static int? parseNonNegativeInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = int.tryParse(value);
    if (number == null || number < 0) return null;
    return number;
  }

  /// Parse and validate a positive double
  static double? parsePositiveDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number <= 0) return null;
    return number;
  }

  /// Parse and validate a non-negative double
  static double? parseNonNegativeDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null || number < 0) return null;
    return number;
  }

  /// Check if a string is empty or whitespace only
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Check if a string is not empty
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }
}
