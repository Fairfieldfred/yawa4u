import 'package:flutter/material.dart';

/// Extension methods for BuildContext
/// Provides convenient access to theme, media query, navigator, etc.
extension ContextExtensions on BuildContext {
  // ========== THEME ==========

  /// Get the current ThemeData
  ThemeData get theme => Theme.of(this);

  /// Get the current ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get the current TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode is active
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode is active
  bool get isLightMode => theme.brightness == Brightness.light;

  // ========== MEDIA QUERY ==========

  /// Get MediaQueryData
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get screen orientation
  Orientation get orientation => mediaQuery.orientation;

  /// Check if device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;

  /// Get device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Get text scaler
  TextScaler get textScaler => mediaQuery.textScaler;

  /// Get text scale factor (for compatibility)
  double get textScaleFactor => mediaQuery.textScaler.scale(1.0);

  /// Get safe area padding (e.g., for notches, status bar)
  EdgeInsets get padding => mediaQuery.padding;

  /// Get view insets (e.g., keyboard height)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ========== RESPONSIVE BREAKPOINTS ==========

  /// Check if screen is small (< 600dp)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (600-840dp)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 840;

  /// Check if screen is large (>= 840dp)
  bool get isLargeScreen => screenWidth >= 840;

  /// Check if device is likely a phone
  bool get isPhone => screenWidth < 600;

  /// Check if device is likely a tablet
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// Check if device is likely a desktop
  bool get isDesktop => screenWidth >= 1200;

  // ========== NAVIGATOR ==========

  /// Get NavigatorState
  NavigatorState get navigator => Navigator.of(this);

  /// Pop the current route
  void pop<T>([T? result]) => navigator.pop(result);

  /// Check if can pop
  bool get canPop => navigator.canPop();

  /// Push a new route
  Future<T?> push<T>(Route<T> route) => navigator.push(route);

  /// Push a named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }

  /// Push and remove until
  Future<T?> pushAndRemoveUntil<T>(
    Route<T> newRoute,
    bool Function(Route<dynamic>) predicate,
  ) {
    return navigator.pushAndRemoveUntil(newRoute, predicate);
  }

  /// Replace current route
  Future<T?> pushReplacement<T, TO>(Route<T> newRoute, {TO? result}) {
    return navigator.pushReplacement(newRoute, result: result);
  }

  // ========== SCAFFOLD ==========

  /// Get ScaffoldMessengerState
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Show a SnackBar
  void showSnackBar(String message, {Duration? duration}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show an error SnackBar
  void showErrorSnackBar(String message, {Duration? duration}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Show a success SnackBar
  void showSuccessSnackBar(String message, {Duration? duration}) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  // ========== FOCUS ==========

  /// Unfocus the current focus (dismiss keyboard)
  void unfocus() {
    FocusScope.of(this).unfocus();
  }

  /// Request focus for a FocusNode
  void requestFocus(FocusNode node) {
    FocusScope.of(this).requestFocus(node);
  }

  // ========== DIALOGS ==========

  /// Show a simple alert dialog
  Future<bool?> showAlertDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showAlertDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
    );
    return result ?? false;
  }

  /// Show a delete confirmation dialog
  Future<bool> showDeleteConfirmDialog({required String itemName}) {
    return showConfirmDialog(
      title: 'Delete $itemName?',
      message: 'This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );
  }

  /// Show a loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message ?? 'Loading...')),
          ],
        ),
      ),
    );
  }

  /// Dismiss the current dialog
  void dismissDialog() {
    if (canPop) pop();
  }

  // ========== BOTTOM SHEET ==========

  /// Show a modal bottom sheet
  Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  // ========== ACCESSIBILITY ==========

  /// Check if accessibility features are enabled
  bool get accessibilityEnabled => mediaQuery.accessibleNavigation;

  /// Check if bold text is enabled
  bool get boldTextEnabled => mediaQuery.boldText;

  /// Get platform brightness
  Brightness get platformBrightness => mediaQuery.platformBrightness;

  // ========== LOCALIZATION ==========

  /// Get current locale
  Locale get locale => Localizations.localeOf(this);

  /// Get current language code
  String get languageCode => locale.languageCode;

  // ========== UTILITY ==========

  /// Get safe area height (screen height - status bar - bottom insets)
  double get safeAreaHeight =>
      screenHeight - padding.top - padding.bottom - viewInsets.bottom;

  /// Get safe area width
  double get safeAreaWidth => screenWidth - padding.left - padding.right;

  /// Calculate responsive size based on screen width
  /// baseSize: size at 375dp width (standard mobile width)
  double responsiveSize(double baseSize) {
    return baseSize * (screenWidth / 375);
  }

  /// Get horizontal padding based on screen size
  double get responsiveHorizontalPadding {
    if (isPhone) return 16;
    if (isTablet) return 24;
    return 32;
  }

  /// Get vertical padding based on screen size
  double get responsiveVerticalPadding {
    if (isPhone) return 16;
    if (isTablet) return 20;
    return 24;
  }
}
