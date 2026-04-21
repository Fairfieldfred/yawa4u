import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../widgets/cardio/sport_badge.dart';

/// Settings → Units screen.
///
/// Lets the user override the metric / imperial unit preference per sport.
/// Mixing units across sports is a real endurance-world preference (miles
/// for running, km for cycling, meters for swimming is a common combo), so
/// we expose that directly instead of forcing a single global flag.
///
/// Reads + writes through [OnboardingService.unitsFor] and
/// [OnboardingService.setUnitsFor]. The legacy [OnboardingService.useMetric]
/// is used only as a fallback when a sport has no explicit preference.
class UnitsScreen extends ConsumerStatefulWidget {
  const UnitsScreen({super.key});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  /// Sports we show a preference row for. Strength is included so the
  /// screen feels complete even though its units are mostly lbs/kg —
  /// inherited from the existing global useMetric flag.
  static const _sports = [
    Sport.strength,
    Sport.run,
    Sport.bike,
    Sport.swim,
  ];

  Future<void> _setUnits(Sport sport, UnitSystem system) async {
    final service = ref.read(onboardingServiceProvider);
    await service.setUnitsFor(sport, system);
    ref.invalidate(onboardingServiceProvider);
    if (mounted) setState(() {});
  }

  Future<void> _resetAll() async {
    final service = ref.read(onboardingServiceProvider);
    await service.clearPerSportUnits();
    ref.invalidate(onboardingServiceProvider);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(onboardingServiceProvider);
    final overrides = service.perSportUnits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        actions: [
          if (overrides.isNotEmpty)
            TextButton.icon(
              onPressed: _resetAll,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Reset'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Pick units per sport. A row you haven\'t touched follows the '
              'sensible default (run → miles, bike → km, swim → meters), '
              'falling back to your main metric / imperial setting.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          for (final sport in _sports)
            _SportUnitsRow(
              sport: sport,
              current: service.unitsFor(sport),
              isExplicit: overrides.containsKey(sport),
              onChanged: (u) => _setUnits(sport, u),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Strength defaults to your main metric/imperial choice '
              '(${service.useMetric ? 'metric' : 'imperial'}) — change that '
              'in Settings → Profile.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportUnitsRow extends StatelessWidget {
  const _SportUnitsRow({
    required this.sport,
    required this.current,
    required this.isExplicit,
    required this.onChanged,
  });

  final Sport sport;
  final UnitSystem current;
  final bool isExplicit;
  final ValueChanged<UnitSystem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportBadge(sport: sport),
              const SizedBox(width: 10),
              if (!isExplicit)
                Text(
                  '(default)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<UnitSystem>(
            segments: const [
              ButtonSegment<UnitSystem>(
                value: UnitSystem.imperial,
                label: Text('Imperial'),
                icon: Icon(Icons.flag_outlined),
              ),
              ButtonSegment<UnitSystem>(
                value: UnitSystem.metric,
                label: Text('Metric'),
                icon: Icon(Icons.public),
              ),
            ],
            selected: {current},
            onSelectionChanged: (set) => onChanged(set.first),
          ),
        ],
      ),
    );
  }
}
