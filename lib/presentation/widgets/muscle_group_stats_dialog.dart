import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/muscle_groups.dart';
import '../../data/models/mesocycle.dart';
import '../../domain/providers/workout_providers.dart';

class MuscleGroupStatsDialog extends ConsumerWidget {
  final Mesocycle mesocycle;

  const MuscleGroupStatsDialog({super.key, required this.mesocycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF2C2C2E),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: workoutsAsync.when(
        data: (allWorkouts) {
          // 1. Filter workouts for this mesocycle
          final workouts = allWorkouts
              .where((w) => w.mesocycleId == mesocycle.id)
              .toList();

          if (workouts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No workouts found for this mesocycle.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // 2. Determine the number of weeks
          final maxWeek = workouts.fold(
            0,
            (max, w) => w.weekNumber > max ? w.weekNumber : max,
          );
          final weeks = List.generate(maxWeek, (index) => index + 1);

          // 3. Aggregate sets per muscle group per week
          // Map<MuscleGroup, Map<WeekNumber, SetCount>>
          final stats = <MuscleGroup, Map<int, int>>{};
          final muscleGroups = <MuscleGroup>{};

          for (final workout in workouts) {
            for (final exercise in workout.exercises) {
              final group = exercise.muscleGroup;
              muscleGroups.add(group);

              stats.putIfAbsent(group, () => {});
              final currentCount = stats[group]![workout.weekNumber] ?? 0;
              stats[group]![workout.weekNumber] =
                  currentCount + exercise.sets.length;
            }
          }

          // Sort muscle groups by name or some other criteria if needed
          final sortedGroups = muscleGroups.toList()
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Muscle group stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Column Headers (Weeks)
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ), // Space for Muscle Group Name
                    ...weeks.map((week) {
                      final isDeload = week == mesocycle.deloadWeek;
                      return Expanded(
                        child: Center(
                          child: Text(
                            isDeload ? 'DL' : 'wk $week',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      );
                    }),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Avg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of Muscle Groups
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: sortedGroups.map((group) {
                        final groupStats = stats[group] ?? {};
                        final totalSets = groupStats.values.fold(
                          0,
                          (sum, count) => sum + count,
                        );
                        final avgSets = weeks.isEmpty
                            ? 0
                            : (totalSets / weeks.length).round();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Muscle Group Name & Avg
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: group.color,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 4,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: group.color.withValues(
                                              alpha: 0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 4,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: group.color.withValues(
                                              alpha: 0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            group.displayName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$avgSets avg sets',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Weekly Bars
                              ...weeks.map((week) {
                                final count = groupStats[week] ?? 0;
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    height:
                                        40, // Fixed height for the bar container
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      count > 0 ? count.toString() : '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // Average Column
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    avgSets.toString(),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
