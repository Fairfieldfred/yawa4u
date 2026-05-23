import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/services/onboarding_service.dart';

void main() {
  late OnboardingService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    service = OnboardingService(prefs);
  });

  group('Onboarding state', () {
    test('isOnboardingComplete defaults to false', () {
      expect(service.isOnboardingComplete, isFalse);
    });

    test('markOnboardingComplete sets to true', () async {
      await service.markOnboardingComplete();
      expect(service.isOnboardingComplete, isTrue);
    });

    test('isFirstTimeUser defaults to true', () {
      expect(service.isFirstTimeUser, isTrue);
    });

    test('markFirstTrainingCycleCreated makes isFirstTimeUser false', () async {
      await service.markFirstTrainingCycleCreated();
      expect(service.isFirstTimeUser, isFalse);
    });
  });

  group('User profile', () {
    test('heightCm defaults to null', () {
      expect(service.heightCm, isNull);
    });

    test('get/set heightCm', () async {
      await service.setHeightCm(182.5);
      expect(service.heightCm, equals(182.5));
    });

    test('weightKg defaults to null', () {
      expect(service.weightKg, isNull);
    });

    test('get/set weightKg', () async {
      await service.setWeightKg(84.3);
      expect(service.weightKg, equals(84.3));
    });

    test('useMetric defaults to false', () {
      expect(service.useMetric, isFalse);
    });

    test('get/set useMetric', () async {
      await service.setUseMetric(true);
      expect(service.useMetric, isTrue);
    });

    test('equipment defaults to empty list', () {
      expect(service.equipment, isEmpty);
    });

    test('get/set equipment', () async {
      await service.setEquipment(['barbell', 'dumbbell', 'cable']);
      expect(service.equipment, equals(['barbell', 'dumbbell', 'cable']));
    });

    test('equipmentFilterEnabled defaults to false', () {
      expect(service.equipmentFilterEnabled, isFalse);
    });

    test('get/set equipmentFilterEnabled', () async {
      await service.setEquipmentFilterEnabled(true);
      expect(service.equipmentFilterEnabled, isTrue);
    });

    test('trainingCycleTerm defaults to trainingCycle', () {
      expect(service.trainingCycleTerm, equals('trainingCycle'));
    });

    test('get/set trainingCycleTerm', () async {
      await service.setTrainingCycleTerm('block');
      expect(service.trainingCycleTerm, equals('block'));
    });

    test('appIconIndex defaults to 1', () {
      expect(service.appIconIndex, equals(1));
    });

    test('get/set appIconIndex', () async {
      await service.setAppIconIndex(3);
      expect(service.appIconIndex, equals(3));
    });
  });

  group('Optional body composition fields', () {
    test('bodyFatPercent defaults to null', () {
      expect(service.bodyFatPercent, isNull);
    });

    test('setBodyFatPercent stores value', () async {
      await service.setBodyFatPercent(15.5);
      expect(service.bodyFatPercent, equals(15.5));
    });

    test('setBodyFatPercent(null) removes key', () async {
      await service.setBodyFatPercent(15.5);
      await service.setBodyFatPercent(null);
      expect(service.bodyFatPercent, isNull);
    });

    test('leanMassKg defaults to null', () {
      expect(service.leanMassKg, isNull);
    });

    test('setLeanMassKg stores value', () async {
      await service.setLeanMassKg(71.0);
      expect(service.leanMassKg, equals(71.0));
    });

    test('setLeanMassKg(null) removes key', () async {
      await service.setLeanMassKg(71.0);
      await service.setLeanMassKg(null);
      expect(service.leanMassKg, isNull);
    });
  });

  group('Training cycle term display', () {
    test('trainingCycleDisplayName for block', () async {
      await service.setTrainingCycleTerm('block');
      expect(service.trainingCycleDisplayName, equals('Training Block'));
    });

    test('trainingCycleDisplayName for mesocycle', () async {
      await service.setTrainingCycleTerm('mesocycle');
      expect(service.trainingCycleDisplayName, equals('Mesocycle'));
    });

    test('trainingCycleDisplayName for phase', () async {
      await service.setTrainingCycleTerm('phase');
      expect(service.trainingCycleDisplayName, equals('Training Phase'));
    });

    test('trainingCycleDisplayName for module', () async {
      await service.setTrainingCycleTerm('module');
      expect(service.trainingCycleDisplayName, equals('Module'));
    });

    test('trainingCycleDisplayName for wave', () async {
      await service.setTrainingCycleTerm('wave');
      expect(service.trainingCycleDisplayName, equals('Training Wave'));
    });

    test('trainingCycleDisplayName defaults to Training Cycle', () {
      expect(service.trainingCycleDisplayName, equals('Training Cycle'));
    });

    test('trainingCycleDisplayNamePlural for block', () async {
      await service.setTrainingCycleTerm('block');
      expect(
        service.trainingCycleDisplayNamePlural,
        equals('Training Blocks'),
      );
    });

    test('trainingCycleDisplayNamePlural for mesocycle', () async {
      await service.setTrainingCycleTerm('mesocycle');
      expect(service.trainingCycleDisplayNamePlural, equals('Mesocycles'));
    });

    test('trainingCycleDisplayNamePlural for phase', () async {
      await service.setTrainingCycleTerm('phase');
      expect(
        service.trainingCycleDisplayNamePlural,
        equals('Training Phases'),
      );
    });

    test('trainingCycleDisplayNamePlural for module', () async {
      await service.setTrainingCycleTerm('module');
      expect(
        service.trainingCycleDisplayNamePlural,
        equals('Training Modules'),
      );
    });

    test('trainingCycleDisplayNamePlural for wave', () async {
      await service.setTrainingCycleTerm('wave');
      expect(
        service.trainingCycleDisplayNamePlural,
        equals('Training Waves'),
      );
    });

    test('trainingCycleDisplayNamePlural defaults to Training Cycles', () {
      expect(
        service.trainingCycleDisplayNamePlural,
        equals('Training Cycles'),
      );
    });
  });

  group('Per-sport units', () {
    test('unitsFor returns sport default when no explicit preference', () {
      // Run defaults to imperial per _sportDefaults
      expect(service.unitsFor(Sport.run), equals(UnitSystem.imperial));
      // Bike defaults to metric
      expect(service.unitsFor(Sport.bike), equals(UnitSystem.metric));
      // Swim defaults to metric
      expect(service.unitsFor(Sport.swim), equals(UnitSystem.metric));
    });

    test('unitsFor for strength falls back to global useMetric', () {
      // No sport default for strength, useMetric defaults to false
      expect(service.unitsFor(Sport.strength), equals(UnitSystem.imperial));
    });

    test('unitsFor for strength respects useMetric=true', () async {
      await service.setUseMetric(true);
      expect(service.unitsFor(Sport.strength), equals(UnitSystem.metric));
    });

    test('setUnitsFor overrides sport default', () async {
      await service.setUnitsFor(Sport.run, UnitSystem.metric);
      expect(service.unitsFor(Sport.run), equals(UnitSystem.metric));
    });

    test('explicit preference takes priority over sport default', () async {
      // Bike defaults to metric; override to imperial
      await service.setUnitsFor(Sport.bike, UnitSystem.imperial);
      expect(service.unitsFor(Sport.bike), equals(UnitSystem.imperial));
    });

    test('clearPerSportUnits restores defaults', () async {
      await service.setUnitsFor(Sport.run, UnitSystem.metric);
      await service.clearPerSportUnits();
      expect(service.unitsFor(Sport.run), equals(UnitSystem.imperial));
    });

    test('perSportUnits returns explicit preferences', () async {
      await service.setUnitsFor(Sport.run, UnitSystem.metric);
      await service.setUnitsFor(Sport.bike, UnitSystem.imperial);

      final prefs = service.perSportUnits;
      expect(prefs[Sport.run], equals(UnitSystem.metric));
      expect(prefs[Sport.bike], equals(UnitSystem.imperial));
      expect(prefs.containsKey(Sport.swim), isFalse);
    });

    test('perSportUnits handles malformed JSON gracefully', () async {
      // Write invalid JSON directly to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_per_sport_units', 'not-json');

      // Should return empty map, not throw
      expect(service.perSportUnits, isEmpty);
      // unitsFor should fall back to defaults
      expect(service.unitsFor(Sport.run), equals(UnitSystem.imperial));
    });
  });

  group('Selected sports', () {
    test('default is [strength]', () {
      expect(service.selectedSports, equals([Sport.strength]));
    });

    test('setSelectedSports normalizes order', () async {
      // Pass in non-canonical order (swim before run)
      await service.setSelectedSports([
        Sport.swim,
        Sport.strength,
        Sport.run,
      ]);

      // Should be reordered to match Sport.values order
      final selected = service.selectedSports;
      expect(selected, contains(Sport.strength));
      expect(selected, contains(Sport.run));
      expect(selected, contains(Sport.swim));
      // strength comes before run, run comes before swim in Sport.values
      expect(
        selected.indexOf(Sport.strength),
        lessThan(selected.indexOf(Sport.run)),
      );
      expect(
        selected.indexOf(Sport.run),
        lessThan(selected.indexOf(Sport.swim)),
      );
    });

    test('hasSport returns true for selected sports', () async {
      await service.setSelectedSports([Sport.strength, Sport.run]);
      expect(service.hasSport(Sport.strength), isTrue);
      expect(service.hasSport(Sport.run), isTrue);
      expect(service.hasSport(Sport.bike), isFalse);
      expect(service.hasSport(Sport.swim), isFalse);
    });

    test('hasSport defaults to true for strength only', () {
      expect(service.hasSport(Sport.strength), isTrue);
      expect(service.hasSport(Sport.run), isFalse);
    });
  });
}
