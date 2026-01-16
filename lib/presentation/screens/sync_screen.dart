import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/skins/skins.dart';
import '../../data/services/data_backup_service.dart';
import '../../data/services/wifi_sync_service.dart';
import '../../domain/providers/sync_providers.dart';

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
  MobileScannerController? _scannerController;

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
    // Stop scanner and server when leaving screen
    // Note: We can't await in dispose, but stop() helps release resources
    _scannerController?.stop();
    _scannerController?.dispose();
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
        _errorMessage =
            'Could not start sync server. Make sure you are connected to WiFi.';
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

  Future<void> _startScanning() async {
    // Stop and dispose old controller properly
    if (_scannerController != null) {
      await _scannerController!.stop();
      await _scannerController!.dispose();
      _scannerController = null;
    }

    // Create new controller with autoStart disabled
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      autoStart: false,
    );

    setState(() {
      _isScanning = true;
    });

    // Start the scanner after setState completes
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      await _scannerController?.start();
    } catch (e) {
      debugPrint('Scanner start error: $e');
    }
  }

  Future<void> _onQRCodeScanned(String code) async {
    // Stop and dispose scanner controller properly
    if (_scannerController != null) {
      await _scannerController!.stop();
      await _scannerController!.dispose();
      _scannerController = null;
    }

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
        _errorMessage =
            'Could not connect to device. Make sure both devices are on the same WiFi network.';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                (result.success ? 'Sync complete!' : 'Sync failed'),
          ),
          backgroundColor: result.success
              ? context.successColor
              : context.errorColor,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                (result.success ? 'Sync complete!' : 'Sync failed'),
          ),
          backgroundColor: result.success
              ? context.successColor
              : context.errorColor,
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
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Data'), centerTitle: true),
      body: _isScanning
          ? _buildScanner()
          : _connectedDevice != null
          ? _buildConnectedView()
          : _isServerRunning
          ? _buildServerView()
          : FutureBuilder<DataStats>(
              future: backupService.getStats(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildInitialView(snapshot.data!, isDesktop);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  Widget _buildInitialView(DataStats stats, bool isDesktop) {
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
                    'Your Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'TrainingCycles',
                        stats.trainingCycleCount,
                      ),
                      _buildStatItem('Workouts', stats.workoutCount),
                      _buildStatItem('Exercises', stats.exerciseCount),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Instructions
          Text(
            'Sync with another device',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Both devices must be on the same WiFi network.',
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
              label: const Text('Host Sync (Show QR Code)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Scan QR code (mobile only, or desktop with camera)
            OutlinedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Waiting for connection...',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan this QR code from the other device',
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    // Controller should already be created by _startScanning()
    if (_scannerController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          errorBuilder: (context, error, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ?? 'Could not access camera',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _isScanning = false),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          },
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                // Stop the scanner before processing
                _scannerController?.stop();
                _onQRCodeScanned(barcode.rawValue!);
                return;
              }
            }
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              if (_scannerController != null) {
                await _scannerController!.stop();
                await _scannerController!.dispose();
                _scannerController = null;
              }
              setState(() {
                _isScanning = false;
              });
            },
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Text(
            'Point camera at QR code',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedView() {
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
                    'Connected to',
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
                        'TrainingCycles',
                        _connectedDevice!.trainingCycleCount,
                      ),
                      _buildStatItem(
                        'Workouts',
                        _connectedDevice!.workoutCount,
                      ),
                      _buildStatItem(
                        'Exercises',
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
            'What would you like to do?',
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
              label: Text('Import from ${_connectedDevice!.name}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Export to device
            OutlinedButton.icon(
              onPressed: _pushData,
              icon: const Icon(Icons.upload),
              label: Text('Export to ${_connectedDevice!.name}'),
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
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
