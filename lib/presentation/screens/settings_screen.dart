import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/onboarding_providers.dart';

/// Available equipment options for the user to select
enum EquipmentOption {
  dumbbells('Dumbbells', Icons.fitness_center),
  homeGymRack('Home Gym Rack', Icons.home),
  functionalTrainer('Functional (Cable) Trainer', Icons.cable),
  gymMachines('Gym Machines', Icons.precision_manufacturing),
  barbells('Barbells', Icons.fitness_center_outlined),
  kettlebells('Kettlebells', Icons.sports_mma),
  resistanceBands('Resistance Bands', Icons.show_chart),
  treadmill('Treadmill', Icons.directions_run),
  exerciseBike('Exercise Bike', Icons.directions_bike),
  rowingMachine('Rowing Machine', Icons.rowing),
  lapPool('Lap Pool', Icons.pool),
  crossfitGym('Crossfit Gym', Icons.sports),
  pullUpBar('Pull-up Bar', Icons.accessibility_new),
  suspensionTrainer('Suspension Trainer (TRX)', Icons.swap_vert);

  const EquipmentOption(this.displayName, this.icon);

  final String displayName;
  final IconData icon;
}

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

/// Settings screen for user preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _useMetric;
  late String _selectedTerminology;
  late Set<String> _selectedEquipment;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final service = ref.read(onboardingServiceProvider);
    _useMetric = service.useMetric;
    _selectedTerminology = service.trainingCycleTerm;
    _selectedEquipment = service.equipment.toSet();
  }

  Future<void> _saveSettings() async {
    final service = ref.read(onboardingServiceProvider);
    await service.setUseMetric(_useMetric);
    await service.setTrainingCycleTerm(_selectedTerminology);
    await service.setEquipment(_selectedEquipment.toList());

    // Invalidate providers to refresh the UI
    ref.invalidate(onboardingServiceProvider);
    ref.invalidate(useMetricProvider);
    ref.invalidate(weightUnitProvider);
    ref.invalidate(trainingCycleTermProvider);
    ref.invalidate(trainingCycleTermPluralProvider);

    setState(() {
      _hasChanges = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  void _toggleEquipment(EquipmentOption equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment.name)) {
        _selectedEquipment.remove(equipment.name);
      } else {
        _selectedEquipment.add(equipment.name);
      }
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(onPressed: _saveSettings, child: const Text('Save')),
        ],
      ),
      body: ListView(
        children: [
          // Units Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Units',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Imperial (lbs)'),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Metric (kg)'),
                    ),
                  ],
                  selected: {_useMetric},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _useMetric = selection.first;
                      _hasChanges = true;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Terminology Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Cycle Terminology',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the term you prefer for your training cycles',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ...TrainingCycleTerm.values.map((term) {
                  final isSelected = _selectedTerminology == term.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTerminology = term.name;
                          _hasChanges = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                            Radio<String>(
                              value: term.name,
                              groupValue: _selectedTerminology,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedTerminology = value;
                                    _hasChanges = true;
                                  });
                                }
                              },
                              activeColor: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    term.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
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
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Equipment Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Equipment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select equipment you have access to',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: EquipmentOption.values.length,
                  itemBuilder: (context, index) {
                    final equipment = EquipmentOption.values[index];
                    final isSelected = _selectedEquipment.contains(
                      equipment.name,
                    );

                    return InkWell(
                      onTap: () => _toggleEquipment(equipment),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
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
                            const SizedBox(width: 8),
                            // Checkbox
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.outline,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.red,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              equipment.icon,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                equipment.displayName,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
