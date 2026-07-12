import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';
import '../../../l10n/app_localizations.dart';

/// Small pill showing a sport's icon + optional label in its accent color.
///
/// Used in lists, calendar days, and session headers wherever we need a
/// compact sport indicator.
class SportBadge extends StatelessWidget {
  const SportBadge({
    super.key,
    required this.sport,
    this.showLabel = true,
    this.compact = false,
  });

  final Sport sport;
  final bool showLabel;

  /// Tighter padding + smaller icon, for dense lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = sport.color;
    final hPadding = compact ? 6.0 : 10.0;
    final vPadding = compact ? 3.0 : 5.0;
    final iconSize = compact ? 12.0 : 14.0;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(sport.icon, size: iconSize, color: color),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(sport.localizedName(AppLocalizations.of(context)!), style: labelStyle),
          ],
        ],
      ),
    );
  }
}
