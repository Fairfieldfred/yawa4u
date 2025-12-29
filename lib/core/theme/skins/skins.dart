/// Skin system exports
///
/// This module provides a complete theming/skin system for the app.
library;

import 'package:flutter/material.dart';

import 'skin_builder.dart';
import 'skin_model.dart';

export 'built_in_skins/built_in_skins.dart';
export 'skin_builder.dart';
export 'skin_model.dart';
export 'skin_provider.dart';
export 'skin_repository.dart';

/// Extension on BuildContext to easily access skin-specific colors.
extension SkinContext on BuildContext {
  /// Get the SkinExtension from the current theme.
  /// Returns null if not available.
  SkinExtension? get skinColors {
    return Theme.of(this).extension<SkinExtension>();
  }

  /// Get success color from skin, with fallback.
  Color get successColor =>
      skinColors?.success ?? Theme.of(this).colorScheme.primary;

  /// Get warning color from skin, with fallback.
  Color get warningColor => skinColors?.warning ?? Colors.orange;

  /// Get info color from skin, with fallback.
  Color get infoColor =>
      skinColors?.info ?? Theme.of(this).colorScheme.secondary;

  /// Get error/danger color from theme (for destructive actions, errors).
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// Get current workout indicator color.
  Color get workoutCurrentColor =>
      skinColors?.workoutCurrent ?? Theme.of(this).colorScheme.primary;

  /// Get completed workout color.
  Color get workoutCompletedColor =>
      skinColors?.workoutCompleted ?? successColor;

  /// Get skipped workout color.
  Color get workoutSkippedColor =>
      skinColors?.workoutSkipped ?? Theme.of(this).disabledColor;

  /// Get deload week color.
  Color get workoutDeloadColor => skinColors?.workoutDeload ?? warningColor;

  /// Get YouTube/video red color (brand-specific, kept consistent).
  Color get youtubeColor => const Color(0xFFFF0000);

  /// Get selected/active indicator color (for radio buttons, checkboxes in menus).
  Color get selectedIndicatorColor => Theme.of(this).colorScheme.primary;

  /// Get the backgrounds configuration from the current skin.
  SkinBackgrounds? get backgrounds => skinColors?.backgrounds;

  /// Check if the current skin has any background images configured.
  bool get hasBackgrounds => backgrounds != null;

  /// Get input field border radius from skin, with fallback to 8.
  double get inputBorderRadius => skinColors?.inputBorderRadius ?? 8;
}
