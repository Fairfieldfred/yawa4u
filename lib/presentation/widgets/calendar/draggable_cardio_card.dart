import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../data/models/session.dart';
import '../../../l10n/app_localizations.dart';
import 'calendar_drag_data.dart';

/// A draggable card representing a cardio session on the calendar.
///
/// Styled to match [DraggableExerciseCard] so strength and cardio items
/// look consistent in the day cell content area.
class DraggableCardioCard extends StatelessWidget {
  final CardioSession session;
  final int periodNumber;
  final int dayNumber;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const DraggableCardioCard({
    super.key,
    required this.session,
    required this.periodNumber,
    required this.dayNumber,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dragData = CardioDragData(
      session: session,
      sourcePeriod: periodNumber,
      sourceDay: dayNumber,
    );

    return Draggable<CalendarDragData>(
      data: dragData,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _buildCard(context, l10n, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCard(context, l10n),
      ),
      child: GestureDetector(onTap: onTap, child: _buildCard(context, l10n)),
    );
  }

  Widget _buildCard(BuildContext context, AppLocalizations l10n, {bool isDragging = false}) {
    final sportColor = session.sport.color;
    final label = session.label ?? session.sport.localizedName(l10n);
    final isComplete = session.status == WorkoutStatus.completed;

    return Container(
      width: isDragging ? (compact ? 120 : 180) : null,
      padding: EdgeInsets.all(compact ? 3 : 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : sportColor.withAlpha(150),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Sport color bar + session name
          Row(
            children: [
              Container(
                width: 3,
                height: compact ? 20 : 36,
                decoration: BoxDecoration(
                  color: sportColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 10 : 12,
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      session.sport.localizedName(l10n),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: sportColor,
                        fontSize: compact ? 8 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 2 : 4),
          // Status row
          Row(
            children: [
              Icon(
                session.sport.icon,
                size: compact ? 10 : 14,
                color: sportColor.withAlpha(180),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildStatusChip(context, l10n, isComplete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, AppLocalizations l10n, bool isComplete) {
    final Color color;
    final String text;

    switch (session.status) {
      case WorkoutStatus.completed:
        color = Colors.green;
        text = l10n.statusDone;
      case WorkoutStatus.skipped:
        color = Theme.of(context).colorScheme.outline;
        text = l10n.statusSkipped;
      case WorkoutStatus.incomplete:
        color = Theme.of(context).colorScheme.primary;
        text = l10n.statusPlanned;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: compact ? 7 : 10,
        ),
      ),
    );
  }
}
