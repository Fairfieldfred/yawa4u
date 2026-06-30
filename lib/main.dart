import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/utils/canvas_kit/unsupported.dart';

import 'core/constants/app_constants.dart';
import 'core/env/env.dart';
import 'core/services/sentry_service.dart';
import 'core/theme/skins/skins.dart';
import 'data/services/csv_loader_service.dart';
import 'data/services/database_service.dart';
import 'data/services/exercise_name_localizer.dart';
import 'data/services/firebase_auth_service.dart';
import 'domain/providers/onboarding_providers.dart';
import 'domain/providers/locale_provider.dart';
import 'domain/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'presentation/navigation/app_router.dart';

Future<void> main() async {
  // Use SentryWidgetsFlutterBinding for better Sentry integration
  SentryWidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Debug: Print environment status
  if (kDebugMode) {
    Env.debugPrintStatus();
  }

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Initialize Drift database
  await DatabaseService().initialize();

  // Initialize Skin Repository with SharedPreferences
  await SkinRepository().initialize(sharedPrefs);

  // Load exercises from CSV
  await CsvLoaderService().loadExercises();

  // Load exercise-name translations for display-time localization
  await ExerciseNameLocalizer().load();

  // Sign in anonymously for community library access (no-op if already signed in)
  await FirebaseAuthService().ensureSignedIn();

  // Create app widget with SharedPreferences override
  Widget createApp() => ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
    child: !kIsWeb || isCanvasKitRenderer() ? BetterFeedback(child: const MyApp()) : const MyApp(),
  );

  // Initialize Sentry using the service and run app
  await SentryService.instance.initialize(
    appRunner: () async {
      runApp(createApp());
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final skinState = ref.watch(skinProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization configuration
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Theme configuration from skin system
      theme: skinState.lightTheme,
      darkTheme: skinState.darkTheme,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,
    );
  }
}
