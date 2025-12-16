import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/muscle_groups.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../screens/add_exercise_screen.dart';
import '../screens/completed_cycle_workout_screen.dart';
import '../screens/cycle_create_screen.dart';
import '../screens/edit_workout_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding/onboarding_profile_screen.dart';
import '../screens/plan_a_cycle_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sync_screen.dart';

/// Navigation routes
class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String trainingCycleList = '/trainingCycles';
  static const String planTrainingCycle = '/plan-trainingCycle';
  static const String trainingCycleCreate = '/trainingCycles/create';
  static const String workoutList = '/trainingCycles/:trainingCycleId/workouts';
  static const String completedTrainingCycleView =
      '/trainingCycles/:trainingCycleId/view';
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
      // Onboarding screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingProfileScreen(),
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

      // Edit workout screen for a trainingCycle
      GoRoute(
        path: '/trainingCycles/:trainingCycleId/workouts',
        name: 'workout-list',
        builder: (context, state) {
          final trainingCycleId = state.pathParameters['trainingCycleId']!;
          return EditWorkoutScreen(trainingCycleId: trainingCycleId);
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

      // Add exercise screen (choose from library)
      GoRoute(
        path:
            '/trainingCycles/:trainingCycleId/workouts/:workoutId/choose-exercise',
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

      // Sync screen
      GoRoute(
        path: '/sync',
        name: 'sync',
        builder: (context, state) => const SyncScreen(),
      ),

      // Settings screen
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
