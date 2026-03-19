import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/theme/skins/skins.dart';
import '../../core/utils/weight_conversion.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/workout.dart';
import '../../domain/controllers/workout_home_controller.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/dialogs/exercise_info_dialog.dart';
import '../widgets/muscle_group_badge.dart';

/// Read-only view of a completed trainingCycle's workouts
/// Used for reviewing prior trainingCycle data and structure
class CompletedCycleWorkoutScreen extends ConsumerStatefulWidget {
  final String trainingCycleId;

  const CompletedCycleWorkoutScreen({super.key, required this.trainingCycleId});

  @override
  ConsumerState<CompletedCycleWorkoutScreen> createState() =>
      _CompletedCycleWorkoutScreenState();
}

class _CompletedCycleWorkoutScreenState
    extends ConsumerState<CompletedCycleWorkoutScreen> {
  int? _selectedPeriod;
  int? _selectedDay;
  bool _showWeekSelector = false;

  void _toggleWeekSelector() {
    setState(() {
      _showWeekSelector = !_showWeekSelector;
    });
  }

  void _hideWeekSelector() {
    setState(() {
      _showWeekSelector = false;
    });
  }

  void _selectDay(int week, int day) {
    setState(() {
      _selectedPeriod = week;
      _selectedDay = day;
      _showWeekSelector = false;
    });
  }

  /// Find the most recent pinned note for exercises with the same name
  Future<String?> _findPinnedNoteForExercise(dynamic exercise) async {
    if (exercise is! Exercise) return null;

    // First check if current exercise has a pinned note
    if (exercise.isNotePinned &&
        exercise.notes != null &&
        exercise.notes!.isNotEmpty) {
      return exercise.notes;
    }

    // Look for pinned notes from other exercises with the same name
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = await workoutRepo.getAll();

    // Find all exercises with the same name that have pinned notes
    final pinnedExercises = <Exercise>[];
    for (final workout in allWorkouts) {
      for (final ex in workout.exercises) {
        if (ex.name.toLowerCase() == exercise.name.toLowerCase() &&
            ex.id != exercise.id &&
            ex.isNotePinned &&
            ex.notes != null &&
            ex.notes!.isNotEmpty) {
          pinnedExercises.add(ex);
        }
      }
    }

    if (pinnedExercises.isEmpty) return null;

    // Return the most recent pinned note (by lastPerformed date, or just the first one)
    pinnedExercises.sort((a, b) {
      if (a.lastPerformed == null && b.lastPerformed == null) return 0;
      if (a.lastPerformed == null) return 1;
      if (b.lastPerformed == null) return -1;
      return b.lastPerformed!.compareTo(a.lastPerformed!);
    });

    return pinnedExercises.first.notes;
  }

  @override
  Widget build(BuildContext context) {
    final trainingCyclesAsync = ref.watch(trainingCyclesProvider);

    return trainingCyclesAsync.when(
      data: (trainingCycles) {
        final trainingCycle = trainingCycles
            .where((m) => m.id == widget.trainingCycleId)
            .firstOrNull;

        if (trainingCycle == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('TrainingCycle Not Found'),
            ),
            body: const Center(
              child: Text('The requested trainingCycle could not be found.'),
            ),
          );
        }

        final allWorkouts = ref.watch(
          workoutsByTrainingCycleListProvider(trainingCycle.id),
        );

        // Default to week 1, day 1 if not selected
        final displayPeriod = _selectedPeriod ?? 1;
        final displayDay = _selectedDay ?? 1;

        final todaysWorkouts = allWorkouts
            .where(
              (w) =>
                  w.periodNumber == displayPeriod && w.dayNumber == displayDay,
            )
            .toList();

        return _buildWorkoutView(
          context,
          ref,
          trainingCycle,
          todaysWorkouts,
          displayPeriod,
          displayDay,
          allWorkouts: allWorkouts,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.errorColor),
              const SizedBox(height: 16),
              Text('Error loading trainingCycle: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutView(
    BuildContext context,
    WidgetRef ref,
    TrainingCycle trainingCycle,
    List<Workout> workouts,
    int displayPeriod,
    int displayDay, {
    required List<Workout> allWorkouts,
  }) {
    // Calculate day name based on the trainingCycle start date
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    String dayName;

    if (workouts.isNotEmpty && workouts.first.dayName != null) {
      dayName = workouts.first.dayName!.substring(0, 3).toUpperCase();
    } else if (trainingCycle.startDate != null) {
      final startDayOfWeek = trainingCycle.startDate!.weekday % 7;
      final daysElapsed =
          ((displayPeriod - 1) * trainingCycle.daysPerPeriod) +
          (displayDay - 1);
      final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
      dayName = defaultDayNames[actualDayOfWeek];
    } else {
      dayName = displayDay >= 1 && displayDay <= defaultDayNames.length
          ? defaultDayNames[displayDay - 1]
          : 'DAY $displayDay';
    }

    // Collect all exercises from all workouts for today
    final allExercises = <dynamic>[];
    for (var workout in workouts) {
      allExercises.addAll(workout.exercises);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    trainingCycle.name.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) {
                      final successColor = context.successColor;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: successColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: successColor, width: 1),
                        ),
                        child: Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: successColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'WEEK $displayPeriod DAY $displayDay $dayName',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _toggleWeekSelector,
            ),
            // Theme toggle
            IconButton(
              icon: Icon(
                ref.watch(isDarkModeProvider)
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              tooltip: 'Toggle theme',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Exercise list
            allExercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises for this day',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80, top: 24),
                    itemCount: allExercises.length,
                    separatorBuilder: (context, index) {
                      final currentMuscleGroup =
                          allExercises[index].muscleGroup;
                      final nextMuscleGroup = index + 1 < allExercises.length
                          ? allExercises[index + 1].muscleGroup
                          : null;
                      final isSameMuscleGroup =
                          currentMuscleGroup == nextMuscleGroup;

                      return isSameMuscleGroup
                          ? Container(height: 1, color: const Color(0xFF3A3A3C))
                          : const SizedBox(height: 32);
                    },
                    itemBuilder: (context, index) {
                      final exercise = allExercises[index];
                      final showMuscleGroupBadge =
                          index == 0 ||
                          allExercises[index - 1].muscleGroup !=
                              exercise.muscleGroup;

                      final weekRir = calculateRIR(
                        displayPeriod,
                        trainingCycle.recoveryPeriod,
                      );

                      return _buildExerciseCard(
                        context,
                        exercise,
                        showMuscleGroupBadge: showMuscleGroupBadge,
                        targetRir: weekRir,
                      );
                    },
                  ),

            // Week selector overlay (shown on top when toggled)
            if (_showWeekSelector) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideWeekSelector,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ReadOnlyCalendarDropdown(
                  trainingCycle: trainingCycle,
                  selectedPeriod: displayPeriod,
                  selectedDay: displayDay,
                  allWorkouts: allWorkouts,
                  onDaySelected: _selectDay,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    dynamic exercise, {
    required bool showMuscleGroupBadge,
    int? targetRir,
  }) {
    final muscleGroup = exercise.muscleGroup as MuscleGroup;
    final equipmentType = exercise.equipmentType as EquipmentType?;

    return FutureBuilder<String?>(
      future: _findPinnedNoteForExercise(exercise),
      builder: (context, snapshot) {
        final pinnedNote = snapshot.data;

        return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipmentType?.displayName.toUpperCase() ??
                                'UNKNOWN',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Info button (read-only, still useful)
                    IconButton(
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8E8E93),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () =>
                          showExerciseInfoDialog(context, exercise as Exercise),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Column headers
                if (exercise.sets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            'WEIGHT',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'REPS',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'LOG',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sets list (read-only)
                ...List.generate(exercise.sets.length, (index) {
                  final set = exercise.sets[index] as ExerciseSet;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Set number indicator (instead of menu)
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Weight Display (read-only)
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor
                                  ?.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                set.weight != null
                                    ? formatWeightForDisplay(
                                        set.weight,
                                        ref.watch(useMetricProvider),
                                      )
                                    : '-',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: set.weight != null
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                          : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Reps Display (read-only)
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor
                                      ?.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    set.reps.isNotEmpty ? set.reps : '-',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: set.reps.isNotEmpty
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurface
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.4),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              // Badge for non-regular set types
                              if (_getSetTypeBadge(set.setType) != null)
                                Positioned(
                                  top: 2,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      _getSetTypeBadge(set.setType)!,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Log Status Display (read-only)
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: set.isLogged
                                  ? context.successColor.withValues(alpha: 0.2)
                                  : (set.isSkipped
                                        ? context.warningColor.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: set.isLogged
                                    ? context.successColor
                                    : (set.isSkipped
                                          ? context.warningColor
                                          : Theme.of(context).dividerColor
                                                .withValues(alpha: 0.3)),
                                width: set.isLogged || set.isSkipped ? 2 : 1,
                              ),
                            ),
                            child: set.isLogged
                                ? Icon(
                                    Icons.check,
                                    color: context.successColor,
                                    size: 20,
                                  )
                                : (set.isSkipped
                                      ? Icon(
                                          Icons.fast_forward,
                                          color: context.warningColor,
                                          size: 16,
                                        )
                                      : null),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Pinned note display (read-only, at bottom of card)
                // Shows pinned notes from any exercise with the same name
                if (pinnedNote != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pinnedNote,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Muscle group badge
        if (showMuscleGroupBadge)
          MuscleGroupBadge.compact(muscleGroup: muscleGroup),
      ],
        );
      },
    );
  }

  String? _getSetTypeBadge(SetType setType) {
    switch (setType) {
      case SetType.myorep:
        return 'MYO';
      case SetType.myorepMatch:
        return 'M-M';
      case SetType.maxReps:
        return 'MAX';
      case SetType.endWithPartials:
        return 'PAR';
      case SetType.dropSet:
        return 'DS';
      case SetType.regular:
        return null;
    }
  }
}

/// Read-only calendar dropdown for selecting week and day
class _ReadOnlyCalendarDropdown extends StatefulWidget {
  final TrainingCycle trainingCycle;
  final int selectedPeriod;
  final int selectedDay;
  final List<Workout> allWorkouts;
  final Function(int week, int day) onDaySelected;

  const _ReadOnlyCalendarDropdown({
    required this.trainingCycle,
    required this.selectedPeriod,
    required this.selectedDay,
    required this.allWorkouts,
    required this.onDaySelected,
  });

  @override
  State<_ReadOnlyCalendarDropdown> createState() =>
      _ReadOnlyCalendarDropdownState();
}

class _ReadOnlyCalendarDropdownState extends State<_ReadOnlyCalendarDropdown> {
  late int _selectedPeriod;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod;
    _selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = 60.0;
    final weekHeaderHeight = 60.0;
    final dayButtonHeight = 48.0;
    final dayMargin = 6.0;
    final bottomPadding = 12.0;

    final calculatedHeight =
        headerHeight +
        weekHeaderHeight +
        (widget.trainingCycle.daysPerPeriod * (dayButtonHeight + dayMargin)) +
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
          // Header (no +/- buttons for read-only view)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WEEKS (READ-ONLY)',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.successColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: context.successColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Week grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.trainingCycle.periodsTotal, (
                  weekIndex,
                ) {
                  final periodNumber = weekIndex + 1;
                  return Expanded(
                    child: _buildWeekColumn(
                      periodNumber,
                      widget.trainingCycle.recoveryPeriod == periodNumber,
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

  Widget _buildWeekColumn(int periodNumber, bool isDeload) {
    final defaultDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final weekDayNames = List.generate(widget.trainingCycle.daysPerPeriod, (
      index,
    ) {
      final dayNumber = index + 1;

      final weekDayWorkouts = widget.allWorkouts
          .where(
            (w) => w.dayNumber == dayNumber && w.periodNumber == periodNumber,
          )
          .toList();

      if (weekDayWorkouts.isNotEmpty) {
        final firstDayName = weekDayWorkouts.first.dayName;
        final allHaveSameName = weekDayWorkouts.every(
          (w) => w.dayName == firstDayName,
        );

        if (allHaveSameName &&
            firstDayName != null &&
            firstDayName.isNotEmpty) {
          return firstDayName.substring(0, 3).toUpperCase();
        }
      }

      if (widget.trainingCycle.startDate != null) {
        final startDayOfWeek = widget.trainingCycle.startDate!.weekday % 7;
        final daysElapsed =
            ((periodNumber - 1) * widget.trainingCycle.daysPerPeriod) +
            (dayNumber - 1);
        final actualDayOfWeek = (startDayOfWeek + daysElapsed) % 7;
        return defaultDayNames[actualDayOfWeek];
      }

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
                  isDeload ? 'DL' : '$periodNumber',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${calculateRIR(periodNumber, widget.trainingCycle.recoveryPeriod)} RIR',
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

          // Day buttons
          ...List.generate(weekDayNames.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final isSelected =
                periodNumber == _selectedPeriod && dayNumber == _selectedDay;

            // All days are completed in a completed trainingCycle
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

            Color backgroundColor;
            Color textColor;

            if (isCompleted) {
              backgroundColor = context.successColor;
              textColor = Colors.white;
            } else {
              backgroundColor = Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest;
              textColor = Theme.of(context).colorScheme.onSurface;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = periodNumber;
                  _selectedDay = dayNumber;
                });
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

}
