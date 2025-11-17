import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';

/// Mesocycle list screen - organized by Draft/Current/Completed
class MesocycleListScreen extends ConsumerWidget {
  const MesocycleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => context.push('/mesocycles/create'),
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
                ...draftMesocycles.map((mesocycle) =>
                    _buildMesocycleCard(context, mesocycle, isDraft: true)),
                const SizedBox(height: 24),
              ],

              // Current Mesocycle Section
              if (currentMesocycles.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Current Mesocycle',
                  '',
                ),
                const SizedBox(height: 12),
                ...currentMesocycles.map((mesocycle) =>
                    _buildMesocycleCard(context, mesocycle, isCurrent: true)),
                const SizedBox(height: 24),
              ],

              // Completed Mesocycles Section
              if (completedMesocycles.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Completed Mesocycles',
                  '',
                ),
                const SizedBox(height: 12),
                ...completedMesocycles.map((mesocycle) =>
                    _buildMesocycleCard(context, mesocycle)),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.weeksTotal} weeks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${mesocycle.daysPerWeek} days/week',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                      Text(
                        '${(mesocycle.getProgress() * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
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
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
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
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/mesocycles/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Mesocycle'),
          ),
        ],
      ),
    );
  }
}
