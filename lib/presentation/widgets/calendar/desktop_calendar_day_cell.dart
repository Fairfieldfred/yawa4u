import 'package:flutter/material.dart';

import '../../../domain/providers/calendar_providers.dart';
import 'calendar_sport_dots.dart';
import 'draggable_cardio_card.dart';
import 'draggable_exercise_card.dart';

/// A calendar day cell optimized for desktop with drag-and-drop support
class DesktopCalendarDayCell extends StatefulWidget {
  final DateTime date;
  final CalendarDayData? dayData;
  final Map<int, Color> periodColors;
  final bool isToday;
  final bool isSelected;
  final ValueChanged<DateTime>? onTap;
  final void Function(CalendarDragData data, DateTime targetDate)? onExerciseDropped;
  final void Function(int oldIndex, int newIndex, DateTime targetDate)? onExerciseReordered;
  final String? selectedExerciseId;
  final ValueChanged<String?>? onExerciseSelected;
  final void Function(int periodNumber, int dayNumber, DateTime date)? onAddExercise;

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
    final hasAnySession = dayData?.hasAnySession ?? false;

    // Determine background color based on session state
    Color backgroundColor = Colors.transparent;
    if (hasAnySession) {
      if (dayData!.isCompleted) {
        backgroundColor = Colors.green.withAlpha(30);
      } else if (dayData.isPartiallyCompleted) {
        backgroundColor = Colors.orange.withAlpha(30);
      } else if (dayData.isRecoveryPeriod) {
        backgroundColor = Colors.blue.withAlpha(20);
      } else if (dayData.periodNumber != null) {
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

    return DragTarget<CalendarDragData>(
      onWillAcceptWithDetails: (details) {
        // Don't accept drops on the same day/position
        final data = details.data;
        if (dayData != null && data.sourcePeriod == dayData.periodNumber && data.sourceDay == dayData.dayNumber) {
          return false;
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _isDragOver = false;
        });

        if (widget.onExerciseDropped != null) {
          widget.onExerciseDropped!(details.data, widget.date);
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
                // Content: Exercise + cardio cards
                Expanded(
                  child: hasAnySession ? _buildContentList(context, dayData!) : _buildEmptyState(context),
                ),
                // Add exercise button at bottom (any day within the cycle)
                if (dayData?.periodNumber != null) _buildAddExerciseButton(context, dayData!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CalendarDayData? dayData) {
    final hasAnySession = dayData?.hasAnySession ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
        children: [
          Text(
            '${widget.date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: (widget.isToday || widget.isSelected) ? FontWeight.bold : FontWeight.w500,
              color: widget.isToday ? Colors.blue : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (hasAnySession) ...[
            Expanded(
              child: Text(
                'P${dayData!.periodNumber}D${dayData.dayNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // v5 — cardio sport indicators (collapses to nothing if none).
            CalendarSportDots(date: widget.date, dotSize: 5, spacing: 2),
            const SizedBox(width: 4),
            _buildStatusIndicator(context, dayData),
          ] else ...[
            const Spacer(),
            CalendarSportDots(date: widget.date, dotSize: 5, spacing: 2),
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

  /// Builds a mixed list of exercise and cardio cards.
  ///
  /// Exercises appear first (with reorder support via [ReorderableDragStartListener]),
  /// followed by cardio sessions (draggable cross-day but not reorderable).
  Widget _buildContentList(BuildContext context, CalendarDayData dayData) {
    final exercises = dayData.exercises;
    final cardioSessions = dayData.cardioSessions;
    final totalCount = exercises.length + cardioSessions.length;

    if (totalCount == 0) {
      return _buildEmptyState(context);
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      buildDefaultDragHandles: false,
      itemCount: totalCount,
      onReorder: (oldIndex, newIndex) {
        // Only handle reorder if both indices are within the exercise range
        if (oldIndex >= exercises.length || newIndex > exercises.length) return;
        if (widget.onExerciseReordered != null) {
          // Adjust for removal
          if (newIndex > oldIndex) newIndex--;
          widget.onExerciseReordered!(oldIndex, newIndex, widget.date);
        }
      },
      itemBuilder: (context, index) {
        if (index < exercises.length) {
          // Exercise card (with reorder drag handle)
          final exerciseItem = exercises[index];
          final isSelected = widget.selectedExerciseId == exerciseItem.exercise.id;

          return ReorderableDragStartListener(
            key: ValueKey(exerciseItem.exercise.id),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
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
        } else {
          // Cardio card (draggable cross-day, not reorderable)
          final cardioIndex = index - exercises.length;
          final session = cardioSessions[cardioIndex];

          return Padding(
            key: ValueKey('cardio_${session.id}'),
            padding: const EdgeInsets.only(bottom: 2),
            child: DraggableCardioCard(
              session: session,
              periodNumber: dayData.periodNumber ?? 0,
              dayNumber: dayData.dayNumber ?? 0,
              compact: true,
            ),
          );
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        _isDragOver ? 'Drop here' : '',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _isDragOver ? Colors.green : Theme.of(context).colorScheme.onSurface.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(
    BuildContext context,
    CalendarDayData dayData,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.onAddExercise != null && dayData.periodNumber != null && dayData.dayNumber != null) {
          widget.onAddExercise!(
            dayData.periodNumber!,
            dayData.dayNumber!,
            widget.date,
          );
        }
      },
      child: Container(
        height: 16,
        alignment: Alignment.center,
        child: Icon(
          Icons.add_circle_outline,
          size: 14,
          color: Theme.of(context).colorScheme.primary.withAlpha(180),
        ),
      ),
    );
  }
}
