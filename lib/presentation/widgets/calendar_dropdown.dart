import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/theme/skins/skins.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/workout_providers.dart';

/// Dropdown for selecting period and day (appears below AppBar)
///
/// Used in both workout_screen and exercises_screen for calendar navigation.
class CalendarDropdown extends ConsumerStatefulWidget {
  final TrainingCycle trainingCycle;
  final int currentPeriod;
  final int currentDay;
  final int selectedPeriod;
  final int selectedDay;
  final List<Workout> allWorkouts;
  final Function(int period, int day) onDaySelected;

  const CalendarDropdown({
    super.key,
    required this.trainingCycle,
    required this.currentPeriod,
    required this.currentDay,
    required this.selectedPeriod,
    required this.selectedDay,
    required this.allWorkouts,
    required this.onDaySelected,
  });

  @override
  ConsumerState<CalendarDropdown> createState() => _CalendarDropdownState();
}

class _CalendarDropdownState extends ConsumerState<CalendarDropdown> {
  late int _selectedPeriod;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod;
    _selectedDay = widget.selectedDay;
  }

  Future<void> _addPeriod() async {
    // Add a new period before the recovery period
    final trainingCycle = widget.trainingCycle;
    final newPeriodNumber = trainingCycle
        .periodsTotal; // This will be the new period number (before recovery)

    // Get all existing workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );

    // Get the last non-recovery period as a template
    // If periodsTotal is 4 (1, 2, 3, 4=DL), we want to copy period 3.
    // templatePeriod = 4 - 1 = 3.
    final templatePeriod = trainingCycle.periodsTotal - 1;

    // Safety check: if we only have 1 period (which is recovery), we can't really copy "previous" period.
    // But usually a trainingCycle starts with at least some periods.
    // If templatePeriod < 1, we might need to copy the recovery period but change it?
    // Or just assume there's always at least one normal period if we are adding.
    // If periodsTotal is 1 (just recovery?), templatePeriod is 0.

    List<Workout> templateWorkouts = [];
    if (templatePeriod >= 1) {
      templateWorkouts = allWorkouts
          .where((w) => w.periodNumber == templatePeriod)
          .toList();
    } else {
      // Fallback: if we are at period 1 (recovery), and we add a period, maybe copy period 1?
      // But period 1 is recovery.
      // Let's just try to find ANY period to copy, or copy the recovery period but reset RIR?
      // For now, let's assume we copy the period before recovery.
      templateWorkouts = allWorkouts
          .where((w) => w.periodNumber == trainingCycle.periodsTotal)
          .toList();
    }

    if (templateWorkouts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cannot add period: No template workouts found',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
      return;
    }

    // 1. Shift Recovery Period: Update recovery period workouts to be one period later
    // Current recovery period is at `trainingCycle.periodsTotal`. New position will be `trainingCycle.periodsTotal + 1`.
    final recoveryWorkouts = allWorkouts
        .where((w) => w.periodNumber == trainingCycle.periodsTotal)
        .toList();
    for (var workout in recoveryWorkouts) {
      final updatedWorkout = workout.copyWith(
        periodNumber: trainingCycle.periodsTotal + 1,
      );
      await repository.update(updatedWorkout);
    }

    // 2. Create New Period: Create new workouts for the new period based on template
    // The new period will take the place of the old recovery period index (which is `trainingCycle.periodsTotal` before increment).
    // Wait, if we have periods 1, 2, 3(DL). periodsTotal=3.
    // We want 1, 2, 3, 4(DL).
    // Old DL was 3. New DL is 4.
    // New period is 3.
    // So newPeriodNumber = trainingCycle.periodsTotal (which is 3). Correct.

    for (var templateWorkout in templateWorkouts) {
      final newWorkout = templateWorkout.copyWith(
        id: const Uuid().v4(),
        periodNumber: newPeriodNumber,
        status: WorkoutStatus.incomplete, // Reset status
        exercises: templateWorkout.exercises
            .map(
              (exercise) => exercise.copyWith(
                id: const Uuid().v4(),
                workoutId: const Uuid()
                    .v4(), // This will be replaced by newWorkout.id but we need to ensure it matches
                // Actually, we should set workoutId after we have the newWorkout ID, but copyWith on top level handles it?
                // No, workout.exercises usually have workoutId.
                // Let's just generate IDs.
                sets: exercise.sets
                    .map(
                      (set) => set.copyWith(
                        id: const Uuid().v4(),
                        isLogged: false,
                        weight:
                            null, // Reset weight? Or keep previous? Usually keep previous for progressive overload reference?
                        // User request says "add another period". Usually implies copying structure.
                        // Let's keep weight empty or null to force user to enter new weights, or maybe copy?
                        // Existing logic in some apps copies previous weights.
                        // But here let's reset logged state.
                        reps: '',
                        isSkipped: false,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );

      // Fix workoutId in exercises
      final fixedExercises = newWorkout.exercises
          .map((e) => e.copyWith(workoutId: newWorkout.id))
          .toList();
      final finalWorkout = newWorkout.copyWith(exercises: fixedExercises);

      await repository.create(finalWorkout);
    }

    // Update trainingCycle periods total and recovery period
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      periodsTotal: trainingCycle.periodsTotal + 1,
      recoveryPeriod: trainingCycle.recoveryPeriod + 1,
    );
    await trainingCycleRepository.update(updatedTrainingCycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Period $newPeriodNumber added'),
          backgroundColor: context.successColor,
        ),
      );
    }
  }

  Future<void> _removePeriod() async {
    // Remove the last period before the recovery period
    final trainingCycle = widget.trainingCycle;

    // If we have periods 1, 2, 3, 4(DL). periodsTotal=4.
    // We want to remove period 3.
    // periodToRemove = 4 - 1 = 3.
    final periodToRemove = trainingCycle.periodsTotal - 1;

    if (periodToRemove < 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cannot remove: Must have at least 1 period'),
            backgroundColor: context.errorColor,
          ),
        );
      }
      return;
    }

    // Get all workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );

    // 1. Delete Period: Delete all workouts for the period to remove
    final workoutsToRemove = allWorkouts
        .where((w) => w.periodNumber == periodToRemove)
        .toList();
    for (var workout in workoutsToRemove) {
      await repository.delete(workout.id);
    }

    // 2. Shift Recovery Period: Update recovery period workouts to be one period earlier
    // Current recovery is `trainingCycle.periodsTotal`. New position is `periodToRemove` (which is periodsTotal - 1).
    final recoveryWorkouts = allWorkouts
        .where((w) => w.periodNumber == trainingCycle.periodsTotal)
        .toList();
    for (var workout in recoveryWorkouts) {
      final updatedWorkout = workout.copyWith(periodNumber: periodToRemove);
      await repository.update(updatedWorkout);
    }

    // Update trainingCycle periods total and recovery period
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      periodsTotal: trainingCycle.periodsTotal - 1,
      recoveryPeriod: trainingCycle.recoveryPeriod - 1,
    );
    await trainingCycleRepository.update(updatedTrainingCycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Period $periodToRemove removed'),
          backgroundColor: context.successColor,
        ),
      );

      // If selected period was removed or is now out of bounds, go to previous period
      if (_selectedPeriod >= updatedTrainingCycle.periodsTotal) {
        setState(() {
          _selectedPeriod = updatedTrainingCycle
              .periodsTotal; // Go to new last period (recovery)
        });
        widget.onDaySelected(_selectedPeriod, _selectedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate day names based on trainingCycle start date
    // Note: Day names are now calculated per-period inside _buildPeriodColumn

    // Calculate dynamic height based on number of workout days
    // Header height: 60, Period header: 60, Day button: 48, Day margin: 6
    // Total per day: 54 (48 + 6 margin)
    final headerHeight = 60.0;
    final periodHeaderHeight = 60.0;
    final dayButtonHeight = 48.0;
    final dayMargin = 6.0;
    final bottomPadding = 16.0;

    final calculatedHeight =
        headerHeight +
        periodHeaderHeight +
        (widget.trainingCycle.daysPerPeriod * (dayButtonHeight + dayMargin)) +
        bottomPadding;

    // Get available screen height and limit the dropdown height
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.5; // Max 50% of screen height
    final constrainedHeight = calculatedHeight.clamp(0.0, maxHeight);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: constrainedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header with +/- buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERIODS',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: widget.trainingCycle.periodsTotal > 1
                          ? () => _removePeriod()
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: () => _addPeriod(),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Period grid with responsive layout
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.trainingCycle.periodsTotal, (
                    periodIndex,
                  ) {
                    final periodNumber = periodIndex + 1;
                    return Expanded(
                      child: _buildPeriodColumn(
                        periodNumber,
                        widget.trainingCycle.recoveryPeriod == periodNumber,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodColumn(int periodNumber, bool isRecovery) {
    // Calculate day names specific to THIS period
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final periodDayNames = List.generate(widget.trainingCycle.daysPerPeriod, (
      index,
    ) {
      final dayNumber = index + 1;

      // Check if there's a custom label for this day in THIS SPECIFIC period
      final periodDayWorkouts = widget.allWorkouts
          .where(
            (w) => w.dayNumber == dayNumber && w.periodNumber == periodNumber,
          )
          .toList();

      if (periodDayWorkouts.isNotEmpty) {
        // Check if all workouts for this day in this period have the same custom dayName
        final firstDayName = periodDayWorkouts.first.dayName;
        final allHaveSameName = periodDayWorkouts.every(
          (w) => w.dayName == firstDayName,
        );

        // Use custom dayName if all workouts in this period have the same non-null custom name
        if (allHaveSameName &&
            firstDayName != null &&
            firstDayName.isNotEmpty) {
          return firstDayName.substring(0, 3).toUpperCase();
        }
      }

      // Otherwise, calculate based on trainingCycle start date
      if (widget.trainingCycle.startDate != null) {
        // Get the day of week when trainingCycle started (0 = Sunday, 6 = Saturday)
        final startDayOfWeek = widget.trainingCycle.startDate!.weekday % 7;

        // Calculate which actual day this workout falls on
        final daysElapsed =
            ((periodNumber - 1) * widget.trainingCycle.daysPerPeriod) +
            (dayNumber - 1);

        // Calculate actual day of week
        final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;

        return defaultDayNames[actualDayOfWeek];
      }

      // Fallback to default
      return defaultDayNames[index % defaultDayNames.length];
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Period header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRecovery
                      ? widget.trainingCycle.recoveryPeriodType.abbreviation
                      : '$periodNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_calculateRIR(periodNumber)} RIR',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Day buttons - limit to available workout days only
          ...List.generate(periodDayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentPeriod = periodNumber == widget.currentPeriod;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                periodNumber == _selectedPeriod && dayNumber == _selectedDay;

            // Check actual workout completion status from database
            final dayWorkouts = widget.allWorkouts
                .where(
                  (w) =>
                      w.periodNumber == periodNumber &&
                      w.dayNumber == dayNumber,
                )
                .toList();
            final isCompleted =
                dayWorkouts.isNotEmpty &&
                dayWorkouts.every((w) => w.status == WorkoutStatus.completed);

            // Determine background and text colors based on state
            Color backgroundColor;
            Color textColor;

            if (isCompleted) {
              backgroundColor = context.successColor;
              textColor = Colors.white;
            } else if (isCurrentPeriod && isCurrentDay) {
              backgroundColor = context.workoutCurrentColor;
              textColor = Colors.white;
            } else {
              backgroundColor = Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest;
              textColor = Theme.of(context).colorScheme.onSurface;
            }

            return GestureDetector(
              onTap: () {
                widget.onDaySelected(periodNumber, dayNumber);
              },
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: context.warningColor, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  periodDayNames[dayIndex],
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _calculateRIR(int periodNumber) {
    final recoveryPeriod = widget.trainingCycle.recoveryPeriod;

    // Recovery period has 8 RIR
    if (periodNumber == recoveryPeriod) {
      return 8;
    }

    // Calculate periods until recovery
    final periodsUntilRecovery = recoveryPeriod - periodNumber;

    // Period before recovery = 0 RIR
    // 2 periods before = 1 RIR
    // 3 periods before = 2 RIR, etc.
    if (periodsUntilRecovery == 1) {
      return 0;
    } else if (periodsUntilRecovery > 1) {
      return periodsUntilRecovery - 1;
    } else {
      // After recovery period
      return 0;
    }
  }
}
