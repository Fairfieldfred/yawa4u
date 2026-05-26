import 'package:flutter/material.dart';

/// Reusable empty-state placeholder shown when a screen or section has no data.
///
/// Provides a consistent look across the app: a large decorative icon, a title,
/// an optional body paragraph, and up to two action buttons (primary + secondary).
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconSize = 72,
    this.primaryAction,
    this.secondaryAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
  });

  /// Decorative icon shown above the title.
  final IconData icon;

  /// Short heading (e.g. "No exercises scheduled").
  final String title;

  /// Optional supporting copy below the title.
  final String? subtitle;

  /// Icon tint. Defaults to `primary` at 50 % alpha.
  final Color? iconColor;

  /// Icon size. Defaults to 72.
  final double iconSize;

  /// Primary CTA rendered as a [FilledButton.icon].
  final EmptyStateAction? primaryAction;

  /// Secondary CTA rendered as an [OutlinedButton.icon].
  final EmptyStateAction? secondaryAction;

  /// Outer padding. Defaults to horizontal 32.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.5);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: effectiveIconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (primaryAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: primaryAction!.onPressed,
                icon: Icon(primaryAction!.icon),
                label: Text(primaryAction!.label),
              ),
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: secondaryAction!.onPressed,
                icon: Icon(secondaryAction!.icon),
                label: Text(secondaryAction!.label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Label + icon + callback for an [EmptyStateWidget] action button.
class EmptyStateAction {
  const EmptyStateAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}
