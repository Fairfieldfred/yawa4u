import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../data/services/data_backup_service.dart';
import '../../../data/services/wifi_sync_service.dart';
import '../../../domain/providers/sync_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/qr_scanner_view.dart';

/// Screen for WiFi-based sync between devices
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _isServerRunning = false;
  String? _connectionInfo;
  DeviceInfo? _connectedDevice;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isScanning = false;

  // Store reference to sync service for safe disposal
  late final WifiSyncService _syncService;

  @override
  void initState() {
    super.initState();
    // Store the sync service reference early so we can use it in dispose
    _syncService = ref.read(wifiSyncServiceProvider);
  }

  @override
  void dispose() {
    // Stop server when leaving screen. The QR scanner manages its own camera
    // lifecycle, so there's nothing scanner-related to tear down here.
    _syncService.stopServer();
    super.dispose();
  }

  Future<void> _startServer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final syncService = ref.read(wifiSyncServiceProvider);
    final success = await syncService.startServer();

    setState(() {
      _isLoading = false;
      _isServerRunning = success;
      _connectionInfo = syncService.connectionInfo;
      if (!success) {
        _errorMessage = AppLocalizations.of(context)!.syncServerError;
      }
    });
  }

  Future<void> _stopServer() async {
    final syncService = ref.read(wifiSyncServiceProvider);
    await syncService.stopServer();

    setState(() {
      _isServerRunning = false;
      _connectionInfo = null;
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
  }

  /// Camera-free entry point: paste the connection code shown on the host.
  Future<void> _pasteCode() async {
    final l10n = AppLocalizations.of(context)!;
    final code = await showPasteConnectionCodeDialog(
      context,
      title: l10n.pasteCodeDialogTitle,
      hint: l10n.pasteCodeDialogHint,
      confirmLabel: l10n.pasteCodeDialogConfirm,
      cancelLabel: l10n.cancel,
    );
    if (code != null) {
      await _onQRCodeScanned(code);
    }
  }

  Future<void> _onQRCodeScanned(String code) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });

    final syncService = ref.read(wifiSyncServiceProvider);
    final device = await syncService.connectToDevice(code);

    setState(() {
      _isLoading = false;
      _connectedDevice = device;
      if (device == null) {
        _errorMessage = AppLocalizations.of(context)!.syncConnectionError;
      }
    });
  }

  Future<void> _pullData() async {
    if (_connectedDevice == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final syncService = ref.read(wifiSyncServiceProvider);
    final result = await syncService.pullFromDevice(
      _connectedDevice!,
      replace: false,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? (result.success ? l10n.syncComplete : l10n.syncFailed),
          ),
          backgroundColor: result.success ? context.successColor : context.errorColor,
        ),
      );

      if (result.success) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _pushData() async {
    if (_connectedDevice == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final syncService = ref.read(wifiSyncServiceProvider);
    final result = await syncService.pushToDevice(
      _connectedDevice!,
      replace: false,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? (result.success ? l10n.syncComplete : l10n.syncFailed),
          ),
          backgroundColor: result.success ? context.successColor : context.errorColor,
        ),
      );

      if (result.success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backupService = ref.watch(dataBackupServiceProvider);
    final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncTitle), centerTitle: true),
      body: _isScanning
          ? _buildScanner()
          : _connectedDevice != null
          ? _buildConnectedView()
          : _isServerRunning
          ? _buildServerView()
          : FutureBuilder<DataStats>(
              future: backupService.getStats(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: context.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.syncFailedToLoad,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return _buildInitialView(snapshot.data!, isDesktop);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  Widget _buildInitialView(DataStats stats, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current data stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncYourData,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        l10n.syncStatTrainingCycles,
                        stats.trainingCycleCount,
                      ),
                      _buildStatItem(l10n.syncStatSessions, stats.workoutCount),
                      _buildStatItem(l10n.syncStatExercises, stats.exerciseCount),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Instructions
          Text(
            l10n.syncWithAnotherDevice,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.syncWifiRequired,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: context.errorColor),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Host sync (show QR code for others to scan)
            ElevatedButton.icon(
              onPressed: _startServer,
              icon: const Icon(Icons.qr_code),
              label: Text(l10n.syncHostButton),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Scan QR code (camera-capable platforms: iOS / Android)
            if (canScanQrWithCamera) ...[
              OutlinedButton.icon(
                onPressed: _startScanning,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.syncScanQrButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Manual paste fallback (always available; the only receive path
            // on desktop / web and the iOS simulator).
            OutlinedButton.icon(
              onPressed: _pasteCode,
              icon: const Icon(Icons.keyboard),
              label: Text(l10n.pasteCodeButton),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildServerView() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.syncWaitingForConnection,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.syncScanFromOtherDevice,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // QR Code
          if (_connectionInfo != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: _connectionInfo!,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
            ),

          const Spacer(),

          // Cancel button
          OutlinedButton(
            onPressed: _stopServer,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return QrScannerView(
      promptText: AppLocalizations.of(context)!.syncScannerPrompt,
      onClose: () => setState(() => _isScanning = false),
      onCode: _onQRCodeScanned,
    );
  }

  Widget _buildConnectedView() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connected device info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.devices, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    l10n.syncConnectedTo,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _connectedDevice!.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        l10n.syncStatTrainingCycles,
                        _connectedDevice!.trainingCycleCount,
                      ),
                      _buildStatItem(
                        l10n.syncStatSessions,
                        _connectedDevice!.workoutCount,
                      ),
                      _buildStatItem(
                        l10n.syncStatExercises,
                        _connectedDevice!.exerciseCount,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Sync options
          Text(
            l10n.syncWhatToDo,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            // Import from device
            ElevatedButton.icon(
              onPressed: _pullData,
              icon: const Icon(Icons.download),
              label: Text(l10n.syncImportFrom(_connectedDevice!.name)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Export to device
            OutlinedButton.icon(
              onPressed: _pushData,
              icon: const Icon(Icons.upload),
              label: Text(l10n.syncExportTo(_connectedDevice!.name)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          const Spacer(),

          // Disconnect
          TextButton(
            onPressed: () {
              setState(() {
                _connectedDevice = null;
              });
            },
            child: Text(l10n.syncDisconnect),
          ),
        ],
      ),
    );
  }
}
