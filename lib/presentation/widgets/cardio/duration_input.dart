import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/cardio_conversions.dart';
import '../../../l10n/app_localizations.dart';

/// A text field that captures duration as `MM:SS` or `HH:MM:SS` and emits
/// seconds to the parent.
///
/// Uses lazy validation: fires `onChanged(null)` while the user is mid-
/// typing, and fires the parsed value once the string round-trips through
/// [CardioConversions.parseDuration]. Invalid input keeps showing an error
/// via the `errorText` helper.
class DurationInput extends StatefulWidget {
  const DurationInput({
    super.key,
    required this.initialSeconds,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final int? initialSeconds;
  final ValueChanged<int?> onChanged;
  final String? label;
  final bool enabled;

  @override
  State<DurationInput> createState() => _DurationInputState();
}

class _DurationInputState extends State<DurationInput> {
  late final TextEditingController _controller;
  bool _hasFormatError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialSeconds != null ? CardioConversions.formatDuration(widget.initialSeconds!) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertColon() {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.baseOffset.clamp(0, text.length);
    final end = selection.extentOffset.clamp(0, text.length);
    final newText = text.replaceRange(start, end, ':');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
    _onChanged(newText);
  }

  void _onChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() => _hasFormatError = false);
      widget.onChanged(null);
      return;
    }
    final seconds = CardioConversions.parseDuration(trimmed);
    if (seconds == null) {
      setState(() => _hasFormatError = true);
      widget.onChanged(null);
      return;
    }
    setState(() => _hasFormatError = false);
    widget.onChanged(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.datetime,
      keyboardAppearance: Brightness.light,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label ?? l10n.durationLabel,
        hintText: l10n.durationHint,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.timer_outlined),
        errorText: _hasFormatError ? l10n.durationFormatError : null,
        suffixIcon: widget.enabled
            ? IconButton(
                icon: Text(
                  ':',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                tooltip: l10n.insertColonTooltip,
                onPressed: _insertColon,
              )
            : null,
      ),
      onChanged: _onChanged,
    );
  }
}
