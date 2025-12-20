import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/onboarding_providers.dart';
import '../widgets/available_equipment_filter.dart';

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
  }

  Future<void> _saveSettings() async {
    final service = ref.read(onboardingServiceProvider);
    await service.setUseMetric(_useMetric);
    await service.setTrainingCycleTerm(_selectedTerminology);

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
                  'Choose the term you prefer for your trainingCycles',
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
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTerminology = term.name;
                          _hasChanges = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
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

          // Equipment Section (using shared widget)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AvailableEquipmentFilter(compact: false, autoSave: true),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
