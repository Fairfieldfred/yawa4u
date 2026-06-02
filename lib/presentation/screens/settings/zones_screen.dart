import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/sports.dart';
import '../../../data/models/sport_zone.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/cardio/sport_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/skeleton_loader.dart';

/// Settings → Zones screen.
///
/// Per-sport HR / pace / power zone editor. v1 focuses on HR zones (bpm)
/// for run / bike / swim — the most commonly configured. Pace and power
/// zones get their own pickers in a follow-up; SportZoneRepository already
/// supports them via the `unit` field.
///
/// Five zones per sport is the conventional count. Default starting values
/// (age-agnostic) seed a sensible starting point for users who don't have
/// lab-tested numbers — they're meant to be edited, not taken as gospel.
class ZonesScreen extends ConsumerStatefulWidget {
  const ZonesScreen({super.key});

  @override
  ConsumerState<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends ConsumerState<ZonesScreen> with SingleTickerProviderStateMixin {
  static const _sports = [Sport.run, Sport.bike, Sport.swim];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sports.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.zonesTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [for (final s in _sports) Tab(text: s.displayName)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final s in _sports) _SportZonesTab(sport: s)],
      ),
    );
  }
}

class _SportZonesTab extends ConsumerStatefulWidget {
  const _SportZonesTab({required this.sport});

  final Sport sport;

  @override
  ConsumerState<_SportZonesTab> createState() => _SportZonesTabState();
}

class _SportZonesTabState extends ConsumerState<_SportZonesTab> {
  bool _saving = false;

  Future<void> _seedDefaults() async {
    final repo = ref.read(sportZoneRepositoryProvider);
    final now = DateTime.now();
    final uuid = const Uuid();
    final seeded = _defaultHrZonesFor(widget.sport, uuid, now);
    await repo.replaceAllForSport(widget.sport, seeded);
    if (mounted) setState(() {});
  }

  Future<void> _updateZone(SportZone zone) async {
    final repo = ref.read(sportZoneRepositoryProvider);
    await repo.update(zone);
  }

  Future<void> _clear() async {
    final repo = ref.read(sportZoneRepositoryProvider);
    setState(() => _saving = true);
    await repo.replaceAllForSport(widget.sport, const []);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(
      sportZoneRepositoryProvider,
    ); // used for writes — reads via stream provider below.
    final streamAsync = ref.watch(_zoneStreamProvider(widget.sport));

    return AbsorbPointer(
      absorbing: _saving,
      child: streamAsync.when(
        loading: () => const SkeletonZoneList(),
        error: (e, _) => Center(
          child: Text(AppLocalizations.of(context)!.zonesErrorLoading(e)),
        ),
        data: (zones) {
          if (zones.isEmpty) {
            return _EmptyState(
              sport: widget.sport,
              onSeed: _seedDefaults,
            );
          }
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  SportBadge(sport: widget.sport),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(l10n.zonesClear),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.zonesHrDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              for (final zone
                  in zones..sort(
                    (a, b) => a.zoneNumber.compareTo(b.zoneNumber),
                  ))
                _ZoneRow(
                  zone: zone,
                  onChanged: _updateZone,
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _seedDefaults,
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.zonesResetToDefaults),
              ),
              // Keep the repo variable referenced so the watch above is
              // meaningful in reactive builds.
              if (zonesAsync.hashCode == 0) const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

/// Stream provider for the zones of a single sport. Kept file-private because
/// it's specific to this screen's rendering (the general-purpose
/// sportZonesProvider lives in session_providers.dart).
final _zoneStreamProvider = StreamProvider.autoDispose.family<List<SportZone>, Sport>((ref, sport) {
  final repo = ref.watch(sportZoneRepositoryProvider);
  return repo.watchBySport(sport);
});

class _ZoneRow extends StatefulWidget {
  const _ZoneRow({required this.zone, required this.onChanged});

  final SportZone zone;
  final Future<void> Function(SportZone) onChanged;

  @override
  State<_ZoneRow> createState() => _ZoneRowState();
}

class _ZoneRowState extends State<_ZoneRow> {
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(
      text: widget.zone.minValue.toStringAsFixed(0),
    );
    _maxCtrl = TextEditingController(
      text: widget.zone.maxValue.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final min = double.tryParse(_minCtrl.text);
    final max = double.tryParse(_maxCtrl.text);
    if (min == null || max == null || max <= min) return;
    final updated = widget.zone.copyWith(minValue: min, maxValue: max);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final zoneLabel = l10n.zonesZoneLabel(widget.zone.zoneNumber);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              zoneLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.zonesMinLabel,
                border: const OutlineInputBorder(),
                suffixText: l10n.zonesBpmSuffix,
                isDense: true,
              ),
              onEditingComplete: _commit,
              onTapOutside: (_) => _commit(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.zonesMaxLabel,
                border: const OutlineInputBorder(),
                suffixText: l10n.zonesBpmSuffix,
                isDense: true,
              ),
              onEditingComplete: _commit,
              onTapOutside: (_) => _commit(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.sport, required this.onSeed});

  final Sport sport;
  final VoidCallback onSeed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: sport.icon,
      iconSize: 64,
      iconColor: sport.color.withValues(alpha: 0.6),
      title: l10n.zonesNoZones(sport.displayName),
      subtitle: l10n.zonesNoZonesSubtitle,
      padding: const EdgeInsets.all(24),
      primaryAction: EmptyStateAction(
        label: l10n.zonesSeedDefaults,
        icon: Icons.add,
        onPressed: onSeed,
      ),
    );
  }
}

/// Default HR zones (bpm) for a given sport.
///
/// These are intentionally conservative starting points, not gospel.
/// Classical 5-zone HR splits aligned roughly to percentages of a
/// hypothetical 180 bpm max — users should adjust to their actual numbers.
List<SportZone> _defaultHrZonesFor(Sport sport, Uuid uuid, DateTime now) {
  // %LTHR-ish bands (50/60/70/80/90 → max), as bpm.
  const bands = [
    (1, 90, 120),
    (2, 120, 140),
    (3, 140, 155),
    (4, 155, 170),
    (5, 170, 190),
  ];

  return [
    for (final band in bands)
      SportZone(
        id: uuid.v4(),
        sport: sport,
        zoneNumber: band.$1,
        minValue: band.$2.toDouble(),
        maxValue: band.$3.toDouble(),
        unit: 'bpm',
        createdAt: now,
      ),
  ];
}
