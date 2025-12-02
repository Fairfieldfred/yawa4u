import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../../domain/providers/workout_providers.dart';
import 'muscle_group_stats_dialog.dart';

class MesocycleSummaryDialog extends ConsumerWidget {
  final Mesocycle mesocycle;

  const MesocycleSummaryDialog({super.key, required this.mesocycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF2C2C2E), // Dark card background
      child: workoutsAsync.when(
        data: (allWorkouts) {
          final workouts =
              allWorkouts.where((w) => w.mesocycleId == mesocycle.id).toList()
                ..sort((a, b) {
                  final weekCompare = a.weekNumber.compareTo(b.weekNumber);
                  if (weekCompare != 0) return weekCompare;
                  return a.dayNumber.compareTo(b.dayNumber);
                });

          final completedCount = workouts
              .where((w) => w.status == WorkoutStatus.completed)
              .length;
          final skippedCount = workouts
              .where((w) => w.status == WorkoutStatus.skipped)
              .length;
          final incompleteCount = workouts
              .where((w) => w.status == WorkoutStatus.incomplete)
              .length;

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mesocycle summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mesocycle.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

                // Workouts Section
                const Text(
                  'Workouts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: completedCount.toString(),
                  iconColor: Colors.white,
                ),
                _buildDivider(),
                _buildStatRow(
                  context,
                  icon: Icons.undo, // Using undo/curved arrow for skipped
                  label: 'Skipped',
                  value: skippedCount.toString(),
                  iconColor: Colors.white,
                ),
                _buildDivider(),
                _buildStatRow(
                  context,
                  icon: Icons.radio_button_unchecked, // Dashed circle approx
                  label: 'Incomplete',
                  value: incompleteCount.toString(),
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 24),

                // Stats Section
                const Text(
                  'Stats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNavigationRow(
                  context,
                  label: 'Muscle groups',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          MuscleGroupStatsDialog(mesocycleId: mesocycle.id),
                    );
                  },
                ),
                _buildDivider(),
                _buildNavigationRow(
                  context,
                  label: 'Exercises',
                  onTap: () {
                    // TODO: Navigate to exercise stats
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exercise stats - Coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Footer
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
        error: (error, _) => SizedBox(
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

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[800]);
  }
}
