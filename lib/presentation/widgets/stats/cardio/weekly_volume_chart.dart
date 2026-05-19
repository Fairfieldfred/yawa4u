import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/sports.dart';
import '../../../../core/utils/cardio_conversions.dart';
import '../../../../data/models/cardio_stats.dart';

/// Stacked bar chart of weekly cardio volume broken down by sport.
///
/// One bar per week (X axis = week index), stack segments per sport
/// coloured by the sport's accent color. Y axis displays hours (converted
/// from durationSec) so a bar's total height is the total hours trained
/// that week. Empty weeks render as empty bars to keep the axis
/// continuous.
class WeeklyVolumeChart extends StatelessWidget {
  const WeeklyVolumeChart({
    super.key,
    required this.weeks,
    this.sportFilter,
    this.height = 220,
  });

  /// Weeks in chronological order (oldest first).
  final List<WeeklyVolumeBucket> weeks;

  /// Optional filter — render only this sport's bar. Null = stacked
  /// multi-sport view.
  final Sport? sportFilter;

  final double height;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return _Empty(height: height, label: 'No cardio in this range yet');
    }

    final theme = Theme.of(context);
    final maxHours = _maxHours();
    final effectiveMax = maxHours == 0 ? 1.0 : maxHours * 1.18;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: effectiveMax,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final bucket = weeks[group.x.toInt()];
                final totalMin = bucket.totalDurationSec ~/ 60;
                return BarTooltipItem(
                  '${_weekLabel(bucket.weekStart)}\n'
                  '${bucket.totalSessions} sessions • ${_fmtMin(totalMin)}',
                  theme.textTheme.bodySmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == 0) return const SizedBox();
                  return Text(
                    '${value.toStringAsFixed(0)}h',
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= weeks.length) return const SizedBox();
                  // Show label every 2 weeks to avoid crowding
                  if (idx % 2 != 0 && weeks.length > 6) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _shortWeekLabel(weeks[idx].weekStart),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: effectiveMax > 0 ? (effectiveMax / 4).ceilToDouble() : 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _barGroups(),
        ),
      ),
    );
  }

  double _maxHours() {
    var max = 0.0;
    for (final w in weeks) {
      final total = sportFilter == null
          ? w.totalDurationSec / 3600
          : (w.perSport[sportFilter]?.durationSec ?? 0) / 3600;
      if (total > max) max = total;
    }
    return max;
  }

  List<BarChartGroupData> _barGroups() {
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < weeks.length; i++) {
      final bucket = weeks[i];
      if (sportFilter != null) {
        final hours = (bucket.perSport[sportFilter]?.durationSec ?? 0) / 3600;
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hours,
                color: sportFilter!.color,
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        );
      } else {
        // Stacked multi-sport bar.
        final stackItems = <BarChartRodStackItem>[];
        double running = 0;
        for (final sport in Sport.values) {
          if (sport == Sport.strength) continue;
          final segHours = (bucket.perSport[sport]?.durationSec ?? 0) / 3600;
          if (segHours <= 0) continue;
          stackItems.add(
            BarChartRodStackItem(running, running + segHours, sport.color),
          );
          running += segHours;
        }
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: running,
                width: 14,
                rodStackItems: stackItems,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        );
      }
    }
    return groups;
  }

  String _weekLabel(DateTime d) {
    return 'Wk of ${_months[d.month - 1]} ${d.day}';
  }

  String _shortWeekLabel(DateTime d) {
    return '${_months[d.month - 1]} ${d.day}';
  }

  String _fmtMin(int minutes) {
    return CardioConversions.formatDuration(minutes * 60);
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class _Empty extends StatelessWidget {
  const _Empty({required this.height, required this.label});

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
