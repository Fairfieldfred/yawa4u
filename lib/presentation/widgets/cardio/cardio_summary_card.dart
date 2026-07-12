import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../data/models/session.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../l10n/app_localizations.dart';
import 'sport_badge.dart';

/// Compact horizontal summary of a [CardioSession] — sport, distance,
/// duration, avg HR. Designed to slot into lists and calendar tiles at
/// approximately the same density as the existing exercise card.
class CardioSummaryCard extends StatelessWidget {
  const CardioSummaryCard({
    super.key,
    required this.session,
    required this.units,
    this.onTap,
  });

  final CardioSession session;
  final UnitSystem units;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = session.detail;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: sport badge + title + status chip.
              Row(
                children: [
                  SportBadge(sport: session.sport),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.localizedDisplayName(l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (session.isCompleted) Icon(Icons.check_circle, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 10),
              // Metrics row — shows whatever is available.
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (detail?.actualDistanceM != null)
                    _Metric(
                      icon: Icons.straighten,
                      label: CardioConversions.formatDistance(
                        detail!.actualDistanceM!,
                        units,
                      ),
                    ),
                  if (detail?.actualDurationSec != null)
                    _Metric(
                      icon: Icons.timer_outlined,
                      label: CardioConversions.formatDuration(
                        detail!.actualDurationSec!,
                      ),
                    ),
                  if (detail?.averageHr != null)
                    _Metric(
                      icon: Icons.favorite_outline,
                      label: '${detail!.averageHr} ${l10n.bpmSuffix}',
                    ),
                  if (detail?.perceivedExertion != null)
                    _Metric(
                      icon: Icons.speed_outlined,
                      label: 'RPE ${detail!.perceivedExertion}',
                    ),
                ],
              ),
              if (session.notes != null && session.notes!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    session.notes!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
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
