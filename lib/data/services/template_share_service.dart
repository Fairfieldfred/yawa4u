import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../models/training_cycle_template.dart';
import '../repositories/template_repository.dart';

/// Service for WiFi-based template sharing between devices
class TemplateShareService {
  final TemplateRepository _templateRepository;

  HttpServer? _server;
  String? _serverIp;
  int? _serverPort;
  String? _syncCode;

  // Templates being shared
  List<TrainingCycleTemplate>? _templatesToShare;

  // Callbacks for UI updates
  void Function(TemplateShareStatus status)? onStatusChanged;
  void Function(String deviceName)? onDeviceConnected;
  void Function(TemplateShareResult result)? onShareComplete;

  TemplateShareService(this._templateRepository);

  /// Check if server is running
  bool get isServerRunning => _server != null;

  /// Get the connection info for QR code
  String? get connectionInfo {
    if (_serverIp == null || _serverPort == null || _syncCode == null) {
      return null;
    }
    return jsonEncode({
      'ip': _serverIp,
      'port': _serverPort,
      'code': _syncCode,
      'type': 'template_share',
    });
  }

  /// Get device name
  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.name;
    } else if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.model;
    } else if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      return info.computerName;
    } else if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      return info.computerName;
    } else if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return info.prettyName;
    }
    return 'Unknown Device';
  }

  /// Check if an IP address is a valid local network address for WiFi sharing
  bool _isValidLocalNetworkIp(String ip) {
    // Only accept RFC 1918 private network ranges used in home/office networks:
    // - 192.168.0.0 - 192.168.255.255 (most common for home routers)
    // - 10.0.0.0 - 10.255.255.255
    // - 172.16.0.0 - 172.31.255.255
    if (ip.startsWith('192.168.')) {
      return true;
    }
    if (ip.startsWith('10.')) {
      return true;
    }
    if (_isIn172PrivateRange(ip)) {
      return true;
    }
    // Reject everything else including:
    // - 169.254.x.x (link-local/APIPA)
    // - 100.64-127.x.x (CGNAT, often Tailscale/carrier)
    // - 127.x.x.x (loopback)
    // - Public IPs
    debugPrint('Rejecting non-private IP: $ip');
    return false;
  }

  /// Check if IP is in 172.16.0.0 - 172.31.255.255 private range
  bool _isIn172PrivateRange(String ip) {
    if (!ip.startsWith('172.')) return false;
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final secondOctet = int.tryParse(parts[1]);
    return secondOctet != null && secondOctet >= 16 && secondOctet <= 31;
  }

  /// Get local IP address with fallback for desktop platforms
  Future<String?> _getLocalIpAddress() async {
    String? fallbackIp;

    // First try network_info_plus (works best on mobile)
    try {
      final networkInfo = NetworkInfo();
      final wifiIp = await networkInfo.getWifiIP();
      debugPrint('network_info_plus returned: $wifiIp');
      if (wifiIp != null && wifiIp.isNotEmpty) {
        if (_isValidLocalNetworkIp(wifiIp)) {
          return wifiIp;
        } else {
          // Store as fallback, but try to find better address
          fallbackIp = wifiIp;
        }
      }
    } catch (e) {
      debugPrint('network_info_plus failed: $e');
    }

    // Fallback: Get IP from network interfaces (works on desktop and as backup)
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: true, // Include them so we can filter properly
      );

      // Look for valid local network addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
      for (final interface in interfaces) {
        // Skip loopback and virtual interfaces
        if (interface.name.toLowerCase().contains('lo') ||
            interface.name.toLowerCase().contains('vmnet') ||
            interface.name.toLowerCase().contains('vbox') ||
            interface.name.toLowerCase().contains(
              'utun',
            ) || // macOS VPN tunnels
            interface.name.toLowerCase().contains('tun') || // Linux VPN tunnels
            interface.name.toLowerCase().contains('tailscale')) {
          debugPrint('Skipping virtual interface: ${interface.name}');
          continue;
        }

        for (final addr in interface.addresses) {
          debugPrint('Found IP: ${addr.address} on ${interface.name}');
          if (_isValidLocalNetworkIp(addr.address)) {
            debugPrint('Using valid local network IP: ${addr.address}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('NetworkInterface.list failed: $e');
    }

    // Last resort: return whatever we found (with warning)
    if (fallbackIp != null) {
      debugPrint(
        'Warning: No valid local network IP found, using fallback: $fallbackIp',
      );
      return fallbackIp;
    }

    debugPrint('ERROR: Could not find any IP address for WiFi sharing');
    return null;
  }

  /// Start the share server with selected templates
  Future<bool> startServer(List<TrainingCycleTemplate> templates) async {
    try {
      _templatesToShare = templates;

      // Get local IP address
      _serverIp = await _getLocalIpAddress();

      if (_serverIp == null) {
        debugPrint('Could not get local IP address');
        return false;
      }

      // Generate a random sync code
      _syncCode = _generateSyncCode();

      // Create router
      final router = Router();

      // Health check endpoint
      router.get('/ping', (Request request) {
        return Response.ok(
          jsonEncode({'status': 'ok', 'type': 'template_share'}),
        );
      });

      // Get device info and template count
      router.get('/info', (Request request) async {
        final deviceName = await getDeviceName();
        return Response.ok(
          jsonEncode({
            'deviceName': deviceName,
            'templateCount': _templatesToShare?.length ?? 0,
            'templateNames':
                _templatesToShare?.map((t) => t.name).toList() ?? [],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Get templates endpoint
      router.get('/templates', (Request request) async {
        // Verify sync code
        final code = request.url.queryParameters['code'];
        if (code != _syncCode) {
          return Response.forbidden('Invalid sync code');
        }

        if (_templatesToShare == null || _templatesToShare!.isEmpty) {
          return Response.ok(
            jsonEncode({'templates': []}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        final templatesJson = _templatesToShare!
            .map((t) => t.toJson())
            .toList();
        return Response.ok(
          jsonEncode({'templates': templatesJson}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Start server on a random available port
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      _serverPort = _server!.port;

      debugPrint('Template share server started at $_serverIp:$_serverPort');
      onStatusChanged?.call(TemplateShareStatus.waiting);

      return true;
    } catch (e) {
      debugPrint('Failed to start template share server: $e');
      return false;
    }
  }

  /// Stop the share server
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _serverIp = null;
    _serverPort = null;
    _syncCode = null;
    _templatesToShare = null;
    onStatusChanged?.call(TemplateShareStatus.idle);
  }

  /// Connect to another device and get its info
  Future<TemplateShareDeviceInfo?> connectToDevice(
    String connectionInfo,
  ) async {
    try {
      final data = jsonDecode(connectionInfo) as Map<String, dynamic>;

      // Check if this is a template share connection
      if (data['type'] != 'template_share') {
        debugPrint('Invalid connection type: ${data['type']}');
        return null;
      }

      final ip = data['ip'] as String;
      final port = data['port'] as int;
      final code = data['code'] as String;

      final response = await http
          .get(Uri.parse('http://$ip:$port/info'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final info = jsonDecode(response.body) as Map<String, dynamic>;
        return TemplateShareDeviceInfo(
          ip: ip,
          port: port,
          code: code,
          name: info['deviceName'] as String,
          templateCount: info['templateCount'] as int,
          templateNames: (info['templateNames'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to connect to device: $e');
    }
    return null;
  }

  /// Pull templates from another device
  Future<TemplateShareResult> pullTemplates(
    TemplateShareDeviceInfo device,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'http://${device.ip}:${device.port}/templates?code=${device.code}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final templatesJson = data['templates'] as List<dynamic>;

        int importedCount = 0;
        for (final templateJson in templatesJson) {
          try {
            final template = TrainingCycleTemplate.fromJson(
              templateJson as Map<String, dynamic>,
            );
            // Save each template
            await _templateRepository.saveTemplateDirectly(template);
            importedCount++;
          } catch (e) {
            debugPrint('Error importing template: $e');
          }
        }

        return TemplateShareResult(
          success: true,
          message: 'Imported $importedCount templates from ${device.name}',
          templatesImported: importedCount,
        );
      } else {
        return TemplateShareResult(
          success: false,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return TemplateShareResult(
        success: false,
        message: 'Connection failed: $e',
      );
    }
  }

  /// Generate a random 6-character sync code
  String _generateSyncCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (i) => chars[(random + i * 7) % chars.length],
    ).join();
  }
}

/// Status of the template share service
enum TemplateShareStatus { idle, waiting, connecting, sharing, complete, error }

/// Result of a template share operation
class TemplateShareResult {
  final bool success;
  final String? message;
  final int templatesImported;

  TemplateShareResult({
    required this.success,
    this.message,
    this.templatesImported = 0,
  });
}

/// Information about a connected device for template sharing
class TemplateShareDeviceInfo {
  final String ip;
  final int port;
  final String code;
  final String name;
  final int templateCount;
  final List<String> templateNames;

  TemplateShareDeviceInfo({
    required this.ip,
    required this.port,
    required this.code,
    required this.name,
    required this.templateCount,
    required this.templateNames,
  });
}
