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

import '../../core/theme/skins/skin_model.dart';
import '../../core/theme/skins/skin_repository.dart';
import 'theme_image_service.dart';

/// Service for WiFi-based skin/theme sharing between devices
class SkinShareService {
  final SkinRepository _skinRepository;
  final ThemeImageService _themeImageService;

  HttpServer? _server;
  String? _serverIp;
  int? _serverPort;
  String? _syncCode;

  // Skins being shared
  List<SkinModel>? _skinsToShare;

  // Callbacks for UI updates
  void Function(SkinShareStatus status)? onStatusChanged;
  void Function(String deviceName)? onDeviceConnected;
  void Function(SkinShareResult result)? onShareComplete;

  SkinShareService(this._skinRepository, this._themeImageService);

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
      'type': 'skin_share',
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
    if (ip.startsWith('192.168.')) return true;
    if (ip.startsWith('10.')) return true;
    if (_isIn172PrivateRange(ip)) return true;
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
          fallbackIp = wifiIp;
        }
      }
    } catch (e) {
      debugPrint('network_info_plus failed: $e');
    }

    // Fallback: Get IP from network interfaces
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: true,
      );

      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains('lo') ||
            interface.name.toLowerCase().contains('vmnet') ||
            interface.name.toLowerCase().contains('vbox') ||
            interface.name.toLowerCase().contains('utun') ||
            interface.name.toLowerCase().contains('tun') ||
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

    if (fallbackIp != null) {
      debugPrint(
        'Warning: No valid local network IP found, using fallback: $fallbackIp',
      );
      return fallbackIp;
    }

    debugPrint('ERROR: Could not find any IP address for WiFi sharing');
    return null;
  }

  /// Start the share server with selected skins
  Future<bool> startServer(List<SkinModel> skins) async {
    try {
      _skinsToShare = skins;

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
          jsonEncode({'status': 'ok', 'type': 'skin_share'}),
        );
      });

      // Get device info and skin count
      router.get('/info', (Request request) async {
        final deviceName = await getDeviceName();
        return Response.ok(
          jsonEncode({
            'deviceName': deviceName,
            'skinCount': _skinsToShare?.length ?? 0,
            'skinNames': _skinsToShare?.map((s) => s.name).toList() ?? [],
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Get skins endpoint
      router.get('/skins', (Request request) async {
        // Verify sync code
        final code = request.url.queryParameters['code'];
        if (code != _syncCode) {
          return Response.forbidden('Invalid sync code');
        }

        if (_skinsToShare == null || _skinsToShare!.isEmpty) {
          return Response.ok(
            jsonEncode({'skins': []}),
            headers: {'Content-Type': 'application/json'},
          );
        }

        // Export skins with their images
        final skinsData = <Map<String, dynamic>>[];
        for (final skin in _skinsToShare!) {
          final imagesBase64 =
              await _themeImageService.exportThemeImagesAsBase64(skin.id);
          final skinJson = skin.toJson();
          skinJson['imagesBase64'] = imagesBase64;
          skinsData.add(skinJson);
        }

        return Response.ok(
          jsonEncode({'skins': skinsData}),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Start server on a random available port
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      _serverPort = _server!.port;

      debugPrint('Skin share server started at $_serverIp:$_serverPort');
      onStatusChanged?.call(SkinShareStatus.waiting);

      return true;
    } catch (e) {
      debugPrint('Failed to start skin share server: $e');
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
    _skinsToShare = null;
    onStatusChanged?.call(SkinShareStatus.idle);
  }

  /// Connect to another device and get its info
  Future<SkinShareDeviceInfo?> connectToDevice(String connectionInfo) async {
    try {
      final data = jsonDecode(connectionInfo) as Map<String, dynamic>;

      // Check if this is a skin share connection
      if (data['type'] != 'skin_share') {
        debugPrint('Invalid connection type: ${data['type']}');
        return null;
      }

      final ip = data['ip'] as String;
      // Port can be int or double depending on platform JSON parsing
      final port = (data['port'] as num).toInt();
      final code = data['code'] as String;

      final response = await http
          .get(Uri.parse('http://$ip:$port/info'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final info = jsonDecode(response.body) as Map<String, dynamic>;
        return SkinShareDeviceInfo(
          ip: ip,
          port: port,
          code: code,
          name: info['deviceName'] as String,
          // skinCount can be int or double depending on platform JSON parsing
          skinCount: (info['skinCount'] as num).toInt(),
          skinNames: (info['skinNames'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to connect to device: $e');
    }
    return null;
  }

  /// Pull skins from another device
  Future<SkinShareResult> pullSkins(SkinShareDeviceInfo device) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'http://${device.ip}:${device.port}/skins?code=${device.code}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final skinsJson = data['skins'] as List<dynamic>;

        int importedCount = 0;
        for (final skinData in skinsJson) {
          try {
            final skinJson = skinData as Map<String, dynamic>;

            // Extract and remove images before parsing skin
            final imagesBase64 =
                skinJson.remove('imagesBase64') as Map<String, dynamic>? ?? {};

            final skin = SkinModel.fromJson(skinJson);

            // Generate new ID to avoid conflicts
            final newSkin = skin.copyWith(
              id: 'shared_${DateTime.now().millisecondsSinceEpoch}_$importedCount',
              isBuiltIn: false,
            );

            // Import images first
            await _themeImageService.importThemeImagesFromBase64(
              themeId: newSkin.id,
              base64Map: imagesBase64.map((k, v) => MapEntry(k, v as String)),
            );

            // Get the actual image paths
            final imagePaths =
                await _themeImageService.getAllThemeImagePaths(newSkin.id);

            // Update skin with image paths
            final updatedSkin = newSkin.copyWith(
              backgrounds: SkinBackgrounds(
                workout: imagePaths['workout'],
                cycles: imagePaths['cycles'],
                exercises: imagePaths['exercises'],
                more: imagePaths['more'],
                defaultBackground: imagePaths['default'],
                appIcon: imagePaths['app_icon'],
              ),
            );

            // Save the skin
            await _skinRepository.saveCustomSkin(updatedSkin);
            importedCount++;
          } catch (e) {
            debugPrint('Error importing skin: $e');
          }
        }

        return SkinShareResult(
          success: true,
          message: 'Imported $importedCount theme${importedCount != 1 ? 's' : ''} from ${device.name}',
          skinsImported: importedCount,
        );
      } else {
        return SkinShareResult(
          success: false,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return SkinShareResult(
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

/// Status of the skin share service
enum SkinShareStatus { idle, waiting, connecting, sharing, complete, error }

/// Result of a skin share operation
class SkinShareResult {
  final bool success;
  final String? message;
  final int skinsImported;

  SkinShareResult({
    required this.success,
    this.message,
    this.skinsImported = 0,
  });
}

/// Information about a connected device for skin sharing
class SkinShareDeviceInfo {
  final String ip;
  final int port;
  final String code;
  final String name;
  final int skinCount;
  final List<String> skinNames;

  SkinShareDeviceInfo({
    required this.ip,
    required this.port,
    required this.code,
    required this.name,
    required this.skinCount,
    required this.skinNames,
  });
}
