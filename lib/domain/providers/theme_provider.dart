import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode notifier using Riverpod 3.0 Notifier pattern
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'theme_mode';

  @override
  ThemeMode build() {
    // Initialize with dark mode, then load from preferences
    _loadThemeMode();
    return ThemeMode.dark;
  }

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_key);

      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeModeString,
          orElse: () => ThemeMode.dark,
        );
      }
    } catch (e) {
      // If loading fails, keep default (dark mode)
      state = ThemeMode.dark;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (e) {
      // Error saving, but state is already updated
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Check if current mode is dark
  bool get isDarkMode => state == ThemeMode.dark;

  /// Check if current mode is light
  bool get isLightMode => state == ThemeMode.light;

  /// Check if current mode is system
  bool get isSystemMode => state == ThemeMode.system;
}

/// Provider for theme mode using NotifierProvider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

/// Provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});

/// Provider for checking if light mode is active
final isLightModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.light;
});

/// Provider for checking if system mode is active
final isSystemModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.system;
});
