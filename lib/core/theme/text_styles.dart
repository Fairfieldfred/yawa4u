import 'package:flutter/material.dart';

import 'colors.dart';

/// Typography scale for Yawa4u app
/// Based on Material Design 3 and UI screenshots
class AppTextStyles {
  AppTextStyles._();

  // Font family (using default system font)
  static const String fontFamily = 'System';

  // ========== DARK THEME TEXT STYLES ==========

  static TextTheme darkTextTheme = TextTheme(
    // Display styles (largest text)
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: -0.25,
    ),

    // Headline styles (screen titles, section headers)
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0,
    ),

    // Title styles (card titles, list item titles)
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.1,
    ),

    // Body styles (main content text)
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.25,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.darkTextSecondary,
      letterSpacing: 0.4,
      height: 1.3,
    ),

    // Label styles (buttons, badges, tags)
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextSecondary,
      letterSpacing: 0.5,
    ),
  );

  // ========== LIGHT THEME TEXT STYLES ==========

  static TextTheme lightTextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: -0.25,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.1,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.25,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.lightTextSecondary,
      letterSpacing: 0.4,
      height: 1.3,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextSecondary,
      letterSpacing: 0.5,
    ),
  );

  // ========== CUSTOM TEXT STYLES ==========
  // Specific to Yawa4u UI patterns

  /// Screen title style (large, bold, white)
  /// Example: "WEEK 2 DAY 4 Friday"
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0,
  );

  /// Subtitle/metadata style (small, gray, uppercase)
  /// Example: "SECOND TRAINING CYCLE CASEY KELLY", "MACHINE"
  static const TextStyle subtitle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextSecondary,
    letterSpacing: 0.5,
  );

  /// Exercise name style (large, bold)
  /// Example: "Machine Chest Press (Incline)"
  static const TextStyle exerciseName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0,
  );

  /// Badge/chip text style (small, uppercase, bold)
  /// Example: "CHEST", "6 / WEEK", "MALE"
  static const TextStyle badgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0.8,
  );

  /// Input field label style
  /// Example: "WEIGHT", "REPS", "LOG"
  static const TextStyle inputLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextSecondary,
    letterSpacing: 1.0,
  );

  /// Input field value style
  /// Example: "142.5", "8", "2 RIR"
  static const TextStyle inputValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0,
  );

  /// Button text style (uppercase, bold)
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: 1.0,
  );

  /// Menu item text style
  static const TextStyle menuItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextPrimary,
    letterSpacing: 0,
  );

  /// Section header style (uppercase, gray)
  /// Example: "TRAINING CYCLE", "WORKOUT", "SET TYPE"
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextSecondary,
    letterSpacing: 1.2,
  );

  /// Placeholder text style
  static const TextStyle placeholder = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextDisabled,
    letterSpacing: 0.25,
    fontStyle: FontStyle.italic,
  );
}
