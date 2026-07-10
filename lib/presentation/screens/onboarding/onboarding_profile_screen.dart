import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';

/// First onboarding screen - collects user's height and weight
class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> with SingleTickerProviderStateMixin {
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
  List<({String label, double minBmi, double? maxBmi, Color color})> _getBmiCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      (label: l10n.bmiCategoryObese, minBmi: 30, maxBmi: null, color: context.errorColor),
      (label: l10n.bmiCategoryOverweight, minBmi: 25, maxBmi: 30, color: context.warningColor),
      (label: l10n.bmiCategoryNormal, minBmi: 18.5, maxBmi: 25, color: context.successColor),
      (label: l10n.bmiCategoryUnderweight, minBmi: 0, maxBmi: 18.5, color: Colors.blue),
    ];
  }

  Widget _buildBmiIndicator() {
    final l10n = AppLocalizations.of(context)!;
    if (_bmi == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 18,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.bmiPlaceholder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // UX review P1 #8 — compact BMI display. The prior design was a
    // two-column card with a 4-row category legend and a big coloured
    // circle. That lives behind the expansion toggle now so the
    // onboarding surface stays visually quiet by default.
    final color = _getBmiColor(context, _bmi!);
    final category = _getBmiCategories(context).firstWhere(
      (cat) => _bmi! >= cat.minBmi && (cat.maxBmi == null || _bmi! < cat.maxBmi!),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.bmiValue(_bmi!.toStringAsFixed(1)),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          // Small info trigger — expands a bottom sheet with the full
          // category breakdown for users who want context.
          IconButton(
            icon: const Icon(Icons.info_outline, size: 18),
            visualDensity: VisualDensity.compact,
            tooltip: l10n.aboutBmiCategories,
            onPressed: () => _showBmiDetails(context),
          ),
        ],
      ),
    );
  }

  /// Expands the full BMI category breakdown + WHO / CDC reference link
  /// in a bottom sheet. Keeps the onboarding surface lightweight while
  /// preserving the educational content for users who want it.
  Future<void> _showBmiDetails(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final categories = _getBmiCategories(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(sheetContext)!.bmiCategoriesTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final cat in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(cat.label)),
                        Text(
                          cat.maxBmi == null
                              ? '${cat.minBmi.toInt()}+'
                              : cat.minBmi == 0
                              ? '< ${cat.maxBmi!.toStringAsFixed(1)}'
                              : '${cat.minBmi.toStringAsFixed(1)}–${cat.maxBmi!.toInt()}',
                          style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(sheetContext).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse('https://www.cdc.gov/bmi/about/index.html'),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(sheetContext)!.bmiGuidelines,
                        style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                          color: Theme.of(sheetContext).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
      // Height/weight are optional at onboarding — the Body stats screen
      // prompts for them on first use. Save only when both were provided.
      double? heightCm;
      double? weightKg;

      if (_useMetric) {
        heightCm = double.tryParse(_heightCmController.text);
        weightKg = double.tryParse(_weightKgController.text);
      } else {
        final feet = int.tryParse(_heightFeetController.text);
        if (feet != null) {
          final inches = int.tryParse(_heightInchesController.text) ?? 0;
          heightCm = ((feet * 12) + inches) * 2.54;
        }
        final weightLbs = double.tryParse(_weightController.text);
        weightKg = weightLbs == null ? null : weightLbs * 0.453592;
      }

      // Parse optional DEXA data
      final bodyFatPercent = double.tryParse(_bodyFatController.text);
      double? leanMassKg = double.tryParse(_leanMassController.text);
      // Convert lean mass to kg if using imperial
      if (leanMassKg != null && !_useMetric) {
        leanMassKg = leanMassKg * 0.453592;
      }

      final notifier = ref.read(userProfileProvider.notifier);
      notifier.updateUseMetric(_useMetric);
      if (heightCm != null && weightKg != null) {
        notifier.updateProfile(heightCm, weightKg, _useMetric);
        // Save height/weight/DEXA to both SharedPreferences and database
        await notifier.saveHeightAndWeight(
          heightCm,
          weightKg,
          bodyFatPercent: bodyFatPercent,
          leanMassKg: leanMassKg,
        );
      }

      // Save the selected app icon
      ref.read(userProfileProvider.notifier).updateAppIconIndex(_selectedIconIndex);

      if (mounted) {
        context.push('/onboarding/sports');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.onboardingProfileTitle),
          centerTitle: true,
          bottom: const _OnboardingProgress(step: 1, total: 4),
        ),
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
                      l10n.onboardingProfileHeadline,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingProfileSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Unit toggle
                    Row(
                      children: [
                        Text(l10n.unitsLabel),
                        const SizedBox(width: 16),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(l10n.imperialLabel),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(l10n.metricLabel),
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
                      l10n.heightLabel,
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
                        decoration: InputDecoration(
                          labelText: l10n.centimetersLabel,
                          labelStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                          suffixText: l10n.cmSuffix,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // Optional — validate only when filled in.
                          if (value == null || value.isEmpty) return null;
                          final cm = int.tryParse(value);
                          if (cm == null || cm < 100 || cm > 250) {
                            return l10n.heightInvalidCmError;
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
                              decoration: InputDecoration(
                                labelText: l10n.feetLabel,
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                suffixText: l10n.ftSuffix,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                // Optional — validate only when filled in.
                                if (value == null || value.isEmpty) return null;
                                final feet = int.tryParse(value);
                                if (feet == null || feet < 3 || feet > 8) {
                                  return l10n.heightInvalidError;
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
                              decoration: InputDecoration(
                                labelText: l10n.inchesLabel,
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                suffixText: l10n.inSuffix,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final inches = int.tryParse(value);
                                  if (inches == null || inches < 0 || inches > 11) {
                                    return l10n.heightInvalidError;
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
                      l10n.weightLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _useMetric ? _weightKgController : _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: _useMetric ? l10n.kilogramsLabel : l10n.poundsLabel,
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        suffixText: _useMetric ? l10n.kgSuffix : l10n.lbsSuffix,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        // Optional — validate only when filled in.
                        if (value == null || value.isEmpty) return null;
                        final weight = double.tryParse(value);
                        if (weight == null) {
                          return l10n.weightInvalidNumberError;
                        }
                        // UX review P1 #8 — tightened ranges catch the
                        // most likely typo (300 instead of 200, extra
                        // digit). Covers ~99.9% of adult users. The
                        // outlier case is an edge we're happy to force
                        // through the validator rather than silently
                        // accept an impossible value from a slip.
                        if (_useMetric) {
                          if (weight < 40 || weight > 180) {
                            return l10n.weightInvalidKgError;
                          }
                        } else {
                          if (weight < 80 || weight > 400) {
                            return l10n.weightInvalidLbsError;
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // BMI Indicator — compact row + info-icon sheet.
                    // The WHO / CDC reference lives inside the sheet now
                    // to keep the onboarding surface uncluttered.
                    _buildBmiIndicator(),

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
                                    l10n.dexaScanTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    l10n.dexaSubtitle,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _showDexaFields ? Icons.expand_less : Icons.expand_more,
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
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,1}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.bodyFatLabel,
                                suffixText: l10n.bodyFatSuffix,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final bf = double.tryParse(value);
                                  if (bf == null || bf < 3 || bf > 60) {
                                    return l10n.bodyFatInvalidError;
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
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,1}'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.leanMassLabel,
                                suffixText: _useMetric ? l10n.kgSuffix : l10n.lbsSuffix,
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final lm = double.tryParse(value);
                                  if (lm == null || lm < 20 || lm > 150) {
                                    return l10n.heightInvalidError;
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

                    // App icon selection — optional, moved below the
                    // core data entry so it doesn't gate onboarding.
                    Text(
                      l10n.appIconTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appIconSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 24),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('onboarding_continue'),
                        onPressed: _continue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(l10n.continueButton),
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

/// Shared 4-step onboarding progress bar used by every onboarding
/// screen's AppBar. Kept private here (also duplicated in the other
/// onboarding files intentionally — each screen can declare its own
/// step value without importing a shared widget).
class _OnboardingProgress extends StatelessWidget implements PreferredSizeWidget {
  const _OnboardingProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Size get preferredSize => const Size.fromHeight(8);

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: step / total,
      minHeight: 3,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest,
    );
  }
}
