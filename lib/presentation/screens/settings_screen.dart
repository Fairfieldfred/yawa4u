import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skins.dart';
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

  // Height and weight controllers
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightLbsController = TextEditingController();
  final _heightCmController = TextEditingController();
  final _weightKgController = TextEditingController();

  // DEXA scan controllers
  final _bodyFatController = TextEditingController();
  final _leanMassController = TextEditingController();
  bool _showDexaFields = false;

  // BMI calculation
  double? _bmi;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightLbsController.dispose();
    _heightCmController.dispose();
    _weightKgController.dispose();
    _bodyFatController.dispose();
    _leanMassController.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final service = ref.read(onboardingServiceProvider);
    _useMetric = service.useMetric;
    _selectedTerminology = service.trainingCycleTerm;

    // Load height and weight
    final heightCm = service.heightCm;
    final weightKg = service.weightKg;

    if (heightCm != null) {
      if (_useMetric) {
        _heightCmController.text = heightCm.toStringAsFixed(0);
      } else {
        final totalInches = heightCm / 2.54;
        final feet = (totalInches / 12).floor();
        final inches = (totalInches % 12).round();
        _heightFeetController.text = feet.toString();
        _heightInchesController.text = inches.toString();
      }
    }

    if (weightKg != null) {
      if (_useMetric) {
        _weightKgController.text = weightKg.toStringAsFixed(1);
      } else {
        final weightLbs = weightKg / 0.453592;
        _weightLbsController.text = weightLbs.toStringAsFixed(1);
      }
    }

    // Load DEXA data
    final bodyFatPercent = service.bodyFatPercent;
    final leanMassKg = service.leanMassKg;

    if (bodyFatPercent != null) {
      _bodyFatController.text = bodyFatPercent.toStringAsFixed(1);
      _showDexaFields = true;
    }

    if (leanMassKg != null) {
      if (_useMetric) {
        _leanMassController.text = leanMassKg.toStringAsFixed(1);
      } else {
        final leanMassLbs = leanMassKg / 0.453592;
        _leanMassController.text = leanMassLbs.toStringAsFixed(1);
      }
      _showDexaFields = true;
    }

    _calculateBmi();
  }

  void _calculateBmi() {
    double? heightCm;
    double? weightKg;

    if (_useMetric) {
      final cm = double.tryParse(_heightCmController.text);
      final kg = double.tryParse(_weightKgController.text);
      if (cm != null && cm > 0 && kg != null && kg > 0) {
        heightCm = cm;
        weightKg = kg;
      }
    } else {
      final feet = int.tryParse(_heightFeetController.text);
      final inches = int.tryParse(_heightInchesController.text) ?? 0;
      final lbs = double.tryParse(_weightLbsController.text);
      if (feet != null && feet > 0 && lbs != null && lbs > 0) {
        final totalInches = (feet * 12) + inches;
        heightCm = totalInches * 2.54;
        weightKg = lbs * 0.453592;
      }
    }

    setState(() {
      if (heightCm != null && weightKg != null) {
        final heightM = heightCm / 100;
        _bmi = weightKg / (heightM * heightM);
      } else {
        _bmi = null;
      }
    });
  }

  Color _getBmiColor(BuildContext context, double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return context.successColor;
    if (bmi < 30) return context.warningColor;
    return context.errorColor;
  }

  void _convertUnits() {
    // Convert values when switching units
    final service = ref.read(onboardingServiceProvider);
    final heightCm = service.heightCm;
    final weightKg = service.weightKg;
    final leanMassKg = service.leanMassKg;

    if (_useMetric) {
      // Converting to metric
      if (heightCm != null) {
        _heightCmController.text = heightCm.toStringAsFixed(0);
      }
      if (weightKg != null) {
        _weightKgController.text = weightKg.toStringAsFixed(1);
      }
      if (leanMassKg != null) {
        _leanMassController.text = leanMassKg.toStringAsFixed(1);
      }
    } else {
      // Converting to imperial
      if (heightCm != null) {
        final totalInches = heightCm / 2.54;
        final feet = (totalInches / 12).floor();
        final inches = (totalInches % 12).round();
        _heightFeetController.text = feet.toString();
        _heightInchesController.text = inches.toString();
      }
      if (weightKg != null) {
        final weightLbs = weightKg / 0.453592;
        _weightLbsController.text = weightLbs.toStringAsFixed(1);
      }
      if (leanMassKg != null) {
        final leanMassLbs = leanMassKg / 0.453592;
        _leanMassController.text = leanMassLbs.toStringAsFixed(1);
      }
    }

    _calculateBmi();
  }

  Future<void> _saveSettings() async {
    final service = ref.read(onboardingServiceProvider);
    await service.setUseMetric(_useMetric);
    await service.setTrainingCycleTerm(_selectedTerminology);

    // Save height and weight
    double? heightCm;
    double? weightKg;

    if (_useMetric) {
      heightCm = double.tryParse(_heightCmController.text);
      weightKg = double.tryParse(_weightKgController.text);
    } else {
      final feet = int.tryParse(_heightFeetController.text);
      final inches = int.tryParse(_heightInchesController.text) ?? 0;
      final lbs = double.tryParse(_weightLbsController.text);
      if (feet != null && feet > 0) {
        final totalInches = (feet * 12) + inches;
        heightCm = totalInches * 2.54;
      }
      if (lbs != null && lbs > 0) {
        weightKg = lbs * 0.453592;
      }
    }

    // Parse DEXA data
    final bodyFatPercent = double.tryParse(_bodyFatController.text);
    double? leanMassKgValue = double.tryParse(_leanMassController.text);
    // Convert lean mass to kg if using imperial
    if (leanMassKgValue != null && !_useMetric) {
      leanMassKgValue = leanMassKgValue * 0.453592;
    }

    if (heightCm != null && weightKg != null) {
      // Save to both SharedPreferences and database with DEXA data
      await ref
          .read(userProfileProvider.notifier)
          .saveHeightAndWeight(
            heightCm,
            weightKg,
            bodyFatPercent: bodyFatPercent,
            leanMassKg: leanMassKgValue,
          );
    }

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
                      _convertUnits();
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Height & Weight Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Body Measurements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your measurements to track BMI over time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Height input
                if (_useMetric) ...[
                  // Metric height (cm)
                  TextFormField(
                    controller: _heightCmController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) {
                      _calculateBmi();
                      setState(() => _hasChanges = true);
                    },
                  ),
                ] else ...[
                  // Imperial height (ft/in)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFeetController,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            suffixText: 'ft',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) {
                            _calculateBmi();
                            setState(() => _hasChanges = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _heightInchesController,
                          decoration: const InputDecoration(
                            labelText: '',
                            suffixText: 'in',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) {
                            _calculateBmi();
                            setState(() => _hasChanges = true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Weight input
                TextFormField(
                  controller: _useMetric
                      ? _weightKgController
                      : _weightLbsController,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    suffixText: _useMetric ? 'kg' : 'lbs',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (_) {
                    _calculateBmi();
                    setState(() => _hasChanges = true);
                  },
                ),
                const SizedBox(height: 16),

                // BMI display
                if (_bmi != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current BMI',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getBmiColor(
                              context,
                              _bmi!,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getBmiColor(context, _bmi!),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _bmi!.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getBmiColor(context, _bmi!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // DEXA Scan Results (Optional - collapsible)
                InkWell(
                  onTap: () {
                    setState(() {
                      _showDexaFields = !_showDexaFields;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.biotech_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEXA Scan Results',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Optional - for bodybuilders',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showDexaFields
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),

                // DEXA fields (shown when expanded)
                if (_showDexaFields) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bodyFatController,
                          decoration: const InputDecoration(
                            labelText: 'Body Fat',
                            suffixText: '%',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          onChanged: (_) {
                            setState(() => _hasChanges = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _leanMassController,
                          decoration: InputDecoration(
                            labelText: 'Lean Mass',
                            suffixText: _useMetric ? 'kg' : 'lbs',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          onChanged: (_) {
                            setState(() => _hasChanges = true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
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
                RadioGroup<String>(
                  groupValue: _selectedTerminology,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTerminology = value;
                        _hasChanges = true;
                      });
                    }
                  },
                  child: Column(
                    children: TrainingCycleTerm.values.map((term) {
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
                                  activeColor: context.selectedIndicatorColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                    }).toList(),
                  ),
                ),
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
