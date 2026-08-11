import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

/// Compact integer text field for entering an average heart rate in bpm.
class HrInput extends StatefulWidget {
  const HrInput({
    super.key,
    required this.initialBpm,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final int? initialBpm;
  final ValueChanged<int?> onChanged;
  final String? label;
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
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      keyboardAppearance: Brightness.light,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.label ?? l10n.avgHrLabel,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.favorite_outline),
        suffixText: l10n.bpmSuffix,
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
