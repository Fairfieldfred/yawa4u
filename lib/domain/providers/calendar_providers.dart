import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../data/services/schedule_service.dart';
import 'database_providers.dart';
import 'training_cycle_providers.dart';
import 'workout_providers.dart';

/// Provider for ScheduleService
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    cycleRepository: ref.watch(trainingCycleRepositoryProvider),
    workoutRepository: ref.watch(workoutRepositoryProvider),
  );
});

/// Data for a single calendar day
class CalendarDayData {
  final DateTime date;
  final int? periodNumber;
  final int? dayNumber;
  final List<Workout> workouts;
  final bool isRecoveryPeriod;
  final bool isCompleted;
  final bool isPartiallyCompleted;
  final Set<String> muscleGroups;

  /// Map of muscle group name to total number of sets
  final Map<String, int> muscleGroupSets;

  /// Map of muscle group name to list of exercise names with set counts
  final Map<String, List<String>> muscleGroupExercises;

  CalendarDayData({
    required this.date,
    this.periodNumber,
    this.dayNumber,
    this.workouts = const [],
    this.isRecoveryPeriod = false,
    this.isCompleted = false,
    this.isPartiallyCompleted = false,
    this.muscleGroups = const {},
    this.muscleGroupSets = const {},
    this.muscleGroupExercises = const {},
  });

  bool get hasWorkout => workouts.isNotEmpty;
}

/// Build calendar data for a month given a training cycle
List<CalendarDayData> buildCalendarData({
  required TrainingCycle cycle,
  required List<Workout> allWorkouts,
  required DateTime month,
}) {
  final result = <CalendarDayData>[];

  if (cycle.startDate == null) {
    return result;
  }

  final cycleStart = DateHelpers.stripTime(cycle.startDate!);
  final cycleEnd = DateHelpers.getTrainingCycleEndDate(
    cycleStart,
    cycle.periodsTotal,
    cycle.daysPerPeriod,
  );

  // Get first and last day of the month
  final firstOfMonth = DateTime(month.year, month.month, 1);
  final lastOfMonth = DateTime(month.year, month.month + 1, 0);

  // Iterate through each day of the month
  for (
    var day = firstOfMonth;
    !day.isAfter(lastOfMonth);
    day = DateHelpers.addDays(day, 1)
  ) {
    final strippedDay = DateHelpers.stripTime(day);

    // Check if this day is within the training cycle
    if (strippedDay.isBefore(cycleStart) || strippedDay.isAfter(cycleEnd)) {
      result.add(CalendarDayData(date: strippedDay));
      continue;
    }

    // Calculate period and day number
    final daysFromStart = DateHelpers.daysBetween(cycleStart, strippedDay);
    final periodNumber = (daysFromStart ~/ cycle.daysPerPeriod) + 1;
    final dayNumber = (daysFromStart % cycle.daysPerPeriod) + 1;

    // Find workouts for this day
    final dayWorkouts = allWorkouts
        .where(
          (w) => w.periodNumber == periodNumber && w.dayNumber == dayNumber,
        )
        .toList();

    // Collect muscle groups and count sets per muscle group
    final muscleGroups = <String>{};
    final muscleGroupSets = <String, int>{};
    final muscleGroupExercises = <String, List<String>>{};
    for (final workout in dayWorkouts) {
      for (final exercise in workout.exercises) {
        final groupName = exercise.muscleGroup.displayName;
        muscleGroups.add(groupName);
        muscleGroupSets[groupName] =
            (muscleGroupSets[groupName] ?? 0) + exercise.sets.length;
        // Track exercise names with set counts
        final exercises = muscleGroupExercises[groupName] ?? [];
        exercises.add('${exercise.name} (${exercise.sets.length} sets)');
        muscleGroupExercises[groupName] = exercises;
      }
    }

    // Determine completion status
    final isCompleted =
        dayWorkouts.isNotEmpty &&
        dayWorkouts.every((w) => w.status == WorkoutStatus.completed);
    final isPartiallyCompleted =
        dayWorkouts.isNotEmpty &&
        !isCompleted &&
        dayWorkouts.any((w) => w.status == WorkoutStatus.completed);

    result.add(
      CalendarDayData(
        date: strippedDay,
        periodNumber: periodNumber,
        dayNumber: dayNumber,
        workouts: dayWorkouts,
        isRecoveryPeriod: periodNumber == cycle.recoveryPeriod,
        isCompleted: isCompleted,
        isPartiallyCompleted: isPartiallyCompleted,
        muscleGroups: muscleGroups,
        muscleGroupSets: muscleGroupSets,
        muscleGroupExercises: muscleGroupExercises,
      ),
    );
  }

  return result;
}

/// Provider for calendar data for a specific month
final calendarDataProvider = Provider.family<List<CalendarDayData>, DateTime>((
  ref,
  month,
) {
  final cycle = ref.watch(currentTrainingCycleProvider);

  if (cycle == null) return [];

  final workouts = ref.watch(workoutsByTrainingCycleListProvider(cycle.id));

  return buildCalendarData(cycle: cycle, allWorkouts: workouts, month: month);
});

/// Provider for period background colors
/// Returns a map of period number to color
final periodColorsProvider = Provider<Map<int, Color>>((ref) {
  // Define a set of distinct colors for periods
  const periodColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  return Map.fromEntries(
    List.generate(periodColors.length, (i) => MapEntry(i + 1, periodColors[i])),
  );
});

/// Get color for a specific period
Color getPeriodColor(Map<int, Color> colors, int periodNumber) {
  // Cycle through colors if more periods than colors
  final index = (periodNumber - 1) % colors.length;
  return colors[index + 1] ?? Colors.grey;
}

/// State for undo functionality
class CalendarUndoState {
  final ScheduleSnapshot? snapshot;
  final String? cycleId;

  const CalendarUndoState({this.snapshot, this.cycleId});

  /// Returns true if there's a snapshot from within the last 24 hours
  bool get hasRecentSnapshot {
    if (snapshot == null) return false;
    final age = DateTime.now().difference(snapshot!.timestamp);
    return age.inHours < 24;
  }

  CalendarUndoState copyWith({ScheduleSnapshot? snapshot, String? cycleId}) {
    return CalendarUndoState(
      snapshot: snapshot ?? this.snapshot,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  CalendarUndoState clear() {
    return const CalendarUndoState();
  }
}

/// Notifier for managing undo state
class CalendarUndoNotifier extends Notifier<CalendarUndoState> {
  @override
  CalendarUndoState build() {
    return const CalendarUndoState();
  }

  void setSnapshot(String cycleId, ScheduleSnapshot snapshot) {
    state = CalendarUndoState(cycleId: cycleId, snapshot: snapshot);
  }

  void clear() {
    state = state.clear();
  }

  Future<bool> undo() async {
    if (state.snapshot == null || state.cycleId == null) {
      return false;
    }

    try {
      final service = ref.read(scheduleServiceProvider);
      await service.restoreSnapshot(state.cycleId!, state.snapshot!);
      clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for undo state
final calendarUndoProvider =
    NotifierProvider<CalendarUndoNotifier, CalendarUndoState>(() {
      return CalendarUndoNotifier();
    });

/// State for calendar screen
class CalendarScreenState {
  final DateTime focusedMonth;
  final DateTime? selectedDate;

  const CalendarScreenState({required this.focusedMonth, this.selectedDate});

  CalendarScreenState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
  }) {
    return CalendarScreenState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
    );
  }
}

/// Notifier for calendar screen state
class CalendarScreenNotifier extends Notifier<CalendarScreenState> {
  @override
  CalendarScreenState build() {
    return CalendarScreenState(
      focusedMonth: DateTime.now(),
      selectedDate: DateTime.now(),
    );
  }

  void setFocusedMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
  }

  void setSelectedDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearSelectedDate: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
  }

  void goToToday() {
    final now = DateTime.now();
    state = CalendarScreenState(focusedMonth: now, selectedDate: now);
  }

  void previousMonth() {
    state = state.copyWith(
      focusedMonth: DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month - 1,
      ),
    );
  }

  void nextMonth() {
    state = state.copyWith(
      focusedMonth: DateTime(
        state.focusedMonth.year,
        state.focusedMonth.month + 1,
      ),
    );
  }
}

/// Provider for calendar screen state
final calendarScreenProvider =
    NotifierProvider<CalendarScreenNotifier, CalendarScreenState>(() {
      return CalendarScreenNotifier();
    });
