import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Low-level Firestore + Storage calls for the community library.
///
/// This service handles raw reads and writes against the `community_templates`
/// and `community_skins` collections, plus skin image uploads/downloads via
/// Firebase Storage. Business-level conversion to/from app models happens in
/// [CommunityRepository].
class CommunityService {
  CommunityService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // ── Collections ──────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _templatesCol => _firestore.collection('community_templates');

  CollectionReference<Map<String, dynamic>> get _skinsCol => _firestore.collection('community_skins');

  // ── Template reads ───────────────────────────────────────────────────

  /// Fetches published templates, ordered by [orderBy] descending.
  ///
  /// Supports pagination via [startAfter] (pass the last document snapshot).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchTemplates({
    String orderBy = 'downloadCount',
    String? sportFilter,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _templatesCol
          .where('status', isEqualTo: 'published')
          .orderBy(orderBy, descending: true)
          .limit(limit);

      if (sportFilter != null) {
        query = query.where('primarySport', isEqualTo: sportFilter);
      }
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e, stack) {
      debugPrint('CommunityService.fetchTemplates error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return [];
    }
  }

  /// Searches published templates by name (case-insensitive prefix match).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchTemplates(
    String query, {
    int limit = 20,
  }) async {
    try {
      // Firestore doesn't support full-text search, so we use a prefix
      // range query on the lowercase name field.
      final lower = query.toLowerCase();
      final upper = '${lower}z';

      final snapshot = await _templatesCol
          .where('status', isEqualTo: 'published')
          .where('nameLower', isGreaterThanOrEqualTo: lower)
          .where('nameLower', isLessThanOrEqualTo: upper)
          .limit(limit)
          .get();

      return snapshot.docs;
    } catch (e, stack) {
      debugPrint('CommunityService.searchTemplates error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return [];
    }
  }

  // ── Skin reads ───────────────────────────────────────────────────────

  /// Fetches published skins, ordered by [orderBy] descending.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchSkins({
    String orderBy = 'downloadCount',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _skinsCol
          .where('status', isEqualTo: 'published')
          .orderBy(orderBy, descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e, stack) {
      debugPrint('CommunityService.fetchSkins error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return [];
    }
  }

  // ── Download count ───────────────────────────────────────────────────

  /// Atomically increments the download count for a template or skin.
  Future<void> incrementDownloadCount({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        'downloadCount': FieldValue.increment(1),
      });
    } catch (e, stack) {
      // Non-critical — log but don't rethrow.
      debugPrint('CommunityService.incrementDownloadCount error: $e');
      Sentry.captureException(e, stackTrace: stack);
    }
  }

  // ── Template publishing ──────────────────────────────────────────────

  /// Publishes a template to Firestore.
  Future<String> publishTemplate(Map<String, dynamic> data) async {
    final docRef = await _templatesCol.add(data);
    return docRef.id;
  }

  /// Updates an existing template document.
  Future<void> updateTemplate(String docId, Map<String, dynamic> data) async {
    await _templatesCol.doc(docId).update(data);
  }

  /// Deletes a template document.
  Future<void> deleteTemplate(String docId) async {
    await _templatesCol.doc(docId).delete();
  }

  // ── Skin publishing ──────────────────────────────────────────────────

  /// Publishes skin metadata to Firestore.
  Future<String> publishSkin(Map<String, dynamic> data) async {
    final docRef = await _skinsCol.add(data);
    return docRef.id;
  }

  /// Updates an existing skin document.
  Future<void> updateSkin(String docId, Map<String, dynamic> data) async {
    await _skinsCol.doc(docId).update(data);
  }

  /// Deletes a skin document and its associated Storage images.
  Future<void> deleteSkin(String docId) async {
    // Delete storage images first.
    try {
      final listResult = await _storage.ref('skins/$docId').listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (_) {
      // Storage folder may not exist — ignore.
    }
    await _skinsCol.doc(docId).delete();
  }

  // ── Storage (skin images) ───────────────────────────────────────────

  /// Uploads a skin image to Firebase Storage and returns the download URL.
  Future<String> uploadSkinImage({
    required String docId,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/png',
  }) async {
    final ref = _storage.ref('skins/$docId/$fileName');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }

  /// Downloads a skin image from Firebase Storage as bytes.
  Future<Uint8List?> downloadSkinImage(String storagePath) async {
    try {
      final ref = _storage.ref(storagePath);
      // Max 2 MB as per security rules.
      return await ref.getData(2 * 1024 * 1024);
    } catch (e, stack) {
      debugPrint('CommunityService.downloadSkinImage error: $e');
      Sentry.captureException(e, stackTrace: stack);
      return null;
    }
  }

  /// Fetches templates published by a specific user.
  ///
  /// Rethrows errors so the calling provider surfaces them in the UI
  /// instead of silently returning an empty list.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchMyTemplates(String uid) async {
    try {
      final snapshot = await _templatesCol
          .where('authorUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs;
    } catch (e, stack) {
      debugPrint('CommunityService.fetchMyTemplates error: $e');
      Sentry.captureException(e, stackTrace: stack);
      rethrow;
    }
  }

  /// Fetches skins published by a specific user.
  ///
  /// Rethrows errors so the calling provider surfaces them in the UI.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchMySkins(String uid) async {
    try {
      final snapshot = await _skinsCol.where('authorUid', isEqualTo: uid).orderBy('createdAt', descending: true).get();
      return snapshot.docs;
    } catch (e, stack) {
      debugPrint('CommunityService.fetchMySkins error: $e');
      Sentry.captureException(e, stackTrace: stack);
      rethrow;
    }
  }
}
