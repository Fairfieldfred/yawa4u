import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compact integer text field for entering an average heart rate in bpm.
class HrInput extends StatefulWidget {
  const HrInput({
    super.key,
    required this.initialBpm,
    required this.onChanged,
    this.label = 'Avg HR',
    this.enabled = true,
  });

  final int? initialBpm;
  final ValueChanged<int?> onChanged;
  final String label;
  final bool enabled;

  @override
  State<HrInput> createState() => _HrInputState();
}

class _HrInputState extends State<HrInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialBpm != null ? '${widget.initialBpm}' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.favorite_outline),
        suffixText: 'bpm',
      ),
      onChanged: (text) {
        final trimmed = text.trim();
        if (trimmed.isEmpty) {
          widget.onChanged(null);
          return;
        }
        final parsed = int.tryParse(trimmed);
        widget.onChanged(parsed);
      },
    );
  }
}
