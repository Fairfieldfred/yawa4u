import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/skins/skins.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/services/schedule_service.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/calendar_providers.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/calendar/calendar_legend_dialog.dart';
import '../widgets/calendar/workout_move_sheet.dart';
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
          title: const Text('Calendar'),
          actions: [
            // Shift backward button
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              tooltip: 'Shift cycle back 1 day',
              onPressed: () => _shiftCycle(-1),
            ),
            // Shift forward button
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              tooltip: 'Shift cycle forward 1 day',
              onPressed: () => _shiftCycle(1),
            ),
            // Today button
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Go to today',
              onPressed: _goToToday,
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

    final calendarData = buildCalendarData(
      cycle: trainingCycle,
      allWorkouts: allWorkouts,
      month: _focusedDay,
    );

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
    return TableCalendar(
      firstDay: DateTime(2020),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
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
          _showMoveSheet(context, trainingCycle, dayData!);
        }
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
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
      border = Border.all(color: context.warningColor, width: 2);
    } else if (isToday) {
      border = Border.all(color: context.workoutCurrentColor, width: 2);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                '${day.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: (isToday || isSelected)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              // Period/Day indicator
              if (dayData?.hasWorkout ?? false)
                Text(
                  'P${dayData!.periodNumber}D${dayData.dayNumber}',
                  style: TextStyle(
                    color: textColor.withAlpha(200),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          // Muscle group dots at bottom
          if (dayData?.hasWorkout ?? false)
            Positioned(
              bottom: 2,
              child: _buildMuscleGroupDots(context, dayData!.muscleGroups),
            ),
        ],
      ),
    );
  }

  Widget _buildOutsideDayCell(BuildContext context, DateTime day) {
    return Container(
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMuscleGroupDots(BuildContext context, Set<String> muscleGroups) {
    if (muscleGroups.isEmpty) return const SizedBox.shrink();

    // Limit to 4 dots
    final groups = muscleGroups.take(4).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: groups.map((group) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _getMuscleGroupColor(context, group),
            shape: BoxShape.circle,
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
              Text(
                DateHelpers.fullDate.format(_selectedDay!),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (dayData?.hasWorkout ?? false)
                _buildStatusBadge(context, dayData!),
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
                onPressed: () =>
                    _showMoveSheet(context, trainingCycle, dayData),
                icon: const Icon(Icons.open_with, size: 18),
                label: const Text('Move'),
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

  Future<void> _shiftCycle(int days) async {
    final cycle = ref.read(currentTrainingCycleProvider);
    if (cycle == null) return;

    try {
      final service = ref.read(scheduleServiceProvider);
      final snapshot = await service.shiftTrainingCycleStart(cycle.id, days);

      // Store snapshot for undo
      ref.read(calendarUndoProvider.notifier).setSnapshot(cycle.id, snapshot);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to shift cycle: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  void _showMoveSheet(
    BuildContext context,
    dynamic trainingCycle,
    CalendarDayData dayData,
  ) {
    WorkoutMoveSheet.show(
      context,
      sourcePeriod: dayData.periodNumber!,
      sourceDay: dayData.dayNumber!,
      cycleStartDate: trainingCycle.startDate,
      daysPerPeriod: trainingCycle.daysPerPeriod,
      periodsTotal: trainingCycle.periodsTotal,
      onMove: (targetPeriod, targetDay, mode) async {
        await _moveWorkout(
          trainingCycle.id,
          dayData.periodNumber!,
          dayData.dayNumber!,
          targetPeriod,
          targetDay,
          mode,
        );
      },
    );
  }

  Future<void> _moveWorkout(
    String cycleId,
    int sourcePeriod,
    int sourceDay,
    int targetPeriod,
    int targetDay,
    MoveMode mode,
  ) async {
    try {
      final service = ref.read(scheduleServiceProvider);
      final snapshot = await service.moveWorkout(
        cycleId: cycleId,
        sourcePeriod: sourcePeriod,
        sourceDay: sourceDay,
        targetPeriod: targetPeriod,
        targetDay: targetDay,
        mode: mode,
      );

      // Store snapshot for undo
      ref.read(calendarUndoProvider.notifier).setSnapshot(cycleId, snapshot);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move workout: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
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
