import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/sports.dart';
import '../../../data/models/session.dart';
import '../../../domain/providers/session_providers.dart';

/// Small strip that shows a coloured dot per cardio sport that has at
/// least one session scheduled on [date].
///
/// Self-contained: watches [sessionsInDateRangeProvider] for a single-day
/// window and renders nothing if there are no cardio sessions. Safe to
/// drop into any calendar cell layout — the empty case collapses to an
/// effectively invisible [SizedBox.shrink].
class CalendarSportDots extends ConsumerWidget {
  const CalendarSportDots({
    super.key,
    required this.date,
    this.dotSize = 6,
    this.spacing = 3,
  });

  final DateTime date;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final async = ref.watch(sessionsInDateRangeProvider((start: start, end: end)));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (sessions) {
        final sports = _cardioSports(sessions);
        if (sports.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < sports.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: sports[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Sport> _cardioSports(List<Session> sessions) {
    final set = <Sport>{};
    for (final s in sessions) {
      if (s.sport != Sport.strength) set.add(s.sport);
    }
    // Stable ordering so dots don't jiggle between rebuilds.
    final sorted = set.toList()..sort((a, b) => a.index.compareTo(b.index));
    return sorted;
  }
}
