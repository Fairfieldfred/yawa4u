import 'package:flutter/material.dart';

import '../../../core/theme/skins/skins.dart';

/// Dialog showing legend for calendar colors and indicators
class CalendarLegendDialog extends StatelessWidget {
  const CalendarLegendDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calendar Legend'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Workout Status'),
            const SizedBox(height: 8),
            _buildLegendItem(
              context,
              color: context.successColor,
              label: 'Completed',
              description: 'All workouts for the day are done',
            ),
            _buildLegendItem(
              context,
              color: context.warningColor,
              label: 'Partially Completed',
              description: 'Some workouts are done',
            ),
            _buildLegendItem(
              context,
              color: Theme.of(context).colorScheme.primaryContainer,
              label: 'Scheduled',
              description: 'Workout day not yet completed',
            ),
            _buildLegendItem(
              context,
              color: context.workoutDeloadColor.withAlpha(77),
              label: 'Recovery Period',
              description: 'Deload/recovery day',
            ),
            const Divider(height: 24),
            _buildSection(context, 'Indicators'),
            const SizedBox(height: 8),
            _buildIndicatorItem(
              context,
              icon: Icons.circle,
              iconSize: 8,
              label: 'P#D#',
              description:
                  'Period and Day number (e.g., P2D3 = Period 2, Day 3)',
            ),
            _buildIndicatorItem(
              context,
              icon: Icons.fiber_manual_record,
              iconSize: 10,
              label: 'Colored dots',
              description: 'Muscle groups being worked',
            ),
            _buildIndicatorItem(
              context,
              color: context.workoutCurrentColor,
              icon: Icons.crop_square,
              iconSize: 16,
              label: 'Border highlight',
              description: 'Today\'s date',
            ),
            _buildIndicatorItem(
              context,
              color: context.warningColor,
              icon: Icons.crop_square,
              iconSize: 16,
              label: 'Selection border',
              description: 'Currently selected date',
            ),
            const Divider(height: 24),
            _buildSection(context, 'Period Colors'),
            const SizedBox(height: 8),
            Text(
              'Each period has a distinct background tint to help visualize training blocks.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(
    BuildContext context, {
    Color? color,
    required IconData icon,
    required double iconSize,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show the legend dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CalendarLegendDialog(),
    );
  }
}
