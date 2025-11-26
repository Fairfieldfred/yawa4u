import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _keyFirstMesocycleCreated = 'has_created_first_mesocycle';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Check if this is a first time user (hasn't created a mesocycle yet)
  bool get isFirstTimeUser {
    return !_prefs.containsKey(_keyFirstMesocycleCreated);
  }

  /// Mark that the user has created their first mesocycle
  Future<void> markFirstMesocycleCreated() async {
    await _prefs.setBool(_keyFirstMesocycleCreated, true);
  }
}
