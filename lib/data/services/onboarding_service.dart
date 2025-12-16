import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state and user preferences
class OnboardingService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyFirstTrainingCycleCreated = 'has_created_first_trainingCycle';
  static const String _keyHeightCm = 'user_height_cm';
  static const String _keyWeightKg = 'user_weight_kg';
  static const String _keyUseMetric = 'user_use_metric';
  static const String _keyEquipment = 'user_equipment';
  static const String _keyTrainingCycleTerm = 'user_training_cycle_term';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Check if onboarding has been completed
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> markOnboardingComplete() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
  }

  /// Check if this is a first time user (hasn't created a trainingCycle yet)
  bool get isFirstTimeUser {
    return !_prefs.containsKey(_keyFirstTrainingCycleCreated);
  }

  /// Mark that the user has created their first trainingCycle
  Future<void> markFirstTrainingCycleCreated() async {
    await _prefs.setBool(_keyFirstTrainingCycleCreated, true);
  }

  // User profile getters
  double? get heightCm => _prefs.getDouble(_keyHeightCm);
  double? get weightKg => _prefs.getDouble(_keyWeightKg);
  bool get useMetric => _prefs.getBool(_keyUseMetric) ?? false;
  List<String> get equipment => _prefs.getStringList(_keyEquipment) ?? [];
  String get trainingCycleTerm =>
      _prefs.getString(_keyTrainingCycleTerm) ?? 'trainingCycle';

  // User profile setters
  Future<void> setHeightCm(double value) async {
    await _prefs.setDouble(_keyHeightCm, value);
  }

  Future<void> setWeightKg(double value) async {
    await _prefs.setDouble(_keyWeightKg, value);
  }

  Future<void> setUseMetric(bool value) async {
    await _prefs.setBool(_keyUseMetric, value);
  }

  Future<void> setEquipment(List<String> value) async {
    await _prefs.setStringList(_keyEquipment, value);
  }

  Future<void> setTrainingCycleTerm(String value) async {
    await _prefs.setString(_keyTrainingCycleTerm, value);
  }

  /// Get display name for the trainingCycle term
  String get trainingCycleDisplayName {
    switch (trainingCycleTerm) {
      case 'block':
        return 'Block';
      case 'phase':
        return 'Phase';
      case 'module':
        return 'Module';
      case 'wave':
        return 'Wave';
      case 'trainingCycle':
      default:
        return 'TrainingCycle';
    }
  }

  /// Get plural display name for the trainingCycle term
  String get trainingCycleDisplayNamePlural {
    switch (trainingCycleTerm) {
      case 'block':
        return 'Blocks';
      case 'phase':
        return 'Phases';
      case 'module':
        return 'Modules';
      case 'wave':
        return 'Waves';
      case 'trainingCycle':
      default:
        return 'TrainingCycles';
    }
  }
}
