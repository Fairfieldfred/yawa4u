import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'text_styles.dart';

/// Theme mode options for the app
enum AppThemeMode { light, dark, system }

extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Custom theme extension for muscle group colors
@immutable
class MuscleGroupColors extends ThemeExtension<MuscleGroupColors> {
  final Color? upperPush;
  final Color? upperPull;
  final Color? legs;
  final Color? coreAndAccessories;

  const MuscleGroupColors({
    required this.upperPush,
    required this.upperPull,
    required this.legs,
    required this.coreAndAccessories,
  });

  @override
  MuscleGroupColors copyWith({
    Color? upperPush,
    Color? upperPull,
    Color? legs,
    Color? coreAndAccessories,
  }) {
    return MuscleGroupColors(
      upperPush: upperPush ?? this.upperPush,
      upperPull: upperPull ?? this.upperPull,
      legs: legs ?? this.legs,
      coreAndAccessories: coreAndAccessories ?? this.coreAndAccessories,
    );
  }

  @override
  MuscleGroupColors lerp(ThemeExtension<MuscleGroupColors>? other, double t) {
    if (other is! MuscleGroupColors) {
      return this;
    }
    return MuscleGroupColors(
      upperPush: Color.lerp(upperPush, other.upperPush, t),
      upperPull: Color.lerp(upperPull, other.upperPull, t),
      legs: Color.lerp(legs, other.legs, t),
      coreAndAccessories: Color.lerp(
        coreAndAccessories,
        other.coreAndAccessories,
        t,
      ),
    );
  }
}

/// Application theme configuration
class AppTheme {
  AppTheme._();

  // ========== DARK THEME ==========

  static ThemeData darkTheme = ThemeData(
    // Brightness
    brightness: Brightness.dark,
    useMaterial3: true,

    // Extensions
    extensions: const <ThemeExtension<dynamic>>[
      MuscleGroupColors(
        upperPush: Colors.pink,
        upperPull: Colors.cyan,
        legs: Colors.teal,
        coreAndAccessories: Colors.purple,
      ),
    ],

    // Color scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.info,
      secondaryContainer: AppColors.infoDark,
      surface: AppColors.darkCardBackground,
      error: AppColors.error,
      onPrimary: AppColors.darkTextPrimary,
      onSecondary: AppColors.darkTextPrimary,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.darkTextPrimary,
      outline: AppColors.darkDivider,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkScaffoldBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.screenTitle,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 24,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.darkCardBackground,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
        disabledBackgroundColor: AppColors.darkTextDisabled,
        disabledForegroundColor: AppColors.darkTextSecondary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkTextPrimary,
        disabledForegroundColor: AppColors.darkTextDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Icon button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.darkTextPrimary,
        disabledForegroundColor: AppColors.darkTextDisabled,
        iconSize: 24,
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.placeholder,
      labelStyle: AppTextStyles.inputLabel,
      floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.primary,
      ),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.checkboxChecked;
        }
        return AppColors.checkboxUnchecked;
      }),
      checkColor: WidgetStateProperty.all(AppColors.darkTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.darkTextDisabled.withValues(alpha: 0.3);
      }),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkInputBackground,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.darkTextDisabled,
      labelStyle: AppTextStyles.badgeText,
      secondaryLabelStyle: AppTextStyles.badgeText,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCardBackground,
      selectedItemColor: AppColors.darkTextPrimary,
      unselectedItemColor: AppColors.darkTextSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCardBackground,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextStyles.darkTextTheme.headlineMedium,
      contentTextStyle: AppTextStyles.darkTextTheme.bodyMedium,
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkCardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),

    // List tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: AppTextStyles.menuItem,
      subtitleTextStyle: AppTextStyles.subtitle,
      iconColor: AppColors.darkTextPrimary,
    ),

    // Text theme
    textTheme: AppTextStyles.darkTextTheme,

    // Icon theme
    iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 24),
  );

  // ========== LIGHT THEME ==========

  static ThemeData lightTheme = ThemeData(
    // Brightness
    brightness: Brightness.light,
    useMaterial3: true,

    // Extensions
    extensions: const <ThemeExtension<dynamic>>[
      MuscleGroupColors(
        upperPush: Colors.pink,
        upperPull: Colors.cyan,
        legs: Colors.teal,
        coreAndAccessories: Colors.purple,
      ),
    ],

    // Color scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.info,
      secondaryContainer: AppColors.infoLight,
      surface: AppColors.lightCardBackground,
      error: AppColors.error,
      onPrimary: AppColors.darkTextPrimary,
      onSecondary: AppColors.darkTextPrimary,
      onSurface: AppColors.lightTextPrimary,
      onError: AppColors.darkTextPrimary,
      outline: AppColors.lightDivider,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,

    // App bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightCardBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.screenTitle.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 24,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.lightCardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
        disabledBackgroundColor: AppColors.lightTextDisabled,
        disabledForegroundColor: AppColors.lightTextSecondary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Text button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightTextPrimary,
        disabledForegroundColor: AppColors.lightTextDisabled,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Icon button
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.lightTextPrimary,
        disabledForegroundColor: AppColors.lightTextDisabled,
        iconSize: 24,
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.placeholder.copyWith(
        color: AppColors.lightTextDisabled,
      ),
      labelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.primary,
      ),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppColors.lightTextDisabled, width: 2),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.success;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.lightTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.lightTextDisabled.withValues(alpha: 0.3);
      }),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightInputBackground,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.lightTextDisabled,
      labelStyle: AppTextStyles.badgeText.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      secondaryLabelStyle: AppTextStyles.badgeText.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCardBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCardBackground,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextStyles.lightTextTheme.headlineMedium,
      contentTextStyle: AppTextStyles.lightTextTheme.bodyMedium,
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightCardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),

    // List tile
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: AppTextStyles.menuItem.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      subtitleTextStyle: AppTextStyles.subtitle.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      iconColor: AppColors.lightTextPrimary,
    ),

    // Text theme
    textTheme: AppTextStyles.lightTextTheme,

    // Icon theme
    iconTheme: const IconThemeData(color: AppColors.lightTextPrimary, size: 24),
  );
}
