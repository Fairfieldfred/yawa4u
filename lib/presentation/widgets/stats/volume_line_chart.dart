import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/stats_data.dart';

/// Line chart showing total volume progression over workout days.
///
/// X-axis: workout days (P1D1, P1D2, ..., P2D1, ...)
/// Y-axis: total volume (weight x reps)
class VolumeLineChart extends StatelessWidget {
  final List<VolumeDataPoint> volumeProgression;

  const VolumeLineChart({super.key, required this.volumeProgression});

  @override
  Widget build(BuildContext context) {
    if (volumeProgression.isEmpty) {
      return Center(
        child: Text(
          'No volume data yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.5).round()),
          ),
        ),
      );
    }

    // Only include data points with volume > 0
    final dataPoints =
        volumeProgression.where((p) => p.totalVolume > 0).toList();
    if (dataPoints.isEmpty) {
      return Center(
        child: Text(
          'No volume data yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.5).round()),
          ),
        ),
      );
    }

    final primaryColor = Theme.of(context).colorScheme.primary;
    final maxY = dataPoints.fold<double>(
      0,
      (max, p) => p.totalVolume > max ? p.totalVolume : max,
    );

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= dataPoints.length) return null;
                final point = dataPoints[index];
                return LineTooltipItem(
                  '${point.label}\n${point.totalVolume.toInt()} vol',
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
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withAlpha((255 * 0.1).round()),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: dataPoints.length > 10
                  ? (dataPoints.length / 5).ceilToDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    dataPoints[index].label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha((255 * 0.6).round()),
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
        maxX: (dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(dataPoints.length, (i) {
              return FlSpot(i.toDouble(), dataPoints[i].totalVolume);
            }),
            isCurved: true,
            curveSmoothness: 0.3,
            color: primaryColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: dataPoints.length <= 20,
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
