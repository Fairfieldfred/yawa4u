import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/sports.dart';

/// Service to manage onboarding state and user preferences
class OnboardingService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyFirstTrainingCycleCreated = 'has_created_first_trainingCycle';
  static const String _keyHeightCm = 'user_height_cm';
  static const String _keyWeightKg = 'user_weight_kg';
  static const String _keyUseMetric = 'user_use_metric';
  static const String _keyEquipment = 'user_equipment';
  static const String _keyEquipmentFilterEnabled = 'equipment_filter_enabled';
  static const String _keyTrainingCycleTerm = 'user_training_cycle_term';
  static const String _keyAppIconIndex = 'user_app_icon_index';
  static const String _keyBodyFatPercent = 'user_body_fat_percent';
  static const String _keyLeanMassKg = 'user_lean_mass_kg';
  // v5 — per-sport unit preferences. Stored as a JSON Map<Sport.name,
  // UnitSystem.name> so it extends cleanly without a schema migration.
  static const String _keyPerSportUnits = 'user_per_sport_units';

  /// Sports the user said they care about during onboarding. Drives
  /// defaults on the cycle creator and hides UI for sports they never
  /// opted into. Users can always toggle this later in Settings.
  static const String _keySelectedSports = 'user_selected_sports';

  /// Sport-aware defaults used when the user hasn't explicitly set a
  /// per-sport preference. Matches real-world endurance conventions:
  /// strength lifters default to their overall [useMetric] preference,
  /// runners default to miles (US-heavy user base), cyclists default to km
  /// (cycling-world standard), and swimmers default to meters.
  ///
  /// These are overridden on a per-sport basis by [setUnitsFor].
  static const Map<Sport, UnitSystem> _sportDefaults = {
    Sport.run: UnitSystem.imperial,
    Sport.bike: UnitSystem.metric,
    Sport.swim: UnitSystem.metric,
    Sport.other: UnitSystem.metric,
  };

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
  bool get equipmentFilterEnabled => _prefs.getBool(_keyEquipmentFilterEnabled) ?? false;
  String get trainingCycleTerm => _prefs.getString(_keyTrainingCycleTerm) ?? 'trainingCycle';
  int get appIconIndex => _prefs.getInt(_keyAppIconIndex) ?? 1; // Default to center icon
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

  // ---------------------------------------------------------------------------
  // v5 — Per-sport unit preferences
  // ---------------------------------------------------------------------------

  Map<Sport, UnitSystem> _readPerSportUnits() {
    final raw = _prefs.getString(_keyPerSportUnits);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final out = <Sport, UnitSystem>{};
      decoded.forEach((sportName, unitName) {
        final sport = Sport.values.where((s) => s.name == sportName).firstOrNull;
        final unit = UnitSystem.values.where((u) => u.name == unitName).firstOrNull;
        if (sport != null && unit != null) out[sport] = unit;
      });
      return out;
    } on FormatException {
      return const {};
    }
  }

  Future<void> _writePerSportUnits(Map<Sport, UnitSystem> map) async {
    final encoded = jsonEncode({
      for (final e in map.entries) e.key.name: e.value.name,
    });
    await _prefs.setString(_keyPerSportUnits, encoded);
  }

  /// Resolved unit system for [sport]. Order of precedence:
  ///   1. Explicit per-sport preference written by [setUnitsFor].
  ///   2. Sport-specific default in [_sportDefaults] (e.g. bike → metric).
  ///   3. The legacy global [useMetric] preference, for back-compat with
  ///      pre-v5 users who only have one unit choice on record.
  UnitSystem unitsFor(Sport sport) {
    final explicit = _readPerSportUnits()[sport];
    if (explicit != null) return explicit;
    final sportDefault = _sportDefaults[sport];
    if (sportDefault != null) return sportDefault;
    return useMetric ? UnitSystem.metric : UnitSystem.imperial;
  }

  /// Write an explicit unit preference for [sport].
  Future<void> setUnitsFor(Sport sport, UnitSystem units) async {
    final current = Map<Sport, UnitSystem>.from(_readPerSportUnits());
    current[sport] = units;
    await _writePerSportUnits(current);
  }

  /// Clear every explicit per-sport preference so [unitsFor] falls back to
  /// defaults + [useMetric]. Primarily for tests and settings "reset".
  Future<void> clearPerSportUnits() async {
    await _prefs.remove(_keyPerSportUnits);
  }

  /// Snapshot of the current per-sport preferences (only sports the user
  /// has explicitly touched). Useful for the Settings → Units screen.
  Map<Sport, UnitSystem> get perSportUnits => _readPerSportUnits();

  // ---------------------------------------------------------------------------
  // v5 — Selected sports (onboarding + Settings).
  // ---------------------------------------------------------------------------

  /// The sports the user has opted into. Empty list means "unset" — we
  /// treat it as "strength only" for back-compat with users who onboarded
  /// before this field existed.
  List<Sport> get selectedSports {
    final raw = _prefs.getStringList(_keySelectedSports);
    if (raw == null || raw.isEmpty) return const [Sport.strength];
    final parsed = <Sport>[];
    for (final name in raw) {
      final sport = Sports.parse(name);
      if (sport != null) parsed.add(sport);
    }
    return parsed.isEmpty ? const [Sport.strength] : parsed;
  }

  Future<void> setSelectedSports(List<Sport> sports) async {
    // Normalize order so the stored list matches [Sport.values] order,
    // giving stable defaults wherever consumers iterate.
    final normalized = Sport.values.where(sports.contains).toList();
    await _prefs.setStringList(
      _keySelectedSports,
      normalized.map((s) => s.name).toList(),
    );
  }

  /// True if [sport] is enabled for this user. UI can use this to hide
  /// cardio surfaces from strength-only users and vice-versa.
  bool hasSport(Sport sport) => selectedSports.contains(sport);
}
