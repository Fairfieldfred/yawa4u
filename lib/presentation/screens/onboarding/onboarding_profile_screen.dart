import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/providers/onboarding_providers.dart';
import 'onboarding_equipment_screen.dart';

/// First onboarding screen - collects user's height and weight
class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();

  bool _useMetric = false;
  final _heightCmController = TextEditingController();
  final _weightKgController = TextEditingController();

  @override
  void dispose() {
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    _heightCmController.dispose();
    _weightKgController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      double heightCm;
      double weightKg;

      if (_useMetric) {
        heightCm = double.parse(_heightCmController.text);
        weightKg = double.parse(_weightKgController.text);
      } else {
        final feet = int.parse(_heightFeetController.text);
        final inches = int.tryParse(_heightInchesController.text) ?? 0;
        final totalInches = (feet * 12) + inches;
        heightCm = totalInches * 2.54;
        final weightLbs = double.parse(_weightController.text);
        weightKg = weightLbs * 0.453592;
      }

      // Save to provider and navigate
      ref
          .read(userProfileProvider.notifier)
          .updateProfile(heightCm, weightKg, _useMetric);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const OnboardingEquipmentScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('About You'), centerTitle: true),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Let\'s get to know you',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This helps us personalize your experience and track your progress.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Unit toggle
                    Row(
                      children: [
                        const Text('Units:'),
                        const SizedBox(width: 16),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Imperial'),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Metric'),
                            ),
                          ],
                          selected: {_useMetric},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _useMetric = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Height input
                    Text(
                      'Height',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_useMetric)
                      TextFormField(
                        controller: _heightCmController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Centimeters',
                          suffixText: 'cm',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          final cm = int.tryParse(value);
                          if (cm == null || cm < 100 || cm > 250) {
                            return 'Please enter a valid height (100-250 cm)';
                          }
                          return null;
                        },
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightFeetController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Feet',
                                suffixText: 'ft',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final feet = int.tryParse(value);
                                if (feet == null || feet < 3 || feet > 8) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightInchesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Inches',
                                suffixText: 'in',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final inches = int.tryParse(value);
                                  if (inches == null ||
                                      inches < 0 ||
                                      inches > 11) {
                                    return 'Invalid';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Weight input
                    Text(
                      'Weight',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _useMetric
                          ? _weightKgController
                          : _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: _useMetric ? 'Kilograms' : 'Pounds',
                        suffixText: _useMetric ? 'kg' : 'lbs',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null) {
                          return 'Please enter a valid number';
                        }
                        if (_useMetric) {
                          if (weight < 30 || weight > 300) {
                            return 'Please enter a valid weight (30-300 kg)';
                          }
                        } else {
                          if (weight < 66 || weight > 660) {
                            return 'Please enter a valid weight (66-660 lbs)';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _continue,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Continue'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
