import 'package:flutter/material.dart';

/// Type of note being edited - determines dialog title and hint text
enum NoteType { trainingCycle, workout, exercise }

/// Result from NoteDialog for exercise notes (includes pin status)
class ExerciseNoteResult {
  final String note;
  final bool isPinned;

  ExerciseNoteResult({required this.note, required this.isPinned});
}

/// A reusable dialog for adding/editing notes.
/// Can be used for Training Cycle, Workout, or Exercise notes.
/// For exercise notes, returns ExerciseNoteResult; for others, returns String.
class NoteDialog extends StatefulWidget {
  final String? initialNote;
  final NoteType noteType;
  final String? customTitle;
  final String? customHint;
  final bool initialPinned;

  const NoteDialog({
    super.key,
    this.initialNote,
    required this.noteType,
    this.customTitle,
    this.customHint,
    this.initialPinned = false,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();

  /// Get the default title for a note type
  static String getTitleForType(NoteType type) {
    switch (type) {
      case NoteType.trainingCycle:
        return 'Training Cycle Note';
      case NoteType.workout:
        return 'Workout Note';
      case NoteType.exercise:
        return 'Exercise Note';
    }
  }

  /// Get the default hint text for a note type
  static String getHintForType(NoteType type) {
    switch (type) {
      case NoteType.trainingCycle:
        return 'Enter note for this training cycle...';
      case NoteType.workout:
        return 'Enter note for this workout...';
      case NoteType.exercise:
        return 'Enter note for this exercise...';
    }
  }
}

class _NoteDialogState extends State<NoteDialog> {
  late final TextEditingController _noteController;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _isPinned = widget.initialPinned;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _title =>
      widget.customTitle ?? NoteDialog.getTitleForType(widget.noteType);

  String get _hint =>
      widget.customHint ?? NoteDialog.getHintForType(widget.noteType);

  bool get _isExerciseNote => widget.noteType == NoteType.exercise;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildNoteField(context),
            if (_isExerciseNote) ...[
              const SizedBox(height: 16),
              _buildPinCheckbox(context),
            ],
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPinCheckbox(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isPinned = !_isPinned),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _isPinned,
                onChanged: (value) =>
                    setState(() => _isPinned = value ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.push_pin_outlined,
              size: 18,
              color: _isPinned
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
            const SizedBox(width: 8),
            Text(
              'Pin to Exercise',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isPinned
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Flexible(
          child: Text(
            _title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildNoteField(BuildContext context) {
    return TextField(
      controller: _noteController,
      autofocus: true,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: _hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CANCEL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () {
              final noteText = _noteController.text.trim();
              if (_isExerciseNote) {
                // Return ExerciseNoteResult for exercise notes
                Navigator.of(
                  context,
                ).pop(ExerciseNoteResult(note: noteText, isPinned: _isPinned));
              } else {
                // Return just the string for other note types
                Navigator.of(context).pop(noteText);
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('SAVE'),
          ),
        ),
      ],
    );
  }
}

/// Dialog for renaming a trainingCycle.
class RenameTrainingCycleDialog extends StatefulWidget {
  final String initialName;

  const RenameTrainingCycleDialog({super.key, required this.initialName});

  @override
  State<RenameTrainingCycleDialog> createState() =>
      _RenameTrainingCycleDialogState();
}

class _RenameTrainingCycleDialogState extends State<RenameTrainingCycleDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildNameField(context),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text(
          'Rename',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextField(
      controller: _nameController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'TrainingCycle name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CANCEL'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: () {
              final trimmedName = _nameController.text.trim();
              if (trimmedName.isNotEmpty) {
                Navigator.of(context).pop(trimmedName);
              }
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('SAVE'),
          ),
        ),
      ],
    );
  }
}

/// Dialog for adding or editing a workout note.
/// This is a convenience wrapper around [NoteDialog] for backward compatibility.
class WorkoutNoteDialog extends StatelessWidget {
  final String? initialNote;

  const WorkoutNoteDialog({super.key, this.initialNote});

  @override
  Widget build(BuildContext context) {
    return NoteDialog(initialNote: initialNote, noteType: NoteType.workout);
  }
}

/// Result record for RelabelDayDialog.
typedef RelabelResult = ({String label, bool applyToAll});

/// Dialog for relabeling a workout day.
class RelabelDayDialog extends StatefulWidget {
  final String initialLabel;

  const RelabelDayDialog({super.key, required this.initialLabel});

  @override
  State<RelabelDayDialog> createState() => _RelabelDayDialogState();
}

class _RelabelDayDialogState extends State<RelabelDayDialog> {
  late String _selectedLabel;
  bool _applyToAll = false;

  static const List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLabel = _daysOfWeek.contains(widget.initialLabel)
        ? widget.initialLabel
        : _daysOfWeek.first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildDescription(context),
            const SizedBox(height: 24),
            _buildDaySelector(context),
            const SizedBox(height: 24),
            _buildApplyToAllCheckbox(context),
            const SizedBox(height: 32),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        Text(
          'Update day label',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'You can apply a different weekday label to this day.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLabel,
          isExpanded: true,
          items: _daysOfWeek.map((String day) {
            return DropdownMenuItem<String>(value: day, child: Text(day));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLabel = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildApplyToAllCheckbox(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _applyToAll,
            onChanged: (bool? value) {
              setState(() {
                _applyToAll = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _applyToAll = !_applyToAll;
              });
            },
            child: Text(
              'Apply to all days in this position',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        const SizedBox(width: 16),
        FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop((label: _selectedLabel, applyToAll: _applyToAll));
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
