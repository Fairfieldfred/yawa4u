import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/skins/skins.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';
import 'template_selection_screen.dart';

/// Plan a trainingCycle screen - Shows different options for creating a trainingCycle
class PlanATrainingCycleScreen extends ConsumerStatefulWidget {
  const PlanATrainingCycleScreen({super.key});

  @override
  ConsumerState<PlanATrainingCycleScreen> createState() =>
      _PlanATrainingCycleScreenState();
}

class _PlanATrainingCycleScreenState
    extends ConsumerState<PlanATrainingCycleScreen> {
  final int _selectedIndex = 1; // Keep on TrainingCycles tab

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Navigate back to home and switch tab
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycleTerm = ref.watch(trainingCycleTermProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Check if we can pop (i.e., there's a route to go back to)
            // If not (e.g., coming from onboarding), navigate to home
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text('Plan a $cycleTerm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // _OptionCard(
            //   icon: Icons.copy_outlined,
            //   iconColor: Colors.pink,
            //   title: 'Copy a trainingCycle',
            //   subtitle:
            //       'Ensure long-term progressive overload by keeping your training similar over time.',
            //   badge: '✨',
            //   onTap: () {
            //     // Navigate to copy trainingCycle screen
            //   },
            // ),
            // const SizedBox(height: 16),
            // _OptionCard(
            //   icon: Icons.play_arrow,
            //   iconColor: Colors.purple,
            //   title: 'Resume plan in progress',
            //   subtitle: 'Pick up where you left off.',
            //   onTap: () {
            //     // Navigate to resume plan screen
            //   },
            // ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.grid_view_outlined,
              iconColor: Colors.blue,
              title: 'Start with a template',
              subtitle:
                  'Pick a template that fits your goals and get started ASAP.',
              onTap: () => _handleStartWithTemplate(),
            ),

            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.note_outlined,
              iconColor: Colors.teal,
              title: 'Start from scratch',
              subtitle:
                  'Build your own $cycleTerm from a completely blank slate.',
              onTap: () => _handleStartFromScratch(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'TrainingCycles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  /// Shows a warning dialog if there are draft cycles, returns true if should proceed
  Future<bool> _checkAndDeleteDrafts() async {
    final draftTrainingCycles = ref.read(draftTrainingCyclesProvider);

    if (!mounted) return false;

    if (draftTrainingCycles.isEmpty) {
      return true; // No drafts, proceed
    }

    final cycleTerm = ref.read(trainingCycleTermProvider);

    // Show warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have a draft $cycleTerm plan already in progress. By starting a new $cycleTerm, your draft will be overwritten.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final warningColor = context.warningColor;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: warningColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: warningColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This will delete your current draft $cycleTerm plan.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: context.errorColor,
                      ),
                      child: const Text('CONTINUE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      // Delete all draft trainingCycles
      try {
        final repository = ref.read(trainingCycleRepositoryProvider);
        for (final draft in draftTrainingCycles) {
          await repository.delete(draft.id);
        }
        return true; // Proceed after deleting
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting draft: $e'),
              backgroundColor: context.errorColor,
            ),
          );
        }
        return false;
      }
    }

    return false; // User cancelled
  }

  Future<void> _handleStartWithTemplate() async {
    final shouldProceed = await _checkAndDeleteDrafts();
    if (shouldProceed && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const TemplateSelectionScreen(),
        ),
      );
    }
  }

  Future<void> _handleStartFromScratch() async {
    final shouldProceed = await _checkAndDeleteDrafts();
    if (shouldProceed && mounted) {
      context.push('/trainingCycles/create');
    }
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
