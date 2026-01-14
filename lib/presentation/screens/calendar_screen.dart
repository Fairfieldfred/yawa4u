import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/skins/skins.dart';
import '../../core/utils/date_helpers.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/calendar_providers.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/app_icon_widget.dart';
import '../widgets/calendar/calendar_edit_sheet.dart';
import '../widgets/calendar/calendar_legend_dialog.dart';
import '../widgets/screen_background.dart';

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

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrainingCycle = ref.watch(currentTrainingCycleProvider);

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
            // Today button
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Go to today',
              onPressed: _goToToday,
            ),
            // Theme toggle
            IconButton(
              icon: Icon(
                ref.watch(isDarkModeProvider)
                    ? Icons.light_mode
                    : Icons.dark_mode,
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
            : _buildCalendarContent(context, currentTrainingCycle),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, dynamic trainingCycle) {
    final allWorkouts = ref.watch(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    // Build calendar data for current month and adjacent months
    // to handle overflow days shown in calendar view
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    final calendarData = [
      ...buildCalendarData(
        cycle: trainingCycle,
        allWorkouts: allWorkouts,
        month: prevMonth,
      ),
      ...buildCalendarData(
        cycle: trainingCycle,
        allWorkouts: allWorkouts,
        month: currentMonth,
      ),
      ...buildCalendarData(
        cycle: trainingCycle,
        allWorkouts: allWorkouts,
        month: nextMonth,
      ),
    ];

    // Build lookup map for quick access
    final dataMap = <DateTime, CalendarDayData>{};
    for (final data in calendarData) {
      dataMap[DateHelpers.stripTime(data.date)] = data;
    }

    final periodColors = ref.watch(periodColorsProvider);

    return Column(
      children: [
        _buildCalendar(context, trainingCycle, dataMap, periodColors),
        if (_selectedDay != null)
          Expanded(
            child: _buildSelectedDayInfo(
              context,
              trainingCycle,
              dataMap[DateHelpers.stripTime(_selectedDay!)],
            ),
          ),
      ],
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
    // Calculate row height based on calendar format
    final double rowHeight;
    switch (_calendarFormat) {
      case CalendarFormat.week:
        rowHeight = 280; // 4x height for week view
      case CalendarFormat.twoWeeks:
        rowHeight = 140; // 2x height for 2 weeks view
      case CalendarFormat.month:
        rowHeight = 70; // Default height for month view
    }

    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      rowHeight: rowHeight,
      selectedDayPredicate: (day) {
        return _selectedDay != null &&
            DateHelpers.isSameDay(day, _selectedDay!);
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
        if (dayData?.hasWorkout ?? false) {
          _showEditSheet(context, dayData!);
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
                      fontWeight: (isToday || isSelected)
                          ? FontWeight.bold
                          : FontWeight.normal,
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
                ],
              ),
            ),
            // Bottom section: Muscle group color bars (month view only)
            if (calendarFormat == CalendarFormat.month &&
                (dayData?.hasWorkout ?? false))
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: _buildMuscleGroupBars(
                  context,
                  dayData!.muscleGroupSets,
                  muscleGroupExercises: dayData.muscleGroupExercises,
                ),
              ),
            // Expanded section: Muscle group circles (2 weeks and week view)
            if ((calendarFormat == CalendarFormat.twoWeeks ||
                    calendarFormat == CalendarFormat.week) &&
                (dayData?.hasWorkout ?? false))
              Expanded(
                flex: calendarFormat == CalendarFormat.week ? 4 : 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _buildMuscleGroupCircles(
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

  Widget _buildMuscleGroupBars(
    BuildContext context,
    Map<String, int> muscleGroupSets, {
    Map<String, List<String>>? muscleGroupExercises,
  }) {
    if (muscleGroupSets.isEmpty) return const SizedBox.shrink();

    // Take up to 4 muscle groups, sorted by set count descending
    final sortedEntries = muscleGroupSets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
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
    final sortedEntries = muscleGroupSets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            final diameter =
                minDiameter + (ratio * (maxDiameter - minDiameter));

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

  Widget _buildSelectedDayInfo(
    BuildContext context,
    dynamic trainingCycle,
    CalendarDayData? dayData,
  ) {
    if (_selectedDay == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              if (dayData?.hasWorkout ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildStatusBadge(context, dayData!),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dayData?.hasWorkout ?? false)
            Expanded(
              child: _buildWorkoutSummary(context, dayData!, trainingCycle),
            )
          else
            Text(
              'No workout scheduled',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
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
        const Spacer(),
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

      // Invalidate provider to force refresh from repository
      ref.invalidate(trainingCyclesProvider);

      // Force UI rebuild
      if (mounted) {
        setState(() {});
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

  void _showEditSheet(BuildContext context, CalendarDayData dayData) {
    CalendarEditSheet.show(
      context,
      selectedPeriod: dayData.periodNumber!,
      selectedDay: dayData.dayNumber!,
      onInsertDayBefore: (period, day) => _insertDayBefore(period, day),
    );
  }

  void _navigateToWorkout(CalendarDayData dayData) {
    if (!dayData.hasWorkout) return;

    // Update workout home controller to select this day
    ref
        .read(workoutHomeControllerProvider.notifier)
        .selectDay(dayData.periodNumber!, dayData.dayNumber!);

    // Switch to workout tab
    ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.workout);
  }
}
