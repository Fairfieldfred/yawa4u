import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale notifier using Riverpod 3.0 Notifier pattern.
///
/// Mirrors [ThemeModeNotifier] — stores a nullable [Locale] where `null`
/// means "follow the system locale" (analogous to [ThemeMode.system]).
class LocaleNotifier extends Notifier<Locale?> {
  static const String _key = 'user_locale';

  @override
  Locale? build() {
    _loadLocale();
    return null; // Default: follow system locale
  }

  /// Load persisted locale from SharedPreferences.
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        state = Locale(code);
      }
    } catch (_) {
      // If loading fails, keep default (system locale)
    }
  }

  /// Set locale and persist to SharedPreferences.
  ///
  /// Pass `null` to follow the system locale.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, locale.languageCode);
      }
    } catch (_) {
      // State is already updated even if persistence fails
    }
  }

  /// Whether the app is following the system locale.
  bool get isSystemLocale => state == null;
}

/// Provider for the user's locale override.
///
/// `null` means the app follows the device's system locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
