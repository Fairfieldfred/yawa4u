import 'package:flutter_test/flutter_test.dart';

import '../harness/app_router_harness.dart';
import '../robots/onboarding_robot.dart';

/// Journey: fresh install → onboarding (profile fields skipped) →
/// land on Home → tap empty-state "Create cycle" CTA → cycle create screen.
void main() {
  late AppRouterHarness harness;

  setUp(() async {
    harness = AppRouterHarness();
    await harness.initialize();
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets('fresh install funnels to Home and the create-cycle CTA', (tester) async {
    final robot = OnboardingRobot(tester, harness);

    await harness.pumpApp(tester);
    robot.expectOnProfileStep();

    await robot.continueFromProfileSkippingFields();
    await robot.continueFromSports();
    await robot.continueFromEquipment();
    await robot.finishOnboarding();

    await robot.tapCreateCycleCta();
  });
}
