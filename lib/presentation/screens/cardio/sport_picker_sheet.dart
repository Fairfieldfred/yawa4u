import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';

/// Modal bottom sheet that lets the user pick a [Sport] for a new session.
///
/// Convenience `show` helper returns the selected sport (or null on dismiss).
/// This is the canonical entry point for "Add session" in a cycle — it's
/// invoked from cycle list / home / more screen, then routes onward to
/// either the existing strength flow or the new cardio session screen.
class SportPickerSheet extends StatelessWidget {
  const SportPickerSheet({
    super.key,
    this.title = 'Add a session',
    this.choices = const [Sport.strength, Sport.run, Sport.bike, Sport.swim],
  });

  final String title;
  final List<Sport> choices;

  /// Presents this sheet and returns the chosen sport, or null if dismissed.
  static Future<Sport?> show(
    BuildContext context, {
    String title = 'Add a session',
    List<Sport> choices = const [
      Sport.strength,
      Sport.run,
      Sport.bike,
      Sport.swim,
    ],
  }) {
    return showModalBottomSheet<Sport>(
      context: context,
      showDragHandle: true,
      builder: (context) => SportPickerSheet(title: title, choices: choices),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Which sport is this session?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            for (final sport in choices) ...[
              _SportRow(
                sport: sport,
                onTap: () => Navigator.of(context).pop(sport),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SportRow extends StatelessWidget {
  const _SportRow({required this.sport, required this.onTap});

  final Sport sport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = sport.color;
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(sport.icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  sport.displayName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
