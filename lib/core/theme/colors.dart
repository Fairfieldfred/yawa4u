import 'package:flutter/material.dart';

/// Color palette for Yawa4u app
/// Colors extracted from UI screenshots
class AppColors {
  AppColors._();

  // ========== DARK THEME COLORS ==========

  /// Dark theme backgrounds
  static const Color darkScaffoldBackground = Color(0xFF1C1C1E);
  static const Color darkCardBackground = Color(0xFF2C2C2E);
  static const Color darkInputBackground = Color.fromARGB(255, 21, 21, 22);
  static const Color darkDivider = Color(0xFF48484A);

  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextDisabled = Color(0xFF616161);

  // ========== LIGHT THEME COLORS ==========

  /// Light theme backgrounds
  static const Color lightScaffoldBackground = Color(0xFFF2F2F7);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightInputBackground = Color(0xFFF9F9F9);
  static const Color lightDivider = Color(0xFFE0E0E0);

  /// Light theme text colors
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);

  // ========== SHARED ACCENT COLORS ==========

  /// Primary accent color (used for buttons, active states)
  static const Color primary = Color(0xFFE53935); // Red
  static const Color primaryDark = Color(0xFFD32F2F);
  static const Color primaryLight = Color(0xFFEF5350);

  /// Success color (completed workouts, logged sets)
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successDark = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF66BB6A);

  /// Warning color
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color warningDark = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFB74D);

  /// Error color
  static const Color error = Color(0xFFEF5350); // Red
  static const Color errorDark = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF9A9A);

  /// Info color (current workout, badges)
  static const Color info = Color(0xFF42A5F5); // Blue
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoLight = Color(0xFF64B5F6);

  // ========== MUSCLE GROUP COLORS ==========
  // Based on UI screenshots

  /// Chest, Triceps, Shoulders - Pink/Magenta
  static const Color musclePink = Color(0xFFE91E63);
  static const Color musclePinkDark = Color(0xFFC2185B);
  static const Color musclePinkLight = Color(0xFFF06292);

  /// Back, Biceps - Cyan/Blue
  static const Color muscleCyan = Color(0xFF00BCD4);
  static const Color muscleCyanDark = Color(0xFF0097A7);
  static const Color muscleCyanLight = Color(0xFF4DD0E1);

  /// Quads, Hamstrings, Glutes, Calves - Teal/Green
  static const Color muscleTeal = Color(0xFF009688);
  static const Color muscleTealDark = Color(0xFF00796B);
  static const Color muscleTealLight = Color(0xFF4DB6AC);

  /// Traps, Forearms, Abs - Purple
  static const Color musclePurple = Color(0xFF9C27B0);
  static const Color musclePurpleDark = Color(0xFF7B1FA2);
  static const Color musclePurpleLight = Color(0xFFBA68C8);

  // ========== SPECIAL UI COLORS ==========

  /// Checkbox colors
  static const Color checkboxChecked = success;
  static const Color checkboxUnchecked = Color(0xFF616161);

  /// Current workout indicator
  static const Color currentWorkout = primary;

  /// Completed workout
  static const Color completedWorkout = success;

  /// Skipped workout
  static const Color skippedWorkout = Color(0xFF757575);

  /// Deload week
  static const Color recoveryPeriod = warning;

  // ========== OVERLAY COLORS ==========

  /// Modal/dialog overlay
  static const Color darkOverlay = Color(0xB3000000); // 70% black
  static const Color lightOverlay = Color(0x80000000); // 50% black

  // ========== HELPER METHODS ==========

  /// Get appropriate text color based on background luminance
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightTextPrimary : darkTextPrimary;
  }

  /// Get muscle group color by name
  static Color getMuscleColor(String muscleGroup) {
    final normalized = muscleGroup.toLowerCase();
    if (normalized.contains('chest') ||
        normalized.contains('tricep') ||
        normalized.contains('shoulder')) {
      return musclePink;
    } else if (normalized.contains('back') || normalized.contains('bicep')) {
      return muscleCyan;
    } else if (normalized.contains('quad') ||
        normalized.contains('hamstring') ||
        normalized.contains('glute') ||
        normalized.contains('calv')) {
      return muscleTeal;
    } else if (normalized.contains('trap') ||
        normalized.contains('forearm') ||
        normalized.contains('ab')) {
      return musclePurple;
    }
    return primary; // Default
  }
}
