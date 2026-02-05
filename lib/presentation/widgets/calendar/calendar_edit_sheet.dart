import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/providers/calendar_providers.dart';

/// Bottom sheet for editing calendar (insert day, remove rest day, undo)
class CalendarEditSheet extends ConsumerWidget {
  final int? selectedPeriod;
  final int? selectedDay;
  final bool isRestDay;
  final DateTime? selectedDate;
  final Future<void> Function(int period, int day)? onInsertDayBefore;
  final Future<void> Function(DateTime date)? onRemoveRestDay;

  const CalendarEditSheet({
    super.key,
    this.selectedPeriod,
    this.selectedDay,
    required this.isRestDay,
    this.selectedDate,
    this.onInsertDayBefore,
    this.onRemoveRestDay,
  });

  /// Show the calendar edit sheet
  static void show(
    BuildContext context, {
    int? selectedPeriod,
    int? selectedDay,
    required bool isRestDay,
    DateTime? selectedDate,
    Future<void> Function(int period, int day)? onInsertDayBefore,
    Future<void> Function(DateTime date)? onRemoveRestDay,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CalendarEditSheet(
        selectedPeriod: selectedPeriod,
        selectedDay: selectedDay,
        isRestDay: isRestDay,
        selectedDate: selectedDate,
        onInsertDayBefore: onInsertDayBefore,
        onRemoveRestDay: onRemoveRestDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final undoState = ref.watch(calendarUndoProvider);
    final canUndo = undoState.hasRecentSnapshot;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Edit Calendar',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isRestDay ? 'Rest Day' : 'Period $selectedPeriod, Day $selectedDay',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 24),

          // Show different options based on whether this is a rest day
          if (isRestDay && selectedDate != null && onRemoveRestDay != null) ...[
            // Remove rest day option (only for rest days)
            _buildActionButton(
              context,
              icon: Icons.remove_circle_outline,
              label: 'Remove Rest Day',
              description:
                  'Remove this rest day and shift all future workouts backward',
              onPressed: () {
                Navigator.of(context).pop();
                onRemoveRestDay!(selectedDate!);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Insert day option (only available when we have period/day info)
          if (selectedPeriod != null &&
              selectedDay != null &&
              onInsertDayBefore != null) ...[
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Insert Day Before',
              description:
                  'Add a rest day here, shifting this and all future workouts forward',
              onPressed: () {
                Navigator.of(context).pop();
                onInsertDayBefore!(selectedPeriod!, selectedDay!);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Undo button
          _buildUndoButton(context, ref, undoState, canUndo),
          const SizedBox(height: 16),

          // Close button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUndoButton(
    BuildContext context,
    WidgetRef ref,
    CalendarUndoState undoState,
    bool canUndo,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canUndo
            ? () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final primaryContainer = Theme.of(
                  context,
                ).colorScheme.primaryContainer;

                final success = await ref
                    .read(calendarUndoProvider.notifier)
                    .undo();
                if (context.mounted) {
                  navigator.pop();
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Change undone'),
                        backgroundColor: primaryContainer,
                      ),
                    );
                  }
                }
              }
            : null,
        icon: const Icon(Icons.undo),
        label: Text(
          canUndo
              ? 'Undo: ${undoState.snapshot?.description ?? "last change"}'
              : 'Undo (no recent changes)',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: canUndo
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withAlpha(97),
        ),
      ),
    );
  }
}
