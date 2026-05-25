import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/health_sync_service.dart';
import '../../../data/services/strava_integration_service.dart';
import '../../../domain/providers/health_providers.dart';
import '../../../domain/providers/session_providers.dart';

/// Settings → Integrations.
///
/// v1 carries a single card for Apple Health / Health Connect. The card
/// exposes the three interactions that matter: request permissions,
/// trigger a sync, reset the incremental cursor. Peloton shows up as an
/// information note — no separate integration toggle, because paired
/// Peloton rides flow through Apple Health / Health Connect and the Health
/// card already covers them.
///
/// Future cards (Strava / Garmin / etc.) slot into the same [ListView]
/// below.
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  HealthSyncResult? _lastResult;
  bool _busy = false;

  Future<void> _requestPermissions() async {
    if (_busy) return;
    setState(() => _busy = true);
    final granted = await ref.read(healthSyncServiceProvider).requestPermissions();
    ref.invalidate(healthSyncStatusProvider);
    if (!mounted) return;
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health permissions granted')),
      );
    } else {
      _showHealthConnectGuide();
    }
    setState(() => _busy = false);
  }

  void _showHealthConnectGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Colors.green),
            SizedBox(width: 12),
            Expanded(child: Text('Health Connect Required')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To sync workouts from Health Connect and Peloton, '
              'please follow these steps:',
            ),
            SizedBox(height: 16),
            Text(
              '1. Download and install Health Connect from the '
              'Google Play Store (Android 14+ has it built in).',
            ),
            SizedBox(height: 8),
            Text(
              '2. Open Health Connect and go to '
              'App permissions.',
            ),
            SizedBox(height: 8),
            Text(
              '3. Find Yawa4u in the list and allow access '
              'to Exercise sessions, Heart rate, Distance, '
              'and Active energy burned.',
            ),
            SizedBox(height: 8),
            Text(
              '4. Return here and tap "Grant permissions" '
              'again.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Future<void> _sync() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(healthSyncServiceProvider).syncNow();
    // New cardio sessions may have landed — repaint any session lists.
    ref.invalidate(sessionsProvider);
    ref.invalidate(healthSyncStatusProvider);
    if (!mounted) return;
    setState(() {
      _lastResult = result;
      _busy = false;
    });
    final text = result.isSuccess
        ? 'Imported ${result.imported} · '
              '${result.skippedDuplicate} duplicate · '
              '${result.skippedUnsupportedType} unsupported'
        : 'Sync failed: ${result.error}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _resetCursor() async {
    await ref.read(healthSyncServiceProvider).resetCursor();
    ref.invalidate(healthSyncStatusProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Next sync will look back 3 months.'),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(healthSyncServiceProvider);
    final statusAsync = ref.watch(healthSyncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HealthCard(
            providerName: service.providerName,
            isSupported: service.isSupported,
            statusAsync: statusAsync,
            lastSyncAt: service.lastSyncAt,
            lastResult: _lastResult,
            busy: _busy,
            onRequestPermissions: _requestPermissions,
            onSync: _sync,
            onResetCursor: _resetCursor,
          ),
          const SizedBox(height: 16),
          _PelotonNote(providerName: service.providerName),
          const SizedBox(height: 16),
          const _StravaCard(),
          const SizedBox(height: 16),
          _FuturePartnersCard(),
        ],
      ),
    );
  }
}

/// Strava integration card. Mirrors [_HealthCard] but with connect/
/// disconnect instead of permissions. "Unconfigured" state (no
/// client_id in the build) shows a muted card explaining what's needed
/// rather than a dead Connect button.
class _StravaCard extends ConsumerStatefulWidget {
  const _StravaCard();

  @override
  ConsumerState<_StravaCard> createState() => _StravaCardState();
}

class _StravaCardState extends ConsumerState<_StravaCard> {
  StravaSyncResult? _lastResult;
  bool _busy = false;

  Future<void> _connect() async {
    if (_busy) return;
    setState(() => _busy = true);
    final success = await ref.read(stravaIntegrationServiceProvider).connect();
    ref.invalidate(stravaSyncStatusProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Connected to Strava' : 'Could not connect to Strava',
        ),
      ),
    );
    setState(() => _busy = false);
  }

  Future<void> _sync() async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref.read(stravaIntegrationServiceProvider).syncNow();
    ref.invalidate(sessionsProvider);
    ref.invalidate(stravaSyncStatusProvider);
    if (!mounted) return;
    setState(() {
      _lastResult = result;
      _busy = false;
    });
    final text = result.isSuccess
        ? 'Imported ${result.imported} · '
              '${result.skippedDuplicate} duplicate · '
              '${result.skippedUnsupportedType} unsupported'
        : 'Sync failed: ${result.error}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    await ref.read(stravaIntegrationServiceProvider).disconnect();
    ref.invalidate(stravaSyncStatusProvider);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(stravaIntegrationServiceProvider);
    final statusAsync = ref.watch(stravaSyncStatusProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_run,
                  color: Color(0xFFFC4C02), // Strava brand orange
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Strava',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StravaStatusBadge(
                  statusAsync: statusAsync,
                  isConfigured: service.isConfigured,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!service.isConfigured)
              Text(
                'Strava requires client credentials at build time. See the '
                'README or the Bucket 3 hand-off doc for setup steps.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Text(
                'Pull activities from Strava — runs, rides, swims import '
                'with distance, duration, HR, and elevation.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            if (service.lastSyncAt != null)
              Text(
                'Last sync: ${_formatTimestamp(service.lastSyncAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            if (_lastResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _lastResult!.isSuccess
                      ? 'Last run: +${_lastResult!.imported} imported · '
                            '${_lastResult!.skippedDuplicate} already here · '
                            '${_lastResult!.skippedUnsupportedType} non-cardio skipped'
                            '${_lastResult!.failed > 0 ? ' · ${_lastResult!.failed} failed' : ''}'
                      : _lastResult!.error ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            if (service.isConfigured)
              statusAsync.when(
                data: (status) => _buildActionRow(status, service),
                loading: () => const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    StravaSyncStatus status,
    StravaIntegrationService service,
  ) {
    switch (status) {
      case StravaSyncStatus.unconfigured:
        return const SizedBox.shrink();
      case StravaSyncStatus.notConnected:
        return FilledButton.icon(
          onPressed: _busy ? null : _connect,
          icon: const Icon(Icons.link),
          label: const Text('Connect to Strava'),
        );
      case StravaSyncStatus.ready:
      case StravaSyncStatus.syncing:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _sync,
              icon: _busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _disconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect'),
            ),
          ],
        );
    }
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }
}

class _StravaStatusBadge extends StatelessWidget {
  const _StravaStatusBadge({
    required this.statusAsync,
    required this.isConfigured,
  });

  final AsyncValue<StravaSyncStatus> statusAsync;
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    if (!isConfigured) {
      return _badge(context, label: 'Unconfigured', color: Colors.grey);
    }
    return statusAsync.when(
      data: (status) {
        switch (status) {
          case StravaSyncStatus.ready:
            return _badge(context, label: 'Connected', color: Colors.green);
          case StravaSyncStatus.notConnected:
            return _badge(context, label: 'Not connected', color: Colors.orange);
          case StravaSyncStatus.syncing:
            return _badge(context, label: 'Syncing…', color: Colors.blue);
          case StravaSyncStatus.unconfigured:
            return _badge(
              context,
              label: 'Unconfigured',
              color: Colors.grey,
            );
        }
      },
      loading: () => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => _badge(context, label: 'Error', color: Colors.red),
    );
  }

  Widget _badge(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.providerName,
    required this.isSupported,
    required this.statusAsync,
    required this.lastSyncAt,
    required this.lastResult,
    required this.busy,
    required this.onRequestPermissions,
    required this.onSync,
    required this.onResetCursor,
  });

  final String providerName;
  final bool isSupported;
  final AsyncValue<HealthSyncStatus> statusAsync;
  final DateTime? lastSyncAt;
  final HealthSyncResult? lastResult;
  final bool busy;
  final VoidCallback onRequestPermissions;
  final VoidCallback onSync;
  final VoidCallback onResetCursor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    providerName,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusBadge(
                  statusAsync: statusAsync,
                  isSupported: isSupported,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isSupported
                  ? 'Pull completed workouts (runs, rides, swims) from '
                        '$providerName so they join your training history.'
                  : 'This integration is only available on iOS and Android '
                        'devices.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (lastSyncAt != null)
              Text(
                'Last sync: ${_formatTimestamp(lastSyncAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            if (lastResult != null) _ResultLine(result: lastResult!),
            const SizedBox(height: 12),
            if (!isSupported)
              const SizedBox.shrink()
            else
              _Actions(
                statusAsync: statusAsync,
                busy: busy,
                onRequestPermissions: onRequestPermissions,
                onSync: onSync,
                onResetCursor: onResetCursor,
                showResetCursor: lastSyncAt != null,
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '$mm/$dd';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.statusAsync, required this.isSupported});

  final AsyncValue<HealthSyncStatus> statusAsync;
  final bool isSupported;

  @override
  Widget build(BuildContext context) {
    if (!isSupported) {
      return _badge(context, label: 'Unavailable', color: Colors.grey);
    }
    return statusAsync.when(
      data: (status) {
        switch (status) {
          case HealthSyncStatus.ready:
            return _badge(context, label: 'Connected', color: Colors.green);
          case HealthSyncStatus.notAuthorized:
            return _badge(context, label: 'Not connected', color: Colors.orange);
          case HealthSyncStatus.syncing:
            return _badge(context, label: 'Syncing…', color: Colors.blue);
          case HealthSyncStatus.unavailable:
            return _badge(context, label: 'Unavailable', color: Colors.grey);
        }
      },
      loading: () => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => _badge(context, label: 'Error', color: Colors.red),
    );
  }

  Widget _badge(BuildContext context, {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.result});
  final HealthSyncResult result;

  @override
  Widget build(BuildContext context) {
    if (!result.isSuccess) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          result.error ?? 'Unknown error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Last run: +${result.imported} imported · '
        '${result.skippedDuplicate} already here · '
        '${result.skippedUnsupportedType} non-cardio skipped'
        '${result.failed > 0 ? ' · ${result.failed} failed' : ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.statusAsync,
    required this.busy,
    required this.onRequestPermissions,
    required this.onSync,
    required this.onResetCursor,
    required this.showResetCursor,
  });

  final AsyncValue<HealthSyncStatus> statusAsync;
  final bool busy;
  final VoidCallback onRequestPermissions;
  final VoidCallback onSync;
  final VoidCallback onResetCursor;
  final bool showResetCursor;

  @override
  Widget build(BuildContext context) {
    final isReady = statusAsync.value == HealthSyncStatus.ready;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!isReady)
          FilledButton.icon(
            onPressed: busy ? null : onRequestPermissions,
            icon: const Icon(Icons.lock_open),
            label: const Text('Grant permissions'),
          )
        else
          FilledButton.icon(
            onPressed: busy ? null : onSync,
            icon: busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: const Text('Sync now'),
          ),
        if (showResetCursor)
          OutlinedButton.icon(
            onPressed: busy ? null : onResetCursor,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset cursor'),
          ),
      ],
    );
  }
}

class _PelotonNote extends StatelessWidget {
  const _PelotonNote({required this.providerName});
  final String providerName;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Peloton comes through here'),
        subtitle: Text(
          'Peloton is paired inside the Peloton app — not $providerName.\n'
          'Open Peloton → Profile / Settings → look for a $providerName '
          'toggle and turn it on. Your rides, runs, and treads will then '
          'flow into the Health card above, and YAWA4U picks them up on '
          'the next sync. No separate Peloton login needed here.',
        ),
      ),
    );
  }
}

class _FuturePartnersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
      child: ListTile(
        leading: const Icon(Icons.hourglass_bottom_outlined),
        title: const Text('More integrations coming'),
        subtitle: const Text(
          'Garmin Connect and Wahoo are on the roadmap.',
        ),
      ),
    );
  }
}
