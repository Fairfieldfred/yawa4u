import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps a widget in the minimal scaffold needed for widget tests.
///
/// Provides [ProviderScope] → [MaterialApp] → [Scaffold] →
/// [SingleChildScrollView] → [child].
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(wrapForTest(MyWidget()));
/// ```
Widget wrapForTest(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}
