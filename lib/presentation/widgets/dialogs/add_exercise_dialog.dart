import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../core/constants/sports.dart';
import '../../../data/models/cardio_detail.dart';
import '../../../data/models/session.dart';
import '../../../data/models/workout.dart';
import '../../../data/services/cardio_session_library_service.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/cardio/cardio_template_picker.dart';
import '../../screens/workout/add_exercise_screen.dart';
import '../cardio/distance_input.dart';
import '../cardio/duration_input.dart';
import '../cardio/sport_chip.dart';

/// Shows a session-creation bottom sheet.
///
/// When [selectedSports] contains multiple sports, a sport picker row
/// appears at the top. Selecting Strength shows the muscle group list;
/// selecting a cardio sport shows an inline planning form with distance,
/// duration, and a "from template" option.
///
/// When [selectedSports] is null or contains only Strength, the sport
/// picker row is hidden and the dialog behaves exactly as before
/// (backward-compatible for edit_workout_screen and exercises_screen).
void showAddExerciseDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<Workout> workouts,
  required String trainingCycleId,
  required int periodNumber,
  required int dayNumber,
  String? dayName,
  List<Sport>? selectedSports,
}) {
  if (workouts.isEmpty && trainingCycleId.isEmpty) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _AddSessionSheet(
      workouts: workouts,
      trainingCycleId: trainingCycleId,
      periodNumber: periodNumber,
      dayNumber: dayNumber,
      dayName: dayName,
      selectedSports: selectedSports,
      ref: ref,
      parentContext: context,
    ),
  );
}

/// Convenience method that extracts workout info and calls
/// [showAddExerciseDialog].
void showAddExerciseDialogFromWorkouts({
  required BuildContext context,
  required WidgetRef ref,
  required List<Workout> workouts,
  List<Sport>? selectedSports,
}) {
  if (workouts.isEmpty) return;

  final firstWorkout = workouts.first;
  showAddExerciseDialog(
    context: context,
    ref: ref,
    workouts: workouts,
    trainingCycleId: firstWorkout.trainingCycleId,
    periodNumber: firstWorkout.periodNumber,
    dayNumber: firstWorkout.dayNumber,
    dayName: firstWorkout.dayName,
    selectedSports: selectedSports,
  );
}

// ---------------------------------------------------------------------------
// Private StatefulWidget for the bottom sheet body
// ---------------------------------------------------------------------------

class _AddSessionSheet extends StatefulWidget {
  final List<Workout> workouts;
  final String trainingCycleId;
  final int periodNumber;
  final int dayNumber;
  final String? dayName;
  final List<Sport>? selectedSports;
  final WidgetRef ref;
  final BuildContext parentContext;

  const _AddSessionSheet({
    required this.workouts,
    required this.trainingCycleId,
    required this.periodNumber,
    required this.dayNumber,
    this.dayName,
    this.selectedSports,
    required this.ref,
    required this.parentContext,
  });

  @override
  State<_AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<_AddSessionSheet> {
  late Sport _currentSport;

  /// Sports to display in the picker row (excluding Sport.other).
  late final List<Sport> _visibleSports;

  /// Whether to show the sport picker row.
  late final bool _showSportPicker;

  // ── Cardio form state ──
  double? _distanceMeters;
  int? _durationSeconds;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentSport = Sport.strength;

    _visibleSports = (widget.selectedSports ?? const []).where((s) => s != Sport.other).toList();

    // Show the picker only when there are multiple sports to choose from.
    _showSportPicker =
        _visibleSports.length > 1 || (_visibleSports.length == 1 && _visibleSports.first != Sport.strength);
  }

  UnitSystem _units() {
    return widget.ref.read(onboardingServiceProvider).unitsFor(_currentSport);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Pre-compute the muscle group → workout map once per build.
    final muscleGroupWorkouts = <MuscleGroup, Workout>{};
    for (final workout in widget.workouts) {
      if (workout.exercises.isNotEmpty) {
        final mg = workout.exercises.first.muscleGroup;
        muscleGroupWorkouts.putIfAbsent(mg, () => workout);
      }
    }

    final allMuscleGroups = MuscleGroup.values.toList()..sort((a, b) => a.displayName.compareTo(b.displayName));

    final isCardio = _currentSport != Sport.strength;

    // Dynamic title based on mode.
    final title = _showSportPicker
        ? (isCardio ? l10n.addSessionPlanSport(_currentSport.displayName) : l10n.addSessionTitle)
        : l10n.selectMuscleGroupTitle;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── Title ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: theme.textTheme.titleLarge),
            ),

            // ── Sport picker row ──
            if (_showSportPicker) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _visibleSports.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SportChip(
                        sport: _visibleSports[i],
                        selected: _visibleSports[i] == _currentSport,
                        onTap: () => _onSportTapped(_visibleSports[i]),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
            ],

            // ── Body: muscle group list OR cardio form ──
            Expanded(
              child: isCardio
                  ? _buildCardioForm(theme)
                  : ListView.builder(
                      itemCount: allMuscleGroups.length,
                      itemBuilder: (listContext, index) {
                        final muscleGroup = allMuscleGroups[index];
                        final existingWorkout = muscleGroupWorkouts[muscleGroup];

                        return ListTile(
                          title: Text(muscleGroup.displayName),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _onMuscleGroupTapped(
                            muscleGroup,
                            existingWorkout,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cardio form ──

  Widget _buildCardioForm(ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickTemplate,
          icon: const Icon(Icons.auto_awesome),
          label: Text(l10n.startFromTemplate),
        ),
        const SizedBox(height: 24),
        DistanceInput(
          initialMeters: _distanceMeters,
          units: _units(),
          sport: _currentSport,
          onChanged: (v) => setState(() => _distanceMeters = v),
        ),
        const SizedBox(height: 12),
        DurationInput(
          initialSeconds: _durationSeconds,
          onChanged: (v) => setState(() => _durationSeconds = v),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : _saveCardioSession,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.planSportButton(_currentSport.displayName)),
        ),
      ],
    );
  }

  // ── Handlers ──

  void _onSportTapped(Sport sport) {
    setState(() {
      _currentSport = sport;
      // Reset cardio form when switching between cardio sports
      // (different units / display).
      if (sport != Sport.strength) {
        _distanceMeters = null;
        _durationSeconds = null;
      }
    });
  }

  Future<void> _pickTemplate() async {
    // Dismiss the Add Session sheet first, then open the template
    // picker on the parent context.
    Navigator.pop(context);

    final parentCtx = widget.parentContext;
    if (!parentCtx.mounted) return;

    final template = await CardioTemplatePicker.show(
      parentCtx,
      sport: _currentSport,
    );
    if (template == null || !parentCtx.mounted) return;

    final session = CardioSessionLibraryService.instance.instantiate(
      template,
      sessionId: const Uuid().v4(),
      newIntervalId: () => const Uuid().v4(),
      trainingCycleId: widget.trainingCycleId.isEmpty ? null : widget.trainingCycleId,
      periodNumber: widget.periodNumber,
      dayNumber: widget.dayNumber,
    );

    await widget.ref.read(sessionRepositoryProvider).createCardio(session);
    widget.ref.invalidate(sessionsProvider);
    if (widget.trainingCycleId.isNotEmpty) {
      widget.ref.invalidate(
        sessionsByTrainingCycleProvider(widget.trainingCycleId),
      );
    }

    if (!parentCtx.mounted) return;
    GoRouter.of(parentCtx).push('/cardio-session/${session.id}/intervals');
  }

  Future<void> _saveCardioSession() async {
    setState(() => _saving = true);
    try {
      final detail = CardioDetail(
        plannedDistanceM: _distanceMeters,
        plannedDurationSec: _durationSeconds,
      );

      final session = CardioSession(
        id: const Uuid().v4(),
        trainingCycleId: widget.trainingCycleId.isEmpty ? null : widget.trainingCycleId,
        sport: _currentSport,
        source: SessionSource.userPlanned,
        status: WorkoutStatus.incomplete,
        periodNumber: widget.periodNumber,
        dayNumber: widget.dayNumber,
        dayName: widget.dayName,
        detail: detail,
      );

      await widget.ref.read(sessionRepositoryProvider).createCardio(session);
      widget.ref.invalidate(sessionsProvider);
      if (widget.trainingCycleId.isNotEmpty) {
        widget.ref.invalidate(
          sessionsByTrainingCycleProvider(widget.trainingCycleId),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);

      final parentCtx = widget.parentContext;
      if (!parentCtx.mounted) return;
      final l10n = AppLocalizations.of(parentCtx)!;
      ScaffoldMessenger.of(parentCtx).showSnackBar(
        SnackBar(
          content: Text(
            l10n.sessionPlannedSnackbar(_currentSport.displayName),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSave(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onMuscleGroupTapped(
    MuscleGroup muscleGroup,
    Workout? existingWorkout,
  ) async {
    Navigator.pop(context);

    final parentCtx = widget.parentContext;

    if (existingWorkout != null) {
      if (!parentCtx.mounted) return;
      Navigator.of(parentCtx).push(
        MaterialPageRoute(
          builder: (_) => AddExerciseScreen(
            trainingCycleId: existingWorkout.trainingCycleId,
            workoutId: existingWorkout.id,
            initialMuscleGroup: muscleGroup,
          ),
        ),
      );
    } else {
      final newWorkout = Workout(
        id: const Uuid().v4(),
        trainingCycleId: widget.trainingCycleId,
        periodNumber: widget.periodNumber,
        dayNumber: widget.dayNumber,
        dayName: widget.dayName,
        label: muscleGroup.displayName,
        exercises: [],
      );

      await widget.ref.read(workoutRepositoryProvider).create(newWorkout);

      if (!parentCtx.mounted) return;
      Navigator.of(parentCtx).push(
        MaterialPageRoute(
          builder: (_) => AddExerciseScreen(
            trainingCycleId: newWorkout.trainingCycleId,
            workoutId: newWorkout.id,
            initialMuscleGroup: muscleGroup,
          ),
        ),
      );
    }
  }
}
