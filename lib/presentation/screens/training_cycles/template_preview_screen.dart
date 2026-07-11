import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/training_cycle_template.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/template_providers.dart';
import '../../../l10n/app_localizations.dart';

class TemplatePreviewScreen extends ConsumerStatefulWidget {
  final TrainingCycleTemplate template;

  const TemplatePreviewScreen({super.key, required this.template});

  @override
  ConsumerState<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends ConsumerState<TemplatePreviewScreen> {
  bool _isLoading = false;

  Future<void> _createProgram() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(templateRepositoryProvider);
      final result = await repository.createTrainingCycleFromTemplate(
        widget.template,
      );

      // Save the strength cycle (existing flow).
      final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
      await trainingCycleRepository.create(result.trainingCycle);

      // Save workouts (which includes exercises and sets)
      final workoutRepository = ref.read(workoutRepositoryProvider);
      for (final workout in result.trainingCycle.workouts) {
        await workoutRepository.create(workout);
      }

      // v6 — write any cardio sessions the template resolved.
      final sessionRepository = ref.read(sessionRepositoryProvider);
      for (final cardio in result.cardioSessions) {
        await sessionRepository.createCardio(cardio);
      }

      if (mounted) {
        // Land on the Cycles tab to show the newly created draft.
        // The Cycles tab is a shell branch now, so go() both dismisses
        // this preview (and the picker below it) and selects the tab.
        context.go('/cycles');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(AppLocalizations.of(context)!.templatePreviewErrorCreating(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.template.name), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description
                Text(
                  widget.template.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Program Details
                _buildInfoSection(),
                const SizedBox(height: 24),

                // Sessions grouped by period
                ..._buildPeriodSections(colorScheme),
              ],
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.templatePreviewLoadProgram,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build workout cards grouped by period number.
  List<Widget> _buildPeriodSections(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    // Group workouts by period
    final byPeriod = <int, List<WorkoutTemplate>>{};
    for (final w in widget.template.workouts) {
      byPeriod.putIfAbsent(w.periodNumber, () => []).add(w);
    }

    final sortedPeriods = byPeriod.keys.toList()..sort();
    final widgets = <Widget>[];

    for (final period in sortedPeriods) {
      final isRecovery = widget.template.recoveryPeriod == period;
      final periodLabel = isRecovery
          ? l10n.templatePreviewPeriodRecoveryHeader(period)
          : l10n.templatePreviewPeriodHeader(period);

      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 16, bottom: 8),
          child: Text(
            periodLabel,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      for (final workout in byPeriod[period]!) {
        widgets.add(_buildWorkoutCard(workout));
      }
    }

    return widgets;
  }

  Widget _buildInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.calendar_today,
            l10n.templateSelectionPeriodsCount(widget.template.periodsTotal),
            l10n.templatePreviewDuration,
          ),
          _buildInfoItem(
            Icons.fitness_center,
            l10n.templatePreviewDaysCount(widget.template.daysPerPeriod),
            l10n.templatePreviewPerPeriod,
          ),
          if (widget.template.recoveryPeriod != null)
            _buildInfoItem(
              Icons.refresh,
              l10n.templatePreviewPeriodHeader(widget.template.recoveryPeriod!),
              l10n.templatePreviewRecovery,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            workout.dayName ?? l10n.templatePreviewDayFallback(workout.dayNumber),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            workout.isCardio
                ? l10n.templatePreviewCardioSession(
                    '${workout.sport[0].toUpperCase()}${workout.sport.substring(1)}',
                  )
                : l10n.templatePreviewExerciseCount(workout.exercises.length),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: workout.isCardio
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (workout.notes != null && workout.notes!.isNotEmpty)
                          Text(
                            workout.notes!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: workout.exercises.map((exercise) {
                        final muscleGroup = MuscleGroup.values.firstWhere(
                          (m) => m.name == exercise.muscleGroup.toLowerCase(),
                          orElse: () => MuscleGroup.chest,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: muscleGroup.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.templatePreviewSetsReps(exercise.sets, exercise.reps),
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
