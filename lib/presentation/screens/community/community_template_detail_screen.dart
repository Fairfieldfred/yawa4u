import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/training_cycle_template.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../domain/providers/community_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/template_providers.dart';
import '../../../data/services/exercise_name_localizer.dart';
import '../../../l10n/app_localizations.dart';

/// Detail + download screen for a single community template.
class CommunityTemplateDetailScreen extends ConsumerStatefulWidget {
  final CommunityTemplate template;

  const CommunityTemplateDetailScreen({
    super.key,
    required this.template,
  });

  @override
  ConsumerState<CommunityTemplateDetailScreen> createState() => _CommunityTemplateDetailScreenState();
}

class _CommunityTemplateDetailScreenState extends ConsumerState<CommunityTemplateDetailScreen> {
  bool _isDownloading = false;
  bool _downloaded = false;

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isDownloading = true);
    try {
      final template = widget.template.template;

      // Save the template into the local library.
      final repo = ref.read(communityRepositoryProvider);
      await repo.downloadTemplate(widget.template);
      // Refresh local template list so it appears immediately.
      ref.invalidate(availableTemplatesProvider);

      // Create a training cycle from the downloaded template. This mirrors the
      // preloaded 'Create Program' flow in TemplatePreviewScreen so a community
      // download lands the user on a usable draft cycle.
      final templateRepository = ref.read(templateRepositoryProvider);
      final result = await templateRepository.createTrainingCycleFromTemplate(template);

      final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
      await trainingCycleRepository.create(result.trainingCycle);

      final workoutRepository = ref.read(workoutRepositoryProvider);
      for (final workout in result.trainingCycle.workouts) {
        await workoutRepository.create(workout);
      }

      final sessionRepository = ref.read(sessionRepositoryProvider);
      for (final cardio in result.cardioSessions) {
        await sessionRepository.createCardio(cardio);
      }

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloaded = true;
        });
        // Confirm the download before navigating (mirrors the skin flow).
        context.showSuccessSnackBar(l10n.communityTemplateSaved(widget.template.template.name));
        // Show the newly created draft on the Cycles tab. go() replaces
        // the stack, dismissing the browse/detail screens on the way.
        context.go('/cycles');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        context.showErrorSnackBar(l10n.communityDownloadFailed(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final t = widget.template.template;

    return Scaffold(
      appBar: AppBar(title: Text(t.name), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Author + download count row
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.template.authorDisplayName,
                      style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.download_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.communityDownloadCount(widget.template.downloadCount),
                      style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  t.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Program details
                _buildInfoSection(t, colorScheme, l10n),
                const SizedBox(height: 24),

                // Tags
                if (widget.template.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: widget.template.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Sessions list
                Text(
                  l10n.communitySessionsHeader,
                  style: context.textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                ...t.workouts.map(
                  (workout) => _buildWorkoutCard(workout, colorScheme, l10n),
                ),
              ],
            ),
          ),

          // Download button
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
                child: FilledButton.icon(
                  onPressed: _isDownloading || _downloaded ? null : _download,
                  icon: _downloaded ? const Icon(Icons.check) : const Icon(Icons.download),
                  label: _isDownloading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _downloaded ? l10n.communitySavedButton : l10n.communityDownloadProgramButton,
                          style: context.textTheme.titleMedium,
                        ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoSection(
    TrainingCycleTemplate t,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
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
            l10n.communityPeriodsCount(t.periodsTotal),
            l10n.communityDurationLabel,
            colorScheme,
          ),
          _buildInfoItem(
            Icons.fitness_center,
            l10n.communityDaysCount(t.daysPerPeriod),
            l10n.communityPerPeriodLabel,
            colorScheme,
          ),
          if (t.recoveryPeriod != null)
            _buildInfoItem(
              Icons.refresh,
              l10n.communityPeriodNumber(t.recoveryPeriod!),
              l10n.communityRecoveryLabel,
              colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String value,
    String label,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    WorkoutTemplate workout,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
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
            workout.dayName ?? l10n.communityDayFallback(workout.dayNumber),
            style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            workout.isCardio
                ? l10n.communityCardioSession(
                    '${workout.sport[0].toUpperCase()}${workout.sport.substring(1)}',
                  )
                : l10n.communityExerciseCount(workout.exercises.length),
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
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                                      context.localizedExerciseName(exercise.name),
                                      style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.communitySetsReps(exercise.sets, exercise.reps),
                                      style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
