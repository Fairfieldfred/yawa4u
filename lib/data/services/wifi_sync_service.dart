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

import 'data_backup_service.dart';

/// Service for WiFi-based sync between devices
class WifiSyncService {
  final DataBackupService _backupService;

  HttpServer? _server;
  String? _serverIp;
  int? _serverPort;
  String? _syncCode;

  // Callbacks for UI updates
  void Function(SyncStatus status)? onStatusChanged;
  void Function(String deviceName)? onDeviceConnected;
  void Function(SyncResult result)? onSyncComplete;

  WifiSyncService(this._backupService);

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

  /// Get local IP address with fallback for desktop platforms
  Future<String?> _getLocalIpAddress() async {
    // First try network_info_plus (works best on mobile)
    try {
      final networkInfo = NetworkInfo();
      final wifiIp = await networkInfo.getWifiIP();
      if (wifiIp != null && wifiIp.isNotEmpty) {
        return wifiIp;
      }
    } catch (e) {
      debugPrint('network_info_plus failed: $e');
    }

    // Fallback: Get IP from network interfaces (works on desktop)
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        // Skip loopback and virtual interfaces
        if (interface.name.toLowerCase().contains('lo') ||
            interface.name.toLowerCase().contains('vmnet') ||
            interface.name.toLowerCase().contains('vbox')) {
          continue;
        }

        for (final addr in interface.addresses) {
          // Skip loopback addresses
          if (!addr.address.startsWith('127.')) {
            debugPrint('Found IP: ${addr.address} on ${interface.name}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('NetworkInterface.list failed: $e');
    }

    return null;
  }

  /// Start the sync server (for receiving data or sending data)
  Future<bool> startServer() async {
    try {
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
        return Response.ok(jsonEncode({'status': 'ok', 'device': 'yawa4u'}));
      });

      // Get device info
      router.get('/info', (Request request) async {
        final deviceName = await getDeviceName();
        final stats = _backupService.getStats();
        return Response.ok(
          jsonEncode({
            'deviceName': deviceName,
            'trainingCycles': stats.trainingCycleCount,
            'workouts': stats.workoutCount,
            'exercises': stats.exerciseCount,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Export data endpoint
      router.get('/export', (Request request) async {
        // Verify sync code
        final code = request.url.queryParameters['code'];
        if (code != _syncCode) {
          return Response.forbidden('Invalid sync code');
        }

        final data = await _backupService.exportToJson();
        return Response.ok(data, headers: {'Content-Type': 'application/json'});
      });

      // Import data endpoint
      router.post('/import', (Request request) async {
        // Verify sync code
        final code = request.url.queryParameters['code'];
        if (code != _syncCode) {
          return Response.forbidden('Invalid sync code');
        }

        final body = await request.readAsString();
        final replace = request.url.queryParameters['replace'] == 'true';

        final result = await _backupService.importFromJson(
          body,
          replace: replace,
        );

        if (result.success) {
          onSyncComplete?.call(
            SyncResult(
              success: true,
              message: 'Imported ${result.totalImported} items',
            ),
          );
        }

        return Response.ok(
          jsonEncode({
            'success': result.success,
            'error': result.error,
            'imported': result.totalImported,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      });

      // Start server on a random available port
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
      _serverPort = _server!.port;

      debugPrint('Sync server started at $_serverIp:$_serverPort');
      onStatusChanged?.call(SyncStatus.waiting);

      return true;
    } catch (e) {
      debugPrint('Failed to start sync server: $e');
      return false;
    }
  }

  /// Stop the sync server
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _serverIp = null;
    _serverPort = null;
    _syncCode = null;
    onStatusChanged?.call(SyncStatus.idle);
  }

  /// Connect to another device and get its info
  Future<DeviceInfo?> connectToDevice(String connectionInfo) async {
    try {
      final data = jsonDecode(connectionInfo) as Map<String, dynamic>;
      final ip = data['ip'] as String;
      final port = data['port'] as int;
      final code = data['code'] as String;

      final response = await http
          .get(Uri.parse('http://$ip:$port/info'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final info = jsonDecode(response.body) as Map<String, dynamic>;
        return DeviceInfo(
          ip: ip,
          port: port,
          code: code,
          name: info['deviceName'] as String,
          trainingCycleCount: info['trainingCycles'] as int,
          workoutCount: info['workouts'] as int,
          exerciseCount: info['exercises'] as int,
        );
      }
    } catch (e) {
      debugPrint('Failed to connect to device: $e');
    }
    return null;
  }

  /// Pull data from another device (import from remote)
  Future<SyncResult> pullFromDevice(
    DeviceInfo device, {
    bool replace = false,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'http://${device.ip}:${device.port}/export?code=${device.code}',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = await _backupService.importFromJson(
          response.body,
          replace: replace,
        );

        if (result.success) {
          return SyncResult(
            success: true,
            message:
                'Imported ${result.totalImported} items from ${device.name}',
          );
        } else {
          return SyncResult(
            success: false,
            message: result.error ?? 'Import failed',
          );
        }
      } else {
        return SyncResult(
          success: false,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return SyncResult(success: false, message: 'Connection failed: $e');
    }
  }

  /// Push data to another device (export to remote)
  Future<SyncResult> pushToDevice(
    DeviceInfo device, {
    bool replace = false,
  }) async {
    try {
      final data = await _backupService.exportToJson();

      final response = await http
          .post(
            Uri.parse(
              'http://${device.ip}:${device.port}/import?code=${device.code}&replace=$replace',
            ),
            headers: {'Content-Type': 'application/json'},
            body: data,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        if (result['success'] == true) {
          return SyncResult(
            success: true,
            message: 'Exported ${result['imported']} items to ${device.name}',
          );
        } else {
          return SyncResult(
            success: false,
            message: result['error'] as String?,
          );
        }
      } else {
        return SyncResult(
          success: false,
          message: 'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      return SyncResult(success: false, message: 'Connection failed: $e');
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

/// Status of the sync service
enum SyncStatus { idle, waiting, connecting, syncing, complete, error }

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String? message;

  SyncResult({required this.success, this.message});
}

/// Information about a connected device
class DeviceInfo {
  final String ip;
  final int port;
  final String code;
  final String name;
  final int trainingCycleCount;
  final int workoutCount;
  final int exerciseCount;

  DeviceInfo({
    required this.ip,
    required this.port,
    required this.code,
    required this.name,
    required this.trainingCycleCount,
    required this.workoutCount,
    required this.exerciseCount,
  });

  int get totalItems => trainingCycleCount + workoutCount + exerciseCount;
}
