import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';
import '../../../l10n/app_localizations.dart';

/// A compact, selectable sport indicator for use in horizontal rows.
///
/// Renders the sport's colored icon in a circular container. When
/// [selected] is true, the background tints with the sport's color to
/// indicate the active choice. A tooltip shows the sport name on
/// long-press for accessibility.
class SportChip extends StatelessWidget {
  final Sport sport;
  final bool selected;
  final VoidCallback onTap;

  const SportChip({
    super.key,
    required this.sport,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = sport.color;

    return Tooltip(
      message: sport.localizedName(AppLocalizations.of(context)!),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color.withValues(alpha: 0.5) : theme.colorScheme.outline.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Icon(sport.icon, size: 22, color: color),
        ),
      ),
    );
  }
}
