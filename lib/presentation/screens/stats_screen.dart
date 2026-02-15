import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../data/models/stats_data.dart';
import '../../data/models/training_cycle.dart';
import '../../domain/providers/stats_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../widgets/responsive_content.dart';
import '../widgets/screen_background.dart';
import '../widgets/stats/cycle_comparison_view.dart';
import '../widgets/stats/volume_bar_chart.dart';
import '../widgets/stats/volume_line_chart.dart';

/// Statistics & Analytics screen showing workout volume,
/// muscle group distribution, exercise frequency, and personal records.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCycleId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCycle = ref.watch(currentTrainingCycleProvider);
    final allCycles = ref.watch(trainingCyclesProvider);

    // Build cycle list for dropdown
    final cycleList = allCycles.when(
      data: (list) => list
          .where(
            (c) =>
                c.status == TrainingCycleStatus.current ||
                c.status == TrainingCycleStatus.completed,
          )
          .toList(),
      loading: () => <TrainingCycle>[],
      error: (_, __) => <TrainingCycle>[],
    );

    // Default to active cycle
    final effectiveCycleId =
        _selectedCycleId ?? currentCycle?.id ?? cycleList.firstOrNull?.id;

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
          title: const Text('Statistics'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Compare'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Overview (existing content)
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
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Error loading stats: $error'),
                    ),
                  ),
                ),
              ],
            ),
            // Tab 2: Compare
            CycleComparisonView(availableCycles: cycleList),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleSelector(
    List<TrainingCycle> cycles,
    String? selectedId,
  ) {
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
                ? '${cycle.name} (Active)'
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
    return ResponsiveContent(
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        _buildSummaryRow(context, stats),
        const SizedBox(height: 24),

        // Volume by muscle group
        _buildSectionHeader(context, 'Volume by Muscle Group'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: VolumeBarChart(setsByMuscleGroup: stats.setsByMuscleGroup),
        ),
        const SizedBox(height: 24),

        // Volume progression
        _buildSectionHeader(context, 'Volume Progression'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: VolumeLineChart(volumeProgression: stats.volumeProgression),
        ),
        const SizedBox(height: 24),

        // Top exercises
        if (stats.exerciseFrequency.isNotEmpty) ...[
          _buildSectionHeader(context, 'Most Used Exercises'),
          const SizedBox(height: 8),
          _buildExerciseFrequencyList(context, stats),
          const SizedBox(height: 24),
        ],

        // Personal records
        if (stats.personalRecords.isNotEmpty) ...[
          _buildSectionHeader(context, 'Personal Records'),
          const SizedBox(height: 8),
          _buildPersonalRecordsList(context, stats),
          const SizedBox(height: 24),
        ],
      ],
    ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, WorkoutStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Workouts',
            '${stats.completedWorkouts}/${stats.totalWorkouts}',
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Completion',
            '${(stats.completionRate * 100).toInt()}%',
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Sets',
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((255 * 0.6).round()),
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
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withAlpha((255 * 0.6).round()),
      ),
    );
  }

  Widget _buildExerciseFrequencyList(
    BuildContext context,
    WorkoutStats stats,
  ) {
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
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((255 * 0.2).round()),
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                title: Text(
                  exerciseEntry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  '${exerciseEntry.value}x',
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
          final weightStr = weight == weight.roundToDouble()
              ? weight.toInt().toString()
              : weight.toString();
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
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withAlpha((255 * 0.4).round()),
                  size: 20,
                ),
                title: Text(
                  recordEntry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Text(
                  '$weightStr lbs',
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
