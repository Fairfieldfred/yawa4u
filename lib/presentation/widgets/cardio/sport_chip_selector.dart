import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';

/// Horizontal row of sport chips used for picking a sport.
///
/// Renders a [FilterChip] per sport in [choices]. Visual style: selected
/// chips fill with the sport's accent color; unselected chips show the icon
/// in muted tone. Designed to sit comfortably in a bottom sheet or at the
/// top of a form.
class SportChipSelector extends StatelessWidget {
  const SportChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.choices = const [Sport.strength, Sport.run, Sport.bike, Sport.swim],
    this.padding = EdgeInsets.zero,
  });

  final Sport? selected;
  final ValueChanged<Sport> onChanged;
  final List<Sport> choices;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final sport in choices)
            _SportChip(
              sport: sport,
              isSelected: sport == selected,
              onTap: () => onChanged(sport),
            ),
        ],
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({
    required this.sport,
    required this.isSelected,
    required this.onTap,
  });

  final Sport sport;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = sport.color;
    final bg = isSelected
        ? color.withValues(alpha: 0.18)
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final border = isSelected ? color : Colors.transparent;
    final textColor = isSelected
        ? color
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sport.icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              sport.displayName,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
