import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/theme_provider.dart';

/// Mesocycle list screen - organized by Draft/Current/Completed
class MesocycleListScreen extends ConsumerStatefulWidget {
  const MesocycleListScreen({super.key});

  @override
  ConsumerState<MesocycleListScreen> createState() =>
      _MesocycleListScreenState();
}

class _MesocycleListScreenState extends ConsumerState<MesocycleListScreen> {
  @override
  Widget build(BuildContext context) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesocycles'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              ref.watch(isDarkModeProvider)
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: 'Toggle theme',
          ),
          // New mesocycle button
          TextButton.icon(
            onPressed: () => _showPlanMesocycleModal(context),
            icon: const Icon(Icons.add),
            label: const Text('New'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: mesocyclesAsync.when(
        data: (mesocycles) {
          if (mesocycles.isEmpty) {
            return _buildEmptyState(context);
          }

          // Separate mesocycles by status
          final draftMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.draft)
              .toList();
          final currentMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.current)
              .toList();
          final completedMesocycles = mesocycles
              .where((m) => m.status == MesocycleStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Draft Mesocycles Section
              if (draftMesocycles.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Draft Mesocycles',
                  'Continue editing',
                ),
                const SizedBox(height: 12),
                ...draftMesocycles.map(
                  (mesocycle) =>
                      _buildMesocycleCard(context, mesocycle, isDraft: true),
                ),
                const SizedBox(height: 24),
              ],

              // Current Mesocycle Section
              if (currentMesocycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Current Mesocycle', ''),
                const SizedBox(height: 12),
                ...currentMesocycles.map(
                  (mesocycle) =>
                      _buildMesocycleCard(context, mesocycle, isCurrent: true),
                ),
                const SizedBox(height: 24),
              ],

              // Completed Mesocycles Section
              if (completedMesocycles.isNotEmpty) ...[
                _buildSectionHeader(context, 'Completed Mesocycles', ''),
                const SizedBox(height: 12),
                ...completedMesocycles.map(
                  (mesocycle) => _buildMesocycleCard(context, mesocycle),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading mesocycles: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMesocycleCard(
    BuildContext context,
    Mesocycle mesocycle, {
    bool isDraft = false,
    bool isCurrent = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/mesocycles/${mesocycle.id}/workouts'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      mesocycle.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDraft)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteMesocycle(mesocycle),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete draft',
                    ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CURRENT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.weeksTotal} weeks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.daysPerWeek} days/week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${(mesocycle.getProgress() * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mesocycle.getProgress(),
                      minHeight: 8,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrent || isDraft
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Mesocycles',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first mesocycle to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showPlanMesocycleModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Mesocycle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMesocycle(Mesocycle mesocycle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft Mesocycle'),
        content: Text(
          'Are you sure you want to delete "${mesocycle.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(mesocycleRepositoryProvider);
        await repository.delete(mesocycle.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${mesocycle.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting mesocycle: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showPlanMesocycleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'Plan a mesocycle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PlanOption(
                    icon: Icons.copy_outlined,
                    iconColor: Colors.pink,
                    title: 'Copy a mesocycle',
                    subtitle:
                        'Ensure long-term progressive overload by keeping your training similar over time.',
                    badge: '✨',
                    onTap: () {
                      // TODO: Navigate to copy mesocycle screen
                    },
                  ),
                  const SizedBox(height: 16),
                  _PlanOption(
                    icon: Icons.play_arrow,
                    iconColor: Colors.purple,
                    title: 'Resume plan in progress',
                    subtitle: 'Pick up where you left off.',
                    onTap: () {
                      // TODO: Navigate to resume plan screen
                    },
                  ),
                  const SizedBox(height: 16),
                  _PlanOption(
                    icon: Icons.grid_view_outlined,
                    iconColor: Colors.blue,
                    title: 'Start with a template',
                    subtitle:
                        'Pick a template that fits your goals and get started ASAP.',
                    onTap: () {
                      // TODO: Navigate to template selection screen
                    },
                  ),
                  const SizedBox(height: 16),
                  _PlanOption(
                    icon: Icons.science_outlined,
                    iconColor: Colors.cyan,
                    title: 'Meso Builder',
                    subtitle:
                        'Build a meso based on your muscle group priorities.',
                    badge: '🧪',
                    onTap: () {
                      // TODO: Navigate to meso builder screen
                    },
                  ),
                  const SizedBox(height: 16),
                  _PlanOption(
                    icon: Icons.note_outlined,
                    iconColor: Colors.teal,
                    title: 'Start from scratch',
                    subtitle:
                        'Build your own meso from a completely blank slate.',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/mesocycles/create');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _PlanOption({
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
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
