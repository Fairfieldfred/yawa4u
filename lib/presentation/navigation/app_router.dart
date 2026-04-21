import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/muscle_groups.dart';
import '../../core/constants/sports.dart';
import '../../core/theme/skins/skins.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../screens/cardio/cardio_session_screen.dart';
import '../screens/cardio/interval_builder_screen.dart';
import '../screens/workout/add_exercise_screen.dart';
import '../screens/workout/completed_cycle_workout_screen.dart';
import '../screens/training_cycles/cycle_create_screen.dart';
import '../screens/workout/edit_workout_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_equipment_screen.dart';
import '../screens/onboarding/onboarding_profile_screen.dart';
import '../screens/onboarding/onboarding_sports_screen.dart';
import '../screens/onboarding/onboarding_terminology_screen.dart';
import '../screens/training_cycles/plan_a_cycle_screen.dart';
import '../screens/settings/sentry_debug_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/skin_selection_screen.dart';
import '../screens/settings/integrations_screen.dart';
import '../screens/settings/units_screen.dart';
import '../screens/settings/zones_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/settings/skin_share_screen.dart';
import '../screens/settings/sync_screen.dart';
import '../screens/settings/template_share_screen.dart';
import '../screens/settings/theme_editor_screen.dart';

/// Navigation routes
class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String trainingCycleList = '/trainingCycles';
  static const String planTrainingCycle = '/plan-trainingCycle';
  static const String trainingCycleCreate = '/trainingCycles/create';
  // UX review P1 #6: user-facing path uses "sessions"; legacy
  // "/workouts" still resolves via a redirect route for backward compat.
  static const String workoutList = '/trainingCycles/:trainingCycleId/sessions';
  static const String completedTrainingCycleView =
      '/trainingCycles/:trainingCycleId/view';
  static const String stats = '/stats';
  // v5 — multi-sport cardio
  static const String cardioSessionNew = '/cardio-session/new';
  static const String cardioSessionEdit = '/cardio-session/:sessionId';
  static const String cardioIntervals = '/cardio-session/:sessionId/intervals';
}

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Read onboarding status fresh each time redirect is called
      final isOnboardingComplete = ref
          .read(onboardingServiceProvider)
          .isOnboardingComplete;

      // If onboarding is not complete, redirect to onboarding
      // unless already on onboarding screens
      if (!isOnboardingComplete) {
        final isOnOnboarding = state.matchedLocation.startsWith('/onboarding');
        if (!isOnOnboarding) {
          return AppRoutes.onboarding;
        }
      }
      return null;
    },
    routes: [
      // Onboarding — first screen (profile).
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingProfileScreen(),
      ),

      // Onboarding — equipment selection.
      GoRoute(
        path: '/onboarding/equipment',
        name: 'onboarding-equipment',
        builder: (context, state) => const OnboardingEquipmentScreen(),
      ),

      // Onboarding — sport preference (v5).
      GoRoute(
        path: '/onboarding/sports',
        name: 'onboarding-sports',
        builder: (context, state) => const OnboardingSportsScreen(),
      ),

      // Onboarding — terminology selection (last step).
      GoRoute(
        path: '/onboarding/terminology',
        name: 'onboarding-terminology',
        builder: (context, state) => const OnboardingTerminologyScreen(),
      ),

      // Home screen with bottom navigation
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Plan a trainingCycle screen
      GoRoute(
        path: AppRoutes.planTrainingCycle,
        name: 'plan-trainingCycle',
        builder: (context, state) => const PlanATrainingCycleScreen(),
      ),

      // TrainingCycle creation screen
      GoRoute(
        path: AppRoutes.trainingCycleCreate,
        name: 'trainingCycle-create',
        builder: (context, state) => const TrainingCycleCreateScreen(),
      ),

      // Edit sessions screen for a trainingCycle.
      //
      // The route label uses "sessions" (UX review P1 #6) while the
      // underlying screen still reads strength Workouts from the
      // repository — that class name is kept one more major version to
      // avoid a big refactor blast.
      GoRoute(
        path: '/trainingCycles/:trainingCycleId/sessions',
        name: 'session-list',
        builder: (context, state) {
          final trainingCycleId = state.pathParameters['trainingCycleId']!;
          return EditWorkoutScreen(trainingCycleId: trainingCycleId);
        },
      ),

      // Back-compat redirect for the old "/workouts" path. Any deep
      // link or bookmark still works; go_router will rewrite to
      // "/sessions". Safe to remove in a later major version once no
      // external share URLs reference the old path.
      GoRoute(
        path: '/trainingCycles/:trainingCycleId/workouts',
        redirect: (context, state) {
          final id = state.pathParameters['trainingCycleId']!;
          return '/trainingCycles/$id/sessions';
        },
      ),

      // Read-only view of a completed trainingCycle
      GoRoute(
        path: '/trainingCycles/:trainingCycleId/view',
        name: 'completed-trainingCycle-view',
        builder: (context, state) {
          final trainingCycleId = state.pathParameters['trainingCycleId']!;
          return CompletedCycleWorkoutScreen(trainingCycleId: trainingCycleId);
        },
      ),

      // Add exercise screen (choose from library).
      //
      // Path uses "sessions" (UX review P1 #6). The `:workoutId` path
      // parameter keeps its historical name because [AddExerciseScreen]
      // still takes `workoutId:` — a schema-level rename is a larger
      // pass for another day.
      GoRoute(
        path:
            '/trainingCycles/:trainingCycleId/sessions/:workoutId/choose-exercise',
        name: 'add-exercise',
        builder: (context, state) {
          final trainingCycleId = state.pathParameters['trainingCycleId']!;
          final workoutId = state.pathParameters['workoutId']!;
          final muscleGroupParam = state.uri.queryParameters['muscleGroup'];

          MuscleGroup? initialMuscleGroup;
          if (muscleGroupParam != null) {
            try {
              initialMuscleGroup = MuscleGroup.values.firstWhere(
                (mg) => mg.name == muscleGroupParam,
              );
            } catch (_) {
              // Invalid muscle group, ignore
            }
          }

          return AddExerciseScreen(
            trainingCycleId: trainingCycleId,
            workoutId: workoutId,
            initialMuscleGroup: initialMuscleGroup,
          );
        },
      ),

      // Back-compat redirect for the legacy "/workouts/.../choose-exercise"
      // path. Preserves the query string (muscleGroup).
      GoRoute(
        path:
            '/trainingCycles/:trainingCycleId/workouts/:workoutId/choose-exercise',
        redirect: (context, state) {
          final tc = state.pathParameters['trainingCycleId']!;
          final wid = state.pathParameters['workoutId']!;
          final query = state.uri.query.isEmpty ? '' : '?${state.uri.query}';
          return '/trainingCycles/$tc/sessions/$wid/choose-exercise$query';
        },
      ),

      // Sync screen
      GoRoute(
        path: '/sync',
        name: 'sync',
        builder: (context, state) => const SyncScreen(),
      ),

      // Template share screen
      GoRoute(
        path: '/template-share',
        name: 'template-share',
        builder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          final autoStart = state.uri.queryParameters['autoStart'] == 'true';
          return TemplateShareScreen(
            preSelectedTemplateId: templateId,
            autoStart: autoStart,
          );
        },
      ),

      // Skin/Theme share screen
      GoRoute(
        path: '/skin-share',
        name: 'skin-share',
        builder: (context, state) {
          final skinId = state.uri.queryParameters['skinId'];
          final autoStart = state.uri.queryParameters['autoStart'] == 'true';
          return SkinShareScreen(
            preSelectedSkinId: skinId,
            autoStart: autoStart,
          );
        },
      ),

      // Skin/Theme selection screen
      GoRoute(
        path: '/skins',
        name: 'skins',
        builder: (context, state) => const SkinSelectionScreen(),
      ),

      // Theme editor screen (create new)
      GoRoute(
        path: '/theme-editor',
        name: 'theme-editor',
        builder: (context, state) => const ThemeEditorScreen(),
      ),

      // Theme editor screen (edit existing)
      GoRoute(
        path: '/theme-editor/:skinId',
        name: 'theme-editor-edit',
        builder: (context, state) {
          final skinId = state.pathParameters['skinId']!;
          return ThemeEditorScreen(skinId: skinId);
        },
      ),

      // Statistics screen
      GoRoute(
        path: AppRoutes.stats,
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),

      // Settings screen
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Sentry debug screen (debug builds only)
      if (kDebugMode)
        GoRoute(
          path: '/sentry-debug',
          name: 'sentry-debug',
          builder: (context, state) => const SentryDebugScreen(),
        ),

      // v5 — Settings → Units (per-sport unit overrides).
      GoRoute(
        path: '/settings/units',
        name: 'settings-units',
        builder: (context, state) => const UnitsScreen(),
      ),

      // v5 — Settings → Zones (per-sport training zones).
      GoRoute(
        path: '/settings/zones',
        name: 'settings-zones',
        builder: (context, state) => const ZonesScreen(),
      ),

      // Phase 5 — Settings → Integrations (Health / Peloton).
      GoRoute(
        path: '/settings/integrations',
        name: 'settings-integrations',
        builder: (context, state) => const IntegrationsScreen(),
      ),

      // v5 — Cardio session screens.
      // Create: /cardio-session/new?sport=run&trainingCycleId=...&period=1&day=2
      GoRoute(
        path: AppRoutes.cardioSessionNew,
        name: 'cardio-session-new',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final sport = params['sport'] != null
              ? Sports.parse(params['sport']!)
              : Sport.run;
          return CardioSessionScreen(
            sport: sport,
            trainingCycleId: params['trainingCycleId'],
            periodNumber: int.tryParse(params['period'] ?? ''),
            dayNumber: int.tryParse(params['day'] ?? ''),
          );
        },
      ),

      // Edit: /cardio-session/:sessionId
      GoRoute(
        path: AppRoutes.cardioSessionEdit,
        name: 'cardio-session-edit',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return CardioSessionScreen(sessionId: sessionId);
        },
      ),

      // Interval builder: /cardio-session/:sessionId/intervals
      GoRoute(
        path: AppRoutes.cardioIntervals,
        name: 'cardio-intervals',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return IntervalBuilderScreen(sessionId: sessionId);
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.errorColor),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
