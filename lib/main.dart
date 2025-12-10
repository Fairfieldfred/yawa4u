import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:yawa4u/core/utils/canvas_kit/unsupported.dart';

import 'core/config/sentry_config.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/services/csv_loader_service.dart';
import 'data/services/database_service.dart';
import 'domain/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'presentation/navigation/app_router.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive database
  await DatabaseService().initialize();

  // Load exercises from CSV
  await CsvLoaderService().loadExercises();

  // Initialize Sentry and run app
  if (SentryConfig.shouldInitialize) {
    await SentryFlutter.init((options) {
      options.dsn = SentryConfig.dsn;
      options.environment = SentryConfig.environment;
      options.release = SentryConfig.release;
      options.tracesSampleRate = SentryConfig.tracesSampleRate;

      // IMPORTANT: Do not send PII (Personal Identifiable Information)
      options.sendDefaultPii = false;

      // Enable performance monitoring
      options.enableAutoPerformanceTracing = true;

      // Disable automatic breadcrumbs for sensitive data
      options.enableAutoNativeBreadcrumbs = false;

      // Session replay settings (optional)
      options.replay.sessionSampleRate = 0.0; // Disabled by default
      options.replay.onErrorSampleRate = 0.1; // 10% of errors

      // Before send callback to filter out sensitive data
      options.beforeSend = (event, hint) {
        // Filter out any events that might contain sensitive data
        // Add custom filtering logic here if needed
        return event;
      };
    }, appRunner: () => runApp(const ProviderScope(child: MyApp())));
  } else {
    runApp(
      ProviderScope(
        child: // * Don't wrap with BetterFeedback if web HTML renderer is used
            // https://pub.dev/packages/feedback#-known-issues-and-limitations
            !kIsWeb || isCanvasKitRenderer()
            ? BetterFeedback(child: MyApp())
            : MyApp(),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration with Riverpod
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router configuration
      // Router configuration
      routerConfig: router,
    );
  }
}
