import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/theme/skins/skin_model.dart';
import '../../core/theme/skins/skin_repository.dart';
import '../models/training_cycle_template.dart';
import '../services/community_service.dart';
import '../services/theme_image_service.dart';
import 'template_repository.dart';

/// Converts between Firestore documents and app models for the community
/// library. Delegates raw Firestore/Storage I/O to [CommunityService].
class CommunityRepository {
  CommunityRepository({
    required CommunityService communityService,
    required TemplateRepository templateRepository,
    required SkinRepository skinRepository,
    required ThemeImageService themeImageService,
  }) : _community = communityService,
       _templateRepo = templateRepository,
       _skinRepo = skinRepository,
       _themeImageService = themeImageService;

  final CommunityService _community;
  final TemplateRepository _templateRepo;
  final SkinRepository _skinRepo;
  final ThemeImageService _themeImageService;

  // ── Template browsing ────────────────────────────────────────────────

  /// Fetches community templates as app models.
  Future<CommunityPage<CommunityTemplate>> fetchTemplates({
    String orderBy = 'downloadCount',
    String? sportFilter,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final docs = await _community.fetchTemplates(
      orderBy: orderBy,
      sportFilter: sportFilter,
      limit: limit,
      startAfter: startAfter,
    );

    final items = docs.map((doc) {
      final data = doc.data();
      return CommunityTemplate(
        firestoreId: doc.id,
        template: TrainingCycleTemplate.fromJson(data),
        authorDisplayName: data['authorDisplayName'] as String? ?? 'Unknown',
        downloadCount: data['downloadCount'] as int? ?? 0,
        tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();

    return CommunityPage(
      items: items,
      lastDocument: docs.isNotEmpty ? docs.last : null,
      hasMore: docs.length == limit,
    );
  }

  /// Searches community templates by name.
  Future<List<CommunityTemplate>> searchTemplates(String query) async {
    final docs = await _community.searchTemplates(query);
    return docs.map((doc) {
      final data = doc.data();
      return CommunityTemplate(
        firestoreId: doc.id,
        template: TrainingCycleTemplate.fromJson(data),
        authorDisplayName: data['authorDisplayName'] as String? ?? 'Unknown',
        downloadCount: data['downloadCount'] as int? ?? 0,
        tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  /// Downloads a community template to local storage.
  Future<void> downloadTemplate(CommunityTemplate communityTemplate) async {
    await _templateRepo.saveTemplateDirectly(communityTemplate.template);
    await _community.incrementDownloadCount(
      collection: 'community_templates',
      docId: communityTemplate.firestoreId,
    );
  }

  // ── Skin browsing ───────────────────────────────────────────────────

  /// Fetches community skins as app models.
  Future<CommunityPage<CommunitySkin>> fetchSkins({
    String orderBy = 'downloadCount',
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    final docs = await _community.fetchSkins(
      orderBy: orderBy,
      limit: limit,
      startAfter: startAfter,
    );

    final items = docs.map((doc) {
      final data = doc.data();
      SkinModel? skin;
      try {
        final skinData = data['skinData'] as Map<String, dynamic>?;
        if (skinData != null) {
          skin = SkinModel.fromJson(skinData);
        }
      } catch (e) {
        debugPrint('Error parsing skin data for ${doc.id}: $e');
      }

      return CommunitySkin(
        firestoreId: doc.id,
        name: data['name'] as String? ?? 'Untitled',
        description: data['description'] as String? ?? '',
        skin: skin,
        imageRefs: (data['imageRefs'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? const {},
        thumbnailUrl: data['thumbnailUrl'] as String?,
        authorDisplayName: data['authorDisplayName'] as String? ?? 'Unknown',
        downloadCount: data['downloadCount'] as int? ?? 0,
        tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();

    return CommunityPage(
      items: items,
      lastDocument: docs.isNotEmpty ? docs.last : null,
      hasMore: docs.length == limit,
    );
  }

  /// Downloads a community skin, including images, to local storage.
  Future<void> downloadSkin(CommunitySkin communitySkin) async {
    if (communitySkin.skin == null) return;

    final newId = 'community_${DateTime.now().millisecondsSinceEpoch}';
    final localSkin = communitySkin.skin!.copyWith(
      id: newId,
      isBuiltIn: false,
    );

    // Download images from Storage and save locally.
    for (final entry in communitySkin.imageRefs.entries) {
      try {
        final bytes = await _community.downloadSkinImage(entry.value);
        if (bytes != null) {
          await _themeImageService.saveBase64Image(
            themeId: newId,
            imageType: entry.key,
            base64String: base64Encode(bytes),
          );
        }
      } catch (e, stack) {
        debugPrint('Error downloading skin image ${entry.key}: $e');
        Sentry.captureException(e, stackTrace: stack);
      }
    }

    // Get actual local file paths and convert to relative paths for storage.
    // Relative paths survive iOS container ID changes across app updates.
    final imagePaths = await _themeImageService.getAllThemeImagePaths(newId);
    final updatedSkin = localSkin.copyWith(
      backgrounds: SkinBackgrounds(
        workout: _themeImageService.toRelativePath(imagePaths['workout']),
        cycles: _themeImageService.toRelativePath(imagePaths['cycles']),
        exercises: _themeImageService.toRelativePath(imagePaths['exercises']),
        more: _themeImageService.toRelativePath(imagePaths['more']),
        defaultBackground: _themeImageService.toRelativePath(imagePaths['default']),
        appIcon: _themeImageService.toRelativePath(imagePaths['app_icon']),
      ),
    );

    await _skinRepo.saveCustomSkin(updatedSkin);
    await _community.incrementDownloadCount(
      collection: 'community_skins',
      docId: communitySkin.firestoreId,
    );
  }

  // ── My uploads ─────────────────────────────────────────────────────

  /// Fetches templates published by the given user.
  Future<List<CommunityTemplate>> fetchMyTemplates(String uid) async {
    final docs = await _community.fetchMyTemplates(uid);
    return docs.map((doc) {
      final data = doc.data();
      return CommunityTemplate(
        firestoreId: doc.id,
        template: TrainingCycleTemplate.fromJson(data),
        authorDisplayName: data['authorDisplayName'] as String? ?? 'Unknown',
        downloadCount: data['downloadCount'] as int? ?? 0,
        tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  /// Fetches skins published by the given user.
  Future<List<CommunitySkin>> fetchMySkins(String uid) async {
    final docs = await _community.fetchMySkins(uid);
    return docs.map((doc) {
      final data = doc.data();
      SkinModel? skin;
      try {
        final skinData = data['skinData'] as Map<String, dynamic>?;
        if (skinData != null) {
          skin = SkinModel.fromJson(skinData);
        }
      } catch (e) {
        debugPrint('Error parsing skin data for ${doc.id}: $e');
      }

      return CommunitySkin(
        firestoreId: doc.id,
        name: data['name'] as String? ?? 'Untitled',
        description: data['description'] as String? ?? '',
        skin: skin,
        imageRefs: (data['imageRefs'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? const {},
        thumbnailUrl: data['thumbnailUrl'] as String?,
        authorDisplayName: data['authorDisplayName'] as String? ?? 'Unknown',
        downloadCount: data['downloadCount'] as int? ?? 0,
        tags: (data['tags'] as List<dynamic>?)?.map((t) => t as String).toList() ?? const [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  /// Deletes a community template by Firestore document ID.
  Future<void> deleteTemplate(String docId) async {
    await _community.deleteTemplate(docId);
  }

  /// Deletes a community skin (including Storage images) by Firestore document
  /// ID.
  Future<void> deleteSkin(String docId) async {
    await _community.deleteSkin(docId);
  }

  // ── Publishing ──────────────────────────────────────────────────────

  /// Publishes a local template to the community library.
  Future<String> publishTemplate({
    required TrainingCycleTemplate template,
    required String authorUid,
    required String authorDisplayName,
    required List<String> tags,
  }) async {
    final data = <String, dynamic>{
      ...template.toJson(),
      'nameLower': template.name.toLowerCase(),
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'downloadCount': 0,
      'tags': tags,
      'version': 1,
      'status': 'published',
    };

    return await _community.publishTemplate(data);
  }

  /// Publishes a local skin to the community library.
  ///
  /// Uploads images to Firebase Storage first, then writes metadata to
  /// Firestore.
  Future<String> publishSkin({
    required SkinModel skin,
    required String authorUid,
    required String authorDisplayName,
    required List<String> tags,
    Map<String, Uint8List>? images,
  }) async {
    // First create the Firestore doc to get the docId for Storage paths.
    final skinJson = skin.toJson();
    // Remove local file paths from backgrounds before uploading.
    skinJson.remove('backgrounds');

    final data = <String, dynamic>{
      'name': skin.name,
      'nameLower': skin.name.toLowerCase(),
      'description': skin.description,
      'skinData': skinJson,
      'imageRefs': <String, String>{},
      'authorUid': authorUid,
      'authorDisplayName': authorDisplayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'downloadCount': 0,
      'tags': tags,
      'version': 1,
      'status': 'published',
    };

    final docId = await _community.publishSkin(data);

    // Upload images if provided.
    if (images != null && images.isNotEmpty) {
      final imageRefs = <String, String>{};
      String? thumbnailUrl;

      for (final entry in images.entries) {
        try {
          final url = await _community.uploadSkinImage(
            docId: docId,
            fileName: '${entry.key}.png',
            bytes: entry.value,
          );
          imageRefs[entry.key] = 'skins/$docId/${entry.key}.png';
          // Use the first image as the thumbnail.
          thumbnailUrl ??= url;
        } catch (e, stack) {
          debugPrint('Error uploading skin image ${entry.key}: $e');
          Sentry.captureException(e, stackTrace: stack);
        }
      }

      // Update Firestore doc with image refs.
      await _community.updateSkin(docId, {
        'imageRefs': imageRefs,
        'thumbnailUrl': ?thumbnailUrl,
      });
    }

    return docId;
  }
}

// ── View models ─────────────────────────────────────────────────────────

/// A community template with its Firestore metadata.
class CommunityTemplate {
  final String firestoreId;
  final TrainingCycleTemplate template;
  final String authorDisplayName;
  final int downloadCount;
  final List<String> tags;
  final DateTime? createdAt;

  const CommunityTemplate({
    required this.firestoreId,
    required this.template,
    required this.authorDisplayName,
    required this.downloadCount,
    required this.tags,
    this.createdAt,
  });
}

/// A community skin with its Firestore metadata.
class CommunitySkin {
  final String firestoreId;
  final String name;
  final String description;
  final SkinModel? skin;
  final Map<String, String> imageRefs;
  final String? thumbnailUrl;
  final String authorDisplayName;
  final int downloadCount;
  final List<String> tags;
  final DateTime? createdAt;

  const CommunitySkin({
    required this.firestoreId,
    required this.name,
    required this.description,
    this.skin,
    required this.imageRefs,
    this.thumbnailUrl,
    required this.authorDisplayName,
    required this.downloadCount,
    required this.tags,
    this.createdAt,
  });
}

/// A paginated result from Firestore.
class CommunityPage<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const CommunityPage({
    required this.items,
    this.lastDocument,
    required this.hasMore,
  });
}
