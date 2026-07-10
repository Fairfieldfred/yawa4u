import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/presentation/navigation/app_router.dart';
import 'package:yawa4u/presentation/screens/calendar/calendar_screen.dart';
import 'package:yawa4u/presentation/screens/training_cycles/cycle_list_screen.dart';
import 'package:yawa4u/presentation/screens/training_cycles/template_selection_screen.dart';

import '../harness/app_router_harness.dart';

/// Journey: tabs are real routes — deep-linking to '/calendar' renders the
/// Calendar tab, and popping a pushed screen returns to the tab it was
/// pushed from.
void main() {
  late AppRouterHarness harness;

  setUp(() async {
    harness = AppRouterHarness();
    // Onboarding already complete so the redirect lets us at the tabs.
    await harness.initialize(initialPrefs: {'onboarding_complete': true});
  });

  tearDown(() async {
    await harness.dispose();
  });

  testWidgets('deep-linking /calendar renders the Calendar tab', (tester) async {
    await harness.pumpApp(tester);

    final router = harness.container.read(routerProvider);
    router.go('/calendar');
    await harness.settle(tester);

    expect(find.byType(CalendarScreen), findsOneWidget);
  });

  testWidgets('back from pushed template screen returns to the Cycles tab', (tester) async {
    await harness.pumpApp(tester);

    final router = harness.container.read(routerProvider);
    router.go('/cycles');
    await harness.settle(tester);
    expect(find.byType(CycleListScreen), findsOneWidget);

    router.push('/templates');
    await harness.settle(tester);
    expect(find.byType(TemplateSelectionScreen), findsOneWidget);

    router.pop();
    await harness.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await harness.settle(tester);
    expect(find.byType(TemplateSelectionScreen), findsNothing);
    expect(find.byType(CycleListScreen), findsOneWidget);
  });
}
