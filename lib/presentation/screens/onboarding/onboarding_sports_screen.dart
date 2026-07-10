import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/cardio/sport_badge.dart';

/// Step 2 of onboarding (Profile → Sports → Equipment → Terminology).
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
  ConsumerState<OnboardingSportsScreen> createState() => _OnboardingSportsScreenState();
}

class _OnboardingSportsScreenState extends ConsumerState<OnboardingSportsScreen> {
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
    // Equipment only matters for strength training — skip it otherwise.
    if (_selected.contains(Sport.strength)) {
      context.push('/onboarding/equipment');
    } else {
      context.push('/onboarding/terminology');
    }
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingSportsTitle),
        centerTitle: true,
        bottom: const _OnboardingProgress(step: 2, total: 4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingSportsHeadline,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingSportsSubtitle,
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
                        : Text(l10n.continueButton),
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
    final l10n = AppLocalizations.of(context)!;
    final color = sport.color;
    final border = selected ? color : Colors.transparent;
    final bg = selected ? color.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surfaceContainerHighest;

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
                    _descriptionFor(sport, l10n),
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
                  child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _descriptionFor(Sport sport, AppLocalizations l10n) {
    switch (sport) {
      case Sport.strength:
        return l10n.sportDescriptionStrength;
      case Sport.run:
        return l10n.sportDescriptionRun;
      case Sport.bike:
        return l10n.sportDescriptionBike;
      case Sport.swim:
        return l10n.sportDescriptionSwim;
      case Sport.other:
        return l10n.sportDescriptionOther;
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
