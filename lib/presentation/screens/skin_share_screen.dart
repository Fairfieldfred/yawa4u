import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/skins/skins.dart';
import '../../data/services/skin_share_service.dart';
import '../../domain/providers/skin_share_providers.dart';

/// Screen for sharing themes/skins via WiFi with QR code
class SkinShareScreen extends ConsumerStatefulWidget {
  /// Optional skin ID to pre-select when opening the screen
  final String? preSelectedSkinId;

  /// Whether to automatically start the server when the screen opens
  final bool autoStart;

  const SkinShareScreen({
    super.key,
    this.preSelectedSkinId,
    this.autoStart = false,
  });

  @override
  ConsumerState<SkinShareScreen> createState() => _SkinShareScreenState();
}

class _SkinShareScreenState extends ConsumerState<SkinShareScreen> {
  // Track selected skins
  late Set<String> _selectedSkinIds;
  bool _initialized = false;
  bool _autoStartTriggered = false;

  bool _isServerRunning = false;
  String? _connectionInfo;
  SkinShareDeviceInfo? _connectedDevice;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  // Store reference to share service for safe disposal
  late final SkinShareService _shareService;

  @override
  void initState() {
    super.initState();
    _selectedSkinIds = {};
    _shareService = ref.read(skinShareServiceProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-select skin if provided (only once)
    if (!_initialized && widget.preSelectedSkinId != null) {
      _selectedSkinIds.add(widget.preSelectedSkinId!);
      _initialized = true;
    }
  }

  /// Auto-start the server with pre-selected skins
  Future<void> _autoStartServerIfReady(List<SkinModel> skins) async {
    if (_autoStartTriggered || !widget.autoStart) return;

    final selectedSkins = skins
        .where((s) => _selectedSkinIds.contains(s.id))
        .toList();
    if (selectedSkins.isNotEmpty) {
      _autoStartTriggered = true;
      _startServer(selectedSkins);
    }
  }

  @override
  void dispose() {
    // Stop scanner and server when leaving screen
    // Note: We can't await in dispose, but stop() helps release resources
    _scannerController?.stop();
    _scannerController?.dispose();
    _shareService.stopServer();
    super.dispose();
  }

  Future<void> _startServer(List<SkinModel> selectedSkins) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final shareService = ref.read(skinShareServiceProvider);
    final success = await shareService.startServer(selectedSkins);

    setState(() {
      _isLoading = false;
      _isServerRunning = success;
      _connectionInfo = shareService.connectionInfo;
      if (!success) {
        _errorMessage =
            'Could not start share server. Make sure you are connected to WiFi.';
      }
    });
  }

  Future<void> _stopServer() async {
    final shareService = ref.read(skinShareServiceProvider);
    await shareService.stopServer();

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

    try {
      final shareService = ref.read(skinShareServiceProvider);
      final device = await shareService.connectToDevice(code);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _connectedDevice = device;
          if (device == null) {
            _errorMessage =
                'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid theme share QR code.';
          }
        });
      }
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _connectedDevice = null;
          _errorMessage = 'Error connecting: $e';
        });
      }
    }
  }

  Future<void> _receiveSkins() async {
    if (_connectedDevice == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final shareService = ref.read(skinShareServiceProvider);
    final result = await shareService.pullSkins(_connectedDevice!);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                (result.success
                    ? 'Themes received!'
                    : 'Failed to receive themes'),
          ),
          backgroundColor: result.success
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );

      if (result.success) {
        // Pop first using go_router, then refresh the skin list
        // This order prevents the MaterialApp rebuild from breaking navigation
        context.pop();

        // Refresh the available skins list after navigation completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(skinProvider);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final skinState = ref.watch(skinProvider);
    // Get only custom (non-built-in) skins for sharing
    final customSkins = skinState.availableSkins
        .where((s) => !s.isBuiltIn)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Share Themes'), centerTitle: true),
      body: _isScanning
          ? _buildScanner()
          : _connectedDevice != null
          ? _buildConnectedView()
          : _isServerRunning
          ? _buildServerView()
          : Builder(
              builder: (context) {
                if (widget.autoStart && !_autoStartTriggered && _initialized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _autoStartServerIfReady(customSkins);
                  });
                }
                return _buildSelectionView(customSkins);
              },
            ),
    );
  }

  Widget _buildSelectionView(List<SkinModel> skins) {
    if (skins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.palette_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No custom themes to share',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a custom theme in Theme Settings to share it.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Still allow scanning to receive
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _startScanning,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Code to Receive Themes'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Instructions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share or Receive Themes',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select themes to share, or scan a QR code to receive themes from another device.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),

        // Scan button to receive themes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _startScanning,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code to Receive Themes'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),

        const Divider(),

        // Select all / Deselect all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Select Themes to Share',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedSkinIds.length == skins.length) {
                      _selectedSkinIds.clear();
                    } else {
                      _selectedSkinIds.clear();
                      _selectedSkinIds.addAll(skins.map((s) => s.id));
                    }
                  });
                },
                child: Text(
                  _selectedSkinIds.length == skins.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              ),
            ],
          ),
        ),

        // Skin list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: skins.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final skin = skins[index];
              return _buildSkinCard(context, skin);
            },
          ),
        ),

        // Share button at bottom
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _selectedSkinIds.isEmpty || _isLoading
                  ? null
                  : () {
                      final selectedSkins = skins
                          .where((s) => _selectedSkinIds.contains(s.id))
                          .toList();
                      _startServer(selectedSkins);
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              label: Text(
                _selectedSkinIds.isEmpty
                    ? 'Select Themes to Share'
                    : 'Share ${_selectedSkinIds.length} Theme${_selectedSkinIds.length > 1 ? 's' : ''}',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinCard(BuildContext context, SkinModel skin) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedSkinIds.contains(skin.id);

    return Card(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedSkinIds.remove(skin.id);
            } else {
              _selectedSkinIds.add(skin.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedSkinIds.add(skin.id);
                    } else {
                      _selectedSkinIds.remove(skin.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              // Color preview circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skin.colors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: skin.colors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.palette, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              // Skin info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skin.name,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skin.description,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              )
                            : colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ready to Share',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ask the other person to scan this QR code',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Themes being shared
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sharing ${_selectedSkinIds.length} Theme${_selectedSkinIds.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When scanned, these themes will be copied to the other device.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

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
                      color: Theme.of(context).colorScheme.error,
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
            'Point camera at theme share QR code',
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_connectedDevice!.skinCount} Theme${_connectedDevice!.skinCount != 1 ? 's' : ''} Available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme list
          if (_connectedDevice!.skinNames.isNotEmpty) ...[
            Text(
              'Themes to Receive:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _connectedDevice!.skinNames
                      .map(
                        (name) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.palette_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(name)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],

          const Spacer(),

          // Receive button
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            ElevatedButton.icon(
              onPressed: _receiveSkins,
              icon: const Icon(Icons.download),
              label: Text(
                'Receive ${_connectedDevice!.skinCount} Theme${_connectedDevice!.skinCount != 1 ? 's' : ''}',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Disconnect
            TextButton(
              onPressed: () {
                setState(() {
                  _connectedDevice = null;
                });
              },
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }
}
