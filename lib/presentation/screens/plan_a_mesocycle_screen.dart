import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';

/// Plan a mesocycle screen - Shows different options for creating a mesocycle
class PlanAMesocycleScreen extends ConsumerStatefulWidget {
  const PlanAMesocycleScreen({super.key});

  @override
  ConsumerState<PlanAMesocycleScreen> createState() =>
      _PlanAMesocycleScreenState();
}

class _PlanAMesocycleScreenState extends ConsumerState<PlanAMesocycleScreen> {
  final int _selectedIndex = 1; // Keep on Mesocycles tab

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      // Navigate back to home and switch tab
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Plan a mesocycle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            _OptionCard(
              icon: Icons.copy_outlined,
              iconColor: Colors.pink,
              title: 'Copy a mesocycle',
              subtitle:
                  'Ensure long-term progressive overload by keeping your training similar over time.',
              badge: '✨',
              onTap: () {
                // Navigate to copy mesocycle screen
              },
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.play_arrow,
              iconColor: Colors.purple,
              title: 'Resume plan in progress',
              subtitle: 'Pick up where you left off.',
              onTap: () {
                // Navigate to resume plan screen
              },
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.grid_view_outlined,
              iconColor: Colors.blue,
              title: 'Start with a template',
              subtitle:
                  'Pick a template that fits your goals and get started ASAP.',
              onTap: () {
                // Navigate to template selection screen
              },
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.science_outlined,
              iconColor: Colors.cyan,
              title: 'Meso Builder',
              subtitle: 'Build a meso based on your muscle group priorities.',
              badge: '🧪',
              onTap: () {
                // Navigate to meso builder screen
              },
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.note_outlined,
              iconColor: Colors.teal,
              title: 'Start from scratch',
              subtitle: 'Build your own meso from a completely blank slate.',
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
            label: 'Mesocycles',
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

  Future<void> _handleStartFromScratch() async {
    // Check if there's a draft mesocycle
    final mesocycles = await ref.read(mesocyclesProvider.future);
    final draftMesocycles = mesocycles
        .where((m) => m.status == MesocycleStatus.draft)
        .toList();

    if (!mounted) return;

    if (draftMesocycles.isNotEmpty) {
      // Show warning dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  'You have a draft mesocycle plan already in progress. By starting a new mesocycle, your draft will be overwritten.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This will delete your current draft mesocycle plan.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
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
                          backgroundColor: Colors.red,
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
        // Delete all draft mesocycles
        try {
          final repository = ref.read(mesocycleRepositoryProvider);
          for (final draft in draftMesocycles) {
            await repository.delete(draft.id);
          }

          if (mounted) {
            // Navigate to create screen
            context.push('/mesocycles/create');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting draft: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      // No drafts, go directly to create screen
      context.push('/mesocycles/create');
    }
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
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
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Text(badge!, style: const TextStyle(fontSize: 16)),
                        ],
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
