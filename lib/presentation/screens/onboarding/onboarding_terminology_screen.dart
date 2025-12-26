import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/onboarding_providers.dart';

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
}

/// Third onboarding screen - collects user's preferred terminology
class OnboardingTerminologyScreen extends ConsumerStatefulWidget {
  const OnboardingTerminologyScreen({super.key});

  @override
  ConsumerState<OnboardingTerminologyScreen> createState() =>
      _OnboardingTerminologyScreenState();
}

class _OnboardingTerminologyScreenState
    extends ConsumerState<OnboardingTerminologyScreen> {
  TrainingCycleTerm _selectedTerm = TrainingCycleTerm.mesocycle;

  Future<void> _completeOnboarding() async {
    // Save terminology preference
    ref
        .read(userProfileProvider.notifier)
        .updateTrainingCycleTerm(_selectedTerm.name);

    // Mark onboarding as complete
    await ref.read(userProfileProvider.notifier).completeOnboarding();

    // Navigate to plan training cycle screen
    if (mounted) {
      context.go('/plan-trainingCycle');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terminology'), centerTitle: true),
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
                    'What do you call a trainingCycle?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the term you\'re most comfortable with. We\'ll use this throughout the app.',
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
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
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
                                      term.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      term.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
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

            // Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _completeOnboarding,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Get Started'),
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
