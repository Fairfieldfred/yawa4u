import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state and user preferences
class OnboardingService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyFirstTrainingCycleCreated =
      'has_created_first_trainingCycle';
  static const String _keyHeightCm = 'user_height_cm';
  static const String _keyWeightKg = 'user_weight_kg';
  static const String _keyUseMetric = 'user_use_metric';
  static const String _keyEquipment = 'user_equipment';
  static const String _keyEquipmentFilterEnabled = 'equipment_filter_enabled';
  static const String _keyTrainingCycleTerm = 'user_training_cycle_term';
  static const String _keyAppIconIndex = 'user_app_icon_index';
  static const String _keyBodyFatPercent = 'user_body_fat_percent';
  static const String _keyLeanMassKg = 'user_lean_mass_kg';

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
  bool get equipmentFilterEnabled =>
      _prefs.getBool(_keyEquipmentFilterEnabled) ?? false;
  String get trainingCycleTerm =>
      _prefs.getString(_keyTrainingCycleTerm) ?? 'trainingCycle';
  int get appIconIndex =>
      _prefs.getInt(_keyAppIconIndex) ?? 1; // Default to center icon
  double? get bodyFatPercent => _prefs.getDouble(_keyBodyFatPercent);
  double? get leanMassKg => _prefs.getDouble(_keyLeanMassKg);

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

  Future<void> setEquipmentFilterEnabled(bool value) async {
    await _prefs.setBool(_keyEquipmentFilterEnabled, value);
  }

  Future<void> setTrainingCycleTerm(String value) async {
    await _prefs.setString(_keyTrainingCycleTerm, value);
  }

  Future<void> setAppIconIndex(int value) async {
    await _prefs.setInt(_keyAppIconIndex, value);
  }

  Future<void> setBodyFatPercent(double? value) async {
    if (value != null) {
      await _prefs.setDouble(_keyBodyFatPercent, value);
    } else {
      await _prefs.remove(_keyBodyFatPercent);
    }
  }

  Future<void> setLeanMassKg(double? value) async {
    if (value != null) {
      await _prefs.setDouble(_keyLeanMassKg, value);
    } else {
      await _prefs.remove(_keyLeanMassKg);
    }
  }

  /// Get display name for the trainingCycle term
  String get trainingCycleDisplayName {
    switch (trainingCycleTerm) {
      case 'block':
        return 'Training Block';
      case 'mesocycle':
        return 'Mesocycle';
      case 'phase':
        return 'Training Phase';
      case 'module':
        return 'Module';
      case 'wave':
        return 'Training Wave';
      default:
        return 'Training Cycle';
    }
  }

  /// Get plural display name for the trainingCycle term
  String get trainingCycleDisplayNamePlural {
    switch (trainingCycleTerm) {
      case 'block':
        return 'Training Blocks';
      case 'mesocycle':
        return 'Mesocycles';
      case 'phase':
        return 'Training Phases';
      case 'module':
        return 'Training Modules';
      case 'wave':
        return 'Training Waves';
      default:
        return 'Training Cycles';
    }
  }
}
