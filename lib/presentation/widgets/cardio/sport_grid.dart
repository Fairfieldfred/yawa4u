import 'package:flutter/material.dart';

import '../../../core/constants/sports.dart';

/// Callbacks fired when the user taps a box in [SportGrid].
///
/// Each callback receives the tapped [Sport]. Screens implement the
/// "what happens next" — typically:
///   * `onLift` → ensure a StrengthSession exists for the current
///     (cycle, period, day), then push `AddExerciseScreen`.
///   * `onRun` / `onBike` / `onSwim` → push
///     `/cardio-session/new?sport=<sport>` with cycle/period/day params.
///
/// A single-tap callback is provided so screens that want a unified
/// handler can pattern-match on `sport`. Per-sport callbacks are
/// provided too so screens can hide specific boxes by leaving them
/// null (useful for future "strength-only cycle hides cardio boxes"
/// variations).
@immutable
class SportGridCallbacks {
  final void Function(Sport sport)? onTap;
  final VoidCallback? onLift;
  final VoidCallback? onRun;
  final VoidCallback? onBike;
  final VoidCallback? onSwim;

  const SportGridCallbacks({
    this.onTap,
    this.onLift,
    this.onRun,
    this.onBike,
    this.onSwim,
  });
}

/// Layout variants of [SportGrid].
///
///   * [compact] — pinned footer under the day's card list. Horizontal
///     layout inside each box (icon + label side by side), tight
///     padding, small header strip. Designed to sit above the iOS
///     home indicator without consuming too much vertical real estate.
///   * [expanded] — fills the available space on an empty-day screen.
///     Larger tap targets, vertical layout inside each box (icon
///     stacked above label), centered in its parent. Designed to be
///     the only content when a day has no scheduled sessions.
enum SportGridVariant { compact, expanded }

/// Four-box sport-picker grid: Lift / Run / Bike / Swim.
///
/// The primary "add a session today" affordance in the redesigned
/// Workout tab — see Section A of DESIGN_OPPORTUNITIES.md. Pairs with
/// [CardioSessionCard] to form the building blocks of the redesigned
/// `WorkoutHomeScreen`.
class SportGrid extends StatelessWidget {
  final SportGridCallbacks callbacks;
  final SportGridVariant variant;

  const SportGrid({
    super.key,
    this.callbacks = const SportGridCallbacks(),
    this.variant = SportGridVariant.compact,
  });

  /// Fixed sport order: strength, run, bike, swim. Mirrors the four
  /// boxes called out in the design doc and the card list.
  static const _sportsInOrder = <Sport>[
    Sport.strength,
    Sport.run,
    Sport.bike,
    Sport.swim,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = variant == SportGridVariant.expanded;

    return Padding(
      padding: isExpanded
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
          : const EdgeInsets.fromLTRB(12, 10, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isExpanded ? 'Ready to train?' : 'ADD SESSION',
            textAlign: isExpanded ? TextAlign.center : TextAlign.center,
            style: isExpanded
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 4),
            Text(
              'Pick a sport to add today\'s session.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 24),
          ] else
            const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            // Fixed aspect ratios keep the boxes tall enough to hit
            // comfortably without blowing out the footer height.
            childAspectRatio: isExpanded ? 1.15 : 2.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final sport in _sportsInOrder)
                _SportBox(
                  sport: sport,
                  variant: variant,
                  onTap: () => _dispatch(sport),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _dispatch(Sport sport) {
    callbacks.onTap?.call(sport);
    switch (sport) {
      case Sport.strength:
        callbacks.onLift?.call();
        break;
      case Sport.run:
        callbacks.onRun?.call();
        break;
      case Sport.bike:
        callbacks.onBike?.call();
        break;
      case Sport.swim:
        callbacks.onSwim?.call();
        break;
      case Sport.other:
        // "Other" is not in the grid.
        break;
    }
  }
}

/// Private — one tappable box in the grid.
class _SportBox extends StatelessWidget {
  final Sport sport;
  final SportGridVariant variant;
  final VoidCallback onTap;

  const _SportBox({
    required this.sport,
    required this.variant,
    required this.onTap,
  });

  /// User-facing label. For strength we show "Lift" instead of the
  /// enum's "Strength" because the grid is action-shaped ("tap to
  /// lift") and "Lift" is what the UX review called for.
  String get _label {
    switch (sport) {
      case Sport.strength:
        return 'Lift';
      case Sport.run:
        return 'Run';
      case Sport.bike:
        return 'Bike';
      case Sport.swim:
        return 'Swim';
      case Sport.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = variant == SportGridVariant.expanded;

    final child = isExpanded
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(theme, expanded: true),
              const SizedBox(height: 10),
              _text(theme, expanded: true),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _icon(theme, expanded: false),
              const SizedBox(width: 10),
              _text(theme, expanded: false),
            ],
          );

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.6,
      ),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Semantics(
            button: true,
            label: 'Add a $_label session',
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _icon(ThemeData theme, {required bool expanded}) {
    final size = expanded ? 48.0 : 32.0;
    final iconSize = expanded ? 26.0 : 18.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: sport.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(expanded ? 12 : 10),
      ),
      child: Icon(sport.icon, size: iconSize, color: sport.color),
    );
  }

  Widget _text(ThemeData theme, {required bool expanded}) {
    return Text(
      _label,
      style: expanded
          ? theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )
          : theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
    );
  }
}
