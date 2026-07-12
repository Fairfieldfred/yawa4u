import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/skins/skins.dart';
import '../../data/models/training_cycle.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../../l10n/app_localizations.dart';
import 'muscle_group_stats_dialog.dart';

class CycleSummaryDialog extends ConsumerWidget {
  final TrainingCycle trainingCycle;

  const CycleSummaryDialog({super.key, required this.trainingCycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor,
      child: workoutsAsync.when(
        data: (workouts) {
          workouts.sort((a, b) {
            final periodCompare = a.periodNumber.compareTo(
              b.periodNumber,
            );
            if (periodCompare != 0) return periodCompare;
            return a.dayNumber.compareTo(b.dayNumber);
          });

          final completedCount = workouts.where((w) => w.status == WorkoutStatus.completed).length;
          final skippedCount = workouts.where((w) => w.status == WorkoutStatus.skipped).length;
          final incompleteCount = workouts.where((w) => w.status == WorkoutStatus.incomplete).length;

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
                          Text(
                            l10n.cycleSummaryTitle(ref.watch(trainingCycleTermProvider)),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trainingCycle.name.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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

                // Workouts Section
                Text(
                  l10n.cycleSummaryWorkoutsSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.check_circle_outline,
                  label: l10n.cycleSummaryCompleted,
                  value: completedCount.toString(),
                  textColor: textColor,
                  iconColor: Colors.white,
                ),
                _buildDivider(dividerColor),
                _buildStatRow(
                  context,
                  icon: Icons.undo, // Using undo/curved arrow for skipped
                  label: l10n.cycleSummarySkipped,
                  value: skippedCount.toString(),
                  textColor: textColor,
                  iconColor: Colors.white,
                ),
                _buildDivider(dividerColor),
                _buildStatRow(
                  context,
                  icon: Icons.radio_button_unchecked, // Dashed circle approx
                  label: l10n.cycleSummaryIncomplete,
                  value: incompleteCount.toString(),
                  textColor: textColor,
                  iconColor: Colors.white,
                ),
                const SizedBox(height: 24),

                // Stats Section
                Text(
                  l10n.cycleSummaryStatsSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                _buildNavigationRow(
                  context,
                  label: l10n.cycleSummaryMuscleGroups,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => MuscleGroupStatsDialog(trainingCycle: trainingCycle),
                    );
                  },
                ),
                _buildDivider(dividerColor),
                const SizedBox(height: 24),

                // Footer
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.closeUpper,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textColor),
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
              style: TextStyle(color: context.errorColor),
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
    required Color textColor,
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color? secondaryTextColor,
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
              ),
            ),
            Icon(Icons.chevron_right, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Color? dividerColor) {
    return Divider(height: 1, thickness: 1, color: dividerColor);
  }
}
