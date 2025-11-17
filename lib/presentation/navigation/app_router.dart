import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/muscle_groups.dart';
import '../screens/home_screen.dart';
import '../screens/mesocycle_create_screen.dart';
import '../screens/workout_list_screen.dart';
import '../screens/workout_detail_screen.dart';
import '../screens/exercise_log_screen.dart';
import '../screens/exercise_selection_screen.dart';
import '../screens/add_exercise_screen.dart';

/// Navigation routes
class AppRoutes {
  static const String home = '/';
  static const String mesocycleList = '/mesocycles';
  static const String mesocycleCreate = '/mesocycles/create';
  static const String workoutList = '/mesocycles/:mesocycleId/workouts';
  static const String workoutDetail = '/mesocycles/:mesocycleId/workouts/:workoutId';
  static const String exerciseLog = '/mesocycles/:mesocycleId/workouts/:workoutId/exercises/:exerciseId';
}

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // Home screen with bottom navigation
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Mesocycle creation screen
      GoRoute(
        path: AppRoutes.mesocycleCreate,
        name: 'mesocycle-create',
        builder: (context, state) => const MesocycleCreateScreen(),
      ),

      // Workout list screen for a mesocycle
      GoRoute(
        path: '/mesocycles/:mesocycleId/workouts',
        name: 'workout-list',
        builder: (context, state) {
          final mesocycleId = state.pathParameters['mesocycleId']!;
          return WorkoutListScreen(mesocycleId: mesocycleId);
        },
      ),

      // Workout detail screen
      GoRoute(
        path: '/mesocycles/:mesocycleId/workouts/:workoutId',
        name: 'workout-detail',
        builder: (context, state) {
          final mesocycleId = state.pathParameters['mesocycleId']!;
          final workoutId = state.pathParameters['workoutId']!;
          return WorkoutDetailScreen(
            mesocycleId: mesocycleId,
            workoutId: workoutId,
          );
        },
      ),

      // Exercise selection screen (add exercise to workout)
      GoRoute(
        path: '/mesocycles/:mesocycleId/workouts/:workoutId/add-exercise',
        name: 'exercise-selection',
        builder: (context, state) {
          final mesocycleId = state.pathParameters['mesocycleId']!;
          final workoutId = state.pathParameters['workoutId']!;
          return ExerciseSelectionScreen(
            mesocycleId: mesocycleId,
            workoutId: workoutId,
          );
        },
      ),

      // Add exercise screen (choose from library)
      GoRoute(
        path: '/mesocycles/:mesocycleId/workouts/:workoutId/choose-exercise',
        name: 'add-exercise',
        builder: (context, state) {
          final mesocycleId = state.pathParameters['mesocycleId']!;
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
            mesocycleId: mesocycleId,
            workoutId: workoutId,
            initialMuscleGroup: initialMuscleGroup,
          );
        },
      ),

      // Exercise logging screen
      GoRoute(
        path: '/mesocycles/:mesocycleId/workouts/:workoutId/exercises/:exerciseId',
        name: 'exercise-log',
        builder: (context, state) {
          final mesocycleId = state.pathParameters['mesocycleId']!;
          final workoutId = state.pathParameters['workoutId']!;
          final exerciseId = state.pathParameters['exerciseId']!;
          return ExerciseLogScreen(
            mesocycleId: mesocycleId,
            workoutId: workoutId,
            exerciseId: exerciseId,
          );
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
