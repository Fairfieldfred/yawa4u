import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'data_backup_service.dart';
import 'firebase_auth_service.dart';

/// Thin seam over Firestore + Storage so [CloudBackupService] is unit-testable
/// with an in-memory fake (project style: fakes over mocks).
abstract class CloudBackupGateway {
  /// Uploads the backup blob and then its metadata doc for [uid].
  Future<void> upload(String uid, Uint8List bytes, Map<String, dynamic> metadata);

  /// Downloads the backup blob for [uid], or null if none exists.
  Future<Uint8List?> download(String uid, {required int maxSizeBytes});

  /// Reads the metadata doc for [uid], or null if none exists.
  Future<Map<String, dynamic>?> readMetadata(String uid);

  /// Deletes the backup blob and metadata doc for [uid].
  Future<void> delete(String uid);
}

/// Production gateway: blob at `user_backups/{uid}/latest.json.gz` in Firebase
/// Storage, metadata doc at `user_backups/{uid}` in Firestore.
class FirebaseCloudBackupGateway implements CloudBackupGateway {
  FirebaseCloudBackupGateway({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Reference _blobRef(String uid) => _storage.ref('user_backups/$uid/latest.json.gz');

  DocumentReference<Map<String, dynamic>> _metadataDoc(String uid) => _firestore.collection('user_backups').doc(uid);

  @override
  Future<void> upload(String uid, Uint8List bytes, Map<String, dynamic> metadata) async {
    // Blob first, metadata second — `updatedAt` must never point at a stale blob.
    await _blobRef(uid).putData(bytes, SettableMetadata(contentType: 'application/gzip'));
    await _metadataDoc(uid).set({
      ...metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Uint8List?> download(String uid, {required int maxSizeBytes}) async {
    try {
      return await _blobRef(uid).getData(maxSizeBytes);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return null;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> readMetadata(String uid) async {
    final snapshot = await _metadataDoc(uid).get();
    return snapshot.data();
  }

  @override
  Future<void> delete(String uid) async {
    try {
      await _blobRef(uid).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
    await _metadataDoc(uid).delete();
  }
}

/// Cloud-side metadata about the latest backup, shown on the Sync screen
/// without downloading the blob.
class CloudBackupMetadata {
  final DateTime? updatedAt;
  final int sizeBytes;
  final int backupVersion;
  final String? deviceName;
  final String? appVersion;
  final Map<String, int> stats;

  CloudBackupMetadata({
    this.updatedAt,
    this.sizeBytes = 0,
    this.backupVersion = 0,
    this.deviceName,
    this.appVersion,
    this.stats = const {},
  });

  factory CloudBackupMetadata.fromMap(Map<String, dynamic> map) {
    final rawStats = map['stats'];
    return CloudBackupMetadata(
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      backupVersion: (map['backupVersion'] as num?)?.toInt() ?? 0,
      deviceName: map['deviceName'] as String?,
      appVersion: map['appVersion'] as String?,
      stats: rawStats is Map ? rawStats.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)) : const {},
    );
  }
}

/// Outcome of a cloud backup attempt.
class CloudBackupResult {
  final bool success;
  final String? error;
  final int sizeBytes;

  CloudBackupResult({required this.success, this.error, this.sizeBytes = 0});
}

/// Outcome of a cloud restore attempt.
class CloudRestoreResult {
  final bool success;
  final bool notFound;
  final String? error;
  final ImportResult? importResult;

  CloudRestoreResult({
    required this.success,
    this.notFound = false,
    this.error,
    this.importResult,
  });
}

/// Backs up the full [DataBackupService] export (v4 JSON, gzipped) to a single
/// per-user slot in Firebase and restores from it.
///
/// One latest backup per uid — the blob and metadata are overwritten on every
/// upload, so the cloud never accumulates duplicates. Restore reuses
/// `importFromJson(replace: false)`, whose uuid-skip merge guarantees no
/// duplicate rows on the device either.
///
/// Requires a signed-in user with a verified email (enforced by the Firebase
/// rules; checked here first to fail fast with a clear message).
class CloudBackupService {
  CloudBackupService({
    required DataBackupService backupService,
    required FirebaseAuthService authService,
    CloudBackupGateway? gateway,
    Future<String> Function()? deviceName,
  }) : _backupService = backupService,
       _authService = authService,
       _gateway = gateway ?? FirebaseCloudBackupGateway(),
       _deviceName = deviceName;

  final DataBackupService _backupService;
  final FirebaseAuthService _authService;
  final CloudBackupGateway _gateway;
  final Future<String> Function()? _deviceName;

  /// Mirrors the Storage rule's size cap.
  static const int maxBackupSizeBytes = 50 * 1024 * 1024;

  static const _gzipMagic = [0x1f, 0x8b];

  String? get _verifiedUid {
    final user = _authService.currentUser;
    if (user == null || !_authService.isEmailVerified) return null;
    return user.uid;
  }

  /// Exports all data and uploads it as the user's latest cloud backup.
  Future<CloudBackupResult> backupNow() async {
    final uid = _verifiedUid;
    if (uid == null) {
      return CloudBackupResult(success: false, error: 'Not signed in with a verified email');
    }

    try {
      final json = await _backupService.exportToJson();
      final bytes = Uint8List.fromList(gzip.encode(utf8.encode(json)));
      if (bytes.length > maxBackupSizeBytes) {
        return CloudBackupResult(success: false, error: 'Backup too large', sizeBytes: bytes.length);
      }

      final stats = await _backupService.getStats();
      final packageInfo = await PackageInfo.fromPlatform();
      final metadata = <String, dynamic>{
        'sizeBytes': bytes.length,
        'backupVersion': DataBackupService.currentVersion,
        'compressed': true,
        'deviceName': await _deviceName?.call(),
        'appVersion': '${packageInfo.version}+${packageInfo.buildNumber}',
        'stats': {
          'trainingCycles': stats.trainingCycleCount,
          'workouts': stats.workoutCount,
          'exercises': stats.exerciseCount,
          'customExercises': stats.customExerciseCount,
          'cardioSessions': stats.cardioSessionCount,
        },
      };

      await _gateway.upload(uid, bytes, metadata);
      return CloudBackupResult(success: true, sizeBytes: bytes.length);
    } catch (e, stack) {
      debugPrint('CloudBackupService.backupNow error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return CloudBackupResult(success: false, error: e.toString());
    }
  }

  /// Downloads the latest cloud backup and merges it into the local database.
  Future<CloudRestoreResult> restore() async {
    final uid = _verifiedUid;
    if (uid == null) {
      return CloudRestoreResult(success: false, error: 'Not signed in with a verified email');
    }

    try {
      final bytes = await _gateway.download(uid, maxSizeBytes: maxBackupSizeBytes);
      if (bytes == null) {
        // Also covers a metadata doc left behind without its blob.
        return CloudRestoreResult(success: false, notFound: true);
      }

      // Sniff the gzip magic bytes rather than trusting metadata, so an
      // uncompressed blob restores too.
      final isGzip = bytes.length >= 2 && bytes[0] == _gzipMagic[0] && bytes[1] == _gzipMagic[1];
      final json = utf8.decode(isGzip ? gzip.decode(bytes) : bytes);

      final importResult = await _backupService.importFromJson(json);
      return CloudRestoreResult(
        success: importResult.success,
        error: importResult.error,
        importResult: importResult,
      );
    } catch (e, stack) {
      debugPrint('CloudBackupService.restore error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return CloudRestoreResult(success: false, error: e.toString());
    }
  }

  /// Reads the cloud backup metadata for the current user, or null if the
  /// user has never backed up (or isn't signed in with a verified email).
  Future<CloudBackupMetadata?> fetchMetadata() async {
    final uid = _verifiedUid;
    if (uid == null) return null;

    try {
      final map = await _gateway.readMetadata(uid);
      return map == null ? null : CloudBackupMetadata.fromMap(map);
    } catch (e, stack) {
      debugPrint('CloudBackupService.fetchMetadata error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return null;
    }
  }

  /// Deletes the user's cloud backup (blob + metadata).
  Future<void> deleteBackup() async {
    final uid = _verifiedUid;
    if (uid == null) return;
    await _gateway.delete(uid);
  }
}
