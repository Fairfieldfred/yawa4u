import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/equipment_types.dart';
import '../../core/theme/skins/skins.dart';
import '../../domain/providers/onboarding_providers.dart';

/// Available equipment options for the user to select.
/// These are high-level gym equipment categories that map to specific EquipmentTypes.
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

  /// Maps user equipment options to exercise equipment types
  Set<EquipmentType> get mappedEquipmentTypes {
    switch (this) {
      case EquipmentOption.dumbbells:
        return {EquipmentType.dumbbell};
      case EquipmentOption.barbells:
        return {EquipmentType.barbell};
      case EquipmentOption.functionalTrainer:
        return {EquipmentType.cable, EquipmentType.freemotion};
      case EquipmentOption.gymMachines:
        return {EquipmentType.machine, EquipmentType.machineAssistance};
      case EquipmentOption.homeGymRack:
        return {EquipmentType.barbell, EquipmentType.bodyweightLoadable};
      case EquipmentOption.pullUpBar:
        return {EquipmentType.bodyweightOnly, EquipmentType.bodyweightLoadable};
      case EquipmentOption.crossfitGym:
        return {
          EquipmentType.barbell,
          EquipmentType.dumbbell,
          EquipmentType.bodyweightOnly,
          EquipmentType.bodyweightLoadable,
        };
      case EquipmentOption.kettlebells:
        return {EquipmentType.kettlebell};
      case EquipmentOption.resistanceBands:
        return {EquipmentType.bandAssistance};
      case EquipmentOption.suspensionTrainer:
        // No direct mapping in EquipmentType yet
        return {};
      case EquipmentOption.treadmill:
      case EquipmentOption.exerciseBike:
      case EquipmentOption.rowingMachine:
      case EquipmentOption.lapPool:
        // Cardio equipment - no exercise mappings
        return {};
    }
  }

  /// Gets all EquipmentTypes from a set of selected EquipmentOptions
  static Set<EquipmentType> getEquipmentTypes(Set<String> selectedOptions) {
    final types = <EquipmentType>{};
    for (final optionName in selectedOptions) {
      try {
        final option = EquipmentOption.values.firstWhere(
          (e) => e.name == optionName,
        );
        types.addAll(option.mappedEquipmentTypes);
      } catch (_) {
        // Option not found, skip
      }
    }
    // Always include bodyweight-only exercises as they require no equipment
    types.add(EquipmentType.bodyweightOnly);
    return types;
  }
}

/// A shared widget for filtering exercises by available equipment.
/// Can be used in both Settings screen (full mode) and Filter modals (compact mode).
class AvailableEquipmentFilter extends ConsumerStatefulWidget {
  /// Whether this is displayed in a compact context (e.g., filter modal)
  final bool compact;

  /// Callback when settings change (for parent to track unsaved changes)
  final VoidCallback? onChanged;

  /// Whether to auto-save changes immediately (for filter modal use)
  final bool autoSave;

  const AvailableEquipmentFilter({
    super.key,
    this.compact = false,
    this.onChanged,
    this.autoSave = false,
  });

  @override
  ConsumerState<AvailableEquipmentFilter> createState() =>
      _AvailableEquipmentFilterState();
}

class _AvailableEquipmentFilterState
    extends ConsumerState<AvailableEquipmentFilter> {
  late Set<String> _selectedEquipment;
  late bool _equipmentFilterEnabled;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final service = ref.read(onboardingServiceProvider);
    _selectedEquipment = service.equipment.toSet();
    _equipmentFilterEnabled = service.equipmentFilterEnabled;
  }

  Future<void> _saveSettings() async {
    final service = ref.read(onboardingServiceProvider);
    await service.setEquipment(_selectedEquipment.toList());
    await service.setEquipmentFilterEnabled(_equipmentFilterEnabled);

    // Invalidate providers to refresh the UI
    ref.invalidate(equipmentFilterEnabledProvider);
    ref.invalidate(selectedEquipmentProvider);
  }

  void _toggleEquipment(EquipmentOption equipment) {
    setState(() {
      if (_selectedEquipment.contains(equipment.name)) {
        _selectedEquipment.remove(equipment.name);
      } else {
        _selectedEquipment.add(equipment.name);
      }
    });
    widget.onChanged?.call();
    if (widget.autoSave) {
      _saveSettings();
    }
  }

  void _setFilterEnabled(bool value) {
    setState(() {
      _equipmentFilterEnabled = value;
    });
    widget.onChanged?.call();
    if (widget.autoSave) {
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactLayout(context);
    }
    return _buildFullLayout(context);
  }

  /// Compact layout for use in filter modals
  Widget _buildCompactLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: _equipmentFilterEnabled
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by Available Equipment',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Only show exercises for equipment you have',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _equipmentFilterEnabled,
                onChanged: _setFilterEnabled,
              ),
            ],
          ),
          if (_equipmentFilterEnabled) ...[
            const SizedBox(height: 16),
            Text(
              'Select equipment you have access to',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            _buildEquipmentGrid(context),
          ],
        ],
      ),
    );
  }

  /// Full layout for use in Settings screen
  Widget _buildFullLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Available Equipment',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Only show exercises for equipment you have',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _equipmentFilterEnabled,
              onChanged: _setFilterEnabled,
            ),
          ],
        ),
        if (_equipmentFilterEnabled) ...[
          const SizedBox(height: 16),
          Text(
            'Select equipment you have access to',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildEquipmentGrid(context),
        ],
      ],
    );
  }

  Widget _buildEquipmentGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: EquipmentOption.values.length,
      itemBuilder: (context, index) {
        final equipment = EquipmentOption.values[index];
        final isSelected = _selectedEquipment.contains(equipment.name);

        return InkWell(
          onTap: () => _toggleEquipment(equipment),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }
}
