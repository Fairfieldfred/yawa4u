import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/skins/skins.dart';
import '../../data/models/training_cycle_template.dart';
import '../../data/services/template_share_service.dart';
import '../../domain/providers/template_providers.dart';
import '../../domain/providers/template_share_providers.dart';

/// Screen for sharing templates via WiFi with QR code
class TemplateShareScreen extends ConsumerStatefulWidget {
  /// Optional template ID to pre-select when opening the screen
  final String? preSelectedTemplateId;

  /// Whether to automatically start the server when the screen opens
  final bool autoStart;

  const TemplateShareScreen({
    super.key,
    this.preSelectedTemplateId,
    this.autoStart = false,
  });

  @override
  ConsumerState<TemplateShareScreen> createState() =>
      _TemplateShareScreenState();
}

class _TemplateShareScreenState extends ConsumerState<TemplateShareScreen> {
  // Track selected templates
  late Set<String> _selectedTemplateIds;
  bool _initialized = false;
  bool _autoStartTriggered = false;

  bool _isServerRunning = false;
  String? _connectionInfo;
  TemplateShareDeviceInfo? _connectedDevice;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isScanning = false;
  MobileScannerController? _scannerController;

  // Store reference to share service for safe disposal
  late final TemplateShareService _shareService;

  @override
  void initState() {
    super.initState();
    // Initialize selected template IDs
    _selectedTemplateIds = {};
    // Store the share service reference early so we can use it in dispose
    _shareService = ref.read(templateShareServiceProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-select template if provided (only once)
    if (!_initialized && widget.preSelectedTemplateId != null) {
      _selectedTemplateIds.add(widget.preSelectedTemplateId!);
      _initialized = true;
    }
  }

  /// Auto-start the server with pre-selected templates
  Future<void> _autoStartServerIfReady(
    List<TrainingCycleTemplate> templates,
  ) async {
    if (_autoStartTriggered || !widget.autoStart) return;

    final selectedTemplates = templates
        .where((t) => _selectedTemplateIds.contains(t.id))
        .toList();
    if (selectedTemplates.isNotEmpty) {
      _autoStartTriggered = true;
      _startServer(selectedTemplates);
    }
  }

  @override
  void dispose() {
    // Stop scanner and server when leaving screen
    _scannerController?.dispose();
    _shareService.stopServer();
    super.dispose();
  }

  Future<void> _startServer(
    List<TrainingCycleTemplate> selectedTemplates,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final shareService = ref.read(templateShareServiceProvider);
    final success = await shareService.startServer(selectedTemplates);

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
    final shareService = ref.read(templateShareServiceProvider);
    await shareService.stopServer();

    setState(() {
      _isServerRunning = false;
      _connectionInfo = null;
    });
  }

  void _startScanning() {
    // Dispose old controller and create fresh one
    _scannerController?.dispose();
    _scannerController = null;
    setState(() {
      _isScanning = true;
    });
  }

  Future<void> _onQRCodeScanned(String code) async {
    // Dispose scanner controller
    _scannerController?.dispose();
    _scannerController = null;

    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });

    final shareService = ref.read(templateShareServiceProvider);
    final device = await shareService.connectToDevice(code);

    setState(() {
      _isLoading = false;
      _connectedDevice = device;
      if (device == null) {
        _errorMessage =
            'Could not connect to device. Make sure both devices are on the same WiFi network and you are scanning a valid template share QR code.';
      }
    });
  }

  Future<void> _receiveTemplates() async {
    if (_connectedDevice == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final shareService = ref.read(templateShareServiceProvider);
    final result = await shareService.pullTemplates(_connectedDevice!);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Refresh the template list
      ref.invalidate(availableTemplatesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ??
                (result.success
                    ? 'Templates received!'
                    : 'Failed to receive templates'),
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
    final templatesAsync = ref.watch(availableTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Share Templates'), centerTitle: true),
      body: _isScanning
          ? _buildScanner()
          : _connectedDevice != null
          ? _buildConnectedView()
          : _isServerRunning
          ? _buildServerView()
          : templatesAsync.when(
              data: (templates) {
                // Auto-start server if requested and not yet triggered
                if (widget.autoStart && !_autoStartTriggered && _initialized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _autoStartServerIfReady(templates);
                  });
                }
                return _buildSelectionView(templates);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: context.errorColor),
                ),
              ),
            ),
    );
  }

  Widget _buildSelectionView(List<TrainingCycleTemplate> templates) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No templates available',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
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
                'Share or Receive Templates',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select templates to share, or scan a QR code to receive templates from another device.',
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
                color: context.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: context.errorColor),
              ),
            ),
          ),

        // Scan button to receive templates
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _startScanning,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code to Receive Templates'),
            style: OutlinedButton.styleFrom(
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
                'Select Templates to Share',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedTemplateIds.length == templates.length) {
                      _selectedTemplateIds.clear();
                    } else {
                      _selectedTemplateIds.clear();
                      _selectedTemplateIds.addAll(templates.map((t) => t.id));
                    }
                  });
                },
                child: Text(
                  _selectedTemplateIds.length == templates.length
                      ? 'Deselect All'
                      : 'Select All',
                ),
              ),
            ],
          ),
        ),

        // Template list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: templates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(context, template);
            },
          ),
        ),

        // Share button at bottom
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _selectedTemplateIds.isEmpty || _isLoading
                  ? null
                  : () {
                      final selectedTemplates = templates
                          .where((t) => _selectedTemplateIds.contains(t.id))
                          .toList();
                      _startServer(selectedTemplates);
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share),
              label: Text(
                _selectedTemplateIds.isEmpty
                    ? 'Select Templates to Share'
                    : 'Share ${_selectedTemplateIds.length} Template${_selectedTemplateIds.length > 1 ? 's' : ''}',
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

  Widget _buildTemplateCard(
    BuildContext context,
    TrainingCycleTemplate template,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedTemplateIds.contains(template.id);

    return Card(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedTemplateIds.remove(template.id);
            } else {
              _selectedTemplateIds.add(template.id);
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
                      _selectedTemplateIds.add(template.id);
                    } else {
                      _selectedTemplateIds.remove(template.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              // Template info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            template.name,
                            style: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${template.daysPerPeriod} Days/Period',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer.withValues(
                                  alpha: 0.7,
                                )
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.periodsTotal} Periods',
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.7,
                                  )
                                : colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer.withValues(
                                  alpha: 0.7,
                                )
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.workouts.length} Workouts',
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.7,
                                  )
                                : colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

          // Templates being shared
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sharing ${_selectedTemplateIds.length} Template${_selectedTemplateIds.length > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When scanned, these templates will be copied to the other device.',
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
    // Create controller if not exists
    _scannerController ??= MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

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
            onPressed: () {
              _scannerController?.dispose();
              _scannerController = null;
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
            'Point camera at template share QR code',
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
                      '${_connectedDevice!.templateCount} Template${_connectedDevice!.templateCount != 1 ? 's' : ''} Available',
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

          // Template list
          if (_connectedDevice!.templateNames.isNotEmpty) ...[
            Text(
              'Templates to Receive:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _connectedDevice!.templateNames
                      .map(
                        (name) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.article_outlined, size: 18),
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
              onPressed: _receiveTemplates,
              icon: const Icon(Icons.download),
              label: Text(
                'Receive ${_connectedDevice!.templateCount} Template${_connectedDevice!.templateCount != 1 ? 's' : ''}',
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
