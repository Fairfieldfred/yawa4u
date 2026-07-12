import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../l10n/app_localizations.dart';

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

/// Step 3 of onboarding (Profile → Sports → Equipment → Terminology).
/// Collects available equipment; skipped entirely when Strength isn't
/// among the selected sports.
class OnboardingEquipmentScreen extends ConsumerStatefulWidget {
  const OnboardingEquipmentScreen({super.key});

  @override
  ConsumerState<OnboardingEquipmentScreen> createState() => _OnboardingEquipmentScreenState();
}

class _OnboardingEquipmentScreenState extends ConsumerState<OnboardingEquipmentScreen> {
  final Set<EquipmentOption> _selectedEquipment = {};

  String _localizedName(AppLocalizations l10n, EquipmentOption e) {
    return switch (e) {
      EquipmentOption.dumbbells => l10n.equipmentDumbbells,
      EquipmentOption.homeGymRack => l10n.equipmentHomeGymRack,
      EquipmentOption.functionalTrainer => l10n.equipmentFunctionalTrainer,
      EquipmentOption.gymMachines => l10n.equipmentGymMachines,
      EquipmentOption.barbells => l10n.equipmentBarbells,
      EquipmentOption.kettlebells => l10n.equipmentKettlebells,
      EquipmentOption.resistanceBands => l10n.equipmentResistanceBands,
      EquipmentOption.treadmill => l10n.equipmentTreadmill,
      EquipmentOption.exerciseBike => l10n.equipmentExerciseBike,
      EquipmentOption.rowingMachine => l10n.equipmentRowingMachine,
      EquipmentOption.lapPool => l10n.equipmentLapPool,
      EquipmentOption.crossfitGym => l10n.equipmentCrossfitGym,
      EquipmentOption.pullUpBar => l10n.equipmentPullUpBar,
      EquipmentOption.suspensionTrainer => l10n.equipmentSuspensionTrainer,
    };
  }

  void _toggleEquipment(EquipmentOption equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment)) {
        _selectedEquipment.remove(equipment);
      } else {
        _selectedEquipment.add(equipment);
      }
    });
  }

  void _continue() {
    // Save equipment selection
    final equipmentNames = _selectedEquipment.map((e) => e.name).toList();
    ref.read(userProfileProvider.notifier).updateEquipment(equipmentNames);

    context.push('/onboarding/terminology');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingEquipmentTitle),
        centerTitle: true,
        bottom: const _OnboardingProgress(step: 3, total: 4),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingEquipmentHeadline,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingEquipmentSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Equipment grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: EquipmentOption.values.length,
                itemBuilder: (context, index) {
                  final equipment = EquipmentOption.values[index];
                  final isSelected = _selectedEquipment.contains(equipment);

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
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
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
                                    ? context.selectedIndicatorColor
                                    : Theme.of(context).colorScheme.outline,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 14,
                                    color: context.selectedIndicatorColor,
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
                              _localizedName(l10n, equipment),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _continue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(l10n.continueButton),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Skip equipment selection
                      ref.read(userProfileProvider.notifier).updateEquipment([]);
                      context.push('/onboarding/terminology');
                    },
                    child: Text(l10n.onboardingEquipmentSkip),
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
