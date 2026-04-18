import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../data/models/cardio_detail.dart';
import '../../../data/models/session.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../widgets/cardio/distance_input.dart';
import '../../widgets/cardio/duration_input.dart';
import '../../widgets/cardio/hr_input.dart';
import '../../widgets/cardio/sport_badge.dart';

/// Form screen for creating or editing a [CardioSession].
///
/// v1 focus: ad-hoc logging of completed cardio activity — the user fills
/// in distance, duration, HR, RPE, and notes, taps save, and a
/// [CardioSession] is persisted via [SessionRepository]. Structured
/// intervals are out of scope for this session (separate screen in a
/// follow-up).
///
/// Can operate in two modes:
///   * create (sessionId == null): uses [sport] + optional [trainingCycleId]
///     to scaffold a brand-new session.
///   * edit (sessionId != null): loads the existing session and populates
///     the form.
///
/// Imported sessions (source.isExternal) only expose editable notes + RPE;
/// aggregate metrics are displayed read-only to protect against
/// accidental overwrites on re-sync.
class CardioSessionScreen extends ConsumerStatefulWidget {
  const CardioSessionScreen({
    super.key,
    this.sessionId,
    this.sport,
    this.trainingCycleId,
  });

  /// Existing session to edit. If null, the screen creates a new one.
  final String? sessionId;

  /// Required when [sessionId] is null — which sport is being logged.
  final Sport? sport;

  /// Optional — attach the new session to this training cycle. Null means
  /// the session is ad-hoc (not tied to a plan).
  final String? trainingCycleId;

  @override
  ConsumerState<CardioSessionScreen> createState() =>
      _CardioSessionScreenState();
}

class _CardioSessionScreenState extends ConsumerState<CardioSessionScreen> {
  final _uuid = const Uuid();
  final _notesController = TextEditingController();

  CardioSession? _existing;
  late Sport _sport;
  DateTime _scheduledDate = DateTime.now();
  double? _distanceMeters;
  int? _durationSeconds;
  int? _averageHr;
  int? _rpe;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sport = widget.sport ?? Sport.run;
    if (widget.sessionId != null) {
      _loadExisting();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(sessionRepositoryProvider);
    final loaded = await repo.getById(widget.sessionId!);
    if (!mounted) return;
    if (loaded is CardioSession) {
      _existing = loaded;
      _sport = loaded.sport;
      _scheduledDate = loaded.scheduledDate ?? DateTime.now();
      _distanceMeters = loaded.detail?.actualDistanceM;
      _durationSeconds = loaded.detail?.actualDurationSec;
      _averageHr = loaded.detail?.averageHr;
      _rpe = loaded.detail?.perceivedExertion;
      _notesController.text = loaded.notes ?? '';
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  UnitSystem _units() {
    return ref.read(onboardingServiceProvider).unitsFor(_sport);
  }

  bool get _isReadOnly => _existing?.isReadOnly ?? false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(sessionRepositoryProvider);

    final detail = CardioDetail(
      actualDistanceM: _distanceMeters,
      actualDurationSec: _durationSeconds,
      averageHr: _averageHr,
      perceivedExertion: _rpe,
    );

    try {
      if (_existing == null) {
        final session = CardioSession(
          id: _uuid.v4(),
          trainingCycleId: widget.trainingCycleId,
          sport: _sport,
          source: SessionSource.userLogged,
          status: WorkoutStatus.completed,
          scheduledDate: _scheduledDate,
          completedDate: DateTime.now(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          detail: detail,
        );
        await repo.createCardio(session);
      } else {
        final updated = _existing!.copyWith(
          scheduledDate: _scheduledDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          detail: detail,
          status: _existing!.status == WorkoutStatus.incomplete
              ? WorkoutStatus.completed
              : _existing!.status,
        );
        await repo.updateCardio(updated);
      }

      // Invalidate stream providers so affected lists repaint.
      ref.invalidate(sessionsProvider);
      if (widget.trainingCycleId != null) {
        ref.invalidate(
          sessionsByTrainingCycleProvider(widget.trainingCycleId!),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existing == null ? 'Session logged' : 'Session updated'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save session: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final units = _units();
    final title = _existing == null
        ? 'Log ${_sport.displayName.toLowerCase()}'
        : 'Edit ${_sport.displayName.toLowerCase()}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isReadOnly)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Chip(label: Text('Imported'), visualDensity: VisualDensity.compact),
            ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                SportBadge(sport: _sport),
                const SizedBox(width: 8),
                Text(
                  _dateLabel(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isReadOnly ? null : _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DistanceInput(
              key: ValueKey('distance-${_sport.name}-${units.name}'),
              initialMeters: _distanceMeters,
              units: units,
              sport: _sport,
              enabled: !_isReadOnly,
              onChanged: (meters) => _distanceMeters = meters,
            ),
            const SizedBox(height: 12),
            DurationInput(
              key: ValueKey('duration-${_existing?.id ?? 'new'}'),
              initialSeconds: _durationSeconds,
              enabled: !_isReadOnly,
              onChanged: (seconds) => _durationSeconds = seconds,
            ),
            const SizedBox(height: 12),
            HrInput(
              key: ValueKey('hr-${_existing?.id ?? 'new'}'),
              initialBpm: _averageHr,
              enabled: !_isReadOnly,
              onChanged: (bpm) => _averageHr = bpm,
            ),
            const SizedBox(height: 16),
            _RpeSlider(
              value: _rpe,
              onChanged: (v) => setState(() => _rpe = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Anything worth remembering about this session…',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _existing == null ? 'Save session' : 'Update session',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_distanceMeters != null && _durationSeconds != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _PaceReadout(
                  distanceMeters: _distanceMeters!,
                  durationSeconds: _durationSeconds!,
                  units: units,
                  sport: _sport,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dateLabel() {
    final d = _scheduledDate;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

/// RPE slider (1–10). Null value means the user hasn't entered anything.
class _RpeSlider extends StatelessWidget {
  const _RpeSlider({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Perceived exertion',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Text(
              value != null ? 'RPE $value' : 'Not set',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: (value ?? 0).toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: value != null ? 'RPE $value' : 'Not set',
          onChanged: (v) => onChanged(v < 1 ? null : v.toInt()),
        ),
      ],
    );
  }
}

/// Read-only pace + speed derived from distance and duration. Shown below
/// the form so users can sanity-check their entries.
class _PaceReadout extends StatelessWidget {
  const _PaceReadout({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.units,
    required this.sport,
  });

  final double distanceMeters;
  final int durationSeconds;
  final UnitSystem units;
  final Sport sport;

  @override
  Widget build(BuildContext context) {
    if (distanceMeters <= 0 || durationSeconds <= 0) {
      return const SizedBox.shrink();
    }
    final secPerMeter = durationSeconds / distanceMeters;
    final mps = distanceMeters / durationSeconds;
    final pace = CardioConversions.formatPace(
      secPerMeter,
      units,
      swim: sport == Sport.swim,
    );
    final speed = CardioConversions.formatSpeed(mps, units);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sport == Sport.bike
                    ? 'Avg speed $speed'
                    : 'Pace $pace  •  Avg speed $speed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
