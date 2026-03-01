import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/skins/skins.dart';
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
    extends ConsumerState<OnboardingProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();

  bool _useMetric = false;
  final _heightCmController = TextEditingController();
  final _weightKgController = TextEditingController();

  // DEXA scan results (optional)
  final _bodyFatController = TextEditingController();
  final _leanMassController = TextEditingController();
  bool _showDexaFields = false;

  // App icon selection
  int _selectedIconIndex = 1; // Default to center (yawa4u-icon)
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _iconPaths = [
    'assets/common/app-icon-dark.png',
    'assets/common/yawa4u-icon-dark.png',
    'assets/common/female-app-icon-dark.png',
  ];

  // BMI calculation
  double? _bmi;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add listeners to recalculate BMI when inputs change
    _heightFeetController.addListener(_calculateBmi);
    _heightInchesController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
    _heightCmController.addListener(_calculateBmi);
    _weightKgController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _heightFeetController.removeListener(_calculateBmi);
    _heightInchesController.removeListener(_calculateBmi);
    _weightController.removeListener(_calculateBmi);
    _heightCmController.removeListener(_calculateBmi);
    _weightKgController.removeListener(_calculateBmi);
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    _heightCmController.dispose();
    _weightKgController.dispose();
    _bodyFatController.dispose();
    _leanMassController.dispose();
    _animationController.dispose();
    super.dispose();
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
      final lbs = double.tryParse(_weightController.text);
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

  // BMI categories with their ranges (in descending order)
  // Colors are computed at runtime to support theming
  List<({String label, double minBmi, double? maxBmi, Color color})>
  _getBmiCategories(BuildContext context) => [
    (label: 'Obese', minBmi: 30, maxBmi: null, color: context.errorColor),
    (label: 'Overweight', minBmi: 25, maxBmi: 30, color: context.warningColor),
    (label: 'Normal', minBmi: 18.5, maxBmi: 25, color: context.successColor),
    (label: 'Underweight', minBmi: 0, maxBmi: 18.5, color: Colors.blue),
  ];

  Widget _buildBmiIndicator() {
    if (_bmi == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'Enter height and weight to see BMI',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final color = _getBmiColor(context, _bmi!);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // BMI category list on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BMI Range',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ..._getBmiCategories(context).map((cat) {
                  final isSelected =
                      _bmi! >= cat.minBmi &&
                      (cat.maxBmi == null || _bmi! < cat.maxBmi!);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cat.color
                                : cat.color.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? cat.color
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.maxBmi == null
                              ? '(${cat.minBmi.toInt()}+)'
                              : '(${cat.minBmi == 0 ? '<' : ''}${cat.minBmi == 0 ? cat.maxBmi!.toStringAsFixed(1) : '${cat.minBmi.toStringAsFixed(1)}-${cat.maxBmi!.toInt()}'})',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? cat.color.withValues(alpha: 0.8)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // BMI circle on the right
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _bmi!.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'BMI',
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectIcon(int index) {
    if (index != _selectedIconIndex) {
      setState(() {
        _selectedIconIndex = index;
      });
      _animationController.forward(from: 0);
    }
  }

  List<int> _getOrderedIndices() {
    // Returns indices ordered so selected is in center
    switch (_selectedIconIndex) {
      case 0:
        return [1, 0, 2]; // Move 0 to center
      case 1:
        return [0, 1, 2]; // 1 already in center
      case 2:
        return [0, 2, 1]; // Move 2 to center
      default:
        return [0, 1, 2];
    }
  }

  Widget _buildSelectableIcon(int iconIndex, {required bool isCenter}) {
    final isSelected = iconIndex == _selectedIconIndex;
    final size = isCenter ? 100.0 : 70.0;
    final borderWidth = isSelected ? 3.0 : 0.0;

    return GestureDetector(
      onTap: () => _selectIcon(iconIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCenter ? 20 : 14),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCenter ? 17 : 11),
          child: Image.asset(_iconPaths[iconIndex], fit: BoxFit.cover),
        ),
      ),
    );
  }

  void _continue() async {
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

      // Parse optional DEXA data
      final bodyFatPercent = double.tryParse(_bodyFatController.text);
      double? leanMassKg = double.tryParse(_leanMassController.text);
      // Convert lean mass to kg if using imperial
      if (leanMassKg != null && !_useMetric) {
        leanMassKg = leanMassKg * 0.453592;
      }

      // Save to provider (updates state with useMetric)
      ref
          .read(userProfileProvider.notifier)
          .updateProfile(heightCm, weightKg, _useMetric);

      // Save height/weight/DEXA to both SharedPreferences and database
      await ref
          .read(userProfileProvider.notifier)
          .saveHeightAndWeight(
            heightCm,
            weightKg,
            bodyFatPercent: bodyFatPercent,
            leanMassKg: leanMassKg,
          );

      // Save the selected app icon
      ref
          .read(userProfileProvider.notifier)
          .updateAppIconIndex(_selectedIconIndex);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OnboardingEquipmentScreen(),
          ),
        );
      }
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
                      'Your preferred app icon.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App icon selection row
                    Center(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final orderedIndices = _getOrderedIndices();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                _buildSelectableIcon(
                                  orderedIndices[i],
                                  isCenter: i == 1,
                                ),
                            ],
                          );
                        },
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
                            _calculateBmi();
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
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
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
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
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
                                labelStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
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
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
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

                    const SizedBox(height: 24),

                    // BMI Indicator
                    _buildBmiIndicator(),
                    if (_bmi != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://www.cdc.gov/bmi/about/index.html',
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.open_in_new,
                                size: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'BMI categories based on WHO guidelines',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,1}'),
                                ),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Body Fat',
                                suffixText: '%',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final bf = double.tryParse(value);
                                  if (bf == null || bf < 3 || bf > 60) {
                                    return 'Invalid (3-60%)';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _leanMassController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,1}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Lean Mass',
                                suffixText: _useMetric ? 'kg' : 'lbs',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lm = double.tryParse(value);
                                  if (lm == null || lm < 20 || lm > 150) {
                                    return 'Invalid';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

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
