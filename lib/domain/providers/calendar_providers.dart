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

/// One exercise entry in a calendar day's muscle-group breakdown.
typedef CalendarExerciseSummary = ({String name, int setCount});

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

/// One active cycle's contribution to a single calendar day.
///
/// Used for per-cycle attribution when multiple cycles are stacked: each
/// segment keeps its own period/day and the sessions that belong to that
/// cycle, so the calendar can group them under the cycle's name instead of
/// pooling everything under the primary cycle.
class CycleDaySegment {
  final String cycleId;
  final String cycleName;
  final int? periodNumber;
  final int? dayNumber;
  final bool isRecoveryPeriod;
  final List<Workout> workouts;
  final List<CardioSession> cardioSessions;

  const CycleDaySegment({
    required this.cycleId,
    required this.cycleName,
    this.periodNumber,
    this.dayNumber,
    this.isRecoveryPeriod = false,
    this.workouts = const [],
    this.cardioSessions = const [],
  });

  /// True if this cycle has any session on the day.
  bool get hasAnySession => workouts.isNotEmpty || cardioSessions.isNotEmpty;
}

/// Data for a single calendar day
class CalendarDayData {
  final DateTime date;
  final int? periodNumber;
  final int? dayNumber;
  final List<Workout> workouts;

  /// Non-strength sessions on this day (imports, cycle-attached cardio, etc.)
  final List<CardioSession> cardioSessions;

  /// Per-cycle breakdown of this day's cycle-attached sessions.
  ///
  /// One entry per active cycle that has a session on this day. Imported
  /// sessions (not tied to an active cycle) are not represented here — they
  /// remain in [cardioSessions] for the month-grid dots.
  final List<CycleDaySegment> segments;

  final bool isRecoveryPeriod;
  final bool isCompleted;
  final bool isPartiallyCompleted;
  final Set<MuscleGroup> muscleGroups;

  /// Map of muscle group to total number of sets
  final Map<MuscleGroup, int> muscleGroupSets;

  /// Map of muscle group to the day's exercises with their set counts.
  /// Exercise names are canonical English — localize at display time.
  final Map<MuscleGroup, List<CalendarExerciseSummary>> muscleGroupExercises;

  /// List of all exercises for this day with workout context (for drag-drop)
  final List<CalendarExerciseItem> exercises;

  CalendarDayData({
    required this.date,
    this.periodNumber,
    this.dayNumber,
    this.workouts = const [],
    this.cardioSessions = const [],
    this.segments = const [],
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

    // Check if this day is within the training cycle range.
    // Even outside the cycle range, attach any imported cardio sessions
    // so they render as cards rather than just sport dots.
    if (strippedDay.isBefore(cycleStart) || strippedDay.isAfter(cycleEnd)) {
      final dayCardio = cardioByDate[strippedDay] ?? const <CardioSession>[];
      result.add(
        CalendarDayData(
          date: strippedDay,
          cardioSessions: dayCardio,
        ),
      );
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
    final muscleGroups = <MuscleGroup>{};
    final muscleGroupSets = <MuscleGroup, int>{};
    final muscleGroupExercises = <MuscleGroup, List<CalendarExerciseSummary>>{};
    final allDayExercises = <CalendarExerciseItem>[];

    for (final workout in dayWorkouts) {
      for (final exercise in workout.exercises) {
        final group = exercise.muscleGroup;
        muscleGroups.add(group);
        muscleGroupSets[group] = (muscleGroupSets[group] ?? 0) + exercise.sets.length;
        // Track exercise names with set counts
        final exercises = muscleGroupExercises[group] ?? [];
        exercises.add((name: exercise.name, setCount: exercise.sets.length));
        muscleGroupExercises[group] = exercises;

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

    // Per-cycle attribution: this day's cycle-attached sessions. Strength
    // workouts are all cycle-attached by construction; cardio is filtered
    // to this cycle so imports stay out of the cycle's segment.
    final segmentCardio = dayCardio.where((s) => s.trainingCycleId == cycle.id).toList();
    final daySegments = (dayWorkouts.isNotEmpty || segmentCardio.isNotEmpty)
        ? [
            CycleDaySegment(
              cycleId: cycle.id,
              cycleName: cycle.name,
              periodNumber: displayPeriod,
              dayNumber: displayDay,
              isRecoveryPeriod: displayPeriod == cycle.recoveryPeriod,
              workouts: dayWorkouts,
              cardioSessions: segmentCardio,
            ),
          ]
        : const <CycleDaySegment>[];

    result.add(
      CalendarDayData(
        date: strippedDay,
        periodNumber: displayPeriod,
        dayNumber: displayDay,
        workouts: dayWorkouts,
        cardioSessions: dayCardio,
        segments: daySegments,
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

/// Merge a secondary cycle's day data into an existing day entry.
///
/// Keeps the primary's period/day numbers (for the month-grid label) but
/// **appends** the secondary's [CycleDaySegment]s so per-cycle attribution
/// is preserved, and combines workouts, cardio, muscle groups, and
/// exercises from both cycles for the aggregate dots/summary.
CalendarDayData mergeDayData(CalendarDayData primary, CalendarDayData secondary) {
  if (!secondary.hasAnySession && secondary.segments.isEmpty) return primary;

  // Deduplicate cardio by ID (dateRangeSessions may overlap).
  final seenCardioIds = primary.cardioSessions.map((s) => s.id).toSet();
  final newCardio = secondary.cardioSessions.where((s) => !seenCardioIds.contains(s.id)).toList();

  // Merge muscle group sets by summing.
  final mergedSets = Map<MuscleGroup, int>.from(primary.muscleGroupSets);
  for (final entry in secondary.muscleGroupSets.entries) {
    mergedSets[entry.key] = (mergedSets[entry.key] ?? 0) + entry.value;
  }

  // Merge muscle group exercises by concatenating.
  final mergedExercises = Map<MuscleGroup, List<CalendarExerciseSummary>>.from(
    primary.muscleGroupExercises,
  );
  for (final entry in secondary.muscleGroupExercises.entries) {
    mergedExercises[entry.key] = [
      ...mergedExercises[entry.key] ?? [],
      ...entry.value,
    ];
  }

  final allWorkouts = [...primary.workouts, ...secondary.workouts];
  final allCardio = [...primary.cardioSessions, ...newCardio];
  final allExercises = [...primary.exercises, ...secondary.exercises];

  // Append secondary segments (deduped by cycle id) for per-cycle attribution.
  final seenCycleIds = primary.segments.map((s) => s.cycleId).toSet();
  final mergedSegments = [
    ...primary.segments,
    ...secondary.segments.where((s) => !seenCycleIds.contains(s.cycleId)),
  ];

  // Recompute completion from merged data.
  final hasSessions = allWorkouts.isNotEmpty || allCardio.isNotEmpty;
  final strengthDone = allWorkouts.isEmpty || allWorkouts.every((w) => w.status == WorkoutStatus.completed);
  final cardioDone = allCardio.isEmpty || allCardio.every((s) => s.status == WorkoutStatus.completed);
  final isCompleted = hasSessions && strengthDone && cardioDone;
  final isPartiallyCompleted =
      hasSessions &&
      !isCompleted &&
      (allWorkouts.any((w) => w.status == WorkoutStatus.completed) ||
          allCardio.any((s) => s.status == WorkoutStatus.completed));

  return CalendarDayData(
    date: primary.date,
    periodNumber: primary.periodNumber,
    dayNumber: primary.dayNumber,
    workouts: allWorkouts,
    cardioSessions: allCardio,
    segments: mergedSegments,
    isRecoveryPeriod: primary.isRecoveryPeriod,
    isCompleted: isCompleted,
    isPartiallyCompleted: isPartiallyCompleted,
    muscleGroups: {...primary.muscleGroups, ...secondary.muscleGroups},
    muscleGroupSets: mergedSets,
    muscleGroupExercises: mergedExercises,
    exercises: allExercises,
  );
}

/// Merged calendar data for the focused month (plus adjacent months for
/// overflow days), keyed by stripped date.
///
/// This is the single source of truth for the calendar: it watches **all**
/// active cycles ([currentTrainingCyclesProvider]), builds each cycle's data,
/// and merges them per date with per-cycle attribution preserved.
final calendarMonthDataProvider = Provider.autoDispose.family<Map<DateTime, CalendarDayData>, DateTime>((
  ref,
  focusedDay,
) {
  final cycles = ref.watch(currentTrainingCyclesProvider);
  if (cycles.isEmpty) return const {};

  final currentMonth = DateTime(focusedDay.year, focusedDay.month, 1);
  final prevMonth = DateTime(focusedDay.year, focusedDay.month - 1, 1);
  final nextMonth = DateTime(focusedDay.year, focusedDay.month + 1, 1);
  final months = [prevMonth, currentMonth, nextMonth];

  // Load date-range sessions for the 3-month window so imports
  // (HealthKit / Strava) appear on the calendar.
  final rangeStart = prevMonth;
  final rangeEnd = DateTime(
    focusedDay.year,
    focusedDay.month + 2,
    0,
    23,
    59,
    59,
  );
  final dateRangeSessions =
      ref
          .watch(
            sessionsInDateRangeProvider((start: rangeStart, end: rangeEnd)),
          )
          .value ??
      const <Session>[];

  final dataMap = <DateTime, CalendarDayData>{};

  // Primary cycle builds the baseline (and owns the imported sessions).
  final primary = cycles.first;
  final primaryWorkouts = ref.watch(
    workoutsByTrainingCycleListProvider(primary.id),
  );
  final primarySessions = ref.watch(sessionsByTrainingCycleProvider(primary.id)).value ?? const <Session>[];
  for (final month in months) {
    for (final day in buildCalendarData(
      cycle: primary,
      allWorkouts: primaryWorkouts,
      month: month,
      dateRangeSessions: dateRangeSessions,
      cycleSessions: primarySessions,
    )) {
      dataMap[DateHelpers.stripTime(day.date)] = day;
    }
  }

  // Merge each stacked cycle. Imports are omitted here (already on the
  // primary) to avoid duplicating them per day.
  for (final cycle in cycles.skip(1)) {
    final secWorkouts = ref.watch(
      workoutsByTrainingCycleListProvider(cycle.id),
    );
    final secSessions = ref.watch(sessionsByTrainingCycleProvider(cycle.id)).value ?? const <Session>[];
    for (final month in months) {
      for (final day in buildCalendarData(
        cycle: cycle,
        allWorkouts: secWorkouts,
        month: month,
        cycleSessions: secSessions,
      )) {
        final key = DateHelpers.stripTime(day.date);
        final existing = dataMap[key];
        dataMap[key] = existing != null ? mergeDayData(existing, day) : day;
      }
    }
  }

  return dataMap;
});

// ========== SHARED SELECTED-DATE STATE ==========

/// The single shared "selected day" that drives the Calendar screen and the
/// AppBar calendars on the Workout and Exercises screens.
///
/// Stored as a stripped [DateTime] (the calendar's natural currency) so every
/// screen converts it to its own cycle's (period, day) via [selectedPeriodDay].
class SelectedWorkoutDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateHelpers.stripTime(DateTime.now());

  void selectDate(DateTime date) => state = DateHelpers.stripTime(date);

  void goToToday() => state = DateHelpers.stripTime(DateTime.now());
}

/// Provider for the shared selected workout date.
final selectedWorkoutDateProvider = NotifierProvider<SelectedWorkoutDateNotifier, DateTime>(
  SelectedWorkoutDateNotifier.new,
);

/// The (period, day) slot of [cycle] that contains [date], honoring schedule
/// shifts via the cycle's workouts. Returns `null` when [date] is outside the
/// cycle (or the cycle has no start date).
({int period, int day})? selectedPeriodDay(
  TrainingCycle cycle,
  List<Workout> workouts,
  DateTime date,
) {
  if (cycle.startDate == null) return null;
  return DateHelpers.periodDayForDate(
    cycleStart: cycle.startDate!,
    daysPerPeriod: cycle.daysPerPeriod,
    periodsTotal: cycle.periodsTotal,
    date: date,
    scheduledDates: DateHelpers.extractScheduledDates(
      workouts.map(
        (w) => (
          periodNumber: w.periodNumber,
          dayNumber: w.dayNumber,
          scheduledDate: w.scheduledDate,
        ),
      ),
    ),
  );
}

/// The (period, day) slot of [cycle] for today's date.
({int period, int day})? currentPeriodDay(
  TrainingCycle cycle,
  List<Workout> workouts,
) => selectedPeriodDay(cycle, workouts, DateTime.now());

/// The effective calendar date for a (period, day) slot of [cycle], honoring
/// schedule shifts. Inverse of [selectedPeriodDay].
DateTime dateForPeriodDay(
  TrainingCycle cycle,
  List<Workout> workouts,
  int period,
  int day,
) {
  final scheduled = workouts
      .where((w) => w.periodNumber == period && w.dayNumber == day)
      .map((w) => w.scheduledDate)
      .firstWhere((d) => d != null, orElse: () => null);
  return DateHelpers.getEffectiveWorkoutDate(
    cycleStart: cycle.startDate ?? cycle.createdDate,
    daysPerPeriod: cycle.daysPerPeriod,
    periodNumber: period,
    dayNumber: day,
    scheduledDate: scheduled,
  );
}

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

/// A single cycle's schedule snapshot, paired with its cycle id.
typedef CalendarUndoEntry = ({String cycleId, ScheduleSnapshot snapshot});

/// State for undo functionality.
///
/// Holds one entry per training cycle affected by the last schedule edit. A
/// single edit (e.g. inserting a rest day) can touch every active cycle when
/// cycles are stacked, so undo must be able to restore all of them.
class CalendarUndoState {
  final List<CalendarUndoEntry> entries;

  const CalendarUndoState({this.entries = const []});

  /// The most recent snapshot, used for display (e.g. the action description).
  ScheduleSnapshot? get snapshot => entries.isEmpty ? null : entries.first.snapshot;

  /// Whether an in-session snapshot exists to undo. Snapshots live only in
  /// memory, so undo is available for the current session — not 24 hours
  /// (the old claim, which never survived an app restart anyway).
  bool get hasRecentSnapshot => snapshot != null;

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

  /// Store a single cycle's snapshot (single-cycle edits).
  void setSnapshot(String cycleId, ScheduleSnapshot snapshot) {
    state = CalendarUndoState(entries: [(cycleId: cycleId, snapshot: snapshot)]);
  }

  /// Store snapshots for every cycle touched by a multi-cycle edit.
  void setSnapshots(List<CalendarUndoEntry> entries) {
    state = CalendarUndoState(entries: entries);
  }

  void clear() {
    state = state.clear();
  }

  Future<bool> undo() async {
    if (state.entries.isEmpty) {
      return false;
    }

    try {
      final service = ref.read(scheduleServiceProvider);
      for (final entry in state.entries) {
        await service.restoreSnapshot(entry.cycleId, entry.snapshot);
      }
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
