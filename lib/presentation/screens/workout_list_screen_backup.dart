import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../../core/constants/enums.dart';

/// Workout list screen for a mesocycle - groups workouts by week
class WorkoutListScreen extends ConsumerWidget {
  final String mesocycleId;

  const WorkoutListScreen({
    super.key,
    required this.mesocycleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Start mesocycle button (if draft)
          mesocyclesAsync.whenData((mesocycles) {
            final mesocycle = mesocycles.firstWhere(
              (m) => m.id == mesocycleId,
              orElse: () => mesocycles.first,
            );

            if (mesocycle.status == MesocycleStatus.draft) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _startMesocycle(context, ref, mesocycle),
                tooltip: 'Start mesocycle',
              );
            }
            return const SizedBox.shrink();
          }).value ??
              const SizedBox.shrink(),
        ],
      ),
      body: mesocyclesAsync.when(
        data: (mesocycles) {
          final mesocycle = mesocycles.firstWhere(
            (m) => m.id == mesocycleId,
            orElse: () => mesocycles.first,
          );

          final workouts = ref.watch(workoutsByMesocycleProvider(mesocycleId));

          if (workouts.isEmpty) {
            return _buildEmptyState(context, ref, mesocycle);
          }

          return _buildWorkoutList(context, ref, mesocycle, workouts);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading mesocycle: $error'),
        ),
      ),
      floatingActionButton: mesocyclesAsync.whenOrNull(
        data: (mesocycles) {
          final mesocycle = mesocycles.firstWhere(
            (m) => m.id == mesocycleId,
            orElse: () => mesocycles.first,
          );
          return FloatingActionButton.extended(
            onPressed: () => _showAddWorkoutDialog(context, ref, mesocycle),
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList(
    BuildContext context,
    WidgetRef ref,
    Mesocycle mesocycle,
    List<Workout> workouts,
  ) {
    // Group workouts by week
    final workoutsByWeek = <int, List<Workout>>{};
    for (final workout in workouts) {
      workoutsByWeek.putIfAbsent(workout.weekNumber, () => []).add(workout);
    }

    // Sort weeks
    final sortedWeeks = workoutsByWeek.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Mesocycle header
        _MesocycleHeader(mesocycle: mesocycle),
        const SizedBox(height: 24),

        // Weeks
        ...sortedWeeks.map((week) {
          final weekWorkouts = workoutsByWeek[week]!
            ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

          return _WeekSection(
            weekNumber: week,
            workouts: weekWorkouts,
            isDeloadWeek: mesocycle.deloadWeek == week,
            mesocycleId: mesocycleId,
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    Mesocycle mesocycle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Workouts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This mesocycle has no workouts yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddWorkoutDialog(context, ref, mesocycle),
            icon: const Icon(Icons.add),
            label: const Text('Add First Workout'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMesocycle(
    BuildContext context,
    WidgetRef ref,
    Mesocycle mesocycle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Mesocycle'),
        content: Text(
          'Start "${mesocycle.name}"? This will set it as your current mesocycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(mesocycleRepositoryProvider);
        await repository.setAsCurrent(mesocycle.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mesocycle started!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddWorkoutDialog(
    BuildContext context,
    WidgetRef ref,
    Mesocycle mesocycle,
  ) async {
    final formKey = GlobalKey<FormState>();
    int weekNumber = 1;
    int dayNumber = 1;
    String? label;
    String? dayName;

    // Get existing workouts to suggest next week/day
    final existingWorkouts =
        ref.read(workoutsByMesocycleProvider(mesocycle.id));
    if (existingWorkouts.isNotEmpty) {
      final lastWorkout = existingWorkouts.last;
      weekNumber = lastWorkout.weekNumber;
      dayNumber = lastWorkout.dayNumber + 1;

      // If we exceed days per week, move to next week
      if (dayNumber > mesocycle.daysPerWeek) {
        weekNumber = lastWorkout.weekNumber + 1;
        dayNumber = 1;
      }
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Workout'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Week Number
                TextFormField(
                  initialValue: weekNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Week Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a week number';
                    }
                    final week = int.tryParse(value);
                    if (week == null || week < 1) {
                      return 'Week must be at least 1';
                    }
                    if (week > mesocycle.weeksTotal) {
                      return 'Week cannot exceed ${mesocycle.weeksTotal}';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    weekNumber = int.tryParse(value) ?? 1;
                  },
                ),
                const SizedBox(height: 16),

                // Day Number
                TextFormField(
                  initialValue: dayNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Day Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a day number';
                    }
                    final day = int.tryParse(value);
                    if (day == null || day < 1) {
                      return 'Day must be at least 1';
                    }
                    if (day > mesocycle.daysPerWeek) {
                      return 'Day cannot exceed ${mesocycle.daysPerWeek}';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    dayNumber = int.tryParse(value) ?? 1;
                  },
                ),
                const SizedBox(height: 16),

                // Day Name (optional)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Day Name (optional)',
                    hintText: 'e.g., Monday, Rest Day',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    dayName = value.isEmpty ? null : value;
                  },
                ),
                const SizedBox(height: 16),

                // Label (optional)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Label (optional)',
                    hintText: 'e.g., Push, Pull, Legs',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    label = value.isEmpty ? null : value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Create the workout
                final newWorkout = Workout(
                  id: const Uuid().v4(),
                  mesocycleId: mesocycle.id,
                  weekNumber: weekNumber,
                  dayNumber: dayNumber,
                  dayName: dayName,
                  label: label,
                  status: WorkoutStatus.incomplete,
                );

                // Save to repository
                ref.read(workoutRepositoryProvider).create(newWorkout);

                Navigator.of(dialogContext).pop();

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Workout added: Week $weekNumber, Day $dayNumber',
                    ),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Mesocycle header widget
class _MesocycleHeader extends StatelessWidget {
  final Mesocycle mesocycle;

  const _MesocycleHeader({required this.mesocycle});

  @override
  Widget build(BuildContext context) {
    final progress = mesocycle.getProgress();
    final currentWeek = mesocycle.getCurrentWeek();
    final completedWorkouts = mesocycle.completedWorkoutCount;
    final totalWorkouts = mesocycle.workouts.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    mesocycle.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _StatusBadge(status: mesocycle.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  currentWeek != null
                      ? 'Week $currentWeek of ${mesocycle.weeksTotal}'
                      : '${mesocycle.weeksTotal} weeks',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedWorkouts / $totalWorkouts workouts',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final MesocycleStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  (String, Color) _getStatusInfo(BuildContext context) {
    switch (status) {
      case MesocycleStatus.current:
        return ('CURRENT', Theme.of(context).colorScheme.primary);
      case MesocycleStatus.completed:
        return ('COMPLETED', Colors.green);
      case MesocycleStatus.draft:
      default:
        return ('DRAFT', Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5));
    }
  }
}

/// Week section widget
class _WeekSection extends StatelessWidget {
  final int weekNumber;
  final List<Workout> workouts;
  final bool isDeloadWeek;
  final String mesocycleId;

  const _WeekSection({
    required this.weekNumber,
    required this.workouts,
    required this.isDeloadWeek,
    required this.mesocycleId,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = workouts.where((w) => w.isCompleted).length;
    final progress = workouts.isEmpty ? 0.0 : completedCount / workouts.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week header
        Row(
          children: [
            Text(
              'Week $weekNumber',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isDeloadWeek) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: Text(
                  'DELOAD',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
            const Spacer(),
            Text(
              '$completedCount / ${workouts.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
        const SizedBox(height: 12),

        // Workouts
        ...workouts.map((workout) => _WorkoutCard(
              workout: workout,
              mesocycleId: mesocycleId,
            )),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Workout card widget
class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final String mesocycleId;

  const _WorkoutCard({
    required this.workout,
    required this.mesocycleId,
  });

  @override
  Widget build(BuildContext context) {
    final (statusIcon, statusColor) = _getStatusInfo(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => context.push(
          '/mesocycles/$mesocycleId/workouts/${workout.id}',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),

              // Workout info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.exercises.length} exercises',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        if (workout.completedExercises > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.completedExercises} completed',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getStatusInfo(BuildContext context) {
    switch (workout.status) {
      case WorkoutStatus.completed:
        return (Icons.check_circle, Colors.green);
      case WorkoutStatus.skipped:
        return (Icons.skip_next, Colors.orange);
      case WorkoutStatus.incomplete:
      default:
        return (
          Icons.circle_outlined,
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
        );
    }
  }
}
