import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'built_in_skins/built_in_skins.dart';
import 'skin_builder.dart';
import 'skin_model.dart';
import 'skin_repository.dart';

/// State class for skin management
@immutable
class SkinState {
  final SkinModel activeSkin;
  final List<SkinModel> availableSkins;
  final bool isLoading;
  final String? error;

  const SkinState({
    required this.activeSkin,
    required this.availableSkins,
    this.isLoading = false,
    this.error,
  });

  SkinState copyWith({
    SkinModel? activeSkin,
    List<SkinModel>? availableSkins,
    bool? isLoading,
    String? error,
  }) {
    return SkinState(
      activeSkin: activeSkin ?? this.activeSkin,
      availableSkins: availableSkins ?? this.availableSkins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Build light theme from active skin
  ThemeData get lightTheme =>
      SkinBuilder.buildTheme(activeSkin, Brightness.light);

  /// Build dark theme from active skin
  ThemeData get darkTheme =>
      SkinBuilder.buildTheme(activeSkin, Brightness.dark);
}

/// Notifier for managing skin state using Riverpod 3.0 Notifier pattern
class SkinNotifier extends Notifier<SkinState> {
  late final SkinRepository _repository;

  @override
  SkinState build() {
    _repository = SkinRepository();
    // Start with default skin, then load from preferences
    _initialize();
    return SkinState(
      activeSkin: BuiltInSkins.defaultSkin,
      availableSkins: BuiltInSkins.all,
    );
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.initialize();
      final activeSkin = _repository.getActiveSkin();
      final availableSkins = _repository.getAllSkins();

      state = SkinState(
        activeSkin: activeSkin,
        availableSkins: availableSkins,
        isLoading: false,
      );

      debugPrint('[SkinNotifier] Initialized with skin: ${activeSkin.name}');
    } on Exception catch (e) {
      debugPrint('[SkinNotifier] Error initializing: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load skin preferences: $e',
      );
    }
  }

  /// Change the active skin
  Future<void> setActiveSkin(String skinId) async {
    final skin = _repository.getSkinById(skinId);
    if (skin == null) {
      debugPrint('[SkinNotifier] Skin not found: $skinId');
      return;
    }

    await _repository.setActiveSkinId(skinId);
    state = state.copyWith(activeSkin: skin);
    debugPrint('[SkinNotifier] Active skin changed to: ${skin.name}');
  }

  /// Save a custom skin
  Future<void> saveCustomSkin(SkinModel skin) async {
    await _repository.saveCustomSkin(skin);
    _refreshAvailableSkins();
  }

  /// Delete a custom skin
  Future<bool> deleteCustomSkin(String skinId) async {
    final deleted = await _repository.deleteCustomSkin(skinId);
    if (deleted) {
      _refreshAvailableSkins();

      // If deleted skin was active, update state
      if (state.activeSkin.id == skinId) {
        final newActive = _repository.getActiveSkin();
        state = state.copyWith(activeSkin: newActive);
      }
    }
    return deleted;
  }

  /// Import a skin from JSON
  Future<SkinModel?> importSkin(String jsonString) async {
    try {
      final skin = await _repository.importSkin(jsonString);
      _refreshAvailableSkins();
      return skin;
    } on Exception catch (e) {
      debugPrint('[SkinNotifier] Error importing skin: $e');
      state = state.copyWith(error: 'Failed to import skin: $e');
      return null;
    }
  }

  /// Export a skin to JSON
  String exportSkin(SkinModel skin) {
    return _repository.exportSkin(skin);
  }

  /// Duplicate an existing skin with a new name
  SkinModel duplicateSkin(SkinModel source, String newName) {
    return _repository.duplicateSkin(source, newName);
  }

  /// Refresh the list of available skins
  void _refreshAvailableSkins() {
    final skins = _repository.getAllSkins();
    state = state.copyWith(availableSkins: skins);
  }

  /// Get built-in skins only
  List<SkinModel> get builtInSkins => BuiltInSkins.all;

  /// Get custom skins only
  List<SkinModel> get customSkins => _repository.getCustomSkins();
}

/// Provider for the skin state using NotifierProvider
final skinProvider = NotifierProvider<SkinNotifier, SkinState>(() {
  return SkinNotifier();
});

/// Convenience provider for the active skin
final activeSkinProvider = Provider<SkinModel>((ref) {
  return ref.watch(skinProvider).activeSkin;
});

/// Convenience provider for the light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(skinProvider).lightTheme;
});

/// Convenience provider for the dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(skinProvider).darkTheme;
});

/// Convenience provider for all available skins
final availableSkinsProvider = Provider<List<SkinModel>>((ref) {
  return ref.watch(skinProvider).availableSkins;
});
