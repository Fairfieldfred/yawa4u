import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/sports.dart';
import '../../../core/utils/cardio_conversions.dart';
import '../../../core/utils/user_errors.dart';
import '../../../data/models/session.dart';
import '../../../data/models/session_interval.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/session_providers.dart';
import '../../widgets/cardio/sport_badge.dart';

/// Interval builder for a cardio session.
///
/// v1 scope — "functional not fancy":
///   * Full-page list editor tied to a single [CardioSession].
///   * Add / remove / reorder intervals via buttons (no drag-to-reorder
///     yet; that lands in a polish pass).
///   * Target-kind picker per interval: duration (sec), distance (m), or
///     HR zone (1..5). Pace and power zones are stored by the model but
///     intentionally not exposed yet — they need Settings → Zones to have
///     been configured per-sport first.
///   * Nested repeat groups are a v2 feature; the data model already
///     supports them via `parentIntervalUuid`, but v1 keeps the list flat.
///
/// Persistence is a single `SessionRepository.updateCardio` call on save —
/// the method diffs old intervals vs. new and reconciles.
class IntervalBuilderScreen extends ConsumerStatefulWidget {
  const IntervalBuilderScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<IntervalBuilderScreen> createState() =>
      _IntervalBuilderScreenState();
}

class _IntervalBuilderScreenState
    extends ConsumerState<IntervalBuilderScreen> {
  final _uuid = const Uuid();
  CardioSession? _session;
  List<SessionInterval> _intervals = [];
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(sessionRepositoryProvider);
    final session = await repo.getById(widget.sessionId);
    if (!mounted) return;
    if (session is CardioSession) {
      setState(() {
        _session = session;
        _intervals = List<SessionInterval>.from(session.intervals);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _addInterval(IntervalIntent intent) {
    setState(() {
      _intervals.add(
        SessionInterval(
          id: _uuid.v4(),
          sessionId: widget.sessionId,
          orderIndex: _intervals.length,
          intent: intent,
          targetKind: IntervalTargetKind.durationSec,
          targetDurationSec: _defaultDurationForIntent(intent),
          repeatCount: intent == IntervalIntent.repeatGroup ? 4 : null,
        ),
      );
      _dirty = true;
    });
  }

  /// Add a child interval to an existing repeat-group row. The child
  /// is inserted right after the last existing child of that group so
  /// the rendered tree stays cohesive.
  void _addToRepeat(String parentId, IntervalIntent intent) {
    final parentIdx = _intervals.indexWhere((i) => i.id == parentId);
    if (parentIdx < 0) return;
    // Find insertion index — after the last contiguous child of this
    // parent, or immediately after the parent if no children yet.
    var insertAt = parentIdx + 1;
    while (insertAt < _intervals.length &&
        _intervals[insertAt].parentIntervalId == parentId) {
      insertAt++;
    }
    setState(() {
      _intervals.insert(
        insertAt,
        SessionInterval(
          id: _uuid.v4(),
          sessionId: widget.sessionId,
          orderIndex: insertAt,
          intent: intent,
          targetKind: IntervalTargetKind.durationSec,
          targetDurationSec: _defaultDurationForIntent(intent),
          parentIntervalId: parentId,
        ),
      );
      _reindex();
      _dirty = true;
    });
  }

  void _removeInterval(int index) {
    setState(() {
      final removed = _intervals.removeAt(index);
      // Cascade delete — if we nuked a repeat group, its children
      // become orphans, so remove them too.
      if (removed.intent == IntervalIntent.repeatGroup) {
        _intervals.removeWhere((i) => i.parentIntervalId == removed.id);
      }
      _reindex();
      _dirty = true;
    });
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    setState(() {
      final item = _intervals.removeAt(index);
      _intervals.insert(index - 1, item);
      _reindex();
      _dirty = true;
    });
  }

  void _moveDown(int index) {
    if (index >= _intervals.length - 1) return;
    setState(() {
      final item = _intervals.removeAt(index);
      _intervals.insert(index + 1, item);
      _reindex();
      _dirty = true;
    });
  }

  /// Handler for [ReorderableListView.onReorder]. Material's callback
  /// quirk: newIndex is post-removal, so we decrement when moving down.
  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _intervals.removeAt(oldIndex);
      _intervals.insert(newIndex, item);
      _reindex();
      _dirty = true;
    });
  }

  void _updateInterval(int index, SessionInterval updated) {
    setState(() {
      _intervals[index] = updated;
      _dirty = true;
    });
  }

  void _reindex() {
    for (var i = 0; i < _intervals.length; i++) {
      _intervals[i] = _intervals[i].copyWith(orderIndex: i);
    }
  }

  Future<void> _save() async {
    final session = _session;
    if (session == null) return;
    setState(() => _saving = true);
    try {
      final updated = session.copyWith(intervals: _intervals);
      await ref.read(sessionRepositoryProvider).updateCardio(updated);
      ref.invalidate(sessionProvider(session.id));
      if (session.trainingCycleId != null) {
        ref.invalidate(
          sessionsByTrainingCycleProvider(session.trainingCycleId!),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intervals saved')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserErrors.describe(e, context: 'save intervals')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes to this interval plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final session = _session;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('Cardio session not found')),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) {
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Intervals'),
          actions: [
            TextButton(
              onPressed: _saving || !_dirty ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    SportBadge(sport: session.sport),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.displayName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${_intervals.length} steps',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _intervals.isEmpty
                    ? _EmptyState(onAdd: _addInterval)
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        itemCount: _intervals.length,
                        onReorder: _reorder,
                        buildDefaultDragHandles: false,
                        itemBuilder: (ctx, i) {
                          final interval = _intervals[i];
                          return _IntervalEditorRow(
                            key: ValueKey(interval.id),
                            index: i,
                            interval: interval,
                            isFirst: i == 0,
                            isLast: i == _intervals.length - 1,
                            isChild: interval.parentIntervalId != null,
                            onChanged: (u) => _updateInterval(i, u),
                            onRemove: () => _removeInterval(i),
                            onMoveUp: () => _moveUp(i),
                            onMoveDown: () => _moveDown(i),
                            onAddToRepeat:
                                interval.intent == IntervalIntent.repeatGroup
                                    ? () => _showAddMenu(
                                          ctx,
                                          (intent) =>
                                              _addToRepeat(interval.id, intent),
                                          includeRepeatGroup: false,
                                        )
                                    : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saving
              ? null
              : () => _showAddMenu(context, _addInterval),
          icon: const Icon(Icons.add),
          label: const Text('Add step'),
        ),
      ),
    );
  }
}

int _defaultDurationForIntent(IntervalIntent intent) {
  switch (intent) {
    case IntervalIntent.warmup:
      return 600; // 10 min
    case IntervalIntent.work:
      return 300; // 5 min
    case IntervalIntent.recovery:
      return 120; // 2 min
    case IntervalIntent.rest:
      return 60;
    case IntervalIntent.cooldown:
      return 300;
    case IntervalIntent.repeatGroup:
      return 0;
  }
}

Future<void> _showAddMenu(
  BuildContext context,
  void Function(IntervalIntent) onPick, {
  bool includeRepeatGroup = true,
}) async {
  final choices = <IntervalIntent>[
    IntervalIntent.warmup,
    IntervalIntent.work,
    IntervalIntent.recovery,
    IntervalIntent.rest,
    IntervalIntent.cooldown,
    if (includeRepeatGroup) IntervalIntent.repeatGroup,
  ];
  final pick = await showModalBottomSheet<IntervalIntent>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in choices)
            ListTile(
              leading: Icon(_iconForIntent(c)),
              title: Text(c.displayName),
              subtitle: c == IntervalIntent.repeatGroup
                  ? const Text('Group several steps and run them N times')
                  : null,
              onTap: () => Navigator.pop(ctx, c),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (pick != null) onPick(pick);
}

IconData _iconForIntent(IntervalIntent i) {
  switch (i) {
    case IntervalIntent.warmup:
      return Icons.local_fire_department_outlined;
    case IntervalIntent.work:
      return Icons.bolt;
    case IntervalIntent.recovery:
      return Icons.waves;
    case IntervalIntent.rest:
      return Icons.pause_circle_outline;
    case IntervalIntent.cooldown:
      return Icons.downloading;
    case IntervalIntent.repeatGroup:
      return Icons.repeat;
  }
}

Color _colorForIntent(BuildContext context, IntervalIntent i) {
  switch (i) {
    case IntervalIntent.warmup:
      return Colors.orange;
    case IntervalIntent.work:
      return Theme.of(context).colorScheme.primary;
    case IntervalIntent.recovery:
      return Colors.blue;
    case IntervalIntent.rest:
      return Colors.grey;
    case IntervalIntent.cooldown:
      return Colors.indigo;
    case IntervalIntent.repeatGroup:
      return Colors.purple;
  }
}

/// Editor for a single interval. Compact but covers the three v1 target
/// kinds: duration, distance, HR zone.
class _IntervalEditorRow extends ConsumerStatefulWidget {
  const _IntervalEditorRow({
    super.key,
    required this.index,
    required this.interval,
    required this.isFirst,
    required this.isLast,
    required this.onChanged,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    this.isChild = false,
    this.onAddToRepeat,
  });

  /// Position of this row in the parent's list. Required for
  /// [ReorderableDragStartListener] to know which item the drag handle
  /// belongs to.
  final int index;
  final SessionInterval interval;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<SessionInterval> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  /// True if this interval has a `parentIntervalId` — rendered indented
  /// so the tree structure is visible.
  final bool isChild;

  /// Non-null only on repeat-group rows. Opens the add-intent picker
  /// with the result wired to become a child of this row.
  final VoidCallback? onAddToRepeat;

  @override
  ConsumerState<_IntervalEditorRow> createState() =>
      _IntervalEditorRowState();
}

class _IntervalEditorRowState extends ConsumerState<_IntervalEditorRow> {
  @override
  Widget build(BuildContext context) {
    final i = widget.interval;
    final color = _colorForIntent(context, i.intent);
    final isRepeat = i.intent == IntervalIntent.repeatGroup;
    // Indent child rows so the tree structure reads at a glance. A
    // thin colored stripe on the left also helps.
    final leftMargin = widget.isChild ? 24.0 : 0.0;
    return Card(
      margin: EdgeInsets.fromLTRB(leftMargin, 4, 0, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Drag handle — long-press to start reordering on mobile,
                // or just press-hold + drag on desktop.
                ReorderableDragStartListener(
                  index: widget.index,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.drag_indicator,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Icon(_iconForIntent(i.intent), color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  i.intent.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Up/down arrows stay for accessibility — drag-to-reorder
                // is a pointer-only interaction, these remain reachable
                // by screen readers and keyboard users.
                IconButton(
                  tooltip: 'Move up',
                  icon: const Icon(Icons.keyboard_arrow_up),
                  onPressed: widget.isFirst ? null : widget.onMoveUp,
                ),
                IconButton(
                  tooltip: 'Move down',
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: widget.isLast ? null : widget.onMoveDown,
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (isRepeat) ...[
              // Repeat-count input — how many times to iterate the
              // group's children. No target-kind / target-value fields
              // for the group itself; those live on the children.
              _RepeatCountField(
                count: i.repeatCount ?? 4,
                onChanged: (count) =>
                    widget.onChanged(i.copyWith(repeatCount: count)),
              ),
              if (widget.onAddToRepeat != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: widget.onAddToRepeat,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add to repeat'),
                  ),
                ),
              ],
            ] else ...[
            _TargetKindPicker(
              value: i.targetKind,
              onChanged: (kind) {
                // Clear whichever target fields are about to become
                // irrelevant so stale data doesn't linger in the DB.
                final updated = i.copyWith(
                  targetKind: kind,
                  targetDurationSec: kind == IntervalTargetKind.durationSec
                      ? (i.targetDurationSec ?? 60)
                      : null,
                  targetDistanceM: kind == IntervalTargetKind.distanceM
                      ? (i.targetDistanceM ?? 400)
                      : null,
                  targetHrZone: kind == IntervalTargetKind.hrZone
                      ? (i.targetHrZone ?? 2)
                      : null,
                  targetPaceZone: kind == IntervalTargetKind.paceZone
                      ? (i.targetPaceZone ?? 2)
                      : null,
                  targetPowerZone: kind == IntervalTargetKind.powerZone
                      ? (i.targetPowerZone ?? 2)
                      : null,
                );
                widget.onChanged(updated);
              },
            ),
            const SizedBox(height: 8),
            _TargetValueField(
              interval: i,
              onChanged: widget.onChanged,
            ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline integer input for a repeat group's `repeatCount` value. Uses
/// a small TextFormField constrained to 2 digits so the row stays compact.
class _RepeatCountField extends StatefulWidget {
  const _RepeatCountField({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  State<_RepeatCountField> createState() => _RepeatCountFieldState();
}

class _RepeatCountFieldState extends State<_RepeatCountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.count}');
  }

  @override
  void didUpdateWidget(covariant _RepeatCountField old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count &&
        int.tryParse(_controller.text) != widget.count) {
      _controller.text = '${widget.count}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Repeat'),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            onChanged: (raw) {
              final n = int.tryParse(raw);
              if (n != null && n > 0) widget.onChanged(n);
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text('times'),
      ],
    );
  }
}

class _TargetKindPicker extends StatelessWidget {
  const _TargetKindPicker({required this.value, required this.onChanged});

  final IntervalTargetKind value;
  final ValueChanged<IntervalTargetKind> onChanged;

  /// Five kinds don't fit a SegmentedButton cleanly on a phone, so this
  /// is a DropdownButton. The icon-per-kind helps scanning the options.
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IntervalTargetKind>(
      initialValue: value,
      isDense: true,
      decoration: const InputDecoration(
        labelText: 'Target type',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(
          value: IntervalTargetKind.durationSec,
          child: _TargetKindRow(icon: Icons.timer_outlined, label: 'Duration'),
        ),
        DropdownMenuItem(
          value: IntervalTargetKind.distanceM,
          child: _TargetKindRow(icon: Icons.straighten, label: 'Distance'),
        ),
        DropdownMenuItem(
          value: IntervalTargetKind.hrZone,
          child: _TargetKindRow(
            icon: Icons.favorite_outline,
            label: 'HR zone',
          ),
        ),
        DropdownMenuItem(
          value: IntervalTargetKind.paceZone,
          child: _TargetKindRow(icon: Icons.speed, label: 'Pace zone'),
        ),
        DropdownMenuItem(
          value: IntervalTargetKind.powerZone,
          child: _TargetKindRow(icon: Icons.bolt, label: 'Power zone'),
        ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _TargetKindRow extends StatelessWidget {
  const _TargetKindRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _TargetValueField extends StatefulWidget {
  const _TargetValueField({
    required this.interval,
    required this.onChanged,
  });

  final SessionInterval interval;
  final ValueChanged<SessionInterval> onChanged;

  @override
  State<_TargetValueField> createState() => _TargetValueFieldState();
}

class _TargetValueFieldState extends State<_TargetValueField> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _renderCurrent());
  }

  @override
  void didUpdateWidget(covariant _TargetValueField old) {
    super.didUpdateWidget(old);
    if (old.interval.targetKind != widget.interval.targetKind) {
      _controller.text = _renderCurrent();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _renderCurrent() {
    final i = widget.interval;
    switch (i.targetKind) {
      case IntervalTargetKind.durationSec:
        return i.targetDurationSec != null
            ? CardioConversions.formatDuration(i.targetDurationSec!)
            : '';
      case IntervalTargetKind.distanceM:
        return i.targetDistanceM != null
            ? i.targetDistanceM!.toStringAsFixed(0)
            : '';
      case IntervalTargetKind.hrZone:
        return i.targetHrZone != null ? '${i.targetHrZone}' : '';
      case IntervalTargetKind.paceZone:
        return i.targetPaceZone != null ? '${i.targetPaceZone}' : '';
      case IntervalTargetKind.powerZone:
        return i.targetPowerZone != null ? '${i.targetPowerZone}' : '';
      case IntervalTargetKind.freeform:
        return i.targetFreeform ?? '';
    }
  }

  void _commit(String raw) {
    final i = widget.interval;
    switch (i.targetKind) {
      case IntervalTargetKind.durationSec:
        final seconds = CardioConversions.parseDuration(raw.trim());
        if (seconds == null && raw.isNotEmpty) {
          setState(() => _error = 'Use MM:SS');
          return;
        }
        setState(() => _error = null);
        widget.onChanged(i.copyWith(targetDurationSec: seconds));
      case IntervalTargetKind.distanceM:
        final meters = double.tryParse(raw.trim());
        if (meters == null && raw.isNotEmpty) {
          setState(() => _error = 'Enter meters');
          return;
        }
        setState(() => _error = null);
        widget.onChanged(i.copyWith(targetDistanceM: meters));
      case IntervalTargetKind.hrZone:
        final zone = int.tryParse(raw.trim());
        if (zone == null || zone < 1 || zone > 5) {
          setState(() => _error = '1..5');
          return;
        }
        setState(() => _error = null);
        widget.onChanged(i.copyWith(targetHrZone: zone));
      case IntervalTargetKind.paceZone:
        final zone = int.tryParse(raw.trim());
        if (zone == null || zone < 1 || zone > 5) {
          setState(() => _error = '1..5');
          return;
        }
        setState(() => _error = null);
        widget.onChanged(i.copyWith(targetPaceZone: zone));
      case IntervalTargetKind.powerZone:
        final zone = int.tryParse(raw.trim());
        if (zone == null || zone < 1 || zone > 5) {
          setState(() => _error = '1..5');
          return;
        }
        setState(() => _error = null);
        widget.onChanged(i.copyWith(targetPowerZone: zone));
      case IntervalTargetKind.freeform:
        setState(() => _error = null);
        widget.onChanged(
          i.copyWith(targetFreeform: raw.trim().isEmpty ? null : raw),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.interval;
    final label = switch (i.targetKind) {
      IntervalTargetKind.durationSec => 'Duration',
      IntervalTargetKind.distanceM => 'Distance (m)',
      IntervalTargetKind.hrZone => 'HR zone (1..5)',
      IntervalTargetKind.paceZone => 'Pace zone (1..5)',
      IntervalTargetKind.powerZone => 'Power zone (1..5)',
      IntervalTargetKind.freeform => 'Target (free text)',
    };
    final kind = i.targetKind;
    final isDuration = kind == IntervalTargetKind.durationSec;
    final isFreeform = kind == IntervalTargetKind.freeform;
    return TextField(
      controller: _controller,
      keyboardType: isDuration
          ? TextInputType.datetime
          : isFreeform
              ? TextInputType.text
              : TextInputType.number,
      inputFormatters: isDuration
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9:]'))]
          : isFreeform
              ? null
              : [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        errorText: _error,
      ),
      onChanged: _commit,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final void Function(IntervalIntent) onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No intervals yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A structured plan looks like warm-up → work → recovery '
              '→ cooldown. Start with a warm-up.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => onAdd(IntervalIntent.warmup),
              icon: const Icon(Icons.add),
              label: const Text('Add warm-up'),
            ),
          ],
        ),
      ),
    );
  }
}
