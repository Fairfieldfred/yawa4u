import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../data/models/exercise_feedback.dart';
import '../../../data/services/exercise_name_localizer.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog for logging exercise feedback: joint pain, muscle pump, and workload.
///
/// Returns an [ExerciseFeedback] if the user saves, or `null` if dismissed.
class ExerciseFeedbackDialog extends StatefulWidget {
  final String exerciseName;
  final ExerciseFeedback? existing;

  const ExerciseFeedbackDialog({
    super.key,
    required this.exerciseName,
    this.existing,
  });

  /// Show the dialog and return the feedback, or `null` if cancelled.
  static Future<ExerciseFeedback?> show(
    BuildContext context, {
    required String exerciseName,
    ExerciseFeedback? existing,
  }) {
    return showDialog<ExerciseFeedback>(
      context: context,
      builder: (_) => ExerciseFeedbackDialog(
        exerciseName: exerciseName,
        existing: existing,
      ),
    );
  }

  @override
  State<ExerciseFeedbackDialog> createState() => _ExerciseFeedbackDialogState();
}

class _ExerciseFeedbackDialogState extends State<ExerciseFeedbackDialog> {
  JointPain? _jointPain;
  MusclePump? _musclePump;
  Workload? _workload;

  @override
  void initState() {
    super.initState();
    _jointPain = widget.existing?.jointPain;
    _musclePump = widget.existing?.musclePump;
    _workload = widget.existing?.workload;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        context.localizedExerciseName(widget.exerciseName),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              theme,
              label: l10n.jointPainLabel,
              icon: Icons.warning_amber_rounded,
              child: _buildChoiceRow<JointPain>(
                values: JointPain.values,
                selected: _jointPain,
                onSelected: (v) => setState(() => _jointPain = v),
                colorFor: _jointPainColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              label: l10n.musclePumpLabel,
              icon: Icons.local_fire_department_outlined,
              child: _buildChoiceRow<MusclePump>(
                values: MusclePump.values,
                selected: _musclePump,
                onSelected: (v) => setState(() => _musclePump = v),
                colorFor: _musclePumpColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              theme,
              label: l10n.workloadLabel,
              icon: Icons.fitness_center,
              child: _buildChoiceRow<Workload>(
                values: Workload.values,
                selected: _workload,
                onSelected: (v) => setState(() => _workload = v),
                colorFor: _workloadColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildChoiceRow<T extends Enum>({
    required List<T> values,
    required T? selected,
    required ValueChanged<T?> onSelected,
    required Color Function(T) colorFor,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: values.map((v) {
        final isSelected = v == selected;
        final color = colorFor(v);
        return ChoiceChip(
          label: Text(
            _localizedName(v, l10n),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : null,
            ),
          ),
          selected: isSelected,
          selectedColor: color,
          onSelected: (sel) => onSelected(sel ? v : null),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  String _localizedName(Enum value, AppLocalizations l10n) {
    if (value is JointPain) return value.localizedName(l10n);
    if (value is MusclePump) return value.localizedName(l10n);
    if (value is Workload) return value.localizedName(l10n);
    return value.name.toUpperCase();
  }

  Color _jointPainColor(JointPain v) {
    return switch (v) {
      JointPain.none => Colors.green,
      JointPain.low => Colors.orange,
      JointPain.moderate => Colors.deepOrange,
      JointPain.severe => Colors.red,
    };
  }

  Color _musclePumpColor(MusclePump v) {
    return switch (v) {
      MusclePump.low => Colors.grey,
      MusclePump.moderate => Colors.blue,
      MusclePump.amazing => Colors.purple,
    };
  }

  Color _workloadColor(Workload v) {
    return switch (v) {
      Workload.easy => Colors.green,
      Workload.prettyGood => Colors.blue,
      Workload.pushedLimits => Colors.orange,
      Workload.tooMuch => Colors.red,
    };
  }

  void _save() {
    final feedback = ExerciseFeedback(
      jointPain: _jointPain,
      musclePump: _musclePump,
      workload: _workload,
      timestamp: DateTime.now(),
    );
    Navigator.of(context).pop(feedback);
  }
}
