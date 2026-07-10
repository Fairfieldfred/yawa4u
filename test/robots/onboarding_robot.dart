import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/presentation/screens/onboarding/onboarding_equipment_screen.dart';
import 'package:yawa4u/presentation/screens/onboarding/onboarding_profile_screen.dart';
import 'package:yawa4u/presentation/screens/onboarding/onboarding_sports_screen.dart';
import 'package:yawa4u/presentation/screens/onboarding/onboarding_terminology_screen.dart';
import 'package:yawa4u/presentation/screens/training_cycles/cycle_create_screen.dart';
import 'package:yawa4u/presentation/screens/workout/workout_screen.dart';

import '../harness/app_router_harness.dart';

/// Drives the first-run onboarding flow and the Workout tab's empty state.
class OnboardingRobot {
  OnboardingRobot(this.tester, this.harness);

  final WidgetTester tester;
  final AppRouterHarness harness;

  void expectOnProfileStep() {
    expect(find.byType(OnboardingProfileScreen), findsOneWidget);
  }

  /// Continues from the profile step WITHOUT filling height/weight —
  /// they're optional now.
  Future<void> continueFromProfileSkippingFields() async {
    final button = find.byKey(const ValueKey('onboarding_continue'));
    expect(button, findsOneWidget);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await harness.settle(tester);
    expect(find.byType(OnboardingSportsScreen), findsOneWidget);
  }

  /// Sports step: strength is pre-selected; continuing leads to equipment.
  Future<void> continueFromSports() async {
    await _tapFilledButton();
    expect(find.byType(OnboardingEquipmentScreen), findsOneWidget);
  }

  Future<void> continueFromEquipment() async {
    await _tapFilledButton();
    expect(find.byType(OnboardingTerminologyScreen), findsOneWidget);
  }

  /// Finishing onboarding lands on Home (not forced cycle creation).
  Future<void> finishOnboarding() async {
    await _tapFilledButton();
    expect(find.byType(WorkoutHomeScreen), findsOneWidget);
  }

  /// Taps the Workout tab's empty-state primary CTA.
  Future<void> tapCreateCycleCta() async {
    final cta = find.byKey(const ValueKey('empty_workout_create_cycle'));
    expect(cta, findsOneWidget);
    await tester.tap(cta);
    await harness.settle(tester);
    expect(find.byType(TrainingCycleCreateScreen), findsOneWidget);
  }

  Future<void> _tapFilledButton() async {
    final button = find.byType(FilledButton).last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await harness.settle(tester);
  }
}
