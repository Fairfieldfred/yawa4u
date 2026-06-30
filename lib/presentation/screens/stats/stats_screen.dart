import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/constants/enums.dart';
import '../../../core/utils/user_errors.dart';
import '../../../data/models/cardio_stats.dart';
import '../../../data/models/stats_data.dart';
import '../../../data/models/training_cycle.dart';
import '../../../data/services/exercise_name_localizer.dart';
import '../../../domain/providers/measurement_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/stats_providers.dart';
import '../../../domain/providers/training_cycle_providers.dart';
import '../../widgets/cardio/quick_log_action.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/cardio/weekly_summary_card.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/screen_background.dart';
import '../../widgets/stats/cardio/sport_legend.dart';
import '../../widgets/stats/cardio/sport_summary_tile.dart';
import '../../widgets/stats/cardio/weekly_volume_chart.dart';
import '../../widgets/stats/cycle_comparison_view.dart';
import '../../widgets/stats/volume_bar_chart.dart';
import '../../widgets/stats/volume_line_chart.dart';
import '../../widgets/stats/weight_progress_chart.dart';
import '../../../l10n/app_localizations.dart';

/// Statistics & Analytics screen showing workout volume,
/// muscle group distribution, exercise frequency, and personal records.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  String? _selectedCycleId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // v5: added Cardio tab after Overview. Compare + Body stay in place.
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCycle = ref.watch(currentTrainingCycleProvider);
    final allCycles = ref.watch(trainingCyclesProvider);

    // Build cycle list for dropdown
    final cycleList = allCycles.when(
      data: (list) => list
          .where(
            (c) => c.status == TrainingCycleStatus.current || c.status == TrainingCycleStatus.completed,
          )
          .toList(),
      loading: () => <TrainingCycle>[],
      error: (_, _) => <TrainingCycle>[],
    );

    // Default to active cycle
    final effectiveCycleId = _selectedCycleId ?? currentCycle?.id ?? cycleList.firstOrNull?.id;

    // Choose lifetime or cycle stats
    final statsAsync = effectiveCycleId != null
        ? ref.watch(cycleStatsProvider(effectiveCycleId))
        : ref.watch(lifetimeStatsProvider);

    return ScreenBackground(
      screenType: ScreenType.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.statsTitle),
          actions: const [QuickLogAction()],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.statsTabOverview),
              Tab(text: l10n.statsTabCardio),
              Tab(text: l10n.statsTabCompare),
              Tab(text: l10n.statsTabBody),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Overview (existing strength content — unchanged)
            Column(
              children: [
                if (cycleList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildCycleSelector(cycleList, effectiveCycleId),
                  ),
                Expanded(
                  child: statsAsync.when(
                    data: (stats) => _buildStatsContent(context, stats),
                    loading: () => const SkeletonStats(),
                    error: (error, stack) {
                      Sentry.captureException(error, stackTrace: stack);
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                UserErrors.describe(
                                  error,
                                  context: 'load stats',
                                ),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () {
                                  if (effectiveCycleId != null) {
                                    ref.invalidate(
                                      cycleStatsProvider(effectiveCycleId),
                                    );
                                  } else {
                                    ref.invalidate(lifetimeStatsProvider);
                                  }
                                },
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Tab 2: Cardio (v5)
            _buildCardioTab(),
            // Tab 3: Compare
            CycleComparisonView(availableCycles: cycleList),
            // Tab 4: Body Metrics
            _buildBodyMetricsTab(),
          ],
        ),
      ),
    );
  }

  /// v5 Cardio tab. Weekly volume (stacked bars, last 12 weeks) +
  /// per-sport summary tiles. Empty state for users with no cardio logged.
  Widget _buildCardioTab() {
    final l10n = AppLocalizations.of(context)!;
    final stats = ref.watch(cardioStatsProvider);
    final recentWeeks = ref.watch(recentCardioWeeksProvider(12));
    final onboarding = ref.watch(onboardingServiceProvider);

    if (stats.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.directions_run,
        iconSize: 64,
        title: l10n.statsNoCardioTitle,
        subtitle: l10n.statsNoCardioSubtitle,
      );
    }

    final sportsWithData = stats.perSport.keys.toList()..sort((a, b) => a.index.compareTo(b.index));

    return ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, l10n.statsWeeklyVolume),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  WeeklyVolumeChart(weeks: recentWeeks),
                  const SizedBox(height: 8),
                  SportLegend(include: sportsWithData),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, l10n.statsBySport),
          const SizedBox(height: 12),
          for (final sport in sportsWithData) ...[
            SportSummaryTile(
              aggregate: stats.perSport[sport]!,
              units: onboarding.unitsFor(sport),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
          _buildSectionHeader(context, l10n.statsLifetimeTotals),
          const SizedBox(height: 12),
          _buildCardioLifetimeRow(context, stats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardioLifetimeRow(BuildContext context, CardioStats stats) {
    final l10n = AppLocalizations.of(context)!;
    final totalHours = (stats.totalDurationSec / 3600).toStringAsFixed(1);
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsCardioSessions,
            '${stats.totalSessions}',
            Icons.directions_run,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsCardioHours,
            totalHours,
            Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsCardioCompleted,
            '${stats.completedSessions}',
            Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMetricsTab() {
    final l10n = AppLocalizations.of(context)!;
    final measurementsAsync = ref.watch(userMeasurementsProvider);

    return measurementsAsync.when(
      data: (measurements) {
        if (measurements.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.monitor_weight_outlined,
            iconSize: 64,
            title: l10n.statsNoMeasurementsTitle,
            subtitle: l10n.statsNoMeasurementsSubtitle,
          );
        }

        final latest = measurements.first;
        final bmiStr = latest.bmi.toStringAsFixed(1);
        final weightStr = latest.weightKg.toStringAsFixed(1);

        return ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      l10n.statsWeightLabel,
                      l10n.statsWeightValueKg(weightStr),
                      Icons.monitor_weight_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      l10n.statsBmiLabel,
                      bmiStr,
                      Icons.straighten,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      l10n.statsEntriesLabel,
                      '${measurements.length}',
                      Icons.timeline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weight chart
              _buildSectionHeader(context, l10n.statsWeightProgression),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: WeightProgressChart(
                  measurements: measurements,
                ),
              ),
              const SizedBox(height: 24),

              // Body fat section (if available)
              if (measurements.any((m) => m.bodyFatPercent != null)) ...[
                _buildSectionHeader(context, l10n.statsBodyComposition),
                const SizedBox(height: 8),
                _buildCompositionList(context, measurements),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        Sentry.captureException(error, stackTrace: stack);
        return Center(child: Text(l10n.statsErrorLoadingMeasurements(error)));
      },
    );
  }

  Widget _buildCompositionList(
    BuildContext context,
    List<dynamic> measurements,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final withFat = measurements.where((m) => m.bodyFatPercent != null).take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: withFat.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          final fatStr = m.bodyFatPercent!.toStringAsFixed(1);
          final leanStr = m.calculatedLeanMassKg?.toStringAsFixed(1);
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.pie_chart_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  leanStr != null ? l10n.statsBodyFatWithLean(fatStr, leanStr) : l10n.statsBodyFatEntry(fatStr),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  '${m.timestamp.month}/${m.timestamp.day}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (index < withFat.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCycleSelector(
    List<TrainingCycle> cycles,
    String? selectedId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String?>(
        value: selectedId,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Theme.of(context).cardTheme.color,
        items: [
          ...cycles.map((cycle) {
            final label = cycle.status == TrainingCycleStatus.current
                ? l10n.statsActiveCycleLabel(cycle.name)
                : cycle.name;
            return DropdownMenuItem<String?>(
              value: cycle.id,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
        onChanged: (value) {
          setState(() => _selectedCycleId = value);
        },
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, WorkoutStats stats) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveContent(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // v5 — weekly summary across all sports at the top of Overview.
          // Auto-collapses to a soft empty state for strength-only users,
          // so it's never visual clutter.
          const WeeklySummaryCard(),
          const SizedBox(height: 12),

          // Summary cards
          _buildSummaryRow(context, stats),
          const SizedBox(height: 24),

          // Volume by muscle group
          _buildSectionHeader(context, l10n.statsVolumeByMuscleGroup),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: VolumeBarChart(setsByMuscleGroup: stats.setsByMuscleGroup),
          ),
          const SizedBox(height: 24),

          // Volume progression
          _buildSectionHeader(context, l10n.statsVolumeProgression),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: VolumeLineChart(volumeProgression: stats.volumeProgression),
          ),
          const SizedBox(height: 24),

          // Top exercises
          if (stats.exerciseFrequency.isNotEmpty) ...[
            _buildSectionHeader(context, l10n.statsMostUsedExercises),
            const SizedBox(height: 8),
            _buildExerciseFrequencyList(context, stats),
            const SizedBox(height: 24),
          ],

          // Personal records
          if (stats.personalRecords.isNotEmpty) ...[
            _buildSectionHeader(context, l10n.statsPersonalRecords),
            const SizedBox(height: 8),
            _buildPersonalRecordsList(context, stats),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, WorkoutStats stats) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsSessionsLabel,
            l10n.statsSessionsValue(stats.completedWorkouts, stats.totalWorkouts),
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsCompletionLabel,
            l10n.statsCompletionValue((stats.completionRate * 100).toInt()),
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.statsTotalSetsLabel,
            stats.totalSets.toString(),
            Icons.format_list_numbered,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Semantics(
      label: '$title: $value',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
      ),
    );
  }

  Widget _buildExerciseFrequencyList(
    BuildContext context,
    WorkoutStats stats,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final topExercises = stats.topExercises();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: topExercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exerciseEntry = entry.value;
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.2).round()),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                title: Text(
                  context.localizedExerciseName(exerciseEntry.key),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  l10n.statsExerciseFrequencyCount(exerciseEntry.value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (index < topExercises.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonalRecordsList(
    BuildContext context,
    WorkoutStats stats,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final topRecords = stats.topRecords();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: topRecords.asMap().entries.map((entry) {
          final index = entry.key;
          final recordEntry = entry.value;
          final weight = recordEntry.value;
          final weightStr = weight == weight.roundToDouble() ? weight.toInt().toString() : weight.toString();
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.emoji_events,
                  color: index == 0
                      ? const Color(0xFFFFD700)
                      : index == 1
                      ? const Color(0xFFC0C0C0)
                      : index == 2
                      ? const Color(0xFFCD7F32)
                      : Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.4).round()),
                  size: 20,
                ),
                title: Text(
                  context.localizedExerciseName(recordEntry.key),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  l10n.statsPersonalRecordWeight(weightStr),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (index < topRecords.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}
