import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yawa4u/l10n/app_localizations.dart';

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

/// Enhanced widget test wrapper with support for GoRouter navigation
/// context, theme injection, and a custom [ProviderScope] builder for
/// Riverpod overrides.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   wrapForTestWithRouter(
///     MyScreen(),
///     providerScopeBuilder: (child) => ProviderScope(
///       overrides: [myProvider.overrideWithValue(mockValue)],
///       child: child,
///     ),
///     theme: ThemeData.dark(),
///   ),
/// );
/// ```
Widget wrapForTestWithRouter(
  Widget child, {
  ProviderScope Function(Widget child)? providerScopeBuilder,
  GoRouter? router,
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode themeMode = ThemeMode.light,
}) {
  final effectiveRouter = router ?? _defaultTestRouter(child);

  final app = MaterialApp.router(
    routerConfig: effectiveRouter,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? ThemeData.light(),
    darkTheme: darkTheme,
    themeMode: themeMode,
  );

  if (providerScopeBuilder != null) {
    return providerScopeBuilder(app);
  }

  return ProviderScope(child: app);
}

/// Creates a minimal GoRouter that displays [child] at the root path.
GoRouter _defaultTestRouter(Widget child) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    ],
  );
}
