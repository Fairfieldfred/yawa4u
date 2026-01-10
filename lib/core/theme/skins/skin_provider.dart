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
  SkinRepository? _repository;

  SkinRepository get repository => _repository ??= SkinRepository();

  @override
  SkinState build() {
    // Reset repository on rebuild (happens when invalidated)
    _repository = null;

    // Since SkinRepository is already initialized in main.dart before runApp,
    // we can synchronously get the active skin here
    final activeSkin = repository.getActiveSkin();
    final availableSkins = repository.getAllSkins();

    debugPrint('[SkinNotifier] Built with skin: ${activeSkin.name}');

    return SkinState(
      activeSkin: activeSkin,
      availableSkins: availableSkins,
      isLoading: false,
    );
  }

  /// Change the active skin
  Future<void> setActiveSkin(String skinId) async {
    final skin = repository.getSkinById(skinId);
    if (skin == null) {
      debugPrint('[SkinNotifier] Skin not found: $skinId');
      return;
    }

    await repository.setActiveSkinId(skinId);
    state = state.copyWith(activeSkin: skin);
    debugPrint('[SkinNotifier] Active skin changed to: ${skin.name}');
  }

  /// Save a custom skin
  Future<void> saveCustomSkin(SkinModel skin) async {
    await repository.saveCustomSkin(skin);
    _refreshAvailableSkins();
  }

  /// Delete a custom skin
  Future<bool> deleteCustomSkin(String skinId) async {
    final deleted = await repository.deleteCustomSkin(skinId);
    if (deleted) {
      _refreshAvailableSkins();

      // If deleted skin was active, update state
      if (state.activeSkin.id == skinId) {
        final newActive = repository.getActiveSkin();
        state = state.copyWith(activeSkin: newActive);
      }
    }
    return deleted;
  }

  /// Import a skin from JSON
  Future<SkinModel?> importSkin(String jsonString) async {
    try {
      final skin = await repository.importSkin(jsonString);
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
    return repository.exportSkin(skin);
  }

  /// Duplicate an existing skin with a new name
  SkinModel duplicateSkin(SkinModel source, String newName) {
    return repository.duplicateSkin(source, newName);
  }

  /// Refresh the list of available skins
  void _refreshAvailableSkins() {
    final skins = repository.getAllSkins();
    state = state.copyWith(availableSkins: skins);
  }

  /// Get built-in skins only
  List<SkinModel> get builtInSkins => BuiltInSkins.all;

  /// Get custom skins only
  List<SkinModel> get customSkins => repository.getCustomSkins();
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

/// Provider for direct access to the SkinRepository
/// Used for export/import operations that don't need state management
final skinRepositoryProvider = Provider<SkinRepository>((ref) {
  return SkinRepository();
});
