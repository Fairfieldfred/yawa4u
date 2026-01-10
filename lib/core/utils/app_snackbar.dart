import 'package:flutter/material.dart';

import '../theme/skins/skins.dart';

/// Helper class for showing themed snack bars.
class AppSnackBar {
  AppSnackBar._();

  /// Show a success snackbar with themed colors.
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an error snackbar with themed colors.
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a warning snackbar with themed colors.
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.warningColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show an info snackbar with themed colors.
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.infoColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
