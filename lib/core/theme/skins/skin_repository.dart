import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'built_in_skins/built_in_skins.dart';
import 'skin_model.dart';

/// Repository for managing skin persistence and retrieval.
///
/// Handles:
/// - Loading/saving the active skin ID
/// - Loading/saving custom user skins
/// - Providing access to built-in skins
class SkinRepository {
  static const String _boxName = 'skin_preferences';
  static const String _activeSkinKey = 'active_skin_id';
  static const String _customSkinsKey = 'custom_skins';

  late final Box<String> _box;
  bool _initialized = false;

  /// Singleton instance
  static final SkinRepository _instance = SkinRepository._internal();

  /// Factory constructor returns the singleton instance
  factory SkinRepository() => _instance;

  SkinRepository._internal();

  /// Initialize the repository
  Future<void> initialize() async {
    if (_initialized) return;

    _box = await Hive.openBox<String>(_boxName);
    _initialized = true;
    debugPrint('[SkinRepository] Initialized');
  }

  /// Get the ID of the currently active skin
  String getActiveSkinId() {
    _checkInitialized();
    return _box.get(_activeSkinKey, defaultValue: BuiltInSkins.defaultSkinId)!;
  }

  /// Set the active skin ID
  Future<void> setActiveSkinId(String skinId) async {
    _checkInitialized();
    await _box.put(_activeSkinKey, skinId);
    debugPrint('[SkinRepository] Active skin set to: $skinId');
  }

  /// Get all available skins (built-in + custom)
  List<SkinModel> getAllSkins() {
    _checkInitialized();
    final customSkins = getCustomSkins();
    return [...BuiltInSkins.all, ...customSkins];
  }

  /// Get a skin by ID (searches both built-in and custom)
  SkinModel? getSkinById(String id) {
    _checkInitialized();

    // Check built-in skins first
    final builtIn = BuiltInSkins.getSkinById(id);
    if (builtIn != null) return builtIn;

    // Check custom skins
    final customSkins = getCustomSkins();
    for (final skin in customSkins) {
      if (skin.id == id) return skin;
    }

    return null;
  }

  /// Get the currently active skin
  SkinModel getActiveSkin() {
    final id = getActiveSkinId();
    return getSkinById(id) ?? BuiltInSkins.defaultSkin;
  }

  /// Get all custom (user-created) skins
  List<SkinModel> getCustomSkins() {
    _checkInitialized();

    final jsonString = _box.get(_customSkinsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final skins = jsonList
          .map((j) => SkinModel.fromJson(j as Map<String, dynamic>))
          .toList();

      // Debug: Log loaded custom skins and their backgrounds
      for (final skin in skins) {
        debugPrint(
          '[SkinRepository] Loaded custom skin: ${skin.name} (${skin.id})',
        );
        debugPrint('  backgrounds: ${skin.backgrounds?.toJson()}');
      }

      return skins;
    } on FormatException catch (e) {
      debugPrint('[SkinRepository] Error parsing custom skins: $e');
      return [];
    }
  }

  /// Save a custom skin
  Future<void> saveCustomSkin(SkinModel skin) async {
    _checkInitialized();

    if (skin.isBuiltIn) {
      throw ArgumentError('Cannot save a built-in skin as custom');
    }

    final customSkins = getCustomSkins();

    // Check if skin with same ID exists, replace it
    final existingIndex = customSkins.indexWhere((s) => s.id == skin.id);
    if (existingIndex >= 0) {
      customSkins[existingIndex] = skin;
    } else {
      customSkins.add(skin);
    }

    await _saveCustomSkins(customSkins);
    debugPrint('[SkinRepository] Saved custom skin: ${skin.name} (${skin.id})');
  }

  /// Delete a custom skin by ID
  Future<bool> deleteCustomSkin(String skinId) async {
    _checkInitialized();

    // Don't allow deleting built-in skins
    if (BuiltInSkins.getSkinById(skinId) != null) {
      debugPrint('[SkinRepository] Cannot delete built-in skin: $skinId');
      return false;
    }

    final customSkins = getCustomSkins();
    final initialLength = customSkins.length;
    customSkins.removeWhere((s) => s.id == skinId);

    if (customSkins.length < initialLength) {
      await _saveCustomSkins(customSkins);

      // If deleted skin was active, switch to default
      if (getActiveSkinId() == skinId) {
        await setActiveSkinId(BuiltInSkins.defaultSkinId);
      }

      debugPrint('[SkinRepository] Deleted custom skin: $skinId');
      return true;
    }

    return false;
  }

  /// Import a skin from JSON
  Future<SkinModel> importSkin(String jsonString) async {
    _checkInitialized();

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final skin = SkinModel.fromJson(jsonMap);

    // Ensure imported skin is marked as not built-in
    final importedSkin = skin.copyWith(isBuiltIn: false);

    // Generate a new ID to avoid conflicts
    final uniqueSkin = importedSkin.copyWith(
      id: '${importedSkin.id}_imported_${DateTime.now().millisecondsSinceEpoch}',
    );

    await saveCustomSkin(uniqueSkin);
    return uniqueSkin;
  }

  /// Export a skin to JSON string
  String exportSkin(SkinModel skin) {
    return json.encode(skin.toJson());
  }

  /// Export a skin with images as a shareable package.
  /// Returns JSON string that can be saved as .yawa-theme file.
  Future<String> exportSkinWithImages(
    SkinModel skin,
    Map<String, String> imagesBase64,
  ) async {
    final skinJson = skin.toJson();
    skinJson['imagesBase64'] = imagesBase64;
    skinJson['exportVersion'] = 1;
    skinJson['exportedAt'] = DateTime.now().toIso8601String();
    return json.encode(skinJson);
  }

  /// Import a skin from a .yawa-theme file content.
  /// Returns the parsed SkinModel and images map.
  Future<({SkinModel skin, Map<String, String> imagesBase64})> parseThemeFile(
    String jsonString,
  ) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;

    // Extract and remove images before parsing skin
    final imagesBase64 =
        data.remove('imagesBase64') as Map<String, dynamic>? ?? {};
    data.remove('exportVersion');
    data.remove('exportedAt');

    final skin = SkinModel.fromJson(data);

    return (
      skin: skin,
      imagesBase64: imagesBase64.map((k, v) => MapEntry(k, v as String)),
    );
  }

  /// Create a new custom skin based on an existing skin
  SkinModel duplicateSkin(SkinModel source, String newName) {
    return source.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: newName,
      isBuiltIn: false,
    );
  }

  Future<void> _saveCustomSkins(List<SkinModel> skins) async {
    final jsonList = skins.map((s) => s.toJson()).toList();
    final jsonString = json.encode(jsonList);
    debugPrint('[SkinRepository] Saving ${skins.length} custom skins');
    debugPrint('[SkinRepository] JSON being saved: $jsonString');
    await _box.put(_customSkinsKey, jsonString);
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw StateError(
        'SkinRepository not initialized. Call initialize() first.',
      );
    }
  }

  /// Clear all custom skins (for testing/reset)
  Future<void> clearCustomSkins() async {
    _checkInitialized();
    await _box.delete(_customSkinsKey);
    debugPrint('[SkinRepository] Cleared all custom skins');
  }
}
