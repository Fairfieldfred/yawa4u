import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../domain/controllers/workout_home_controller.dart';
import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../data/models/session.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/calendar_providers.dart';
import '../../../domain/providers/navigation_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../../domain/providers/theme_provider.dart';
import '../../../domain/providers/training_cycle_providers.dart';
import '../../../domain/providers/workout_providers.dart';
import '../../widgets/app_icon_widget.dart';
import '../../widgets/cardio/quick_log_action.dart';
import '../../widgets/calendar/calendar_drag_data.dart';
import '../../widgets/calendar/calendar_edit_sheet.dart';
import '../../widgets/calendar/calendar_legend_dialog.dart';
import '../../widgets/calendar/calendar_sport_dots.dart';
import '../../widgets/calendar/desktop_calendar_day_cell.dart';
import '../../widgets/screen_background.dart';
import '../workout/add_exercise_screen.dart';

/// Calendar screen showing workouts in a monthly calendar view
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currentCycles = ref.watch(currentTrainingCyclesProvider);
    final currentTrainingCycle = currentCycles.isEmpty ? null : currentCycles.first;

    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: const AppIconWidget(),
          leadingWidth: kToolbarHeight + 12,
          title: const Text('Calendar'),
          actions: [
            const QuickLogAction(),
            // Today button
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Go to today',
              onPressed: _goToToday,
            ),
            // Theme toggle
            IconButton(
              icon: Icon(
                ref.watch(isDarkModeProvider) ? Icons.light_mode : Icons.dark_mode,
              ),
              tooltip: 'Toggle theme',
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
            // Legend info button
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Show legend',
              onPressed: () => CalendarLegendDialog.show(context),
            ),
          ],
        ),
        body: currentTrainingCycle == null
            ? _buildNoTrainingCycle(context)
            : _buildCalendarContent(context, currentCycles),
      ),
    );
  }

  Widget _buildCalendarContent(
    BuildContext context,
    List<TrainingCycle> allCycles,
  ) {
    final primaryCycle = allCycles.first;

    // Build calendar data for current month and adjacent months
    // to handle overflow days shown in calendar view
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    // Load date-range sessions for the 3-month window so imports
    // (HealthKit / Strava) and cycle-attached cardio appear on calendar.
    final rangeStart = prevMonth;
    final rangeEnd = DateTime(
      _focusedDay.year,
      _focusedDay.month + 2,
      0,
      23,
      59,
      59,
    );
    final sessionsAsync = ref.watch(
      sessionsInDateRangeProvider((start: rangeStart, end: rangeEnd)),
    );
    final dateRangeSessions = sessionsAsync.value ?? const <Session>[];

    // Build calendar data for the primary cycle first.
    final primaryWorkouts = ref.watch(
      workoutsByTrainingCycleListProvider(primaryCycle.id),
    );
    final primarySessionsAsync = ref.watch(
      sessionsByTrainingCycleProvider(primaryCycle.id),
    );
    final primarySessions = primarySessionsAsync.value ?? const <Session>[];

    final months = [prevMonth, currentMonth, nextMonth];
    final dataMap = <DateTime, CalendarDayData>{};
    for (final month in months) {
      for (final day in buildCalendarData(
        cycle: primaryCycle,
        allWorkouts: primaryWorkouts,
        month: month,
        dateRangeSessions: dateRangeSessions,
        cycleSessions: primarySessions,
      )) {
        dataMap[DateHelpers.stripTime(day.date)] = day;
      }
    }

    // Merge data from secondary stacked cycles so their workouts
    // and cardio sessions also appear on the calendar.
    for (final cycle in allCycles.skip(1)) {
      final secWorkouts = ref.watch(
        workoutsByTrainingCycleListProvider(cycle.id),
      );
      final secSessionsAsync = ref.watch(
        sessionsByTrainingCycleProvider(cycle.id),
      );
      final secSessions = secSessionsAsync.value ?? const <Session>[];

      for (final month in months) {
        for (final day in buildCalendarData(
          cycle: cycle,
          allWorkouts: secWorkouts,
          month: month,
          // dateRangeSessions already included in primary — pass
          // empty to avoid duplicating imports on each day.
          cycleSessions: secSessions,
        )) {
          final key = DateHelpers.stripTime(day.date);
          final existing = dataMap[key];
          if (existing != null) {
            dataMap[key] = _mergeDayData(existing, day);
          } else {
            dataMap[key] = day;
          }
        }
      }
    }

    final periodColors = ref.watch(periodColorsProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCalendar(context, primaryCycle, dataMap, periodColors),
          if (_selectedDay != null)
            _buildSelectedDayInfo(
              context,
              primaryCycle,
              dataMap[DateHelpers.stripTime(_selectedDay!)],
            ),
        ],
      ),
    );
  }

  /// Merge a secondary cycle's day data into the primary day entry.
  ///
  /// Keeps the primary's period/day numbers (for display) and combines
  /// workouts, cardio sessions, muscle groups, and exercises from both.
  CalendarDayData _mergeDayData(
    CalendarDayData primary,
    CalendarDayData secondary,
  ) {
    if (!secondary.hasAnySession) return primary;

    // Deduplicate cardio by ID (dateRangeSessions may overlap).
    final seenCardioIds = primary.cardioSessions.map((s) => s.id).toSet();
    final newCardio = secondary.cardioSessions.where((s) => !seenCardioIds.contains(s.id)).toList();

    // Merge muscle group sets by summing.
    final mergedSets = Map<String, int>.from(primary.muscleGroupSets);
    for (final entry in secondary.muscleGroupSets.entries) {
      mergedSets[entry.key] = (mergedSets[entry.key] ?? 0) + entry.value;
    }

    // Merge muscle group exercises by concatenating.
    final mergedExercises = Map<String, List<String>>.from(
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
      isRecoveryPeriod: primary.isRecoveryPeriod,
      isCompleted: isCompleted,
      isPartiallyCompleted: isPartiallyCompleted,
      muscleGroups: {...primary.muscleGroups, ...secondary.muscleGroups},
      muscleGroupSets: mergedSets,
      muscleGroupExercises: mergedExercises,
      exercises: allExercises,
    );
  }

  Widget _buildNoTrainingCycle(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
            ),
            const SizedBox(height: 16),
            Text(
              'No active training cycle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a training cycle to see your workouts on the calendar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    dynamic trainingCycle,
    Map<DateTime, CalendarDayData> dataMap,
    Map<int, Color> periodColors,
  ) {
    // Calculate row height based on calendar format and screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final double rowHeight;
    switch (_calendarFormat) {
      case CalendarFormat.week:
        // Use less height on smaller screens to prevent overflow
        rowHeight = screenHeight < 700 ? 300 : 450;
      case CalendarFormat.twoWeeks:
        rowHeight = screenHeight < 700 ? 140 : 180;
      case CalendarFormat.month:
        rowHeight = 70; // Default height for month view
    }

    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      rowHeight: rowHeight,
      selectedDayPredicate: (day) {
        return _selectedDay != null && DateHelpers.isSameDay(day, _selectedDay!);
      },
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onDayLongPressed: (selectedDay, focusedDay) {
        final dayData = dataMap[DateHelpers.stripTime(selectedDay)];
        // Show edit sheet for workout days OR rest days within cycle date range
        if (dayData != null) {
          // For workout days, show all options
          // For rest days (no workout but within cycle dates), show remove option
          _showEditSheet(context, dayData);
        }
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        cellMargin: const EdgeInsets.all(1),
        cellPadding: EdgeInsets.zero,
        outsideTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
        ),
        todayDecoration: BoxDecoration(
          border: Border.all(color: context.workoutCurrentColor, width: 2),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          border: Border.all(color: context.warningColor, width: 2),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        defaultTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        weekendTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        formatButtonTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            context,
            day,
            dataMap,
            periodColors,
            false,
            false,
            _calendarFormat,
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            context,
            day,
            dataMap,
            periodColors,
            true,
            false,
            _calendarFormat,
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(
            context,
            day,
            dataMap,
            periodColors,
            false,
            true,
            _calendarFormat,
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          return _buildOutsideDayCell(context, day);
        },
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    Map<DateTime, CalendarDayData> dataMap,
    Map<int, Color> periodColors,
    bool isToday,
    bool isSelected,
    CalendarFormat calendarFormat,
  ) {
    final strippedDay = DateHelpers.stripTime(day);
    final dayData = dataMap[strippedDay];

    // Use desktop drag-drop cell for expanded views on all platforms
    // This provides a consistent experience with exercise list and drag-drop
    final useDesktopCell = (calendarFormat == CalendarFormat.week || calendarFormat == CalendarFormat.twoWeeks);

    if (useDesktopCell) {
      return _buildDesktopDayCell(
        context,
        day,
        dayData,
        periodColors,
        isToday,
        isSelected,
      );
    }

    // Determine background color based on workout state
    Color backgroundColor;
    Color textColor;

    if (dayData?.hasWorkout ?? false) {
      if (dayData!.isCompleted) {
        backgroundColor = context.successColor;
        textColor = Colors.white;
      } else if (dayData.isPartiallyCompleted) {
        backgroundColor = context.warningColor;
        textColor = Colors.white;
      } else if (dayData.isRecoveryPeriod) {
        backgroundColor = context.workoutDeloadColor.withAlpha(77);
        textColor = Theme.of(context).colorScheme.onSurface;
      } else {
        // Use period color with low opacity
        final periodColor = getPeriodColor(periodColors, dayData.periodNumber!);
        backgroundColor = periodColor.withAlpha(51);
        textColor = Theme.of(context).colorScheme.onSurface;
      }
    } else {
      backgroundColor = Colors.transparent;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    // Border for today/selected
    BoxBorder? border;
    if (isSelected) {
      border = Border.all(color: context.warningColor, width: 3);
    } else if (isToday) {
      border = Border.all(color: context.workoutCurrentColor, width: 3);
    }

    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        child: Column(
          children: [
            // Top section: Day number and period/day
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (dayData?.hasWorkout ?? false)
                    Text(
                      'P${dayData!.periodNumber}D${dayData.dayNumber}',
                      style: TextStyle(
                        color: textColor.withAlpha(200),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  // v5 — cardio sport indicators. Renders nothing if the
                  // day has no cardio sessions so strength-only days are
                  // unchanged.
                  CalendarSportDots(
                    date: day,
                    dotSize: 4,
                    spacing: 2,
                  ),
                ],
              ),
            ),
            // Bottom section: Muscle group color bars (month view only)
            if (calendarFormat == CalendarFormat.month && (dayData?.hasWorkout ?? false))
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: _buildMuscleGroupBars(
                  context,
                  dayData!.muscleGroupSets,
                  muscleGroupExercises: dayData.muscleGroupExercises,
                ),
              ),
            // Expanded section: Muscle group display (2 weeks and week view)
            if ((calendarFormat == CalendarFormat.twoWeeks || calendarFormat == CalendarFormat.week) &&
                (dayData?.hasWorkout ?? false))
              Expanded(
                flex: calendarFormat == CalendarFormat.week ? 4 : 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Platform.isMacOS
                      ? _buildMuscleGroupList(
                          context,
                          dayData!.muscleGroupSets,
                          calendarFormat,
                          muscleGroupExercises: dayData.muscleGroupExercises,
                        )
                      : _buildMuscleGroupCircles(
                          context,
                          dayData!.muscleGroupSets,
                          calendarFormat,
                          muscleGroupExercises: dayData.muscleGroupExercises,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutsideDayCell(BuildContext context, DateTime day) {
    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.all(1),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Builds a desktop-optimized day cell with drag-and-drop support
  Widget _buildDesktopDayCell(
    BuildContext context,
    DateTime day,
    CalendarDayData? dayData,
    Map<int, Color> periodColors,
    bool isToday,
    bool isSelected,
  ) {
    final currentCycle = ref.watch(currentTrainingCycleProvider);

    return DesktopCalendarDayCell(
      date: day,
      dayData: dayData,
      periodColors: periodColors,
      isToday: isToday,
      isSelected: isSelected,
      selectedExerciseId: _selectedExerciseId,
      onTap: (selectedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
      },
      onExerciseSelected: (exerciseId) {
        setState(() {
          _selectedExerciseId = exerciseId;
        });
      },
      onExerciseDropped: (dragData, targetDate) async {
        if (currentCycle == null) return;

        try {
          switch (dragData) {
            case ExerciseDragData():
              final scheduleService = ref.read(scheduleServiceProvider);
              await scheduleService.moveExerciseToDate(
                cycleId: currentCycle.id,
                sourceWorkoutId: dragData.sourceWorkoutId,
                exerciseId: dragData.exercise.id,
                targetDate: targetDate,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Moved ${dragData.exercise.name} to ${DateHelpers.shortDate.format(targetDate)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

            case CardioDragData():
              final scheduleService = ref.read(scheduleServiceProvider);
              await scheduleService.moveCardioToDate(
                cycleId: currentCycle.id,
                session: dragData.session,
                targetDate: targetDate,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Moved ${dragData.session.label ?? dragData.session.sport.displayName} to ${DateHelpers.shortDate.format(targetDate)}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to move: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onExerciseReordered: (oldIndex, newIndex, targetDate) async {
        if (currentCycle == null) return;

        try {
          final scheduleService = ref.read(scheduleServiceProvider);
          await scheduleService.reorderExerciseWithinDayByDate(
            cycleId: currentCycle.id,
            targetDate: targetDate,
            oldIndex: oldIndex,
            newIndex: newIndex,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to reorder exercise: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      onAddExercise: (periodNumber, dayNumber, date) {
        _showAddExerciseModal(
          context,
          currentCycle,
          periodNumber,
          dayNumber,
          date,
        );
      },
    );
  }

  /// Shows a modal dialog to add an exercise to a specific day.
  ///
  /// Uses date-aware matching to avoid collisions with schedule-shifted
  /// workouts. When no workout exists on the target calendar [date],
  /// a blank workout is created with the correct period and a unique
  /// dayNumber (existing days in the period are renumbered to make room).
  Future<void> _showAddExerciseModal(
    BuildContext context,
    dynamic trainingCycle,
    int periodNumber,
    int dayNumber,
    DateTime date,
  ) async {
    if (trainingCycle == null || trainingCycle.startDate == null) return;

    final strippedDate = DateHelpers.stripTime(date);
    final cycleStart = DateHelpers.stripTime(trainingCycle.startDate!);
    final int daysPerPeriod = trainingCycle.daysPerPeriod;

    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );

    // Match workouts by effective date (not just period/day) to avoid
    // collisions with schedule-shifted workouts.
    final matchByDate = allWorkouts.where((w) {
      final wDate = DateHelpers.getEffectiveWorkoutDate(
        cycleStart: cycleStart,
        daysPerPeriod: daysPerPeriod,
        periodNumber: w.periodNumber,
        dayNumber: w.dayNumber,
        scheduledDate: w.scheduledDate,
      );
      return DateHelpers.isSameDay(wDate, strippedDate);
    }).toList();

    String workoutId;

    if (matchByDate.isNotEmpty) {
      // A workout already exists on this calendar date.
      workoutId = matchByDate.first.id;
    } else {
      // Blank day — determine the correct period and create a workout.
      final effectivePeriod = _determinePeriodForDate(
        allWorkouts,
        cycleStart,
        daysPerPeriod,
        strippedDate,
      );

      // Get all workouts in this period, sorted by effective date.
      final periodWorkouts = allWorkouts.where((w) => w.periodNumber == effectivePeriod).toList()
        ..sort((a, b) {
          final aDate = DateHelpers.getEffectiveWorkoutDate(
            cycleStart: cycleStart,
            daysPerPeriod: daysPerPeriod,
            periodNumber: a.periodNumber,
            dayNumber: a.dayNumber,
            scheduledDate: a.scheduledDate,
          );
          final bDate = DateHelpers.getEffectiveWorkoutDate(
            cycleStart: cycleStart,
            daysPerPeriod: daysPerPeriod,
            periodNumber: b.periodNumber,
            dayNumber: b.dayNumber,
            scheduledDate: b.scheduledDate,
          );
          return aDate.compareTo(bDate);
        });

      // Find the insertion dayNumber. Walk through existing workouts
      // in chronological order — the new day goes right after the last
      // workout whose date is before or on the target date.
      int insertionDayNumber = 1;
      for (final w in periodWorkouts) {
        final wDate = DateHelpers.getEffectiveWorkoutDate(
          cycleStart: cycleStart,
          daysPerPeriod: daysPerPeriod,
          periodNumber: w.periodNumber,
          dayNumber: w.dayNumber,
          scheduledDate: w.scheduledDate,
        );
        if (!wDate.isAfter(strippedDate)) {
          insertionDayNumber = w.dayNumber + 1;
        }
      }

      // Renumber: shift existing workouts at or after the insertion
      // point forward by 1 (process in descending order to avoid
      // temporary dayNumber collisions).
      final repository = ref.read(workoutRepositoryProvider);
      final toShift = periodWorkouts.where((w) => w.dayNumber >= insertionDayNumber).toList()
        ..sort((a, b) => b.dayNumber.compareTo(a.dayNumber));

      for (final w in toShift) {
        await repository.update(
          w.copyWith(dayNumber: w.dayNumber + 1),
        );
      }

      // Create the new blank workout.
      final newId = const Uuid().v4();
      final newWorkout = Workout(
        id: newId,
        trainingCycleId: trainingCycle.id,
        periodNumber: effectivePeriod,
        dayNumber: insertionDayNumber,
        status: WorkoutStatus.incomplete,
        scheduledDate: strippedDate,
        exercises: [],
      );
      await repository.create(newWorkout);
      workoutId = newId;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.8,
            child: AddExerciseScreen(
              trainingCycleId: trainingCycle.id,
              workoutId: workoutId,
            ),
          ),
        ),
      ),
    );
  }

  /// Determine which period a blank-day [targetDate] belongs to by
  /// examining the nearest preceding workout by effective date.
  int _determinePeriodForDate(
    List<Workout> allWorkouts,
    DateTime cycleStart,
    int daysPerPeriod,
    DateTime targetDate,
  ) {
    Workout? nearest;
    DateTime? nearestDate;

    for (final w in allWorkouts) {
      final wDate = DateHelpers.getEffectiveWorkoutDate(
        cycleStart: cycleStart,
        daysPerPeriod: daysPerPeriod,
        periodNumber: w.periodNumber,
        dayNumber: w.dayNumber,
        scheduledDate: w.scheduledDate,
      );
      if (!wDate.isAfter(targetDate)) {
        if (nearestDate == null || wDate.isAfter(nearestDate)) {
          nearest = w;
          nearestDate = wDate;
        }
      }
    }
    if (nearest != null) return nearest.periodNumber;

    // No preceding workout — try the next one after targetDate.
    Workout? nextWorkout;
    DateTime? nextDate;
    for (final w in allWorkouts) {
      final wDate = DateHelpers.getEffectiveWorkoutDate(
        cycleStart: cycleStart,
        daysPerPeriod: daysPerPeriod,
        periodNumber: w.periodNumber,
        dayNumber: w.dayNumber,
        scheduledDate: w.scheduledDate,
      );
      if (wDate.isAfter(targetDate)) {
        if (nextDate == null || wDate.isBefore(nextDate)) {
          nextWorkout = w;
          nextDate = wDate;
        }
      }
    }
    if (nextWorkout != null) return nextWorkout.periodNumber;

    // Absolute fallback: use the contiguous formula.
    final daysFromStart = DateHelpers.daysBetween(cycleStart, targetDate);
    return (daysFromStart ~/ daysPerPeriod) + 1;
  }

  Widget _buildMuscleGroupBars(
    BuildContext context,
    Map<String, int> muscleGroupSets, {
    Map<String, List<String>>? muscleGroupExercises,
  }) {
    if (muscleGroupSets.isEmpty) return const SizedBox.shrink();

    // Take up to 4 muscle groups, sorted by set count descending
    final sortedEntries = muscleGroupSets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final groups = sortedEntries.take(4).toList();

    // Calculate total sets for proportional widths
    final totalSets = groups.fold<int>(0, (sum, e) => sum + e.value);

    return Row(
      children: groups.map((entry) {
        // Use flex based on set count for proportional width
        final flex = ((entry.value / totalSets) * 100).round().clamp(1, 100);

        // Build tooltip message with exercise names
        final exercises = muscleGroupExercises?[entry.key] ?? [];
        final tooltipMessage = _buildTooltipMessage(
          entry.key,
          entry.value,
          exercises,
        );

        return Expanded(
          flex: flex,
          child: Tooltip(
            message: tooltipMessage,
            preferBelow: false,
            waitDuration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 12,
            ),
            child: Container(
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getMuscleGroupColor(context, entry.key),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getMuscleGroupColor(BuildContext context, String muscleGroup) {
    // Map muscle groups to colors based on category
    final upperPush = ['Chest', 'Triceps', 'Shoulders'];
    final upperPull = ['Back', 'Biceps'];
    final legs = ['Quads', 'Hamstrings', 'Glutes', 'Calves'];

    if (upperPush.contains(muscleGroup)) {
      return Colors.pink;
    } else if (upperPull.contains(muscleGroup)) {
      return Colors.cyan;
    } else if (legs.contains(muscleGroup)) {
      return Colors.teal;
    } else {
      return Colors.purple;
    }
  }

  /// Builds a tooltip message showing muscle group, set count, and exercises
  String _buildTooltipMessage(
    String muscleGroup,
    int setCount,
    List<String> exercises,
  ) {
    final buffer = StringBuffer();
    buffer.write('$muscleGroup • $setCount sets');
    if (exercises.isNotEmpty) {
      buffer.writeln();
      for (final exercise in exercises) {
        buffer.write('\n• $exercise');
      }
    }
    return buffer.toString();
  }

  Widget _buildMuscleGroupCircles(
    BuildContext context,
    Map<String, int> muscleGroupSets,
    CalendarFormat calendarFormat, {
    Map<String, List<String>>? muscleGroupExercises,
  }) {
    if (muscleGroupSets.isEmpty) return const SizedBox.shrink();

    // Sort by set count descending
    final sortedEntries = muscleGroupSets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Find max sets for scaling
    final maxSets = sortedEntries.first.value;

    // Base size depends on view - larger for week view
    final double maxDiameter = calendarFormat == CalendarFormat.week ? 32 : 20;
    final double minDiameter = calendarFormat == CalendarFormat.week ? 12 : 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: sortedEntries.map((entry) {
            // Scale diameter proportionally to sets (min to max range)
            final ratio = maxSets > 0 ? entry.value / maxSets : 0.0;
            final diameter = minDiameter + (ratio * (maxDiameter - minDiameter));

            // Build tooltip message with exercise names
            final exercises = muscleGroupExercises?[entry.key] ?? [];
            final tooltipMessage = _buildTooltipMessage(
              entry.key,
              entry.value,
              exercises,
            );

            return Tooltip(
              message: tooltipMessage,
              preferBelow: false,
              waitDuration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 12,
              ),
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  color: _getMuscleGroupColor(context, entry.key),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Builds a list view of muscle groups with exercises for macOS desktop
  Widget _buildMuscleGroupList(
    BuildContext context,
    Map<String, int> muscleGroupSets,
    CalendarFormat calendarFormat, {
    Map<String, List<String>>? muscleGroupExercises,
  }) {
    if (muscleGroupSets.isEmpty) return const SizedBox.shrink();

    // Sort by set count descending
    final sortedEntries = muscleGroupSets.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final isWeekView = calendarFormat == CalendarFormat.week;
    final textStyle = Theme.of(context).textTheme;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final muscleGroup = entry.key;
        final setCount = entry.value;
        final exercises = muscleGroupExercises?[muscleGroup] ?? [];
        final color = _getMuscleGroupColor(context, muscleGroup);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color indicator
              Container(
                width: 4,
                height: isWeekView ? 40 : 24,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Muscle group header with set count
                    Text(
                      '$muscleGroup • $setCount sets',
                      style: textStyle.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: isWeekView ? 11 : 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Exercise names (week view shows more detail)
                    if (exercises.isNotEmpty)
                      ...exercises
                          .take(isWeekView ? 4 : 2)
                          .map(
                            (exercise) => Text(
                              exercise,
                              style: textStyle.labelSmall?.copyWith(
                                fontSize: isWeekView ? 10 : 8,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    // Show "+X more" if there are more exercises
                    if (exercises.length > (isWeekView ? 4 : 2))
                      Text(
                        '+${exercises.length - (isWeekView ? 4 : 2)} more',
                        style: textStyle.labelSmall?.copyWith(
                          fontSize: isWeekView ? 9 : 7,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayInfo(
    BuildContext context,
    dynamic trainingCycle,
    CalendarDayData? dayData,
  ) {
    if (_selectedDay == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(100),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateHelpers.fullDate.format(_selectedDay!),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (dayData?.hasAnySession ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildStatusBadge(context, dayData!),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dayData?.hasWorkout ?? false) _buildWorkoutSummary(context, dayData!, trainingCycle),
          if (dayData?.hasCardio ?? false) ...[
            if (dayData!.hasWorkout) const SizedBox(height: 12),
            _buildCardioSummary(context, dayData),
          ],
          if (!(dayData?.hasAnySession ?? false))
            if (dayData != null)
              // Rest day - show message and edit button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rest Day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(128),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditSheet(context, dayData),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'No session scheduled',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(128),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, CalendarDayData dayData) {
    Color color;
    String label;

    if (dayData.isCompleted) {
      color = context.successColor;
      label = 'Completed';
    } else if (dayData.isPartiallyCompleted) {
      color = context.warningColor;
      label = 'In Progress';
    } else {
      color = Theme.of(context).colorScheme.primary;
      label = dayData.isRecoveryPeriod ? 'Recovery' : 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildWorkoutSummary(
    BuildContext context,
    CalendarDayData dayData,
    dynamic trainingCycle,
  ) {
    var totalExercises = 0;
    for (final workout in dayData.workouts) {
      totalExercises += workout.exercises.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Period ${dayData.periodNumber}, Day ${dayData.dayNumber}${dayData.isRecoveryPeriod ? ' (Recovery)' : ''}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '$totalExercises exercises • ${dayData.muscleGroups.join(', ')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showEditSheet(context, dayData),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _navigateToWorkout(dayData),
                icon: Icon(
                  dayData.isCompleted ? Icons.visibility : Icons.play_arrow,
                  size: 18,
                ),
                label: Text(dayData.isCompleted ? 'View' : 'Go to Workout'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Compact summary of cardio sessions for the selected day.
  Widget _buildCardioSummary(
    BuildContext context,
    CalendarDayData dayData,
  ) {
    final theme = Theme.of(context);
    final sessions = dayData.cardioSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${sessions.length} cardio session${sessions.length == 1 ? '' : 's'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        for (final session in sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  session.sport.icon,
                  size: 16,
                  color: session.sport.color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.label ?? session.sport.displayName,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildSessionStatusChip(context, session),
              ],
            ),
          ),
        if (!dayData.hasWorkout) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (dayData.periodNumber != null && dayData.dayNumber != null)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _navigateToWorkout(dayData),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Day'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSessionStatusChip(BuildContext context, CardioSession session) {
    final Color color;
    final String label;
    switch (session.status) {
      case WorkoutStatus.completed:
        color = context.successColor;
        label = 'Done';
      case WorkoutStatus.skipped:
        color = Theme.of(context).colorScheme.outline;
        label = 'Skipped';
      case WorkoutStatus.incomplete:
        color = Theme.of(context).colorScheme.primary;
        label = 'Planned';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  Future<void> _insertDayBefore(int period, int day) async {
    final cycle = ref.read(currentTrainingCycleProvider);
    if (cycle == null) return;

    try {
      final service = ref.read(scheduleServiceProvider);
      final snapshot = await service.insertDayBefore(
        cycleId: cycle.id,
        fromPeriod: period,
        fromDay: day,
      );

      // Store snapshot for undo
      ref.read(calendarUndoProvider.notifier).setSnapshot(cycle.id, snapshot);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rest day inserted before P${period}D$day'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to insert day: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _removeRestDay(DateTime restDayDate) async {
    final cycle = ref.read(currentTrainingCycleProvider);
    if (cycle == null) return;

    try {
      final service = ref.read(scheduleServiceProvider);
      final snapshot = await service.removeRestDay(
        cycleId: cycle.id,
        restDayDate: restDayDate,
      );

      // Store snapshot for undo
      ref.read(calendarUndoProvider.notifier).setSnapshot(cycle.id, snapshot);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rest day removed on ${DateHelpers.shortDate.format(restDayDate)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove rest day: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  void _showEditSheet(BuildContext context, CalendarDayData dayData) {
    // Determine if this is a rest day (no workouts scheduled)
    final isRestDay = !dayData.hasWorkout;

    CalendarEditSheet.show(
      context,
      selectedPeriod: dayData.periodNumber, // Can be null for rest days
      selectedDay: dayData.dayNumber, // Can be null for rest days
      isRestDay: isRestDay,
      selectedDate: dayData.date,
      onInsertDayBefore: dayData.hasWorkout ? (period, day) => _insertDayBefore(period, day) : null,
      onRemoveRestDay: isRestDay ? (date) => _removeRestDay(date) : null,
    );
  }

  void _navigateToWorkout(CalendarDayData dayData) {
    if (!dayData.hasWorkout) return;

    // Update workout home controller to select this day
    ref.read(workoutHomeControllerProvider.notifier).selectDay(dayData.periodNumber!, dayData.dayNumber!);

    // Switch to workout tab
    ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.workout);
  }
}
