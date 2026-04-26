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

/// Sport-picker grid for adding a session.
///
/// The primary "add a session today" affordance in the redesigned
/// Workout tab — see Section A of DESIGN_OPPORTUNITIES.md. Pairs with
/// [CardioSessionCard] to form the building blocks of the redesigned
/// `WorkoutHomeScreen`.
///
/// Renders one box per entry in [sports]. When [sports] is null, the
/// grid falls back to the canonical four — Lift / Run / Bike / Swim —
/// so existing callers and tests don't need to be updated. Pass the
/// user's `selectedSportsProvider` value to honour their onboarding /
/// Settings choice.
class SportGrid extends StatelessWidget {
  final SportGridCallbacks callbacks;
  final SportGridVariant variant;

  /// The sports to render, in display order. Null = fall back to
  /// [_defaultSports]. `Sport.other` is filtered out — there's no box
  /// for it because it has no sport-specific logging flow.
  final List<Sport>? sports;

  const SportGrid({
    super.key,
    this.callbacks = const SportGridCallbacks(),
    this.variant = SportGridVariant.compact,
    this.sports,
  });

  /// Default sport order, used when [sports] is null. Mirrors the four
  /// boxes called out in the design doc and the card list.
  static const _defaultSports = <Sport>[
    Sport.strength,
    Sport.run,
    Sport.bike,
    Sport.swim,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = variant == SportGridVariant.expanded;

    // Resolve which sports to render. Filter out `other` because the
    // grid has no UI affordance for it (no _onLiftPressed / _onCardioPressed
    // equivalent).
    final visibleSports =
        (sports ?? _defaultSports).where((s) => s != Sport.other).toList();

    // Defensive fallback — if the caller passes an empty list (or only
    // `Sport.other`), render nothing rather than an empty grid that
    // would still consume the footer's vertical space.
    if (visibleSports.isEmpty) return const SizedBox.shrink();

    final count = visibleSports.length;

    // Layout chosen by sport count so 1, 2, 3, or 4 sports each look
    // intentional rather than like a missing-item bug:
    //
    //   compact (footer)         | expanded (empty day)
    //   1 sport: 1×1, very wide  | 1×1, square
    //   2 sports: 1×2            | 1×2
    //   3 sports: 1×3            | 1×3
    //   4 sports: 1×4            | 2×2
    final crossAxisCount = isExpanded
        ? (count >= 4 ? 2 : count)
        : count;

    // Aspect ratios: keep each box ≥ 48 px in both axes (Material
    // touch-target minimum) and visually balanced for the count.
    final compactAspect = switch (count) {
      1 => 5.0,
      2 => 2.6,
      3 => 1.8,
      _ => 1.4,
    };
    final expandedAspect = switch (count) {
      1 => 1.6,
      2 => 1.4,
      3 => 1.2,
      _ => 1.15,
    };

    return Padding(
      padding: isExpanded
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
          // Compact footer — minimal padding so the grid sits right
          // above the iOS home indicator without consuming much
          // vertical real estate.
          : const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header is shown only in the expanded (empty-day) variant.
          // Compact footer drops it to keep total height tight — the
          // icon-labelled boxes are self-explanatory.
          if (isExpanded) ...[
            Text(
              'Ready to train?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
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
          ],
          GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: isExpanded ? 8 : 6,
            crossAxisSpacing: isExpanded ? 8 : 6,
            childAspectRatio: isExpanded ? expandedAspect : compactAspect,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final sport in visibleSports)
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
        return 'Strength';
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
            // Compact 1×4 boxes are narrow (~85 px on a typical phone);
            // small spacer + flexible text keeps "Bike"/"Swim" from
            // touching the icon while allowing graceful ellipsis on
            // very narrow screens.
            children: [
              _icon(theme, expanded: false),
              const SizedBox(width: 6),
              Flexible(child: _text(theme, expanded: false)),
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
    final size = expanded ? 48.0 : 28.0;
    final iconSize = expanded ? 26.0 : 16.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: sport.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(expanded ? 12 : 8),
      ),
      child: Icon(sport.icon, size: iconSize, color: sport.color),
    );
  }

  Widget _text(ThemeData theme, {required bool expanded}) {
    return Text(
      _label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: expanded
          ? theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )
          : theme.textTheme.titleMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
    );
  }
}
