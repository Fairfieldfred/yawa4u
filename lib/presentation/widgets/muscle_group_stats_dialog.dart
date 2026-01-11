import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/muscle_groups.dart';
import '../../core/theme/skins/skins.dart';
import '../../data/models/training_cycle.dart';
import '../../domain/providers/workout_providers.dart';

class MuscleGroupStatsDialog extends ConsumerWidget {
  final TrainingCycle trainingCycle;

  const MuscleGroupStatsDialog({super.key, required this.trainingCycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cellBackgroundColor = isDark ? Colors.grey[700] : Colors.grey[200];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
      child: workoutsAsync.when(
        data: (allWorkouts) {
          // 1. Filter workouts for this trainingCycle
          final workouts = allWorkouts
              .where((w) => w.trainingCycleId == trainingCycle.id)
              .toList();

          if (workouts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No workouts found for this trainingCycle.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          // 2. Determine the number of periods
          final maxPeriod = workouts.fold(
            0,
            (max, w) => w.periodNumber > max ? w.periodNumber : max,
          );
          final periods = List.generate(maxPeriod, (index) => index + 1);

          // 3. Aggregate sets per muscle group per period
          // Map<MuscleGroup, Map<PeriodNumber, SetCount>>
          final stats = <MuscleGroup, Map<int, int>>{};
          final muscleGroups = <MuscleGroup>{};

          for (final workout in workouts) {
            for (final exercise in workout.exercises) {
              final group = exercise.muscleGroup;
              muscleGroups.add(group);

              stats.putIfAbsent(group, () => {});
              final currentCount = stats[group]![workout.periodNumber] ?? 0;
              stats[group]![workout.periodNumber] =
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
                    Text(
                      'Muscle group stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: textColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Column Headers (Periods)
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ), // Space for Muscle Group Name
                    ...periods.map((period) {
                      final isRecovery = period == trainingCycle.recoveryPeriod;
                      return Expanded(
                        child: Center(
                          child: Text(
                            isRecovery ? 'DL' : 'pd $period',
                            style: TextStyle(fontSize: 12, color: textColor),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // List of Muscle Groups
                Flexible(
                  child: SingleChildScrollView(
                    child: Builder(
                      builder: (context) {
                        // First pass: calculate all averages to find the max
                        final avgSetsMap = <MuscleGroup, int>{};
                        for (final group in sortedGroups) {
                          final groupStats = stats[group] ?? {};
                          final totalSets = groupStats.values.fold(
                            0,
                            (sum, count) => sum + count,
                          );
                          final avgSets = periods.isEmpty
                              ? 0
                              : (totalSets / periods.length).round();
                          avgSetsMap[group] = avgSets;
                        }

                        // Find the maximum average sets
                        final maxAvgSets = avgSetsMap.values.isEmpty
                            ? 1
                            : avgSetsMap.values.reduce((a, b) => a > b ? a : b);

                        return Column(
                          children: sortedGroups.map((group) {
                            final groupStats = stats[group] ?? {};
                            final avgSets = avgSetsMap[group] ?? 0;

                            // Calculate diameter proportional to sets (max = 16)
                            final diameter = maxAvgSets > 0
                                ? (avgSets / maxAvgSets) * 16.0
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  // Muscle Group Name & Avg
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: Center(
                                                child: Container(
                                                  width: diameter,
                                                  height: diameter,
                                                  decoration: BoxDecoration(
                                                    color: group.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                group.displayName,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
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
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Period Bars
                                  ...periods.map((period) {
                                    final count = groupStats[period] ?? 0;
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        height:
                                            40, // Fixed height for the bar container
                                        decoration: BoxDecoration(
                                          color: cellBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          count > 0 ? count.toString() : '-',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
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
              style: TextStyle(color: context.errorColor),
            ),
          ),
        ),
      ),
    );
  }
}
