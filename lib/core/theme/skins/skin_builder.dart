import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../text_styles.dart';
import 'skin_model.dart';

/// Builds Flutter [ThemeData] from a [SkinModel].
///
/// This class converts the skin's configuration into usable Flutter themes.
class SkinBuilder {
  const SkinBuilder._();

  /// Build a complete [ThemeData] for the given skin and brightness.
  static ThemeData buildTheme(SkinModel skin, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final modeColors = isDark ? skin.darkMode : skin.lightMode;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,

      // Extensions
      extensions: <ThemeExtension<dynamic>>[
        MuscleGroupColors(
          upperPush: skin.muscleGroups.upperPushColor,
          upperPull: skin.muscleGroups.upperPullColor,
          legs: skin.muscleGroups.legsColor,
          coreAndAccessories: skin.muscleGroups.coreAndAccessoriesColor,
        ),
        SkinExtension(
          workoutCurrent: skin.workoutStatus.currentColor,
          workoutCompleted: skin.workoutStatus.completedColor,
          workoutSkipped: skin.workoutStatus.skippedColor,
          workoutDeload: skin.workoutStatus.deloadColor,
          success: skin.colors.successColor,
          warning: skin.colors.warningColor,
          info: skin.colors.infoColor,
          backgrounds: skin.backgrounds,
          inputBorderRadius: skin.components.inputBorderRadius,
        ),
      ],

      // Color scheme
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: skin.colors.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: isDark
            ? skin.colors.primaryColor.withValues(alpha: 0.3)
            : skin.colors.primaryLightColor.withValues(alpha: 0.4),
        onPrimaryContainer: isDark
            ? Colors.white
            : skin.colors.primaryDarkColor,
        secondary: skin.colors.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: isDark
            ? skin.colors.secondaryColor.withValues(alpha: 0.3)
            : skin.colors.secondaryColor.withValues(alpha: 0.25),
        onSecondaryContainer: isDark
            ? Colors.white
            : skin.colors.secondaryColor,
        surface: modeColors.cardBackgroundColor,
        onSurface: modeColors.textPrimaryColor,
        surfaceContainerHighest: modeColors.inputBackgroundColor,
        error: skin.colors.errorColor,
        onError: Colors.white,
        outline: modeColors.dividerColor,
        outlineVariant: modeColors.dividerColor.withValues(alpha: 0.5),
      ),

      // Scaffold
      scaffoldBackgroundColor: modeColors.scaffoldBackgroundColor,

      // Divider
      dividerColor: modeColors.dividerColor,
      dividerTheme: DividerThemeData(
        color: modeColors.dividerColor,
        thickness: 1,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: modeColors.scaffoldBackgroundColor,
        foregroundColor: modeColors.textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.screenTitle.copyWith(
          color: modeColors.textPrimaryColor,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: modeColors.textPrimaryColor, size: 24),
      ),

      // Card
      cardTheme: CardThemeData(
        color: modeColors.cardBackgroundColor,
        elevation: skin.components.cardElevation,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.components.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: skin.colors.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: modeColors.textDisabledColor,
          disabledForegroundColor: modeColors.textSecondaryColor,
          elevation: skin.components.buttonElevation,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              skin.components.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Filled button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: skin.colors.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: modeColors.textDisabledColor,
          disabledForegroundColor: modeColors.textSecondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              skin.components.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: skin.colors.primaryColor,
          disabledForegroundColor: modeColors.textDisabledColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: skin.colors.primaryColor,
          disabledForegroundColor: modeColors.textDisabledColor,
          side: BorderSide(color: skin.colors.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              skin.components.buttonBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Icon button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: modeColors.textPrimaryColor,
          disabledForegroundColor: modeColors.textDisabledColor,
          iconSize: 24,
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: skin.colors.primaryColor,
        foregroundColor: Colors.white,
        elevation: skin.components.buttonElevation + 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            skin.components.buttonBorderRadius + 8,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: modeColors.inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            skin.components.inputBorderRadius,
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            skin.components.inputBorderRadius,
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            skin.components.inputBorderRadius,
          ),
          borderSide: BorderSide(color: skin.colors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            skin.components.inputBorderRadius,
          ),
          borderSide: BorderSide(color: skin.colors.errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            skin.components.inputBorderRadius,
          ),
          borderSide: BorderSide(color: skin.colors.errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: modeColors.textSecondaryColor),
        hintStyle: TextStyle(color: modeColors.textDisabledColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return skin.colors.successColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: modeColors.textSecondaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return skin.colors.primaryColor;
          }
          return modeColors.textDisabledColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return skin.colors.primaryColor.withValues(alpha: 0.5);
          }
          return modeColors.dividerColor;
        }),
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: skin.colors.primaryColor,
        linearTrackColor: modeColors.dividerColor,
        circularTrackColor: modeColors.dividerColor,
      ),

      // Bottom navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: modeColors.cardBackgroundColor,
        selectedItemColor: skin.colors.primaryColor,
        unselectedItemColor: modeColors.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: modeColors.cardBackgroundColor,
        indicatorColor: skin.colors.primaryColor.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: skin.colors.primaryColor);
          }
          return IconThemeData(color: modeColors.textSecondaryColor);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: skin.colors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(color: modeColors.textSecondaryColor, fontSize: 12);
        }),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: modeColors.cardBackgroundColor,
        titleTextStyle: TextStyle(
          color: modeColors.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: modeColors.textSecondaryColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.components.cardBorderRadius),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? modeColors.cardBackgroundColor
            : const Color(0xFF323232),
        contentTextStyle: TextStyle(
          color: isDark ? modeColors.textPrimaryColor : Colors.white,
        ),
        actionTextColor: skin.colors.primaryLightColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(skin.components.cardBorderRadius),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: modeColors.inputBackgroundColor,
        selectedColor: skin.colors.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: modeColors.textPrimaryColor),
        secondaryLabelStyle: TextStyle(color: skin.colors.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            skin.components.buttonBorderRadius,
          ),
        ),
      ),

      // List tile
      listTileTheme: ListTileThemeData(
        iconColor: modeColors.textSecondaryColor,
        textColor: modeColors.textPrimaryColor,
        subtitleTextStyle: TextStyle(color: modeColors.textSecondaryColor),
      ),

      // Text theme
      textTheme:
          (isDark ? AppTextStyles.darkTextTheme : AppTextStyles.lightTextTheme)
              .apply(
                bodyColor: modeColors.textPrimaryColor,
                displayColor: modeColors.textPrimaryColor,
              ),
    );
  }
}

/// Theme extension for additional skin-specific colors.
@immutable
class SkinExtension extends ThemeExtension<SkinExtension> {
  final Color workoutCurrent;
  final Color workoutCompleted;
  final Color workoutSkipped;
  final Color workoutDeload;
  final Color success;
  final Color warning;
  final Color info;
  final SkinBackgrounds? backgrounds;
  final double inputBorderRadius;

  const SkinExtension({
    required this.workoutCurrent,
    required this.workoutCompleted,
    required this.workoutSkipped,
    required this.workoutDeload,
    required this.success,
    required this.warning,
    required this.info,
    this.backgrounds,
    this.inputBorderRadius = 8,
  });

  @override
  SkinExtension copyWith({
    Color? workoutCurrent,
    Color? workoutCompleted,
    Color? workoutSkipped,
    Color? workoutDeload,
    Color? success,
    Color? warning,
    Color? info,
    SkinBackgrounds? backgrounds,
    double? inputBorderRadius,
  }) {
    return SkinExtension(
      workoutCurrent: workoutCurrent ?? this.workoutCurrent,
      workoutCompleted: workoutCompleted ?? this.workoutCompleted,
      workoutSkipped: workoutSkipped ?? this.workoutSkipped,
      workoutDeload: workoutDeload ?? this.workoutDeload,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      backgrounds: backgrounds ?? this.backgrounds,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
    );
  }

  @override
  SkinExtension lerp(ThemeExtension<SkinExtension>? other, double t) {
    if (other is! SkinExtension) {
      return this;
    }
    return SkinExtension(
      workoutCurrent: Color.lerp(workoutCurrent, other.workoutCurrent, t)!,
      workoutCompleted: Color.lerp(
        workoutCompleted,
        other.workoutCompleted,
        t,
      )!,
      workoutSkipped: Color.lerp(workoutSkipped, other.workoutSkipped, t)!,
      workoutDeload: Color.lerp(workoutDeload, other.workoutDeload, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      // Backgrounds don't lerp, just take the target
      backgrounds: t < 0.5 ? backgrounds : other.backgrounds,
      // Lerp the border radius
      inputBorderRadius:
          lerpDouble(inputBorderRadius, other.inputBorderRadius, t) ??
          inputBorderRadius,
    );
  }
}
