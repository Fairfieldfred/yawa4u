import '../../../data/models/exercise.dart';
import '../../../data/models/session.dart';

/// Sealed drag data for calendar day cells.
///
/// Allows a single [DragTarget] to accept both exercise and cardio drags.
sealed class CalendarDragData {
  const CalendarDragData({
    required this.sourcePeriod,
    required this.sourceDay,
  });

  /// Period number of the source day.
  final int sourcePeriod;

  /// Day number within the period of the source day.
  final int sourceDay;
}

/// Drag data for a strength exercise being moved between days.
class ExerciseDragData extends CalendarDragData {
  final Exercise exercise;
  final String sourceWorkoutId;
  final int sourceIndex;

  const ExerciseDragData({
    required this.exercise,
    required this.sourceWorkoutId,
    required super.sourcePeriod,
    required super.sourceDay,
    required this.sourceIndex,
  });
}

/// Drag data for a cardio session being moved between days.
class CardioDragData extends CalendarDragData {
  final CardioSession session;

  const CardioDragData({
    required this.session,
    required super.sourcePeriod,
    required super.sourceDay,
  });
}
