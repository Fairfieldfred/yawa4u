import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/stats_data.dart';
import '../../../data/models/training_cycle.dart';
import '../../../domain/providers/stats_providers.dart';

/// Cycle comparison tab content for the Stats screen.
///
/// Allows selecting two training cycles and shows side-by-side
/// comparison cards with color-coded deltas.
class CycleComparisonView extends ConsumerStatefulWidget {
  final List<TrainingCycle> availableCycles;

  const CycleComparisonView({super.key, required this.availableCycles});

  @override
  ConsumerState<CycleComparisonView> createState() =>
      _CycleComparisonViewState();
}

class _CycleComparisonViewState extends ConsumerState<CycleComparisonView> {
  String? _cycleAId;
  String? _cycleBId;

  @override
  Widget build(BuildContext context) {
    if (widget.availableCycles.length < 2) {
      return _buildNotEnoughCycles(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Cycle selectors
        _buildCycleSelectors(context),
        const SizedBox(height: 16),

        // Comparison content
        if (_cycleAId != null && _cycleBId != null)
          _buildComparison(context)
        else
          _buildSelectPrompt(context),
      ],
    );
  }

  Widget _buildNotEnoughCycles(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.compare_arrows,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((255 * 0.4).round()),
            ),
            const SizedBox(height: 16),
            Text(
              'Need at least 2 cycles to compare',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((255 * 0.6).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a training cycle to unlock comparisons.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withAlpha((255 * 0.5).round()),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleSelectors(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDropdown(context, isA: true)),
        const SizedBox(width: 8),
        Icon(
          Icons.compare_arrows,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withAlpha((255 * 0.4).round()),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildDropdown(context, isA: false)),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, {required bool isA}) {
    final selectedId = isA ? _cycleAId : _cycleBId;
    final label = isA ? 'Cycle A' : 'Cycle B';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String?>(
        value: selectedId,
        hint: Text(label, overflow: TextOverflow.ellipsis),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: Theme.of(context).cardTheme.color,
        items: widget.availableCycles.map((cycle) {
          return DropdownMenuItem<String?>(
            value: cycle.id,
            child: Text(
              cycle.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (isA) {
              _cycleAId = value;
            } else {
              _cycleBId = value;
            }
          });
        },
      ),
    );
  }

  Widget _buildSelectPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Text(
          'Select two cycles to compare',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.5).round()),
          ),
        ),
      ),
    );
  }

  Widget _buildComparison(BuildContext context) {
    final statsA = ref.watch(cycleStatsProvider(_cycleAId!));
    final statsB = ref.watch(cycleStatsProvider(_cycleBId!));

    return statsA.when(
      data: (a) => statsB.when(
        data: (b) => _buildComparisonCards(context, a, b),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildComparisonCards(
    BuildContext context,
    WorkoutStats a,
    WorkoutStats b,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary delta cards
        _buildSummaryComparison(context, a, b),
        const SizedBox(height: 24),

        // Muscle group comparison
        _buildSectionHeader(context, 'Sets by Muscle Group'),
        const SizedBox(height: 8),
        _buildMuscleGroupComparison(context, a, b),
        const SizedBox(height: 24),

        // PR comparison
        if (_hasPROverlap(a, b)) ...[
          _buildSectionHeader(context, 'Personal Record Changes'),
          const SizedBox(height: 8),
          _buildPRComparison(context, a, b),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSummaryComparison(
    BuildContext context,
    WorkoutStats a,
    WorkoutStats b,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDeltaCard(
            context,
            'Completion',
            '${(a.completionRate * 100).toInt()}%',
            '${(b.completionRate * 100).toInt()}%',
            (b.completionRate - a.completionRate) * 100,
            suffix: '%',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDeltaCard(
            context,
            'Total Sets',
            a.totalSets.toString(),
            b.totalSets.toString(),
            (b.totalSets - a.totalSets).toDouble(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDeltaCard(
            context,
            'Workouts',
            '${a.completedWorkouts}',
            '${b.completedWorkouts}',
            (b.completedWorkouts - a.completedWorkouts).toDouble(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeltaCard(
    BuildContext context,
    String title,
    String valueA,
    String valueB,
    double delta, {
    String suffix = '',
  }) {
    final isPositive = delta > 0;
    final isNegative = delta < 0;
    final deltaColor = isPositive
        ? Colors.green
        : isNegative
            ? Colors.red
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.5).round());
    final deltaStr = isPositive
        ? '+${delta.toInt()}$suffix'
        : '${delta.toInt()}$suffix';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withAlpha((255 * 0.6).round()),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                valueA,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward, size: 12, color: deltaColor),
              ),
              Text(
                valueB,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          if (delta != 0)
            Text(
              deltaStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: deltaColor,
              ),
            ),
        ],
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

  Widget _buildMuscleGroupComparison(
    BuildContext context,
    WorkoutStats a,
    WorkoutStats b,
  ) {
    // Collect all muscle groups from both
    final allGroups = <MuscleGroup>{
      ...a.setsByMuscleGroup.keys,
      ...b.setsByMuscleGroup.keys,
    };
    final sorted = allGroups.toList()
      ..sort((x, y) {
        final deltaX = (b.setsByMuscleGroup[x] ?? 0) -
            (a.setsByMuscleGroup[x] ?? 0);
        final deltaY = (b.setsByMuscleGroup[y] ?? 0) -
            (a.setsByMuscleGroup[y] ?? 0);
        return deltaY.compareTo(deltaX);
      });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: sorted.asMap().entries.map((entry) {
          final index = entry.key;
          final group = entry.value;
          final countA = a.setsByMuscleGroup[group] ?? 0;
          final countB = b.setsByMuscleGroup[group] ?? 0;
          final delta = countB - countA;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: group.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        group.displayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$countA',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward, size: 12),
                    ),
                    Text(
                      '$countB',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        delta > 0 ? '+$delta' : '$delta',
                        textAlign: TextAlign.end,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: delta > 0
                              ? Colors.green
                              : delta < 0
                                  ? Colors.red
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withAlpha((255 * 0.5).round()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < sorted.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmtWeight(double w) =>
      w == w.roundToDouble() ? w.toInt().toString() : w.toString();

  bool _hasPROverlap(WorkoutStats a, WorkoutStats b) {
    return a.personalRecords.keys
        .any((name) => b.personalRecords.containsKey(name));
  }

  Widget _buildPRComparison(
    BuildContext context,
    WorkoutStats a,
    WorkoutStats b,
  ) {
    // Find exercises present in both cycles
    final commonExercises = a.personalRecords.keys
        .where((name) => b.personalRecords.containsKey(name))
        .toList();

    // Sort by biggest improvement first
    commonExercises.sort((x, y) {
      final deltaX = b.personalRecords[x]! - a.personalRecords[x]!;
      final deltaY = b.personalRecords[y]! - a.personalRecords[y]!;
      return deltaY.compareTo(deltaX);
    });

    // Limit to top 10
    final limited = commonExercises.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: limited.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final weightA = a.personalRecords[name]!;
          final weightB = b.personalRecords[name]!;
          final delta = weightB - weightA;

          return Column(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '${_fmtWeight(weightA)} \u2192 ${_fmtWeight(weightB)} lbs',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Text(
                  delta > 0
                      ? '+${_fmtWeight(delta)}'
                      : _fmtWeight(delta),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: delta > 0
                        ? Colors.green
                        : delta < 0
                            ? Colors.red
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha((255 * 0.5).round()),
                  ),
                ),
              ),
              if (index < limited.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}
