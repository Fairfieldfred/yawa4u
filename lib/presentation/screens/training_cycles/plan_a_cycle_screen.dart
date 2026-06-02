import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';
import 'template_selection_screen.dart';

/// Plan a trainingCycle screen - Shows different options for creating a trainingCycle
class PlanATrainingCycleScreen extends ConsumerStatefulWidget {
  const PlanATrainingCycleScreen({super.key});

  @override
  ConsumerState<PlanATrainingCycleScreen> createState() => _PlanATrainingCycleScreenState();
}

class _PlanATrainingCycleScreenState extends ConsumerState<PlanATrainingCycleScreen> {
  final int _selectedIndex = 1; // Keep on TrainingCycles tab

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Navigate back to home and switch tab
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.planCycleTitle(cycleTerm)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.grid_view_outlined,
              iconColor: Colors.blue,
              title: l10n.planCycleStartWithTemplate,
              subtitle: l10n.planCycleStartWithTemplateSubtitle,
              onTap: () => _handleStartWithTemplate(),
            ),

            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.note_outlined,
              iconColor: Colors.teal,
              title: l10n.planCycleStartFromScratch,
              subtitle: l10n.planCycleStartFromScratchSubtitle(cycleTerm),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_circle_fill),
            label: l10n.navSession,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: l10n.navTrainingCycles,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: l10n.navExercises,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: l10n.navMore),
        ],
      ),
    );
  }

  void _handleStartWithTemplate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TemplateSelectionScreen()),
    );
  }

  void _handleStartFromScratch() {
    context.push('/trainingCycles/create');
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
