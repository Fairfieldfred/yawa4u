import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';

/// Thin horizontal bar showing proportional sport distribution for a
/// training cycle, plus a compact legend below.
///
/// Takes a `Map<Sport, int>` (session counts per sport) and renders
/// proportional colored segments using each [Sport]'s accent color.
/// When only one sport is present the bar is a single solid segment.
/// Empty maps render nothing ([SizedBox.shrink]).
class SportDistributionRibbon extends StatelessWidget {
  const SportDistributionRibbon({
    super.key,
    required this.distribution,
    this.height = 6,
    this.borderRadius = 3,
  });

  /// Session count per sport.
  final Map<Sport, int> distribution;

  /// Height of the colored bar.
  final double height;

  /// Corner radius applied to the bar ends.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) return const SizedBox.shrink();

    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    // Sort entries by Sport.index for stable ordering.
    final entries = distribution.entries.toList()..sort((a, b) => a.key.index.compareTo(b.key.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- proportional bar ---
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (final entry in entries)
                  Expanded(
                    flex: entry.value,
                    child: ColoredBox(color: entry.key.color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // --- legend ---
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final entry in entries)
              _LegendItem(
                sport: entry.key,
                count: entry.value,
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.sport, required this.count});

  final Sport sport;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = sport.color;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.7),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$count ${sport.displayName}', style: style),
      ],
    );
  }
}
