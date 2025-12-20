import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/workout_providers.dart';

/// Dropdown for selecting week and day (appears below AppBar)
///
/// Used in both workout_screen and exercises_screen for calendar navigation.
class CalendarDropdown extends ConsumerStatefulWidget {
  final TrainingCycle trainingCycle;
  final int currentWeek;
  final int currentDay;
  final int selectedWeek;
  final int selectedDay;
  final List<Workout> allWorkouts;
  final Function(int week, int day) onDaySelected;

  const CalendarDropdown({
    super.key,
    required this.trainingCycle,
    required this.currentWeek,
    required this.currentDay,
    required this.selectedWeek,
    required this.selectedDay,
    required this.allWorkouts,
    required this.onDaySelected,
  });

  @override
  ConsumerState<CalendarDropdown> createState() => _CalendarDropdownState();
}

class _CalendarDropdownState extends ConsumerState<CalendarDropdown> {
  late int _selectedWeek;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedWeek = widget.selectedWeek;
    _selectedDay = widget.selectedDay;
  }

  Future<void> _addWeek() async {
    // Add a new week before the deload week
    final trainingCycle = widget.trainingCycle;
    final newWeekNumber = trainingCycle
        .weeksTotal; // This will be the new week number (before deload)

    // Get all existing workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    // Get the last non-deload week as a template
    // If weeksTotal is 4 (1, 2, 3, 4=DL), we want to copy week 3.
    // templateWeek = 4 - 1 = 3.
    final templateWeek = trainingCycle.weeksTotal - 1;

    // Safety check: if we only have 1 week (which is deload), we can't really copy "previous" week.
    // But usually a trainingCycle starts with at least some weeks.
    // If templateWeek < 1, we might need to copy the deload week but change it?
    // Or just assume there's always at least one normal week if we are adding.
    // If weeksTotal is 1 (just deload?), templateWeek is 0.

    List<Workout> templateWorkouts = [];
    if (templateWeek >= 1) {
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == templateWeek)
          .toList();
    } else {
      // Fallback: if we are at week 1 (deload), and we add a week, maybe copy week 1?
      // But week 1 is deload.
      // Let's just try to find ANY week to copy, or copy the deload week but reset RIR?
      // For now, let's assume we copy the week before deload.
      templateWorkouts = allWorkouts
          .where((w) => w.weekNumber == trainingCycle.weeksTotal)
          .toList();
    }

    if (templateWorkouts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot add week: No template workouts found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 1. Shift Deload Week: Update deload week workouts to be one week later
    // Current deload week is at `trainingCycle.weeksTotal`. New position will be `trainingCycle.weeksTotal + 1`.
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == trainingCycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      final updatedWorkout = workout.copyWith(
        weekNumber: trainingCycle.weeksTotal + 1,
      );
      await repository.update(updatedWorkout);
    }

    // 2. Create New Week: Create new workouts for the new week based on template
    // The new week will take the place of the old deload week index (which is `trainingCycle.weeksTotal` before increment).
    // Wait, if we have weeks 1, 2, 3(DL). weeksTotal=3.
    // We want 1, 2, 3, 4(DL).
    // Old DL was 3. New DL is 4.
    // New week is 3.
    // So newWeekNumber = trainingCycle.weeksTotal (which is 3). Correct.

    for (var templateWorkout in templateWorkouts) {
      final newWorkout = templateWorkout.copyWith(
        id: const Uuid().v4(),
        weekNumber: newWeekNumber,
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
                        // User request says "add another week". Usually implies copying structure.
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

    // Update trainingCycle weeks total and deload week
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      weeksTotal: trainingCycle.weeksTotal + 1,
      deloadWeek: trainingCycle.deloadWeek + 1,
    );
    await trainingCycleRepository.update(updatedTrainingCycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $newWeekNumber added'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeWeek() async {
    // Remove the last week before the deload week
    final trainingCycle = widget.trainingCycle;

    // If we have weeks 1, 2, 3, 4(DL). weeksTotal=4.
    // We want to remove week 3.
    // weekToRemove = 4 - 1 = 3.
    final weekToRemove = trainingCycle.weeksTotal - 1;

    if (weekToRemove < 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot remove: Must have at least 1 week'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Get all workouts
    final repository = ref.read(workoutRepositoryProvider);
    final allWorkouts = ref.read(
      workoutsByTrainingCycleProvider(trainingCycle.id),
    );

    // 1. Delete Week: Delete all workouts for the week to remove
    final workoutsToRemove = allWorkouts
        .where((w) => w.weekNumber == weekToRemove)
        .toList();
    for (var workout in workoutsToRemove) {
      await repository.delete(workout.id);
    }

    // 2. Shift Deload Week: Update deload week workouts to be one week earlier
    // Current deload is `trainingCycle.weeksTotal`. New position is `weekToRemove` (which is weeksTotal - 1).
    final deloadWorkouts = allWorkouts
        .where((w) => w.weekNumber == trainingCycle.weeksTotal)
        .toList();
    for (var workout in deloadWorkouts) {
      final updatedWorkout = workout.copyWith(weekNumber: weekToRemove);
      await repository.update(updatedWorkout);
    }

    // Update trainingCycle weeks total and deload week
    final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
    final updatedTrainingCycle = trainingCycle.copyWith(
      weeksTotal: trainingCycle.weeksTotal - 1,
      deloadWeek: trainingCycle.deloadWeek - 1,
    );
    await trainingCycleRepository.update(updatedTrainingCycle);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week $weekToRemove removed'),
          backgroundColor: Colors.green,
        ),
      );

      // If selected week was removed or is now out of bounds, go to previous week
      if (_selectedWeek >= updatedTrainingCycle.weeksTotal) {
        setState(() {
          _selectedWeek =
              updatedTrainingCycle.weeksTotal; // Go to new last week (deload)
        });
        widget.onDaySelected(_selectedWeek, _selectedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate day names based on trainingCycle start date
    // Note: Day names are now calculated per-week inside _buildWeekColumn

    // Calculate dynamic height based on number of workout days
    // Header height: 60, Week header: 60, Day button: 48, Day margin: 6
    // Total per day: 54 (48 + 6 margin)
    final headerHeight = 60.0;
    final weekHeaderHeight = 60.0;
    final dayButtonHeight = 48.0;
    final dayMargin = 6.0;
    final bottomPadding = 12.0;

    final calculatedHeight =
        headerHeight +
        weekHeaderHeight +
        (widget.trainingCycle.daysPerWeek * (dayButtonHeight + dayMargin)) +
        bottomPadding;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: calculatedHeight,
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
                  'WEEKS',
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
                      onPressed: widget.trainingCycle.weeksTotal > 1
                          ? () => _removeWeek()
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
                      onPressed: () => _addWeek(),
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

          // Week grid with responsive layout
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.trainingCycle.weeksTotal, (
                  weekIndex,
                ) {
                  final weekNumber = weekIndex + 1;
                  return Expanded(
                    child: _buildWeekColumn(
                      weekNumber,
                      widget.trainingCycle.deloadWeek == weekNumber,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekColumn(int weekNumber, bool isDeload) {
    // Calculate day names specific to THIS week
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final weekDayNames = List.generate(widget.trainingCycle.daysPerWeek, (
      index,
    ) {
      final dayNumber = index + 1;

      // Check if there's a custom label for this day in THIS SPECIFIC week
      final weekDayWorkouts = widget.allWorkouts
          .where((w) => w.dayNumber == dayNumber && w.weekNumber == weekNumber)
          .toList();

      if (weekDayWorkouts.isNotEmpty) {
        // Check if all workouts for this day in this week have the same custom dayName
        final firstDayName = weekDayWorkouts.first.dayName;
        final allHaveSameName = weekDayWorkouts.every(
          (w) => w.dayName == firstDayName,
        );

        // Use custom dayName if all workouts in this week have the same non-null custom name
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
            ((weekNumber - 1) * widget.trainingCycle.daysPerWeek) +
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
          // Week header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDeload
                      ? widget.trainingCycle.recoveryWeekType.abbreviation
                      : '$weekNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_calculateRIR(weekNumber)} RIR',
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
          ...List.generate(weekDayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isCurrentWeek = weekNumber == widget.currentWeek;
            final isCurrentDay = dayNumber == widget.currentDay;
            final isSelected =
                weekNumber == _selectedWeek && dayNumber == _selectedDay;

            // Check actual workout completion status from database
            final dayWorkouts = widget.allWorkouts
                .where(
                  (w) => w.weekNumber == weekNumber && w.dayNumber == dayNumber,
                )
                .toList();
            final isCompleted =
                dayWorkouts.isNotEmpty &&
                dayWorkouts.every((w) => w.status == WorkoutStatus.completed);

            // Determine background and text colors based on state
            Color backgroundColor;
            Color textColor;

            if (isCompleted) {
              backgroundColor = Colors.green;
              textColor = Colors.white;
            } else if (isCurrentWeek && isCurrentDay) {
              backgroundColor = Colors.red;
              textColor = Colors.white;
            } else {
              backgroundColor = Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest;
              textColor = Theme.of(context).colorScheme.onSurface;
            }

            return GestureDetector(
              onTap: () {
                widget.onDaySelected(weekNumber, dayNumber);
              },
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.orange, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  weekDayNames[dayIndex],
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

  int _calculateRIR(int weekNumber) {
    final deloadWeek = widget.trainingCycle.deloadWeek;

    // Deload week has 8 RIR
    if (weekNumber == deloadWeek) {
      return 8;
    }

    // Calculate weeks until deload
    final weeksUntilDeload = deloadWeek - weekNumber;

    // Week before deload = 0 RIR
    // 2 weeks before = 1 RIR
    // 3 weeks before = 2 RIR, etc.
    if (weeksUntilDeload == 1) {
      return 0;
    } else if (weeksUntilDeload > 1) {
      return weeksUntilDeload - 1;
    } else {
      // After deload week
      return 0;
    }
  }
}
