import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/rest_timer_provider.dart';
import '../../l10n/app_localizations.dart';

/// Compact rest timer bar shown during workout.
/// Displays a countdown with pause, +30s, and skip controls.
/// Tapping the banner (outside the control buttons) invokes [onTap]
/// with the exercise ID and workout ID that triggered the timer.
class RestTimerWidget extends ConsumerWidget {
  /// Called when the user taps the timer banner.
  /// Parameters are (exerciseId, workoutId) stored in [RestTimerState].
  final void Function(String exerciseId, String workoutId)? onTap;

  const RestTimerWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final timer = ref.watch(restTimerProvider);

    if (!timer.isRunning) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final canTap = onTap != null && timer.exerciseId != null && timer.workoutId != null;

    return Semantics(
      label: l10n.restTimerSemantic(timer.displayTime),
      child: GestureDetector(
        onTap: canTap ? () => onTap!(timer.exerciseId!, timer.workoutId!) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: timer.progress,
                  minHeight: 6,
                  backgroundColor: colorScheme.onPrimaryContainer.withAlpha((255 * 0.15).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Timer display and controls
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.restTimerDisplay(timer.displayTime),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  // Pause / Resume
                  _TimerButton(
                    icon: timer.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    tooltip: timer.isPaused ? l10n.restTimerResume : l10n.restTimerPause,
                    onPressed: () {
                      final notifier = ref.read(restTimerProvider.notifier);
                      timer.isPaused ? notifier.resume() : notifier.pause();
                    },
                    color: colorScheme.onPrimaryContainer,
                  ),
                  // −30s
                  _TimerButton(
                    icon: Icons.remove,
                    tooltip: l10n.restTimerSubtract30,
                    onPressed: () {
                      ref.read(restTimerProvider.notifier).addTime(-30);
                    },
                    color: colorScheme.onPrimaryContainer,
                  ),
                  // +30s
                  _TimerButton(
                    icon: Icons.add,
                    tooltip: l10n.restTimerAdd30,
                    onPressed: () {
                      ref.read(restTimerProvider.notifier).addTime();
                    },
                    color: colorScheme.onPrimaryContainer,
                  ),
                  // Skip
                  _TimerButton(
                    icon: Icons.skip_next_rounded,
                    tooltip: l10n.restTimerSkip,
                    onPressed: () {
                      ref.read(restTimerProvider.notifier).cancel();
                    },
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  const _TimerButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  /// Minimum tap-target edge for one-handed in-gym use (a11y guideline).
  static const double _minHitBox = 44;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: _minHitBox, minHeight: _minHitBox),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
