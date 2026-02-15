import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/muscle_groups.dart';

/// Horizontal bar chart showing logged sets per muscle group.
///
/// Each bar uses the muscle group's color from [MuscleGroup.color].
class VolumeBarChart extends StatelessWidget {
  final Map<MuscleGroup, int> setsByMuscleGroup;

  const VolumeBarChart({super.key, required this.setsByMuscleGroup});

  @override
  Widget build(BuildContext context) {
    if (setsByMuscleGroup.isEmpty) {
      return Center(
        child: Text(
          'No data yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.5).round()),
          ),
        ),
      );
    }

    // Sort by count descending
    final sorted = setsByMuscleGroup.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sorted.first.value.toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = sorted[group.x.toInt()];
              return BarTooltipItem(
                '${entry.key.displayName}\n${entry.value} sets',
                Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= sorted.length) {
                  return const SizedBox.shrink();
                }
                final name = sorted[index].key.displayName;
                // Abbreviate long names
                final label =
                    name.length > 5 ? '${name.substring(0, 4)}.' : name;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha((255 * 0.7).round()),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(sorted.length, (index) {
          final entry = sorted[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: entry.key.color,
                width: sorted.length > 8 ? 12 : 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
