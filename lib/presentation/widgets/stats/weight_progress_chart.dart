import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/user_measurement.dart';

/// Line chart showing body weight progression over time.
///
/// X-axis: measurement dates
/// Y-axis: weight in kg (or lbs based on [useMetric])
class WeightProgressChart extends StatelessWidget {
  final List<UserMeasurement> measurements;
  final bool useMetric;

  const WeightProgressChart({
    super.key,
    required this.measurements,
    this.useMetric = true,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.length < 2) {
      return Center(
        child: Text(
          measurements.isEmpty ? 'No measurements yet' : 'Need at least 2 measurements to show a chart',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
          ),
        ),
      );
    }

    // Sort by timestamp ascending
    final sorted = List<UserMeasurement>.from(measurements)..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final primaryColor = Theme.of(context).colorScheme.primary;
    final dateFormat = DateFormat('M/d');

    // Convert weight values
    final weights = sorted.map((m) {
      return useMetric ? m.weightKg : m.weightKg * 2.20462;
    }).toList();

    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW;
    // Pad y-axis by 10% on each side, minimum 1 unit
    final padding = range > 0 ? range * 0.1 : 1.0;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= sorted.length) return null;
                final m = sorted[index];
                final w = weights[index];
                final unit = useMetric ? 'kg' : 'lbs';
                final wStr = w == w.roundToDouble() ? w.toInt().toString() : w.toStringAsFixed(1);
                return LineTooltipItem(
                  '${dateFormat.format(m.timestamp)}\n$wStr $unit',
                  Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 0 ? range / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.1).round()),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: sorted.length > 10 ? (sorted.length / 5).ceilToDouble() : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    dateFormat.format(sorted[index].timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
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
        minX: 0,
        maxX: (sorted.length - 1).toDouble(),
        minY: minW - padding,
        maxY: maxW + padding,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sorted.length, (i) {
              return FlSpot(i.toDouble(), weights[i]);
            }),
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: sorted.length <= 20,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: primaryColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withAlpha((255 * 0.15).round()),
            ),
          ),
        ],
      ),
    );
  }
}
