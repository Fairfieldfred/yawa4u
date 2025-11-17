import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'firebase_options.dart';
import 'core/config/sentry_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Sentry and run app
  if (SentryConfig.shouldInitialize) {
    await SentryFlutter.init(
      (options) {
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
      },
      appRunner: () => runApp(const MyApp()),
    );
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark theme

      // Home page - will be replaced with proper routing later
      home: const PlaceholderHomePage(),
    );
  }
}

/// Placeholder home page until we implement the actual UI
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ${AppConstants.appName}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Track your mesocycles, workouts, and progress',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            Text(
              'Setting up your gym...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
