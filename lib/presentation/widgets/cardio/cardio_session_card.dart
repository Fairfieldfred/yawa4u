import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../data/models/session.dart';
import '../../../domain/providers/onboarding_providers.dart';

/// Callbacks used by [CardioSessionCard].
///
/// Mirrors the shape of `ExerciseCardCallbacks` so a screen bundling
/// both card types into one list can hand the same callback-object
/// pattern to each. Every callback is nullable; null = hide or disable
/// the corresponding affordance.
@immutable
class CardioSessionCardCallbacks {
  /// Primary CTA: opens the session editor. For planned sessions this
  /// is "Log session"; for completed sessions it's "View details."
  final void Function(String sessionId)? onPrimary;

  /// Secondary CTA on completed sessions — opens the feedback editor
  /// (RPE / enjoyment / notes).
  final void Function(String sessionId)? onAddFeedback;

  /// Opens the note editor. Shown in the footer on planned cards.
  final void Function(String sessionId)? onAddNote;

  /// Move this session up in the day's card list.
  final void Function(String sessionId)? onMoveUp;

  /// Move this session down in the day's card list.
  final void Function(String sessionId)? onMoveDown;

  /// Delete this session. Screen is responsible for the Undo-snackbar.
  final void Function(String sessionId)? onDelete;

  /// Expand the intervals row in-place (or open a detail sheet).
  final void Function(String sessionId)? onViewIntervals;

  const CardioSessionCardCallbacks({
    this.onPrimary,
    this.onAddFeedback,
    this.onAddNote,
    this.onMoveUp,
    this.onMoveDown,
    this.onDelete,
    this.onViewIntervals,
  });
}

/// Visual sibling of `ExerciseCardWidget` for cardio sessions.
///
/// Matches the outer shape of the exercise card (full-width container
/// using `cardTheme.color`, 16-16-16-4 padding, same header/footer
/// rhythm) so a mixed scroll of strength exercises and cardio sessions
/// reads as a single list of sibling cards. Inner content diverges:
/// strength cards render sets rows, cardio cards render target
/// (planned) or actual metrics (completed).
///
/// Three render paths:
///   * Planned (incomplete, status != completed) — TARGET row,
///     optional intervals expansion, "Log session" primary button.
///   * Completed (user-logged) — MetricsHero + MetricsSub, "Add
///     feedback" secondary button.
///   * Completed (imported from HealthKit / Strava / Peloton / etc.) —
///     same as above plus a source pill under the title.
///
/// Swim sessions substitute pool-specific metrics (pool length, SWOLF,
/// stroke type, lap count) for the run/bike elevation/pace row.
class CardioSessionCard extends ConsumerWidget {
  final CardioSession session;
  final CardioSessionCardCallbacks callbacks;

  const CardioSessionCard({
    super.key,
    required this.session,
    this.callbacks = const CardioSessionCardCallbacks(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingServiceProvider);
    final units = onboarding.unitsFor(session.sport);
    final theme = Theme.of(context);

    final isCompleted = session.status == WorkoutStatus.completed;
    final isExternal = session.source.isExternal;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme, isExternal),
            const SizedBox(height: 12),
            if (!isCompleted)
              _buildPlannedBody(context, theme, units)
            else
              _buildCompletedBody(context, theme, units),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 8),
            _buildFooter(context, theme, isCompleted),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isExternal,
  ) {
    final sport = session.sport;
    final title = session.label?.trim().isNotEmpty == true
        ? session.label!
        : sport.displayName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SportIconTile(sport: sport),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                sport.displayName.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (isExternal)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _SourceBadge(source: session.source),
                ),
            ],
          ),
        ),
        _OverflowMenu(
          sessionId: session.id,
          callbacks: callbacks,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body — planned variant
  // ---------------------------------------------------------------------------

  Widget _buildPlannedBody(
    BuildContext context,
    ThemeData theme,
    UnitSystem units,
  ) {
    final detail = session.detail;
    final bits = <String>[];
    if (detail?.plannedDistanceM != null && detail!.plannedDistanceM! > 0) {
      final formatted = session.sport == Sport.swim
          ? CardioConversions.formatSwimDistance(
              detail.plannedDistanceM!, units,
            )
          : CardioConversions.formatDistance(
              detail.plannedDistanceM!, units,
            );
      bits.add(formatted);
    }
    if (detail?.plannedDurationSec != null && detail!.plannedDurationSec! > 0) {
      bits.add(CardioConversions.formatDuration(detail.plannedDurationSec!));
    }
    final intervalCount = session.intervals.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TARGET',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),
        if (bits.isEmpty)
          Text(
            'No target set',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          )
        else
          Text(
            bits.join('  ·  '),
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (intervalCount > 0) ...[
          const SizedBox(height: 10),
          _IntervalsRow(
            count: intervalCount,
            onTap: callbacks.onViewIntervals == null
                ? null
                : () => callbacks.onViewIntervals!(session.id),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body — completed variant
  // ---------------------------------------------------------------------------

  Widget _buildCompletedBody(
    BuildContext context,
    ThemeData theme,
    UnitSystem units,
  ) {
    final detail = session.detail;
    final isSwim = session.sport == Sport.swim;

    // Hero row: three biggest metrics.
    final hero = <_HeroMetricData>[];
    if (detail != null) {
      if (detail.actualDistanceM != null && detail.actualDistanceM! > 0) {
        hero.add(_HeroMetricData(
          value: isSwim
              ? CardioConversions.formatSwimDistance(
                  detail.actualDistanceM!, units,
                )
              : CardioConversions.formatDistance(
                  detail.actualDistanceM!, units,
                ),
          label: 'Distance',
        ));
      }
      if (detail.actualDurationSec != null && detail.actualDurationSec! > 0) {
        hero.add(_HeroMetricData(
          value: CardioConversions.formatDuration(detail.actualDurationSec!),
          label: 'Duration',
        ));
      }
      if (isSwim) {
        if (detail.swolf != null) {
          hero.add(_HeroMetricData(
            value: detail.swolf.toString(),
            label: 'SWOLF',
          ));
        }
      } else {
        if (detail.averagePaceSecPerMeter != null &&
            detail.averagePaceSecPerMeter! > 0) {
          hero.add(_HeroMetricData(
            value: CardioConversions.formatPace(
              detail.averagePaceSecPerMeter!, units,
            ),
            label: units.isMetric ? 'Pace' : 'Pace',
          ));
        } else if (detail.averageSpeedMps != null &&
            detail.averageSpeedMps! > 0) {
          hero.add(_HeroMetricData(
            value: CardioConversions.formatSpeed(
              detail.averageSpeedMps!, units,
            ),
            label: 'Avg speed',
          ));
        }
      }
    }

    // Sub-metrics row.
    final sub = <_SubMetric>[];
    if (detail != null) {
      if (isSwim) {
        if (detail.lapCount != null && detail.lapCount! > 0) {
          sub.add(_SubMetric(label: '', value: '${detail.lapCount} laps'));
        }
        if (detail.poolLengthM != null && detail.poolLengthM! > 0) {
          sub.add(_SubMetric(
            label: 'pool',
            value: CardioConversions.formatSwimDistance(
              detail.poolLengthM!, units,
            ),
          ));
        }
        if (detail.strokeType != null) {
          sub.add(_SubMetric(label: '', value: detail.strokeType!.displayName));
        }
      } else {
        if (detail.elevationGainM != null && detail.elevationGainM! > 0) {
          sub.add(_SubMetric(
            label: '▲',
            value: '${detail.elevationGainM!.toStringAsFixed(0)} m',
          ));
        }
        if (detail.averageHr != null && detail.averageHr! > 0) {
          sub.add(_SubMetric(label: 'avg', value: '${detail.averageHr} bpm'));
        }
        if (detail.maxHr != null && detail.maxHr! > 0) {
          sub.add(_SubMetric(label: 'max', value: '${detail.maxHr} bpm'));
        }
        if (detail.averagePowerWatts != null && detail.averagePowerWatts! > 0) {
          sub.add(_SubMetric(
            label: 'avg',
            value: '${detail.averagePowerWatts!.round()} W',
          ));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hero.isEmpty)
          Text(
            'Completed',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < hero.length; i++) ...[
                Expanded(child: _HeroMetric(data: hero[i])),
                if (i < hero.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final m in sub) _SubMetricChip(data: m),
            ],
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------------

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    bool isCompleted,
  ) {
    if (!isCompleted) {
      // Planned: primary "Log session", secondary "Notes".
      return Row(
        children: [
          FilledButton.icon(
            onPressed: callbacks.onPrimary == null
                ? null
                : () => callbacks.onPrimary!(session.id),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Log session'),
          ),
          const Spacer(),
          if (callbacks.onAddNote != null)
            TextButton.icon(
              onPressed: () => callbacks.onAddNote!(session.id),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Notes'),
            ),
        ],
      );
    }
    // Completed: "✓ Completed" on the left, "Add feedback" on the right.
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          'Completed',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const Spacer(),
        if (callbacks.onAddFeedback != null)
          TextButton.icon(
            onPressed: () => callbacks.onAddFeedback!(session.id),
            icon: const Icon(Icons.sentiment_satisfied, size: 18),
            label: const Text('Add feedback'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SportIconTile extends StatelessWidget {
  final Sport sport;
  const _SportIconTile({required this.sport});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: sport.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(sport.icon, size: 20, color: sport.color),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final SessionSource source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_sync_outlined,
            size: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
          const SizedBox(width: 4),
          Text(
            source.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  final String sessionId;
  final CardioSessionCardCallbacks callbacks;
  const _OverflowMenu({required this.sessionId, required this.callbacks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <PopupMenuEntry<String>>[];
    if (callbacks.onMoveUp != null) {
      items.add(const PopupMenuItem(value: 'move_up', child: Text('Move up')));
    }
    if (callbacks.onMoveDown != null) {
      items.add(
        const PopupMenuItem(value: 'move_down', child: Text('Move down')),
      );
    }
    if (callbacks.onDelete != null) {
      items.add(const PopupMenuItem(value: 'delete', child: Text('Delete')));
    }
    if (items.isEmpty) {
      return const SizedBox(width: 32);
    }
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      itemBuilder: (_) => items,
      onSelected: (v) {
        switch (v) {
          case 'move_up':
            callbacks.onMoveUp?.call(sessionId);
            break;
          case 'move_down':
            callbacks.onMoveDown?.call(sessionId);
            break;
          case 'delete':
            callbacks.onDelete?.call(sessionId);
            break;
        }
      },
    );
  }
}

class _IntervalsRow extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  const _IntervalsRow({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 8),
            Text(
              '$count interval${count == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            if (onTap != null)
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _HeroMetricData {
  final String value;
  final String label;
  const _HeroMetricData({required this.value, required this.label});
}

class _HeroMetric extends StatelessWidget {
  final _HeroMetricData data;
  const _HeroMetric({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          data.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

@immutable
class _SubMetric {
  final String label;
  final String value;
  const _SubMetric({required this.label, required this.value});
}

class _SubMetricChip extends StatelessWidget {
  final _SubMetric data;
  const _SubMetricChip({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Uses Text.rich (not a bare RichText) so `find.text` and
    // `find.textContaining` can still match against the flattened
    // rendered string in widget tests — the finders ignore bare
    // RichText widgets.
    return Text.rich(
      TextSpan(
        children: [
          if (data.label.isNotEmpty) ...[
            TextSpan(text: '${data.label} '),
          ],
          TextSpan(
            text: data.value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
      ),
    );
  }
}
