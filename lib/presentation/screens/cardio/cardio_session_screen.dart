import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../core/utils/user_errors.dart';
import '../../../data/models/cardio_detail.dart';
import '../../../data/models/session.dart';
import '../../../data/services/cardio_session_library_service.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/onboarding_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../widgets/cardio/distance_input.dart';
import '../../widgets/cardio/duration_input.dart';
import '../../widgets/cardio/hr_input.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/cardio/sport_badge.dart';
import 'cardio_template_picker.dart';

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
    this.periodNumber,
    this.dayNumber,
    this.planned = false,
  });

  /// Existing session to edit. If null, the screen creates a new one.
  final String? sessionId;

  /// Required when [sessionId] is null — which sport is being logged.
  final Sport? sport;

  /// Optional — attach the new session to this training cycle. Null means
  /// the session is ad-hoc (not tied to a plan).
  final String? trainingCycleId;

  /// Optional — the period this session belongs to in the training cycle.
  /// Used when the creation flow knows which slot the session fills
  /// (e.g., the Add cardio button on the edit-workout screen).
  final int? periodNumber;

  /// Optional — the day number within the period. See [periodNumber].
  final int? dayNumber;

  /// When true, the session is saved as a plan (`WorkoutStatus.incomplete`,
  /// `SessionSource.userPlanned`) with values in the planned detail fields.
  /// Used when adding cardio to a draft cycle or from the sport grid.
  final bool planned;

  @override
  ConsumerState<CardioSessionScreen> createState() => _CardioSessionScreenState();
}

class _CardioSessionScreenState extends ConsumerState<CardioSessionScreen> {
  final _uuid = const Uuid();
  final _labelController = TextEditingController();
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

  /// Set when any form field changes; drives the PopScope discard guard.
  bool _dirty = false;

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void initState() {
    super.initState();
    _sport = widget.sport ?? Sport.run;
    if (widget.sessionId != null) {
      _loadExisting().then((_) {
        _labelController.addListener(_markDirty);
        _notesController.addListener(_markDirty);
      });
    } else {
      _loading = false;
      _labelController.addListener(_markDirty);
      _notesController.addListener(_markDirty);
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
      // Prefill from actuals; fall back to planned values so
      // opening a planned session shows the targets the user set.
      _distanceMeters = loaded.detail?.actualDistanceM ?? loaded.detail?.plannedDistanceM;
      _durationSeconds = loaded.detail?.actualDurationSec ?? loaded.detail?.plannedDurationSec;
      _averageHr = loaded.detail?.averageHr;
      _rpe = loaded.detail?.perceivedExertion;
      _labelController.text = loaded.label ?? '';
      _notesController.text = loaded.notes ?? '';
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  UnitSystem _units() {
    return ref.read(onboardingServiceProvider).unitsFor(_sport);
  }

  bool get _isReadOnly => _existing?.isReadOnly ?? false;

  /// Show the library picker, instantiate the chosen template as a
  /// brand-new CardioSession, save it, and navigate to the interval
  /// builder so the user can review/tune the plan.
  Future<void> _pickTemplate() async {
    final template = await CardioTemplatePicker.show(
      context,
      sport: _sport,
    );
    if (template == null || !mounted) return;
    setState(() => _saving = true);
    try {
      final session = CardioSessionLibraryService.instance.instantiate(
        template,
        sessionId: _uuid.v4(),
        newIntervalId: () => _uuid.v4(),
        trainingCycleId: widget.trainingCycleId,
        periodNumber: widget.periodNumber,
        dayNumber: widget.dayNumber,
        scheduledDate: _scheduledDate,
      );
      await ref.read(sessionRepositoryProvider).createCardio(session);
      ref.invalidate(sessionsProvider);
      if (widget.trainingCycleId != null) {
        ref.invalidate(
          sessionsByTrainingCycleProvider(widget.trainingCycleId!),
        );
      }
      if (!mounted) return;
      // Replace this screen with the interval builder so Back lands the
      // user on wherever they came from originally.
      context.pushReplacement('/cardio-session/${session.id}/intervals');
    } catch (e) {
      if (!mounted) return;
      context.showSnackBar(UserErrors.describe(e, context: 'load template'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    // Promoting a planned session to completed is a meaningful state
    // change — confirm before it happens.
    final promotesPlan =
        _existing != null && _existing!.status == WorkoutStatus.incomplete && !_existing!.source.isExternal;
    if (promotesPlan) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cardioSessionPromoteTitle),
          content: Text(l10n.cardioSessionPromoteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.cardioSessionLogButton),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _saving = true);
    final repo = ref.read(sessionRepositoryProvider);

    // When creating a planned session, values go to the planned fields.
    // When logging (new or completing an existing plan), values go to
    // the actual fields.  Editing an existing planned session promotes
    // it to completed and writes actuals while preserving the original
    // planned targets.
    final isPlanning = widget.planned && _existing == null;

    final detail = isPlanning
        ? CardioDetail(
            plannedDistanceM: _distanceMeters,
            plannedDurationSec: _durationSeconds,
            averageHr: _averageHr,
            perceivedExertion: _rpe,
          )
        : CardioDetail(
            // Preserve original planned values when completing a plan.
            plannedDistanceM: _existing?.detail?.plannedDistanceM,
            plannedDurationSec: _existing?.detail?.plannedDurationSec,
            actualDistanceM: _distanceMeters,
            actualDurationSec: _durationSeconds,
            averageHr: _averageHr,
            perceivedExertion: _rpe,
          );

    final trimmedLabel = _labelController.text.trim().isEmpty ? null : _labelController.text.trim();
    final trimmedNotes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    try {
      if (_existing == null) {
        final session = CardioSession(
          id: _uuid.v4(),
          trainingCycleId: widget.trainingCycleId,
          sport: _sport,
          source: isPlanning ? SessionSource.userPlanned : SessionSource.userLogged,
          status: isPlanning ? WorkoutStatus.incomplete : WorkoutStatus.completed,
          scheduledDate: _scheduledDate,
          completedDate: isPlanning ? null : DateTime.now(),
          label: trimmedLabel,
          notes: trimmedNotes,
          detail: detail,
          periodNumber: widget.periodNumber,
          dayNumber: widget.dayNumber,
        );
        await repo.createCardio(session);
      } else {
        final updated = _existing!.copyWith(
          scheduledDate: _scheduledDate,
          label: trimmedLabel,
          notes: trimmedNotes,
          detail: detail,
          // Completing a planned session promotes to completed.
          status: _existing!.status == WorkoutStatus.incomplete ? WorkoutStatus.completed : _existing!.status,
          completedDate: _existing!.status == WorkoutStatus.incomplete ? DateTime.now() : _existing!.completedDate,
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
      _dirty = false;
      final l10n = AppLocalizations.of(context)!;
      context.showSnackBar(
        _existing == null
            ? (isPlanning ? l10n.cardioSessionPlanned : l10n.cardioSessionLogged)
            : l10n.cardioSessionUpdated,
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(UserErrors.describe(e, context: 'save session'));
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

    final l10n = AppLocalizations.of(context)!;
    final units = _units();
    final sportName = _sport.localizedName(l10n).toLowerCase();
    final String title;
    if (_existing != null) {
      title = _existing!.status == WorkoutStatus.incomplete
          ? l10n.cardioSessionLogTitle(sportName)
          : l10n.cardioSessionEditTitle(sportName);
    } else {
      title = widget.planned ? l10n.cardioSessionPlanTitle(sportName) : l10n.cardioSessionLogTitle(sportName);
    }

    // Explicit Plan vs Log mode indicator (segmented, non-interactive).
    final isPlanMode = (_existing == null && widget.planned) || (_existing?.status == WorkoutStatus.incomplete);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (_existing != null)
              IconButton(
                tooltip: l10n.cardioSessionEditIntervalsTooltip,
                icon: const Icon(Icons.timeline),
                onPressed: () {
                  context.push(
                    '/cardio-session/${_existing!.id}/intervals',
                  );
                },
              ),
            if (_isReadOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Chip(label: Text(l10n.cardioSessionImportedChip), visualDensity: VisualDensity.compact),
              ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!_isReadOnly) ...[
                _ModeIndicator(isPlan: isPlanMode),
                const SizedBox(height: 12),
              ],
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
                    label: Text(l10n.cardioSessionDateButton),
                  ),
                ],
              ),
              // "Start from template" — only shown when creating a new
              // session. Opens the template picker, instantiates the
              // chosen one via SessionRepository, and routes straight to
              // the interval builder so the user can review/edit.
              if (_existing == null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickTemplate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.cardioSessionStartFromTemplate),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                enabled: !_isReadOnly,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.cardioSessionNameLabel,
                  hintText: l10n.cardioSessionNameHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),
              DistanceInput(
                key: ValueKey('distance-${_sport.name}-${units.name}'),
                initialMeters: _distanceMeters,
                units: units,
                sport: _sport,
                enabled: !_isReadOnly,
                onChanged: (meters) {
                  _distanceMeters = meters;
                  _markDirty();
                },
              ),
              const SizedBox(height: 12),
              DurationInput(
                key: ValueKey('duration-${_existing?.id ?? 'new'}'),
                initialSeconds: _durationSeconds,
                enabled: !_isReadOnly,
                onChanged: (seconds) {
                  _durationSeconds = seconds;
                  _markDirty();
                },
              ),
              const SizedBox(height: 12),
              HrInput(
                key: ValueKey('hr-${_existing?.id ?? 'new'}'),
                initialBpm: _averageHr,
                enabled: !_isReadOnly,
                onChanged: (bpm) {
                  _averageHr = bpm;
                  _markDirty();
                },
              ),
              const SizedBox(height: 16),
              _RpeSlider(
                value: _rpe,
                onChanged: (v) => setState(() {
                  _rpe = v;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.cardioSessionNotesLabel,
                  hintText: l10n.cardioSessionNotesHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_note),
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
                  _existing == null
                      ? (widget.planned ? l10n.cardioSessionPlanButton : l10n.cardioSessionSaveButton)
                      : (_existing!.status == WorkoutStatus.incomplete
                            ? l10n.cardioSessionLogButton
                            : l10n.cardioSessionUpdateButton),
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
      ),
    );
  }

  /// Discard-changes confirmation for the PopScope guard.
  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDiscardTitle),
        content: Text(l10n.settingsDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsKeepEditingButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsDiscardButton),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _dateLabel() {
    return DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_scheduledDate);
  }
}

/// Non-interactive Plan/Log mode indicator so users always know whether
/// saving produces a target or a completed workout.
class _ModeIndicator extends StatelessWidget {
  const _ModeIndicator({required this.isPlan});

  final bool isPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IgnorePointer(
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment<bool>(
            value: true,
            icon: const Icon(Icons.event_note, size: 16),
            label: Text(l10n.cardioSessionModePlan),
          ),
          ButtonSegment<bool>(
            value: false,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: Text(l10n.cardioSessionModeLog),
          ),
        ],
        selected: {isPlan},
        onSelectionChanged: null,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }
}

/// RPE slider (1–10). Null value means "not set"; the clear button makes
/// the not-set state an explicit affordance instead of a hidden zero.
class _RpeSlider extends StatelessWidget {
  const _RpeSlider({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.cardioSessionPerceivedExertion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            Text(
              value != null ? l10n.cardioSessionRpeValue(value!) : l10n.cardioSessionRpeNotSet,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (value != null)
              IconButton(
                tooltip: l10n.cardioSessionRpeClearTooltip,
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: () => onChanged(null),
              ),
          ],
        ),
        Slider(
          value: (value ?? 1).toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: value != null ? l10n.cardioSessionRpeValue(value!) : l10n.cardioSessionRpeNotSet,
          onChanged: (v) => onChanged(v.toInt()),
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
    final l10n = AppLocalizations.of(context)!;
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
                sport == Sport.bike ? l10n.cardioSessionAvgSpeed(speed) : l10n.cardioSessionPaceAvgSpeed(pace, speed),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
