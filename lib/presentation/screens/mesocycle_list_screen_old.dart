import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../navigation/app_router.dart';

/// Mesocycle list screen - shows all mesocycles
class MesocycleListScreen extends ConsumerWidget {
  const MesocycleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesocyclesAsync = ref.watch(mesocyclesProvider);
    final currentMesocycle = ref.watch(currentMesocycleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
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
        ],
      ),
      body: mesocyclesAsync.when(
        data: (mesocycles) {
          if (mesocycles.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              // Current mesocycle card (if exists)
              if (currentMesocycle != null)
                _CurrentMesocycleCard(mesocycle: currentMesocycle),

              // List header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Mesocycles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${mesocycles.length} total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Mesocycle list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: mesocycles.length,
                  itemBuilder: (context, index) {
                    final mesocycle = mesocycles[index];
                    return _MesocycleCard(
                      mesocycle: mesocycle,
                      isCurrent: mesocycle.id == currentMesocycle?.id,
                    );
                  },
                ),
              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.mesocycleCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Mesocycle'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Mesocycles Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first mesocycle to start tracking\nyour workout progress',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.mesocycleCreate),
            icon: const Icon(Icons.add),
            label: const Text('Create Mesocycle'),
          ),
        ],
      ),
    );
  }
}

/// Current mesocycle card widget
class _CurrentMesocycleCard extends StatelessWidget {
  final Mesocycle mesocycle;

  const _CurrentMesocycleCard({required this.mesocycle});

  @override
  Widget build(BuildContext context) {
    final progress = mesocycle.getProgress();
    final currentWeek = mesocycle.getCurrentWeek();

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: InkWell(
        onTap: () => context.push(
          '/mesocycles/${mesocycle.id}/workouts',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mesocycle.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentWeek != null
                        ? 'Week $currentWeek of ${mesocycle.weeksTotal}'
                        : '${mesocycle.weeksTotal} weeks',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mesocycle.daysPerWeek} days/week',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mesocycle card widget
class _MesocycleCard extends StatelessWidget {
  final Mesocycle mesocycle;
  final bool isCurrent;

  const _MesocycleCard({
    required this.mesocycle,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = mesocycle.getProgress();
    final statusColor = _getStatusColor(context, mesocycle.status);
    final statusLabel = mesocycle.status.toString().split('.').last.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => context.push('/mesocycles/${mesocycle.id}/workouts'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mesocycle.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${mesocycle.weeksTotal} weeks',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${mesocycle.daysPerWeek} days/week',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, MesocycleStatus status) {
    switch (status) {
      case MesocycleStatus.current:
        return Theme.of(context).colorScheme.primary;
      case MesocycleStatus.completed:
        return Colors.green;
      case MesocycleStatus.draft:
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }
}
