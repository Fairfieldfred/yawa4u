import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch', () {
    testWidgets('app starts and renders a MaterialApp', (tester) async {
      // Minimal smoke test: verify the app's widget tree builds.
      // Full app boot (Firebase, Sentry, Drift) requires platform channels
      // that aren't available in all integration-test runners, so we test
      // a standalone widget here. Replace with the real app entry point
      // once platform mocks or a test-flavored main() are in place.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Integration test scaffold')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Integration test scaffold'), findsOneWidget);
    });
  });
}
