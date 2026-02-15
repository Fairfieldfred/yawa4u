/// Represents a position in the training cycle day sequence.
class DayPosition {
  final int period;
  final int day;

  const DayPosition(this.period, this.day);

  @override
  bool operator ==(Object other) =>
      other is DayPosition && other.period == period && other.day == day;

  @override
  int get hashCode => Object.hash(period, day);

  @override
  String toString() => 'P${period}D$day';
}

/// Compute the ordered sequence of all days in a training cycle.
///
/// Returns a list like:
/// [(1,1), (1,2), ..., (1,N), (2,1), (2,2), ..., (P,N)]
/// where P = periodsTotal and N = daysPerPeriod.
List<DayPosition> buildDaySequence(int periodsTotal, int daysPerPeriod) {
  final positions = <DayPosition>[];
  for (int period = 1; period <= periodsTotal; period++) {
    for (int day = 1; day <= daysPerPeriod; day++) {
      positions.add(DayPosition(period, day));
    }
  }
  return positions;
}

/// Find the index of a specific (period, day) in the day sequence.
///
/// Returns null if the position is not found.
int? findDayIndex(List<DayPosition> sequence, int period, int day) {
  final target = DayPosition(period, day);
  final index = sequence.indexOf(target);
  return index >= 0 ? index : null;
}
