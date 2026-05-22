import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/exercise.dart';
import '../../data/models/session.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../data/services/schedule_service.dart';
import 'database_providers.dart';
import 'session_providers.dart';
import 'training_cycle_providers.dart';
import 'workout_providers.dart';

/// Provider for ScheduleService
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    cycleRepository: ref.watch(trainingCycleRepositoryProvider),
    workoutRepository: ref.watch(workoutRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
  );
});

/// Represents an exercise with its parent workout context
class CalendarExerciseItem {
  final Exercise exercise;
  final String workoutId;
  final int periodNumber;
  final int dayNumber;

  const CalendarExerciseItem({
    required this.exercise,
    required this.workoutId,
    required this.periodNumber,
    required this.dayNumber,
  });

  String get id => exercise.id;
  String get name => exercise.name;
  int get setCount => exercise.sets.length;
  int get loggedSetCount => exercise.sets.where((s) => s.isLogged).length;
}

/// Data for a single calendar day
class CalendarDayData {
  final DateTime date;
  final int? periodNumber;
  final int? dayNumber;
  final List<Workout> workouts;

  /// Non-strength sessions on this day (imports, cycle-attached cardio, etc.)
  final List<CardioSession> cardioSessions;

  final bool isRecoveryPeriod;
  final bool isCompleted;
  final bool isPartiallyCompleted;
  final Set<String> muscleGroups;

  /// Map of muscle group name to total number of sets
  final Map<String, int> muscleGroupSets;

  /// Map of muscle group name to list of exercise names with set counts
  final Map<String, List<String>> muscleGroupExercises;

  /// List of all exercises for this day with workout context (for drag-drop)
  final List<CalendarExerciseItem> exercises;

  CalendarDayData({
    required this.date,
    this.periodNumber,
    this.dayNumber,
    this.workouts = const [],
    this.cardioSessions = const [],
    this.isRecoveryPeriod = false,
    this.isCompleted = false,
    this.isPartiallyCompleted = false,
    this.muscleGroups = const {},
    this.muscleGroupSets = const {},
    this.muscleGroupExercises = const {},
    this.exercises = const [],
  });

  /// True if this day has at least one strength workout.
  bool get hasWorkout => workouts.isNotEmpty;

  /// True if this day has at least one cardio session.
  bool get hasCardio => cardioSessions.isNotEmpty;

  /// True if this day has any session (strength or cardio).
  bool get hasAnySession => hasWorkout || hasCardio;
}

/// Get the effective scheduled date for a workout.
/// Delegates to [DateHelpers.getEffectiveWorkoutDate].
DateTime getWorkoutScheduledDate(
  Workout workout,
  DateTime cycleStart,
  int daysPerPeriod,
) {
  return DateHelpers.getEffectiveWorkoutDate(
    cycleStart: cycleStart,
    daysPerPeriod: daysPerPeriod,
    periodNumber: workout.periodNumber,
    dayNumber: workout.dayNumber,
    scheduledDate: workout.scheduledDate,
  );
}

/// Build calendar data for a month given a training cycle.
///
/// This function maps workouts to calendar dates using scheduledDate when
/// available, falling back to calculating the date from period/day.
/// This allows workouts to be shifted to different dates while preserving
/// their original period/day designations.
///
/// When [dateRangeSessions] is provided, non-strength sessions are grouped
/// by date and attached to each day's [CalendarDayData.cardioSessions].
/// This lets imports (HealthKit / Strava) and cycle-attached cardio appear
/// alongside strength workouts on the calendar.
List<CalendarDayData> buildCalendarData({
  required TrainingCycle cycle,
  required List<Workout> allWorkouts,
  required DateTime month,
  List<Session> dateRangeSessions = const [],
  List<Session> cycleSessions = const [],
}) {
  final result = <CalendarDayData>[];

  if (cycle.startDate == null) {
    // No start date — fall back to createdDate so the calendar still
    // renders data instead of showing empty.
    debugPrint(
      '[Calendar] cycle "${cycle.name}" has no startDate, '
      'falling back to createdDate ${cycle.createdDate}',
    );
  }

  final cycleStart = DateHelpers.stripTime(
    cycle.startDate ?? cycle.createdDate,
  );

  // Calculate cycle end date, accounting for any inserted rest days
  // Find the latest scheduled date among all workouts
  DateTime cycleEnd = DateHelpers.getTrainingCycleEndDate(
    cycleStart,
    cycle.periodsTotal,
    cycle.daysPerPeriod,
  );

  // Extend cycleEnd if any workout is scheduled beyond it
  for (final workout in allWorkouts) {
    final workoutDate = getWorkoutScheduledDate(
      workout,
      cycleStart,
      cycle.daysPerPeriod,
    );
    if (workoutDate.isAfter(cycleEnd)) {
      cycleEnd = workoutDate;
    }
  }

  // Build a map of calendar date -> list of workouts for that date
  final workoutsByDate = <DateTime, List<Workout>>{};
  for (final workout in allWorkouts) {
    final date = getWorkoutScheduledDate(
      workout,
      cycleStart,
      cycle.daysPerPeriod,
    );
    workoutsByDate.putIfAbsent(date, () => []).add(workout);
  }

  // Group non-strength sessions by date so imports appear alongside
  // cycle-attached workouts on the calendar.
  final cardioByDate = <DateTime, List<CardioSession>>{};
  final seenCardioIds = <String>{};
  for (final session in dateRangeSessions) {
    if (session is! CardioSession) continue;
    final date = session.scheduledDate ?? session.completedDate;
    if (date == null) continue;
    final stripped = DateHelpers.stripTime(date);
    cardioByDate.putIfAbsent(stripped, () => []).add(session);
    seenCardioIds.add(session.id);
  }

  // Cycle-attached cardio sessions without scheduledDate (e.g. from
  // templates) won't appear in dateRangeSessions. Calculate their
  // calendar date from periodNumber/dayNumber — same logic strength
  // workouts use.
  for (final session in cycleSessions) {
    if (session is! CardioSession) continue;
    if (seenCardioIds.contains(session.id)) continue;
    DateTime? date = session.scheduledDate ?? session.completedDate;
    if (date == null && session.periodNumber != null && session.dayNumber != null) {
      date = DateHelpers.getEffectiveWorkoutDate(
        cycleStart: cycleStart,
        daysPerPeriod: cycle.daysPerPeriod,
        periodNumber: session.periodNumber!,
        dayNumber: session.dayNumber!,
        scheduledDate: null,
      );
    }
    if (date == null) continue;
    final stripped = DateHelpers.stripTime(date);
    cardioByDate.putIfAbsent(stripped, () => []).add(session);
  }

  // Get first and last day of the month
  final firstOfMonth = DateTime(month.year, month.month, 1);
  final lastOfMonth = DateTime(month.year, month.month + 1, 0);

  // Iterate through each day of the month
  for (var day = firstOfMonth; !day.isAfter(lastOfMonth); day = DateHelpers.addDays(day, 1)) {
    final strippedDay = DateHelpers.stripTime(day);

    // Check if this day is within the training cycle range
    if (strippedDay.isBefore(cycleStart) || strippedDay.isAfter(cycleEnd)) {
      result.add(CalendarDayData(date: strippedDay));
      continue;
    }

    // Find workouts scheduled for this calendar date
    final dayWorkouts = workoutsByDate[strippedDay] ?? [];

    // Get period/day from workouts if available, otherwise calculate default
    int? displayPeriod;
    int? displayDay;

    if (dayWorkouts.isNotEmpty) {
      // Use the period/day from the first workout (all workouts on same day should share period/day)
      displayPeriod = dayWorkouts.first.periodNumber;
      displayDay = dayWorkouts.first.dayNumber;
    } else {
      // No workouts on this day - it could be a rest day or inserted blank day
      // Calculate what the default period/day would be for UI display purposes
      final daysFromStart = DateHelpers.daysBetween(cycleStart, strippedDay);
      displayPeriod = (daysFromStart ~/ cycle.daysPerPeriod) + 1;
      displayDay = (daysFromStart % cycle.daysPerPeriod) + 1;
    }

    // Collect muscle groups and count sets per muscle group
    final muscleGroups = <String>{};
    final muscleGroupSets = <String, int>{};
    final muscleGroupExercises = <String, List<String>>{};
    final allDayExercises = <CalendarExerciseItem>[];

    for (final workout in dayWorkouts) {
      for (final exercise in workout.exercises) {
        final groupName = exercise.muscleGroup.displayName;
        muscleGroups.add(groupName);
        muscleGroupSets[groupName] = (muscleGroupSets[groupName] ?? 0) + exercise.sets.length;
        // Track exercise names with set counts
        final exercises = muscleGroupExercises[groupName] ?? [];
        exercises.add('${exercise.name} (${exercise.sets.length} sets)');
        muscleGroupExercises[groupName] = exercises;

        // Add to flat exercise list for drag-drop
        // Use the workout's actual period/day, not calculated
        allDayExercises.add(
          CalendarExerciseItem(
            exercise: exercise,
            workoutId: workout.id,
            periodNumber: workout.periodNumber,
            dayNumber: workout.dayNumber,
          ),
        );
      }
    }

    // Sort exercises by order index
    allDayExercises.sort(
      (a, b) => a.exercise.orderIndex.compareTo(b.exercise.orderIndex),
    );

    // Cardio sessions for this day (imports + cycle-attached).
    final dayCardio = cardioByDate[strippedDay] ?? const <CardioSession>[];

    // Determine completion status across both strength and cardio.
    final strengthDone = dayWorkouts.isEmpty || dayWorkouts.every((w) => w.status == WorkoutStatus.completed);
    final cardioDone = dayCardio.isEmpty || dayCardio.every((s) => s.status == WorkoutStatus.completed);
    final hasSessions = dayWorkouts.isNotEmpty || dayCardio.isNotEmpty;

    final isCompleted = hasSessions && strengthDone && cardioDone;
    final isPartiallyCompleted =
        hasSessions &&
        !isCompleted &&
        (dayWorkouts.any((w) => w.status == WorkoutStatus.completed) ||
            dayCardio.any((s) => s.status == WorkoutStatus.completed));

    result.add(
      CalendarDayData(
        date: strippedDay,
        periodNumber: displayPeriod,
        dayNumber: displayDay,
        workouts: dayWorkouts,
        cardioSessions: dayCardio,
        isRecoveryPeriod: displayPeriod == cycle.recoveryPeriod,
        isCompleted: isCompleted,
        isPartiallyCompleted: isPartiallyCompleted,
        muscleGroups: muscleGroups,
        muscleGroupSets: muscleGroupSets,
        muscleGroupExercises: muscleGroupExercises,
        exercises: allDayExercises,
      ),
    );
  }

  return result;
}

/// Provider for calendar data for a specific month.
///
/// Merges cycle-attached strength workouts with date-scoped sessions
/// so that imports (HealthKit / Strava) appear on the calendar.
final calendarDataProvider = Provider.autoDispose.family<List<CalendarDayData>, DateTime>((
  ref,
  month,
) {
  final cycle = ref.watch(currentTrainingCycleProvider);

  if (cycle == null) return [];

  final workouts = ref.watch(workoutsByTrainingCycleListProvider(cycle.id));

  // Watch date-range sessions for the full month to pick up imports.
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final sessionsAsync = ref.watch(
    sessionsInDateRangeProvider((start: monthStart, end: monthEnd)),
  );
  final dateRangeSessions = sessionsAsync.value ?? const <Session>[];

  // Also watch cycle-attached sessions so cardio without scheduledDate
  // (e.g. from templates) can be placed on the calendar via period/day.
  final cycleSessionsAsync = ref.watch(
    sessionsByTrainingCycleProvider(cycle.id),
  );
  final cycleSessions = cycleSessionsAsync.value ?? const <Session>[];

  return buildCalendarData(
    cycle: cycle,
    allWorkouts: workouts,
    month: month,
    dateRangeSessions: dateRangeSessions,
    cycleSessions: cycleSessions,
  );
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
final calendarUndoProvider = NotifierProvider<CalendarUndoNotifier, CalendarUndoState>(() {
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
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
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
final calendarScreenProvider = NotifierProvider<CalendarScreenNotifier, CalendarScreenState>(() {
  return CalendarScreenNotifier();
});
