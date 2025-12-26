/// Barrel file for all built-in skins.
library;

import '../skin_model.dart';
import 'default_skin.dart';
import 'forest_skin.dart';
import 'minimal_skin.dart';
import 'neon_skin.dart';
import 'ocean_skin.dart';
import 'sunset_skin.dart';

export 'default_skin.dart';
export 'forest_skin.dart';
export 'minimal_skin.dart';
export 'neon_skin.dart';
export 'ocean_skin.dart';
export 'sunset_skin.dart';

/// Provides access to all built-in skins.
class BuiltInSkins {
  BuiltInSkins._();

  /// The ID of the default skin
  static const String defaultSkinId = 'default';

  /// The default skin instance
  static SkinModel get defaultSkin => defaultSkinDefinition;

  /// List of all built-in skins
  static List<SkinModel> get all => [
    defaultSkinDefinition,
    oceanSkinDefinition,
    forestSkinDefinition,
    sunsetSkinDefinition,
    neonSkinDefinition,
    minimalSkinDefinition,
  ];

  /// Get a built-in skin by ID
  static SkinModel? getSkinById(String id) {
    for (final skin in all) {
      if (skin.id == id) {
        return skin;
      }
    }
    return null;
  }

  /// Check if a skin ID belongs to a built-in skin
  static bool isBuiltIn(String id) => getSkinById(id) != null;
}
