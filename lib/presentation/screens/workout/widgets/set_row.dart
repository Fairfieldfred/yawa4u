import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/exercise_set.dart';
import '../../../../core/constants/enums.dart';

/// A row widget for displaying and editing a single exercise set
///
/// Features:
/// - Overflow menu (3 dots) for set actions
/// - Weight input field
/// - Reps input field (supports "2 RIR" text)
/// - RIR hint text based on current week
/// - LOG checkbox (green when checked)
/// - Auto-save on field blur
/// - Myorep badge ("M" or "MM")
/// - Bodyweight support ("+WEIGHT" label)
class SetRow extends StatefulWidget {
  final ExerciseSet set;
  final int setNumber;
  final bool isBodyweightLoadable;
  final double? bodyweight;
  final int? targetRir;
  final ValueChanged<ExerciseSet>? onSetChanged;
  final VoidCallback? onMenuPressed;

  const SetRow({
    super.key,
    required this.set,
    required this.setNumber,
    this.isBodyweightLoadable = false,
    this.bodyweight,
    this.targetRir,
    this.onSetChanged,
    this.onMenuPressed,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _handleWeightChange() {
    final weight = double.tryParse(_weightController.text);
    if (widget.onSetChanged != null) {
      widget.onSetChanged!(
        widget.set.copyWith(weight: weight),
      );
    }
  }

  void _handleRepsChange() {
    if (widget.onSetChanged != null) {
      widget.onSetChanged!(
        widget.set.copyWith(reps: _repsController.text),
      );
    }
  }

  void _handleLogToggle() {
    if (widget.onSetChanged != null) {
      widget.onSetChanged!(
        widget.set.copyWith(isLogged: !widget.set.isLogged),
      );
    }
  }

  String _getSetTypeBadge() {
    switch (widget.set.setType) {
      case SetType.myorep:
        return 'M';
      case SetType.myorepMatch:
        return 'MM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _getSetTypeBadge();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set overflow menu
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF8E8E93),
              size: 20,
            ),
            onPressed: widget.onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          const SizedBox(width: 8),

          // Set number with optional badge
          SizedBox(
            width: 32,
            child: Row(
              children: [
                Text(
                  '${widget.setNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (badge.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E8E93),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Weight field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3A3A3C),
                  width: 1,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (_) => _handleWeightChange(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Reps field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3A3A3C),
                  width: 1,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: widget.targetRir != null ? '${widget.targetRir} RIR' : null,
                    hintStyle: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onChanged: (_) => _handleRepsChange(),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // LOG checkbox
          GestureDetector(
            onTap: _handleLogToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.set.isLogged
                    ? const Color(0xFF30D158)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.set.isLogged
                      ? const Color(0xFF30D158)
                      : const Color(0xFF3A3A3C),
                  width: 2,
                ),
              ),
              child: widget.set.isLogged
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
