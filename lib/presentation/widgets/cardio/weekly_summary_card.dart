import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../data/models/cardio_stats.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/stats_providers.dart';

/// Compact "This week" summary card.
///
/// Reads [thisWeekVolumeProvider] + [thisWeekStrengthCountProvider] and
/// renders a one-line-per-sport recap — designed to drop into the home
/// screen above the current cycle card. Self-contained: no params, no
/// callbacks; the parent just embeds it.
///
/// Not wired into home_screen.dart yet — additive, left for follow-up.
class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucket = ref.watch(thisWeekVolumeProvider);
    final strengthSessions = ref.watch(thisWeekStrengthCountProvider);
    final onboarding = ref.watch(onboardingServiceProvider);

    final hasAnything = !bucket.isEmpty || strengthSessions > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_view_week,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'This week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!hasAnything)
              Text(
                'Nothing logged yet — your next session lands here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )
            else ...[
              if (strengthSessions > 0)
                _SportLine(
                  sport: Sport.strength,
                  label: '$strengthSessions strength session${strengthSessions == 1 ? '' : 's'}',
                ),
              for (final entry in _sortedSportEntries(bucket))
                _SportLine(
                  sport: entry.key,
                  label: _formatLine(
                    entry.key,
                    entry.value,
                    onboarding.unitsFor(entry.key),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<MapEntry<Sport, WeeklySportVolume>> _sortedSportEntries(
    WeeklyVolumeBucket bucket,
  ) {
    final entries = bucket.perSport.entries.toList()..sort((a, b) => a.key.index.compareTo(b.key.index));
    return entries;
  }

  String _formatLine(
    Sport sport,
    WeeklySportVolume volume,
    UnitSystem units,
  ) {
    final parts = <String>[];
    parts.add(
      '${volume.sessions} ${sport.displayName.toLowerCase()}'
      '${volume.sessions == 1 ? '' : 's'}',
    );
    if (volume.distanceM > 0) {
      parts.add(
        sport == Sport.swim
            ? CardioConversions.formatSwimDistance(volume.distanceM, units)
            : CardioConversions.formatDistance(volume.distanceM, units),
      );
    }
    if (volume.durationSec > 0) {
      parts.add(CardioConversions.formatDuration(volume.durationSec));
    }
    return parts.join(' • ');
  }
}

class _SportLine extends StatelessWidget {
  const _SportLine({required this.sport, required this.label});

  final Sport sport;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(sport.icon, size: 16, color: sport.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
