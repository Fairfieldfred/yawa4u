import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/onboarding_service.dart';
import 'database_providers.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in main.dart');
});

/// Provider for OnboardingService
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingService(prefs);
});

/// User profile state class
class UserProfile {
  final double? heightCm;
  final double? weightKg;
  final bool useMetric;
  final List<String> equipment;
  final String trainingCycleTerm;
  final int appIconIndex;
  final double? bodyFatPercent;
  final double? leanMassKg;

  const UserProfile({
    this.heightCm,
    this.weightKg,
    this.useMetric = false,
    this.equipment = const [],
    this.trainingCycleTerm = 'trainingCycle',
    this.appIconIndex = 1,
    this.bodyFatPercent,
    this.leanMassKg,
  });

  UserProfile copyWith({
    double? heightCm,
    double? weightKg,
    bool? useMetric,
    List<String>? equipment,
    String? trainingCycleTerm,
    int? appIconIndex,
    double? bodyFatPercent,
    double? leanMassKg,
  }) {
    return UserProfile(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      useMetric: useMetric ?? this.useMetric,
      equipment: equipment ?? this.equipment,
      trainingCycleTerm: trainingCycleTerm ?? this.trainingCycleTerm,
      appIconIndex: appIconIndex ?? this.appIconIndex,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      leanMassKg: leanMassKg ?? this.leanMassKg,
    );
  }
}

/// User profile notifier using Riverpod 3.0 Notifier pattern
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final service = ref.watch(onboardingServiceProvider);
    return UserProfile(
      heightCm: service.heightCm,
      weightKg: service.weightKg,
      useMetric: service.useMetric,
      equipment: service.equipment,
      trainingCycleTerm: service.trainingCycleTerm,
      appIconIndex: service.appIconIndex,
      bodyFatPercent: service.bodyFatPercent,
      leanMassKg: service.leanMassKg,
    );
  }

  OnboardingService get _service => ref.read(onboardingServiceProvider);

  void updateProfile(double heightCm, double weightKg, bool useMetric) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      useMetric: useMetric,
    );
  }

  /// Save height and weight to both SharedPreferences and database
  Future<void> saveHeightAndWeight(
    double heightCm,
    double weightKg, {
    double? bodyFatPercent,
    double? leanMassKg,
  }) async {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      bodyFatPercent: bodyFatPercent,
      leanMassKg: leanMassKg,
    );

    // Save to SharedPreferences (for quick access)
    await _service.setHeightCm(heightCm);
    await _service.setWeightKg(weightKg);
    await _service.setBodyFatPercent(bodyFatPercent);
    await _service.setLeanMassKg(leanMassKg);

    // Save to database with timestamp (for BMI history tracking)
    final measurementRepo = ref.read(userMeasurementRepositoryProvider);
    await measurementRepo.add(
      heightCm: heightCm,
      weightKg: weightKg,
      bodyFatPercent: bodyFatPercent,
      leanMassKg: leanMassKg,
    );
  }

  void updateEquipment(List<String> equipment) {
    state = state.copyWith(equipment: equipment);
  }

  void updateTrainingCycleTerm(String term) {
    state = state.copyWith(trainingCycleTerm: term);
  }

  void updateAppIconIndex(int index) {
    state = state.copyWith(appIconIndex: index);
  }

  /// Save app icon index immediately (for settings changes)
  Future<void> saveAppIconIndex(int index) async {
    state = state.copyWith(appIconIndex: index);
    await _service.setAppIconIndex(index);
  }

  Future<void> completeOnboarding() async {
    // Save all data to SharedPreferences
    if (state.heightCm != null) {
      await _service.setHeightCm(state.heightCm!);
    }
    if (state.weightKg != null) {
      await _service.setWeightKg(state.weightKg!);
    }
    await _service.setUseMetric(state.useMetric);
    await _service.setEquipment(state.equipment);
    await _service.setTrainingCycleTerm(state.trainingCycleTerm);
    await _service.setAppIconIndex(state.appIconIndex);
    await _service.markOnboardingComplete();

    // Invalidate providers so router re-evaluates onboarding status
    ref.invalidate(onboardingServiceProvider);
    ref.invalidate(isOnboardingCompleteProvider);
  }
}

/// Provider for user profile using NotifierProvider
final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  () {
    return UserProfileNotifier();
  },
);

/// Provider to check if onboarding is complete
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.isOnboardingComplete;
});

/// Provider for the user's preferred trainingCycle term display name
final trainingCycleTermProvider = Provider<String>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.trainingCycleDisplayName;
});

/// Provider for the user's preferred trainingCycle term plural display name
final trainingCycleTermPluralProvider = Provider<String>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.trainingCycleDisplayNamePlural;
});

/// Provider for whether user prefers metric units
final useMetricProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.useMetric;
});

/// Provider for the weight unit label (kg or lbs)
final weightUnitProvider = Provider<String>((ref) {
  final useMetric = ref.watch(useMetricProvider);
  return useMetric ? 'kg' : 'lbs';
});

/// Provider for whether equipment filter is enabled
final equipmentFilterEnabledProvider = Provider<bool>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.equipmentFilterEnabled;
});

/// Provider for the user's selected equipment list
final selectedEquipmentProvider = Provider<List<String>>((ref) {
  final service = ref.watch(onboardingServiceProvider);
  return service.equipment;
});
