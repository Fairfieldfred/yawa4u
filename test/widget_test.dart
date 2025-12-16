// This is a basic Flutter widget test for Yawa4u app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/main.dart';

void main() {
  testWidgets('App loads and shows welcome screen', (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify that app name is displayed
    expect(find.text('YAWA4U'), findsWidgets);

    // Verify welcome message
    expect(find.text('Welcome to YAWA4U'), findsOneWidget);

    // Verify description text
    expect(
      find.text('Track your trainingCycles, workouts, and progress'),
      findsOneWidget,
    );

    // Verify database status card
    expect(find.text('Database Status'), findsOneWidget);

    // Verify fitness icon
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });

  testWidgets('Database status labels are displayed', (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verify database status items are present (regardless of initialization state)
    expect(find.text('Database'), findsOneWidget);
    expect(find.text('Exercises Library'), findsOneWidget);
    expect(find.text('TrainingCycles'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Exercises Logged'), findsOneWidget);
  });

  testWidgets('Theme is applied correctly', (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Find the MaterialApp widget
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    // Verify dark theme is set as default
    expect(materialApp.themeMode, ThemeMode.dark);

    // Verify both themes are configured
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
  });
}
