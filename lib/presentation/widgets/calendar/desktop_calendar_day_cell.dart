import 'package:flutter/material.dart';

import '../../../domain/providers/calendar_providers.dart';
import 'draggable_exercise_card.dart';

/// A calendar day cell optimized for desktop with drag-and-drop support
class DesktopCalendarDayCell extends StatefulWidget {
  final DateTime date;
  final CalendarDayData? dayData;
  final Map<int, Color> periodColors;
  final bool isToday;
  final bool isSelected;
  final ValueChanged<DateTime>? onTap;
  final void Function(ExerciseDragData data, int targetPeriod, int targetDay)?
  onExerciseDropped;
  final void Function(
    int oldIndex,
    int newIndex,
    int targetPeriod,
    int targetDay,
  )?
  onExerciseReordered;
  final String? selectedExerciseId;
  final ValueChanged<String?>? onExerciseSelected;
  final void Function(int periodNumber, int dayNumber)? onAddExercise;

  const DesktopCalendarDayCell({
    super.key,
    required this.date,
    required this.dayData,
    required this.periodColors,
    this.isToday = false,
    this.isSelected = false,
    this.onTap,
    this.onExerciseDropped,
    this.onExerciseReordered,
    this.selectedExerciseId,
    this.onExerciseSelected,
    this.onAddExercise,
  });

  @override
  State<DesktopCalendarDayCell> createState() => _DesktopCalendarDayCellState();
}

class _DesktopCalendarDayCellState extends State<DesktopCalendarDayCell> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final dayData = widget.dayData;
    final hasWorkout = dayData?.hasWorkout ?? false;

    // Determine background color based on workout state
    Color backgroundColor = Colors.transparent;
    if (hasWorkout) {
      if (dayData!.isCompleted) {
        backgroundColor = Colors.green.withAlpha(30);
      } else if (dayData.isPartiallyCompleted) {
        backgroundColor = Colors.orange.withAlpha(30);
      } else if (dayData.isRecoveryPeriod) {
        backgroundColor = Colors.blue.withAlpha(20);
      } else {
        final periodColor = getPeriodColor(
          widget.periodColors,
          dayData.periodNumber!,
        );
        backgroundColor = periodColor.withAlpha(20);
      }
    }

    // Border
    BoxBorder? border;
    if (widget.isSelected) {
      border = Border.all(color: Colors.orange, width: 3);
    } else if (widget.isToday) {
      border = Border.all(color: Colors.blue, width: 3);
    } else if (_isDragOver) {
      border = Border.all(color: Colors.green, width: 2);
    }

    return DragTarget<ExerciseDragData>(
      onWillAcceptWithDetails: (details) {
        // Don't accept drops on the same day/position
        final data = details.data;
        if (dayData != null &&
            data.sourcePeriod == dayData.periodNumber &&
            data.sourceDay == dayData.dayNumber) {
          return false;
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _isDragOver = false;
        });

        if (dayData != null && widget.onExerciseDropped != null) {
          widget.onExerciseDropped!(
            details.data,
            dayData.periodNumber!,
            dayData.dayNumber!,
          );
        }
      },
      onMove: (details) {
        if (!_isDragOver) {
          setState(() {
            _isDragOver = true;
          });
        }
      },
      onLeave: (_) {
        setState(() {
          _isDragOver = false;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () => widget.onTap?.call(widget.date),
          child: Container(
            decoration: BoxDecoration(
              color: _isDragOver ? Colors.green.withAlpha(40) : backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Day number and period info
                _buildHeader(context, dayData),
                // Content: Exercise cards
                Expanded(
                  child: hasWorkout
                      ? _buildExerciseList(context, dayData!)
                      : _buildEmptyState(context),
                ),
                // Add exercise button at bottom
                if (dayData?.hasWorkout ?? false)
                  _buildAddExerciseButton(context, dayData!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CalendarDayData? dayData) {
    final hasWorkout = dayData?.hasWorkout ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(
          widget.isToday || widget.isSelected ? 150 : 80,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.date.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: (widget.isToday || widget.isSelected)
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: widget.isToday
                  ? Colors.blue
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (hasWorkout) ...[
            Text(
              'P${dayData!.periodNumber}D${dayData.dayNumber}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
            _buildStatusIndicator(context, dayData),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, CalendarDayData dayData) {
    IconData icon;
    Color color;

    if (dayData.isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (dayData.isPartiallyCompleted) {
      icon = Icons.timelapse;
      color = Colors.orange;
    } else if (dayData.isRecoveryPeriod) {
      icon = Icons.spa;
      color = Colors.blue;
    } else {
      icon = Icons.circle_outlined;
      color = Theme.of(context).colorScheme.onSurface.withAlpha(100);
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildExerciseList(BuildContext context, CalendarDayData dayData) {
    // Use the pre-built exercises list from CalendarDayData
    final allExercises = dayData.exercises;

    if (allExercises.isEmpty) {
      return _buildEmptyState(context);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(4),
      buildDefaultDragHandles: false,
      itemCount: allExercises.length,
      onReorder: (oldIndex, newIndex) {
        if (widget.onExerciseReordered != null) {
          // Adjust for removal
          if (newIndex > oldIndex) newIndex--;
          widget.onExerciseReordered!(
            oldIndex,
            newIndex,
            dayData.periodNumber!,
            dayData.dayNumber!,
          );
        }
      },
      itemBuilder: (context, index) {
        final exerciseItem = allExercises[index];
        final isSelected =
            widget.selectedExerciseId == exerciseItem.exercise.id;

        return ReorderableDragStartListener(
          key: ValueKey(exerciseItem.exercise.id),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: DraggableExerciseCard(
              exercise: exerciseItem.exercise,
              workoutId: exerciseItem.workoutId,
              periodNumber: exerciseItem.periodNumber,
              dayNumber: exerciseItem.dayNumber,
              index: index,
              isSelected: isSelected,
              compact: true,
              onTap: () {
                widget.onExerciseSelected?.call(
                  isSelected ? null : exerciseItem.exercise.id,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        _isDragOver ? 'Drop here' : '',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _isDragOver
              ? Colors.green
              : Theme.of(context).colorScheme.onSurface.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(
    BuildContext context,
    CalendarDayData dayData,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onAddExercise != null &&
                dayData.periodNumber != null &&
                dayData.dayNumber != null) {
              widget.onAddExercise!(dayData.periodNumber!, dayData.dayNumber!);
            }
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(100),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Add',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
