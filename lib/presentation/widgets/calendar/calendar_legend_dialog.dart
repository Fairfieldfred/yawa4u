import 'package:flutter/material.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog showing legend for calendar colors and indicators
class CalendarLegendDialog extends StatelessWidget {
  const CalendarLegendDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.calendarLegendTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, l10n.legendWorkoutStatus),
            const SizedBox(height: 8),
            _buildLegendItem(
              context,
              color: context.successColor,
              label: l10n.legendCompleted,
              description: l10n.legendCompletedDesc,
            ),
            _buildLegendItem(
              context,
              color: context.warningColor,
              label: l10n.legendPartiallyCompleted,
              description: l10n.legendPartiallyCompletedDesc,
            ),
            _buildLegendItem(
              context,
              color: Theme.of(context).colorScheme.primaryContainer,
              label: l10n.legendScheduled,
              description: l10n.legendScheduledDesc,
            ),
            _buildLegendItem(
              context,
              color: context.workoutDeloadColor.withAlpha(77),
              label: l10n.legendRecoveryPeriod,
              description: l10n.legendRecoveryPeriodDesc,
            ),
            const Divider(height: 24),
            _buildSection(context, l10n.legendIndicators),
            const SizedBox(height: 8),
            _buildIndicatorItem(
              context,
              icon: Icons.circle,
              iconSize: 8,
              label: l10n.legendPeriodDay,
              description: l10n.legendPeriodDayDesc,
            ),
            _buildIndicatorItem(
              context,
              icon: Icons.fiber_manual_record,
              iconSize: 10,
              label: l10n.legendColoredDots,
              description: l10n.legendColoredDotsDesc,
            ),
            _buildIndicatorItem(
              context,
              color: context.workoutCurrentColor,
              icon: Icons.crop_square,
              iconSize: 16,
              label: l10n.legendBorderHighlight,
              description: l10n.legendBorderHighlightDesc,
            ),
            _buildIndicatorItem(
              context,
              color: context.warningColor,
              icon: Icons.crop_square,
              iconSize: 16,
              label: l10n.legendSelectionBorder,
              description: l10n.legendSelectionBorderDesc,
            ),
            const Divider(height: 24),
            _buildSection(context, l10n.legendPeriodColors),
            const SizedBox(height: 8),
            Text(
              l10n.legendPeriodColorsDesc,
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
          child: Text(l10n.close),
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
