import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/cloud_backup_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/auth/email_link_prompt.dart';

/// Training cycle terminology options
enum TrainingCycleTerm {
  block('Block', 'A focused training block with specific goals'),
  mesocycle(
    'Mesocycle',
    'A structured training period typically lasting 3-6 weeks',
  ),
  module('Module', 'A modular training unit that can be stacked'),
  phase('Phase', 'A training phase within your overall program'),
  wave('Wave', 'A wave of progressive training intensity');

  const TrainingCycleTerm(this.displayName, this.description);

  final String displayName;
  final String description;

  /// Localized user-facing name for this terminology option.
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case TrainingCycleTerm.block:
        return l10n.trainingCycleTermBlock;
      case TrainingCycleTerm.mesocycle:
        return l10n.trainingCycleTermMesocycle;
      case TrainingCycleTerm.module:
        return l10n.trainingCycleTermModule;
      case TrainingCycleTerm.phase:
        return l10n.trainingCycleTermPhase;
      case TrainingCycleTerm.wave:
        return l10n.trainingCycleTermWave;
    }
  }

  /// Localized description for this terminology option.
  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case TrainingCycleTerm.block:
        return l10n.trainingCycleTermBlockDesc;
      case TrainingCycleTerm.mesocycle:
        return l10n.trainingCycleTermMesocycleDesc;
      case TrainingCycleTerm.module:
        return l10n.trainingCycleTermModuleDesc;
      case TrainingCycleTerm.phase:
        return l10n.trainingCycleTermPhaseDesc;
      case TrainingCycleTerm.wave:
        return l10n.trainingCycleTermWaveDesc;
    }
  }
}

/// Step 4 of onboarding (Profile → Sports → Equipment → Terminology).
/// Collects the user's preferred terminology; finishing lands on Home.
class OnboardingTerminologyScreen extends ConsumerStatefulWidget {
  const OnboardingTerminologyScreen({super.key});

  @override
  ConsumerState<OnboardingTerminologyScreen> createState() => _OnboardingTerminologyScreenState();
}

class _OnboardingTerminologyScreenState extends ConsumerState<OnboardingTerminologyScreen> {
  TrainingCycleTerm _selectedTerm = TrainingCycleTerm.mesocycle;
  bool _cloudBackupOptIn = false;

  Future<void> _completeOnboarding() async {
    // Save terminology preference
    ref.read(userProfileProvider.notifier).updateTrainingCycleTerm(_selectedTerm.name);

    // Cloud backup opt-in: enable the pref, then ask for the verified email
    // it needs. Cancelling the sheet keeps backup enabled but pending —
    // sign-in can be finished later from the Sync screen. No upload happens
    // here (a fresh install has no data yet); the first backup runs on a
    // later app launch or via "Back up now".
    if (_cloudBackupOptIn) {
      await ref.read(cloudBackupSettingsProvider.notifier).setEnabled(true);
      if (mounted) {
        await showEmailLinkPrompt(context);
      }
    }

    // Mark onboarding as complete
    if (!mounted) return;
    await ref.read(userProfileProvider.notifier).completeOnboarding();

    // Land on Home — the Workout tab's empty state carries the
    // "Create cycle" / "Use template" CTAs, so users aren't forced
    // straight into cycle creation.
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTerminologyTitle),
        centerTitle: true,
        bottom: const _OnboardingProgress(step: 4, total: 4),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingTerminologyHeadline,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingTerminologySubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Terminology options
            Expanded(
              child: RadioGroup<TrainingCycleTerm>(
                groupValue: _selectedTerm,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTerm = value;
                    });
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: TrainingCycleTerm.values.length,
                  itemBuilder: (context, index) {
                    final term = TrainingCycleTerm.values[index];
                    final isSelected = _selectedTerm == term;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTerm = term;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Radio<TrainingCycleTerm>(
                                value: term,
                                activeColor: context.selectedIndicatorColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      term.localizedName(l10n),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      term.localizedDescription(l10n),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Cloud backup opt-in
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  secondary: const Icon(Icons.cloud_upload_outlined),
                  title: Text(l10n.cloudBackupOnboardingTitle),
                  subtitle: Text(l10n.cloudBackupOnboardingSubtitle),
                  value: _cloudBackupOptIn,
                  onChanged: (value) {
                    setState(() {
                      _cloudBackupOptIn = value;
                    });
                  },
                ),
              ),
            ),

            // Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _completeOnboarding,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.getStartedButton),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
