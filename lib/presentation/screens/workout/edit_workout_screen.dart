import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/sports.dart';
import '../../../core/theme/skins/skins.dart';
import '../../../core/utils/template_exporter.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/exercise_set.dart';
import '../../../data/models/session.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../../domain/providers/training_cycle_providers.dart';
import '../../../domain/providers/workout_providers.dart';
import '../../widgets/cardio/sport_badge.dart';
import '../../widgets/dialogs/add_exercise_dialog.dart';
import '../../widgets/dialogs/exercise_info_dialog.dart';
import '../../widgets/dialogs/workout_dialogs.dart';
import '../../widgets/muscle_group_badge.dart';
import '../../widgets/skeleton_loader.dart';
import '../cardio/sport_picker_sheet.dart';
import 'add_exercise_screen.dart';
import '../../../l10n/app_localizations.dart';
import 'edit_workout_controller.dart';

/// Edit workout screen - Edit draft trainingCycle design
class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String trainingCycleId;

  const EditWorkoutScreen({super.key, required this.trainingCycleId});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  int _selectedDayIndex = 0;
  int _selectedPeriod = 1;

  @override
  Widget build(BuildContext context) {
    final trainingCyclesAsync = ref.watch(trainingCyclesProvider);
    final controller = ref.watch(
      editWorkoutControllerProvider(widget.trainingCycleId),
    );

    final l10n = AppLocalizations.of(context)!;

    return trainingCyclesAsync.when(
      data: (trainingCycles) {
        final trainingCycle = trainingCycles.firstWhere(
          (m) => m.id == widget.trainingCycleId,
          orElse: () => trainingCycles.first,
        );

        final workouts = ref.watch(
          workoutsByTrainingCycleListProvider(widget.trainingCycleId),
        );

        // Get workouts for the selected period and day
        final dayWorkouts = workouts
            .where(
              (w) => w.periodNumber == _selectedPeriod && w.dayNumber == _selectedDayIndex + 1,
            )
            .toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
              title: Text(trainingCycle.name),
              actions: [
                // Export template button (Debug only)
                if (kDebugMode)
                  IconButton(
                    icon: const Icon(Icons.save_alt),
                    onPressed: () => _exportTemplate(context, trainingCycle, workouts),
                    tooltip: l10n.editWorkoutExportTemplateTooltip,
                  ),
                // Start trainingCycle button (if draft)
                if (trainingCycle.status == TrainingCycleStatus.draft)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _startTrainingCycle(
                        context,
                        controller,
                        trainingCycle,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: context.successColor,
                              size: 24,
                            ),
                            Text(
                              l10n.editWorkoutStartButton,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Period selector
                _buildPeriodSelector(trainingCycle, controller),

                // Day selector
                _buildDaySelector(trainingCycle, workouts, controller),

                // v5 — Cardio banner (collapses if no cardio for this day).
                _buildCardioBanner(trainingCycle),

                // Exercise list
                Expanded(
                  child: dayWorkouts.isEmpty
                      ? _buildEmptyState(context, trainingCycle, controller)
                      : _buildExerciseList(context, dayWorkouts, controller),
                ),
              ],
            ),
            floatingActionButton: dayWorkouts.isEmpty
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _showMuscleGroupSelector(
                      context,
                      trainingCycle,
                      controller,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    label: Text(l10n.editWorkoutAddExerciseButton),
                    icon: const Icon(Icons.add),
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        );
      },
      loading: () => const Scaffold(body: SkeletonCardList()),
      error: (error, stack) {
        Sentry.captureException(error, stackTrace: stack);
        return Scaffold(body: Center(child: Text(l10n.errorGeneric(error))));
      },
    );
  }

  /// v5 — Cardio banner shown below the day selector.
  ///
  /// Always present: renders as a compact single-row "Add cardio session"
  /// hint when there are none for this period/day, or expands into a
  /// scrollable row of cardio tiles otherwise. Tapping a tile opens the
  /// cardio session editor; the "+" chip opens the sport picker and then
  /// creates a new session tied to this cycle.
  Widget _buildCardioBanner(TrainingCycle trainingCycle) {
    return Consumer(
      builder: (context, ref, _) {
        final async = ref.watch(
          sessionsByTrainingCycleProvider(widget.trainingCycleId),
        );
        final cardioForDay = async.when(
          data: (sessions) => sessions
              .whereType<CardioSession>()
              .where(
                (s) => s.periodNumber == _selectedPeriod && s.dayNumber == _selectedDayIndex + 1,
              )
              .toList(),
          loading: () => const <CardioSession>[],
          error: (_, _) => const <CardioSession>[],
        );

        if (cardioForDay.isEmpty) {
          return _buildCardioAddHint(trainingCycle);
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cardioForDay.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                if (i == cardioForDay.length) {
                  return _AddCardioChip(
                    onTap: () => _pickAndCreateCardio(trainingCycle),
                  );
                }
                final session = cardioForDay[i];
                return _CardioPill(
                  session: session,
                  onTap: () {
                    context.push('/cardio-session/${session.id}');
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardioAddHint(TrainingCycle trainingCycle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _AddCardioChip(
          onTap: () => _pickAndCreateCardio(trainingCycle),
        ),
      ),
    );
  }

  Future<void> _pickAndCreateCardio(TrainingCycle trainingCycle) async {
    final l10n = AppLocalizations.of(context)!;
    final sport = await SportPickerSheet.show(
      context,
      title: l10n.editWorkoutAddCardioSessionTitle,
      choices: const [Sport.run, Sport.bike, Sport.swim],
    );
    if (sport == null || !mounted) return;
    // Pass the selected period + day as query params so the cardio screen
    // attaches the new session to the same slot in the cycle. That's what
    // makes it appear in this banner.
    context.push(
      '/cardio-session/new'
      '?sport=${sport.name}'
      '&trainingCycleId=${trainingCycle.id}'
      '&period=$_selectedPeriod'
      '&day=${_selectedDayIndex + 1}'
      '&planned=true',
    );
  }

  Widget _buildPeriodSelector(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) {
    final allWorkouts = ref.watch(
      workoutsByTrainingCycleListProvider(widget.trainingCycleId),
    );
    final period1HasWorkouts = allWorkouts.any((w) => w.periodNumber == 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.editWorkoutPeriodLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          // Remove period button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: trainingCycle.periodsTotal > 2 ? () => _showRemovePeriodDialog(trainingCycle, controller) : null,
            tooltip: AppLocalizations.of(context)!.editWorkoutRemovePeriodTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add period button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => _addPeriod(trainingCycle, controller),
            tooltip: AppLocalizations.of(context)!.editWorkoutAddPeriodTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(trainingCycle.periodsTotal, (index) {
                  final periodNumber = index + 1;
                  final isSelected = periodNumber == _selectedPeriod;
                  final isRecoveryPeriod = periodNumber == trainingCycle.recoveryPeriod;

                  final chip = ChoiceChip(
                    label: Text(
                      isRecoveryPeriod ? trainingCycle.recoveryPeriodType.abbreviation : '$periodNumber',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPeriod = periodNumber);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: isRecoveryPeriod
                        ? GestureDetector(
                            onLongPress: () => _showRecoveryTypeSelector(
                              trainingCycle,
                              controller,
                            ),
                            child: chip,
                          )
                        : chip,
                  );
                }),
              ),
            ),
          ),
          // Mirror period 1 button (only show when not on period 1 and period 1 has workouts)
          if (_selectedPeriod > 1 && period1HasWorkouts)
            IconButton(
              icon: const Icon(Icons.content_copy, size: 20),
              onPressed: () => _mirrorPeriod1ToSelectedPeriod(trainingCycle, controller),
              tooltip: AppLocalizations.of(context)!.editWorkoutMirrorPeriod1Tooltip,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addPeriod(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.addPeriod(trainingCycle);
      if (mounted) {
        context.showSuccessSnackBar(l10n.editWorkoutPeriodAdded(trainingCycle.periodsTotal));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(l10n.editWorkoutPeriodAddError(e));
      }
    }
  }

  Future<void> _showRemovePeriodDialog(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final lastNonRecoveryPeriod = trainingCycle.periodsTotal - 1;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editWorkoutRemovePeriodTitle),
        content: Text(
          l10n.editWorkoutRemovePeriodContent(lastNonRecoveryPeriod),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'deload'),
            child: Text(l10n.editWorkoutRemoveDeload),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'training'),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(l10n.editWorkoutRemovePeriodAction(lastNonRecoveryPeriod)),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        final removeRecovery = result == 'deload';
        await controller.removePeriod(
          trainingCycle,
          removeRecovery: removeRecovery,
        );

        // Adjust selected period if it no longer exists
        if (_selectedPeriod > trainingCycle.periodsTotal - 1) {
          setState(() => _selectedPeriod = trainingCycle.periodsTotal - 1);
        }

        if (mounted) {
          context.showSuccessSnackBar(
            removeRecovery
                ? l10n.editWorkoutRecoveryPeriodRemoved
                : l10n.editWorkoutPeriodRemoved(lastNonRecoveryPeriod),
          );
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.editWorkoutPeriodRemoveError(e));
        }
      }
    }
  }

  Future<void> _showRecoveryTypeSelector(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<RecoveryPeriodType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editWorkoutRecoveryTypeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RecoveryPeriodType.values.map((type) {
            final isSelected = type == trainingCycle.recoveryPeriodType;
            return ListTile(
              title: Text(type.displayName),
              subtitle: Text(type.description),
              leading: Radio<RecoveryPeriodType>(
                value: type,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (type == trainingCycle.recoveryPeriodType) {
                    return Theme.of(context).colorScheme.primary;
                  }
                  return null;
                }),
              ),
              trailing: Text(
                type.abbreviation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
              onTap: () => Navigator.pop(context, type),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (result != null && result != trainingCycle.recoveryPeriodType && mounted) {
      try {
        await controller.updateRecoveryPeriodType(trainingCycle, result);
        if (mounted) {
          context.showSuccessSnackBar(l10n.editWorkoutRecoveryTypeChanged(result.displayName));
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.editWorkoutRecoveryTypeError(e));
        }
      }
    }
  }

  Widget _buildDaySelector(
    TrainingCycle trainingCycle,
    List<Workout> workouts,
    EditWorkoutController controller,
  ) {
    // Build day labels as D1, D2, D3, etc.
    final dayLabels = <String>[];
    for (int dayNum = 1; dayNum <= trainingCycle.daysPerPeriod; dayNum++) {
      dayLabels.add('D$dayNum');
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Text(
            AppLocalizations.of(context)!.editWorkoutDayLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          // Remove day button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: trainingCycle.daysPerPeriod > 1 ? () => _removeDay(trainingCycle, controller) : null,
            tooltip: AppLocalizations.of(context)!.editWorkoutRemoveDayTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          // Add day button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: trainingCycle.daysPerPeriod < AppConstants.maxDaysPerPeriod
                ? () => _addDay(trainingCycle, controller)
                : null,
            tooltip: AppLocalizations.of(context)!.editWorkoutAddDayTooltip,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dayLabels.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      dayLabels[index],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDayIndex = index);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDay(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await controller.addDay(trainingCycle);
      if (mounted) {
        context.showSuccessSnackBar(l10n.editWorkoutDayAdded(trainingCycle.daysPerPeriod + 1));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(l10n.editWorkoutDayAddError(e));
      }
    }
  }

  Future<void> _removeDay(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final dayToRemove = trainingCycle.daysPerPeriod;

    // Check if there are any workouts on this day
    final allWorkouts = ref.read(
      workoutsByTrainingCycleListProvider(trainingCycle.id),
    );
    final hasWorkoutsOnDay = allWorkouts.any((w) => w.dayNumber == dayToRemove);

    final l10n = AppLocalizations.of(context)!;

    if (hasWorkoutsOnDay) {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.editWorkoutRemoveDayTitle),
          content: Text(
            l10n.editWorkoutRemoveDayContent(dayToRemove),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: context.errorColor,
              ),
              child: Text(l10n.editWorkoutRemoveDayAction),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await controller.removeDay(trainingCycle);

      // Adjust selected day if it no longer exists
      if (_selectedDayIndex >= trainingCycle.daysPerPeriod - 1) {
        setState(() => _selectedDayIndex = trainingCycle.daysPerPeriod - 2);
      }

      if (mounted) {
        context.showSuccessSnackBar(l10n.editWorkoutDayRemoved(dayToRemove));
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(l10n.editWorkoutDayRemoveError(e));
      }
    }
  }

  Widget _buildExerciseList(
    BuildContext context,
    List<Workout> dayWorkouts,
    EditWorkoutController controller,
  ) {
    if (dayWorkouts.isEmpty) {
      return _buildEmptyState(context, null, controller);
    }

    // Collect all exercises from all workouts for this day
    final allExercises = <Exercise>[];
    for (var workout in dayWorkouts) {
      allExercises.addAll(workout.exercises);
    }

    if (allExercises.isEmpty) {
      return _buildEmptyState(context, null, controller);
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 24),
      itemCount: allExercises.length,
      separatorBuilder: (context, index) {
        // Check if next exercise is same muscle group
        final currentMuscleGroup = allExercises[index].muscleGroup;
        final nextMuscleGroup = index + 1 < allExercises.length ? allExercises[index + 1].muscleGroup : null;
        final isSameMuscleGroup = currentMuscleGroup == nextMuscleGroup;

        // Thin grey divider for same muscle group, black spacer for different
        return isSameMuscleGroup ? Container(height: 1, color: const Color(0xFF3A3A3C)) : const SizedBox(height: 32);
      },
      itemBuilder: (context, index) {
        final exercise = allExercises[index];
        final showMuscleGroupBadge = index == 0 || allExercises[index - 1].muscleGroup != exercise.muscleGroup;

        return _buildExerciseCard(
          context,
          exercise,
          controller,
          showMuscleGroupBadge: showMuscleGroupBadge,
          index: index,
          totalExercises: allExercises.length,
        );
      },
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
    EditWorkoutController controller, {
    required bool showMuscleGroupBadge,
    required int index,
    required int totalExercises,
  }) {
    final muscleGroup = exercise.muscleGroup;
    final equipmentType = exercise.equipmentType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Exercise card
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipmentType.displayName.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Info button
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
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () => showExerciseInfoDialog(context, exercise),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 0),
                    // Overflow menu button
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        size: 24,
                      ),
                      offset: const Offset(-180, 40),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 250),
                      color: Theme.of(context).cardTheme.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'note':
                            _newExerciseNote(exercise);
                            break;
                          case 'move_up':
                            controller.moveExerciseUp(
                              exercise.workoutId,
                              exercise.id,
                            );
                            break;
                          case 'move_down':
                            controller.moveExerciseDown(
                              exercise.workoutId,
                              exercise.id,
                            );
                            break;
                          case 'replace':
                            _replaceExercise(exercise);
                            break;
                          case 'add_set':
                            _addSetToExercise(exercise, controller);
                            break;
                          case 'delete':
                            _deleteExercise(exercise, controller);
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return [
                          // Header
                          PopupMenuItem<String>(
                            enabled: false,
                            height: 32,
                            child: Text(
                              l10n.editWorkoutExerciseMenuHeader,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          // New note
                          PopupMenuItem<String>(
                            value: 'note',
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutNewNote,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                          // Move up (disabled if first exercise)
                          PopupMenuItem<String>(
                            value: 'move_up',
                            enabled: index > 0,
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: index > 0
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).disabledColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutMoveUp,
                                  style: TextStyle(
                                    color: index > 0
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Move down (disabled if last exercise)
                          PopupMenuItem<String>(
                            value: 'move_down',
                            enabled: index < totalExercises - 1,
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: index < totalExercises - 1
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).disabledColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutMoveDown,
                                  style: TextStyle(
                                    color: index < totalExercises - 1
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Replace
                          PopupMenuItem<String>(
                            value: 'replace',
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutReplace,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                          // Add set
                          PopupMenuItem<String>(
                            value: 'add_set',
                            height: 48,
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutAddSet,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                          // Delete exercise
                          PopupMenuItem<String>(
                            value: 'delete',
                            height: 48,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: context.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.editWorkoutDeleteExercise,
                                  style: TextStyle(color: context.errorColor),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
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
                        const SizedBox(width: 24), // Spacer for set menu
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.editWorkoutSetHeader,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.editWorkoutRepsHeader,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const SizedBox(width: 40), // Spacer for actions
                      ],
                    ),
                  ),

                // Sets list
                ...List.generate(exercise.sets.length, (index) {
                  final set = exercise.sets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Set menu (3 dots)
                        SizedBox(
                          width: 24,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Theme.of(
                                context,
                              ).iconTheme.color?.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            offset: const Offset(0, 40),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 250),
                            color: Theme.of(context).cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'add_below':
                                  _addSetBelow(exercise, index, controller);
                                  break;
                                case 'delete':
                                  _deleteSet(exercise, index, controller);
                                  break;
                                case 'regular':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.regular,
                                    controller,
                                  );
                                  break;
                                case 'myorep':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.myorep,
                                    controller,
                                  );
                                  break;
                                case 'myorep_match':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.myorepMatch,
                                    controller,
                                  );
                                  break;
                                case 'max_reps':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.maxReps,
                                    controller,
                                  );
                                  break;
                                case 'end_with_partials':
                                  _updateSetType(
                                    exercise,
                                    index,
                                    SetType.endWithPartials,
                                    controller,
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return [
                                // SET Header
                                PopupMenuItem<String>(
                                  enabled: false,
                                  height: 32,
                                  child: Text(
                                    l10n.editWorkoutSetMenuHeader,
                                    style: context.textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                // Add set below
                                PopupMenuItem<String>(
                                  value: 'add_below',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.subdirectory_arrow_right,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.editWorkoutAddSetBelow,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete set
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: context.errorColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.editWorkoutDeleteSet,
                                        style: TextStyle(
                                          color: context.errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                // SET TYPE Header
                                PopupMenuItem<String>(
                                  enabled: false,
                                  height: 32,
                                  child: Text(
                                    l10n.editWorkoutSetTypeHeader,
                                    style: context.textTheme.labelMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                // Regular
                                PopupMenuItem<String>(
                                  value: 'regular',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        set.setType == SetType.regular
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: set.setType == SetType.regular
                                            ? context.selectedIndicatorColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.setTypeRegular,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Myorep
                                PopupMenuItem<String>(
                                  value: 'myorep',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        set.setType == SetType.myorep
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: set.setType == SetType.myorep
                                            ? context.selectedIndicatorColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.setTypeMyorep,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Myorep match
                                PopupMenuItem<String>(
                                  value: 'myorep_match',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        set.setType == SetType.myorepMatch
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: set.setType == SetType.myorepMatch
                                            ? context.selectedIndicatorColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.setTypeMyorepMatch,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Max reps
                                PopupMenuItem<String>(
                                  value: 'max_reps',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        set.setType == SetType.maxReps
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: set.setType == SetType.maxReps
                                            ? context.selectedIndicatorColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.setTypeMaxReps,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // End with partials
                                PopupMenuItem<String>(
                                  value: 'end_with_partials',
                                  height: 40,
                                  child: Row(
                                    children: [
                                      Icon(
                                        set.setType == SetType.endWithPartials
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: set.setType == SetType.endWithPartials
                                            ? context.selectedIndicatorColor
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.setTypeEndWithPartials,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ),

                        // Set number display
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${set.setNumber}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Reps Input
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).inputDecorationTheme.fillColor,
                                  borderRadius: BorderRadius.circular(
                                    context.inputBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Center(
                                  child: TextFormField(
                                    key: ValueKey('reps_${set.id}'),
                                    initialValue: set.reps,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    keyboardAppearance: Brightness.light,
                                    decoration: InputDecoration(
                                      filled: false,
                                      hintText: AppLocalizations.of(context)!.editWorkoutRepsHint,
                                      hintStyle: Theme.of(
                                        context,
                                      ).inputDecorationTheme.hintStyle,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          context.inputBorderRadius,
                                        ),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _updateSetReps(
                                        exercise,
                                        index,
                                        value,
                                        controller,
                                      );
                                    },
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
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).brightness == Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Placeholder for alignment (no LOG checkbox in edit mode)
                        const SizedBox(width: 40),
                      ],
                    ),
                  );
                }),

                // Note display (if exercise has a note)
                if (exercise.notes != null && exercise.notes!.isNotEmpty) _buildNoteDisplay(context, exercise),
              ],
            ),
          ),
        ),

        // Muscle group badge - overlays the card
        if (showMuscleGroupBadge) MuscleGroupBadge.compact(muscleGroup: muscleGroup),
      ],
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
        return 'EWP';
      default:
        return null;
    }
  }

  Widget _buildNoteDisplay(BuildContext context, Exercise exercise) {
    return InkWell(
      onTap: () => _newExerciseNote(exercise),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              exercise.isNotePinned ? Icons.push_pin : Icons.note_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                exercise.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit,
              size: 14,
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
            ),
          ],
        ),
      ),
    );
  }

  // Exercise action methods
  void _replaceExercise(Exercise exercise) {
    // Navigate to add exercise screen with replace mode
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          trainingCycleId: widget.trainingCycleId,
          workoutId: exercise.workoutId,
          initialMuscleGroup: exercise.muscleGroup,
          replaceExerciseId: exercise.id,
        ),
      ),
    );
  }

  Future<void> _addSetToExercise(
    Exercise exercise,
    EditWorkoutController controller,
  ) async {
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    await controller.addSetToExercise(exercise.workoutId, exercise.id, newSet);
  }

  Future<void> _deleteExercise(
    Exercise exercise,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editWorkoutDeleteExerciseTitle),
        content: Text(l10n.editWorkoutDeleteExerciseContent(exercise.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteExercise(exercise.workoutId, exercise.id);
    }
  }

  // Set action methods
  Future<void> _addSetBelow(
    Exercise exercise,
    int currentSetIndex,
    EditWorkoutController controller,
  ) async {
    final newSet = ExerciseSet(
      id: const Uuid().v4(),
      setNumber: exercise.sets.length + 1,
      reps: '',
      setType: SetType.regular,
    );

    await controller.insertSetAtIndex(
      exercise.workoutId,
      exercise.id,
      currentSetIndex + 1,
      newSet,
    );
  }

  Future<void> _deleteSet(
    Exercise exercise,
    int setIndex,
    EditWorkoutController controller,
  ) async {
    await controller.removeSetFromExercise(
      exercise.workoutId,
      exercise.id,
      setIndex,
    );
  }

  Future<void> _updateSetType(
    Exercise exercise,
    int setIndex,
    SetType type,
    EditWorkoutController controller,
  ) async {
    await controller.updateSetType(
      exercise.workoutId,
      exercise.id,
      setIndex,
      type,
    );
  }

  Future<void> _updateSetReps(
    Exercise exercise,
    int setIndex,
    String value,
    EditWorkoutController controller,
  ) async {
    await controller.updateSetReps(
      exercise.workoutId,
      exercise.id,
      setIndex,
      value,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    TrainingCycle? trainingCycle,
    EditWorkoutController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.editWorkoutNoExercisesTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.editWorkoutNoExercisesSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (trainingCycle != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showMuscleGroupSelector(context, trainingCycle, controller),
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.editWorkoutAddExerciseButton),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _mirrorPeriod1ToSelectedPeriod(
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editWorkoutMirrorTitle),
        content: Text(
          l10n.editWorkoutMirrorContent(_selectedPeriod),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.editWorkoutMirrorAction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await controller.mirrorPeriod1ToSelectedPeriod(
          trainingCycle,
          _selectedPeriod,
        );

        if (mounted) {
          context.showSuccessSnackBar(l10n.editWorkoutPeriod1Mirrored(_selectedPeriod));
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.editWorkoutMirrorError(e));
        }
      }
    }
  }

  Future<void> _startTrainingCycle(
    BuildContext context,
    EditWorkoutController controller,
    TrainingCycle trainingCycle,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final cycleTerm = ref.read(trainingCycleTermProvider);
    final currentCycles = ref.read(currentTrainingCyclesProvider);

    bool stack = false;

    if (currentCycles.isEmpty) {
      // No existing current cycle — simple confirmation.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.editWorkoutStartCycleTitle(cycleTerm)),
          content: Text(
            l10n.editWorkoutStartCycleContent(trainingCycle.name, cycleTerm),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.editWorkoutStartButton),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    } else {
      // Existing current cycle(s) — offer replace vs stack.
      final activeNames = currentCycles.map((c) => c.name).join(', ');
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.editWorkoutStartCycleTitle(cycleTerm)),
          content: Text(
            l10n.editWorkoutStartCycleActiveContent(cycleTerm, activeNames, trainingCycle.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: Text(l10n.cancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context, 'replace'),
              child: Text(l10n.editWorkoutStartCycleReplace),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'stack'),
              child: Text(l10n.editWorkoutStartCycleStack),
            ),
          ],
        ),
      );
      if (result == null || result == 'cancel' || !context.mounted) return;
      stack = result == 'stack';
    }

    try {
      await controller.startTrainingCycle(trainingCycle, stack: stack);

      if (context.mounted) {
        // Navigate to workout tab on home screen
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(l10n.editWorkoutPeriodAddError(e));
      }
    }
  }

  void _showMuscleGroupSelector(
    BuildContext context,
    TrainingCycle trainingCycle,
    EditWorkoutController controller,
  ) {
    // Get workouts for the current day
    final workouts = ref.read(
      workoutsByTrainingCycleListProvider(widget.trainingCycleId),
    );
    final dayWorkouts = workouts
        .where(
          (w) => w.periodNumber == _selectedPeriod && w.dayNumber == _selectedDayIndex + 1,
        )
        .toList();

    showAddExerciseDialog(
      context: context,
      ref: ref,
      workouts: dayWorkouts,
      trainingCycleId: trainingCycle.id,
      periodNumber: _selectedPeriod,
      dayNumber: _selectedDayIndex + 1,
    );
  }

  Future<void> _newExerciseNote(Exercise exercise) async {
    // Get the workout containing this exercise from the repository
    final repository = ref.read(workoutRepositoryProvider);
    final workout = await repository.getById(exercise.workoutId);
    if (workout == null || !mounted) return;

    final currentNote = exercise.notes;

    final result = await showDialog<ExerciseNoteResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoteDialog(
        initialNote: currentNote,
        noteType: NoteType.exercise,
        initialPinned: exercise.isNotePinned,
      ),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      try {
        final repository = ref.read(workoutRepositoryProvider);
        final updatedExercise = exercise.copyWith(
          notes: result.note.isEmpty ? null : result.note,
          isNotePinned: result.isPinned,
        );
        final updatedExercises = workout.exercises.map((e) => e.id == exercise.id ? updatedExercise : e).toList();
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);
        await repository.update(updatedWorkout);

        // Invalidate providers to refresh UI
        ref.invalidate(workoutsProvider);
        ref.invalidate(workoutsByTrainingCycleProvider(widget.trainingCycleId));

        if (mounted) {
          context.showSuccessSnackBar(l10n.noteSaved);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(l10n.noteSaveError(e));
        }
      }
    }
  }

  Future<void> _exportTemplate(
    BuildContext context,
    TrainingCycle trainingCycle,
    List<Workout> workouts,
  ) async {
    try {
      // Create a copy of the trainingCycle with the latest workouts
      final trainingCycleToExport = trainingCycle.copyWith(workouts: workouts);
      await TemplateExporter.exportToClipboard(trainingCycleToExport);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showSuccessSnackBar(l10n.editWorkoutTemplateExported);
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showErrorSnackBar(l10n.editWorkoutTemplateExportError(e));
      }
    }
  }
}

/// Pill displayed in the cardio banner for an existing [CardioSession].
class _CardioPill extends StatelessWidget {
  const _CardioPill({required this.session, required this.onTap});

  final CardioSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = session.sport.color;
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SportBadge(sport: session.sport, compact: true),
              const SizedBox(width: 8),
              Text(
                session.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (session.isCompleted) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, size: 14, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed-outline "+ Add cardio" chip at the end of the banner row
/// (or shown alone when no cardio exists for the day).
class _AddCardioChip extends StatelessWidget {
  const _AddCardioChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_run, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.editWorkoutAddCardio,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
