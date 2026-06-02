import 'package:flutter/material.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/constants/sports.dart';
import '../../../../core/utils/cardio_conversions.dart';
import '../../../../data/models/cardio_stats.dart';
import '../../../../l10n/app_localizations.dart';

/// Compact card showing a [SportAggregate]: sessions / total time / total
/// distance / avg HR. Used on the Cardio tab of the Stats screen.
class SportSummaryTile extends StatelessWidget {
  const SportSummaryTile({
    super.key,
    required this.aggregate,
    required this.units,
    this.onTap,
  });

  final SportAggregate aggregate;
  final UnitSystem units;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sport = aggregate.sport;
    final color = sport.color;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(sport.icon, size: 20, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    sport.localizedName(l10n),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    '${aggregate.sessions}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.sportSummarySessionLabel(aggregate.sessions),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _Stat(
                    icon: Icons.timer_outlined,
                    label: CardioConversions.formatDuration(
                      aggregate.totalDurationSec,
                    ),
                  ),
                  if (aggregate.totalDistanceM > 0)
                    _Stat(
                      icon: Icons.straighten,
                      label: sport == Sport.swim
                          ? CardioConversions.formatSwimDistance(
                              aggregate.totalDistanceM,
                              units,
                            )
                          : CardioConversions.formatDistance(
                              aggregate.totalDistanceM,
                              units,
                            ),
                    ),
                  if (aggregate.avgHr != null)
                    _Stat(
                      icon: Icons.favorite_outline,
                      label: '${aggregate.avgHr} ${l10n.bpmSuffix}',
                    ),
                  if (aggregate.bestDistanceM > 0)
                    _Stat(
                      icon: Icons.emoji_events_outlined,
                      label: l10n.sportSummaryBestLabel(
                        sport == Sport.swim
                            ? CardioConversions.formatSwimDistance(aggregate.bestDistanceM, units)
                            : CardioConversions.formatDistance(aggregate.bestDistanceM, units),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
