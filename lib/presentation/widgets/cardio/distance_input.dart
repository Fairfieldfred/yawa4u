import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';

/// A text field that captures distance in the user's chosen display unit
/// and emits meters to the parent.
///
/// The unit is derived from the current [Sport] + the per-sport unit
/// preference passed in as [units]. The label on the suffix updates
/// automatically when units change.
///
/// For swims, set [sport] to [Sport.swim] so the label becomes "m" / "yd"
/// instead of "km" / "mi".
class DistanceInput extends StatefulWidget {
  const DistanceInput({
    super.key,
    required this.initialMeters,
    required this.units,
    required this.onChanged,
    this.sport,
    this.label = 'Distance',
    this.enabled = true,
  });

  final double? initialMeters;
  final UnitSystem units;
  final Sport? sport;

  /// Fires with meters (or null if the user cleared the field).
  final ValueChanged<double?> onChanged;

  final String label;
  final bool enabled;

  @override
  State<DistanceInput> createState() => _DistanceInputState();
}

class _DistanceInputState extends State<DistanceInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatInitial());
  }

  @override
  void didUpdateWidget(covariant DistanceInput old) {
    super.didUpdateWidget(old);
    // Reformat when the unit flips under us.
    if (old.units != widget.units || old.sport != widget.sport) {
      _controller.text = _formatInitial();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatInitial() {
    final meters = widget.initialMeters;
    if (meters == null) return '';
    if (widget.sport == Sport.swim) {
      // For swim, treat the input unit as meters/yards (no conversion to km).
      return widget.units.isMetric
          ? meters.toStringAsFixed(0)
          : (meters / CardioConversions.metersPerYard).toStringAsFixed(0);
    }
    return CardioConversions.metersToDisplay(
      meters,
      widget.units,
    ).toStringAsFixed(2);
  }

  String get _suffix {
    if (widget.sport == Sport.swim) {
      return widget.units.isMetric ? 'm' : 'yd';
    }
    return widget.units.isMetric ? 'km' : 'mi';
  }

  void _onChanged(String text) {
    if (text.trim().isEmpty) {
      widget.onChanged(null);
      return;
    }
    final parsed = double.tryParse(text.trim());
    if (parsed == null) {
      widget.onChanged(null);
      return;
    }
    double meters;
    if (widget.sport == Sport.swim) {
      meters = widget.units.isMetric
          ? parsed
          : parsed * CardioConversions.metersPerYard;
    } else {
      meters = CardioConversions.displayToMeters(parsed, widget.units);
    }
    widget.onChanged(meters);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.straighten),
        suffixText: _suffix,
      ),
      onChanged: _onChanged,
    );
  }
}
