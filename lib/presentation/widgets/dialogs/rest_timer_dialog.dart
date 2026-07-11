import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Dialog for setting a custom rest timer duration for an exercise.
///
/// Returns the selected rest duration in seconds, or null if cancelled.
/// Returns -1 to indicate "use default" (clear the override).
class RestTimerDialog extends StatefulWidget {
  final int? currentRestSeconds;

  const RestTimerDialog({super.key, this.currentRestSeconds});

  /// Show the dialog and return the selected rest seconds.
  static Future<int?> show(
    BuildContext context, {
    int? currentRestSeconds,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => RestTimerDialog(
        currentRestSeconds: currentRestSeconds,
      ),
    );
  }

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  late int _selectedSeconds;
  bool _useDefault;

  static const _presets = [30, 45, 60, 90, 120, 180];

  _RestTimerDialogState() : _useDefault = false;

  @override
  void initState() {
    super.initState();
    _useDefault = widget.currentRestSeconds == null;
    _selectedSeconds = widget.currentRestSeconds ?? 60;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.restTimerDialogTitle),
      // Scrollable so large text scales / small screens never overflow.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use default toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.restTimerUseDefault,
                style: theme.textTheme.bodyMedium,
              ),
              subtitle: Text(
                l10n.restTimerBasedOnSetType,
                style: theme.textTheme.bodySmall,
              ),
              value: _useDefault,
              onChanged: (value) {
                setState(() => _useDefault = value);
              },
            ),
            if (!_useDefault) ...[
              const SizedBox(height: 8),
              Text(
                l10n.restTimerDuration,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((seconds) {
                  final label = seconds >= 60
                      ? '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
                      : '${seconds}s';
                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedSeconds == seconds,
                    onSelected: (_) {
                      setState(() => _selectedSeconds = seconds);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Slider for fine-tuning
              Row(
                children: [
                  Text(
                    _formatDuration(_selectedSeconds),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _selectedSeconds.toDouble(),
                      min: 10,
                      max: 300,
                      divisions: 29,
                      onChanged: (value) {
                        setState(() => _selectedSeconds = value.round());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_useDefault) {
              Navigator.pop(context, -1); // Signal to clear override
            } else {
              Navigator.pop(context, _selectedSeconds);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return s > 0 ? '${m}m ${s}s' : '${m}m';
    }
    return '${s}s';
  }
}
