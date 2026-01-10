import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/onboarding_providers.dart';
import 'onboarding_terminology_screen.dart';

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

/// Second onboarding screen - collects user's available equipment
class OnboardingEquipmentScreen extends ConsumerStatefulWidget {
  const OnboardingEquipmentScreen({super.key});

  @override
  ConsumerState<OnboardingEquipmentScreen> createState() =>
      _OnboardingEquipmentScreenState();
}

class _OnboardingEquipmentScreenState
    extends ConsumerState<OnboardingEquipmentScreen> {
  final Set<EquipmentOption> _selectedEquipment = {};

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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingTerminologyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Equipment'), centerTitle: true),
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
                    'What equipment do you have access to?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select all that apply. This helps us suggest appropriate exercises.',
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
                              equipment.displayName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('Continue'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Skip equipment selection
                      ref
                          .read(userProfileProvider.notifier)
                          .updateEquipment([]);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const OnboardingTerminologyScreen(),
                        ),
                      );
                    },
                    child: const Text('Skip for now'),
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
