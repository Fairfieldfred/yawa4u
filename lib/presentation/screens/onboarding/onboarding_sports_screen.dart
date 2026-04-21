import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../widgets/cardio/sport_badge.dart';

/// Step 3 of onboarding (Profile → Equipment → Sports → Terminology).
///
/// Collects which sports the user plans to track so subsequent UI can
/// default sensibly — cycle creator's primary sport, per-sport unit
/// choices, and (eventually) which cardio surfaces to show on the home
/// tab. Multi-select; Strength is pre-selected because the app's heritage
/// is lifting and every user is assumed to be interested unless they
/// explicitly deselect.
class OnboardingSportsScreen extends ConsumerStatefulWidget {
  const OnboardingSportsScreen({super.key});

  @override
  ConsumerState<OnboardingSportsScreen> createState() =>
      _OnboardingSportsScreenState();
}

class _OnboardingSportsScreenState
    extends ConsumerState<OnboardingSportsScreen> {
  final Set<Sport> _selected = {Sport.strength};
  bool _saving = false;

  static const _choices = [
    Sport.strength,
    Sport.run,
    Sport.bike,
    Sport.swim,
  ];

  void _toggle(Sport sport) {
    setState(() {
      if (_selected.contains(sport)) {
        // Keep at least one sport selected. Strength is the default.
        if (_selected.length == 1) return;
        _selected.remove(sport);
      } else {
        _selected.add(sport);
      }
    });
  }

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);
    final service = ref.read(onboardingServiceProvider);
    await service.setSelectedSports(_selected.toList());

    // Seed per-sport unit preferences based on endurance conventions for
    // any newly-enabled sport. The user can override later in
    // Settings → Units.
    for (final sport in _selected) {
      final defaultUnits = _defaultUnitFor(sport, service.useMetric);
      await service.setUnitsFor(sport, defaultUnits);
    }

    if (!mounted) return;
    context.push('/onboarding/terminology');
  }

  UnitSystem _defaultUnitFor(Sport sport, bool userUseMetric) {
    switch (sport) {
      case Sport.run:
        // Runners in the US-heavy user base default to miles, but respect
        // the user's global metric preference if they set it explicitly.
        return userUseMetric ? UnitSystem.metric : UnitSystem.imperial;
      case Sport.bike:
        // Cycling world overwhelmingly uses km.
        return UnitSystem.metric;
      case Sport.swim:
        // Pool swimming is meters / yards; bias metric.
        return UnitSystem.metric;
      case Sport.strength:
      case Sport.other:
        return userUseMetric ? UnitSystem.metric : UnitSystem.imperial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your sports'),
        centerTitle: true,
        bottom: const _OnboardingProgress(step: 3, total: 4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Which sports do you train?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick all that apply. You can add more later in Settings.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final sport in _choices)
                      _SportTile(
                        sport: sport,
                        selected: _selected.contains(sport),
                        onToggle: () => _toggle(sport),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _continue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({
    required this.sport,
    required this.selected,
    required this.onToggle,
  });

  final Sport sport;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = sport.color;
    final border = selected ? color : Colors.transparent;
    final bg = selected
        ? color.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                SportBadge(sport: sport),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _descriptionFor(sport),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? color
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _descriptionFor(Sport sport) {
    switch (sport) {
      case Sport.strength:
        return 'Lifting, hypertrophy, powerlifting';
      case Sport.run:
        return 'Running, treadmill, trail';
      case Sport.bike:
        return 'Road, trainer, MTB, spin (Peloton)';
      case Sport.swim:
        return 'Pool or open water';
      case Sport.other:
        return 'Other activities';
    }
  }
}

/// Thin 4-step progress indicator shown in the AppBar bottom.
///
/// Phase 5 / batch-1 also applies this to the other onboarding screens
/// so users see "Step N of 4" consistently.
class _OnboardingProgress extends StatelessWidget implements PreferredSizeWidget {
  const _OnboardingProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Size get preferredSize => const Size.fromHeight(8);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: step / total,
      minHeight: 3,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest,
    );
  }
}
