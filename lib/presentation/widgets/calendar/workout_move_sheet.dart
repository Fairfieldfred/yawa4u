import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/schedule_service.dart';
import '../../../domain/providers/calendar_providers.dart';

/// Bottom sheet for selecting how to move a workout
class WorkoutMoveSheet extends ConsumerStatefulWidget {
  final int sourcePeriod;
  final int sourceDay;
  final DateTime? cycleStartDate;
  final int daysPerPeriod;
  final int periodsTotal;
  final Function(int targetPeriod, int targetDay, MoveMode mode) onMove;

  const WorkoutMoveSheet({
    super.key,
    required this.sourcePeriod,
    required this.sourceDay,
    required this.cycleStartDate,
    required this.daysPerPeriod,
    required this.periodsTotal,
    required this.onMove,
  });

  @override
  ConsumerState<WorkoutMoveSheet> createState() => _WorkoutMoveSheetState();

  /// Show the workout move sheet
  static void show(
    BuildContext context, {
    required int sourcePeriod,
    required int sourceDay,
    required DateTime? cycleStartDate,
    required int daysPerPeriod,
    required int periodsTotal,
    required Function(int targetPeriod, int targetDay, MoveMode mode) onMove,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => WorkoutMoveSheet(
        sourcePeriod: sourcePeriod,
        sourceDay: sourceDay,
        cycleStartDate: cycleStartDate,
        daysPerPeriod: daysPerPeriod,
        periodsTotal: periodsTotal,
        onMove: onMove,
      ),
    );
  }
}

class _WorkoutMoveSheetState extends ConsumerState<WorkoutMoveSheet> {
  late int _targetPeriod;
  late int _targetDay;
  MoveMode _selectedMode = MoveMode.shiftSubsequent;

  @override
  void initState() {
    super.initState();
    _targetPeriod = widget.sourcePeriod;
    _targetDay = widget.sourceDay;
  }

  @override
  Widget build(BuildContext context) {
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
            'Move Workout',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'From Period ${widget.sourcePeriod}, Day ${widget.sourceDay}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 24),

          // Target selection
          Text(
            'Move to:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // Period/Day dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  context,
                  label: 'Period',
                  value: _targetPeriod,
                  items: List.generate(widget.periodsTotal, (i) => i + 1),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetPeriod = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  context,
                  label: 'Day',
                  value: _targetDay,
                  items: List.generate(widget.daysPerPeriod, (i) => i + 1),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _targetDay = value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Move mode selection
          Text(
            'Move mode:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          _buildModeOption(
            context,
            mode: MoveMode.shiftSubsequent,
            title: 'Shift Subsequent',
            description: 'Move this workout and shift all following workouts',
            isSelected: _selectedMode == MoveMode.shiftSubsequent,
          ),
          _buildModeOption(
            context,
            mode: MoveMode.swap,
            title: 'Swap',
            description: 'Exchange with the workout on the target date',
            isSelected: _selectedMode == MoveMode.swap,
          ),
          _buildModeOption(
            context,
            mode: MoveMode.single,
            title: 'Single',
            description: 'Move only this workout (may create gaps)',
            isSelected: _selectedMode == MoveMode.single,
          ),
          const SizedBox(height: 24),

          // Undo button (enabled if there are recent changes)
          _buildUndoButton(context),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _canMove()
                      ? () {
                          Navigator.of(context).pop();
                          widget.onMove(
                            _targetPeriod,
                            _targetDay,
                            _selectedMode,
                          );
                        }
                      : null,
                  child: const Text('Move'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUndoButton(BuildContext context) {
    final undoState = ref.watch(calendarUndoProvider);
    final canUndo = undoState.hasRecentSnapshot;

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
                if (mounted) {
                  navigator.pop();
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Move undone'),
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
              : 'Undo Move (no recent changes)',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: canUndo
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withAlpha(97),
        ),
      ),
    );
  }

  bool _canMove() {
    // Can't move to the same position
    return _targetPeriod != widget.sourcePeriod ||
        _targetDay != widget.sourceDay;
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text('$item'));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required MoveMode mode,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha(26)
              : null,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withAlpha(153),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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
      ),
    );
  }
}
