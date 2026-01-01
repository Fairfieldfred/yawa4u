import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Service for handling custom theme images.
///
/// Provides functionality to:
/// - Pick images from gallery or camera
/// - Compress images to ≤500KB
/// - Save images to app documents directory
/// - Extract dominant colors from images
/// - Clean up theme images when deleted
class ThemeImageService {
  static const int maxImageSizeBytes = 500 * 1024; // 500KB
  static const int targetWidth = 1080;
  static const int targetHeight = 1920;
  static const int minQuality = 30;
  static const int startQuality = 85;

  final ImagePicker _picker = ImagePicker();

  /// Get the base directory for storing theme images.
  Future<Directory> getThemesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final themesDir = Directory(path.join(appDir.path, 'themes'));
    if (!await themesDir.exists()) {
      await themesDir.create(recursive: true);
    }
    return themesDir;
  }

  /// Get the directory for a specific theme.
  Future<Directory> getThemeDirectory(String themeId) async {
    final themesDir = await getThemesDirectory();
    final themeDir = Directory(path.join(themesDir.path, themeId));
    if (!await themeDir.exists()) {
      await themeDir.create(recursive: true);
    }
    return themeDir;
  }

  /// Pick an image from gallery.
  Future<XFile?> pickImageFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: targetWidth.toDouble(),
      maxHeight: targetHeight.toDouble(),
    );
  }

  /// Pick an image from camera.
  Future<XFile?> pickImageFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: targetWidth.toDouble(),
      maxHeight: targetHeight.toDouble(),
    );
  }

  /// Compress an image to be under the max size limit.
  /// Returns the compressed image bytes, or null if compression fails.
  Future<Uint8List?> compressImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();

    // If already under limit, return original
    if (bytes.length <= maxImageSizeBytes) {
      return bytes;
    }

    // Try progressively lower quality until under limit
    int quality = startQuality;
    Uint8List? result;

    while (quality >= minQuality) {
      result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result.length <= maxImageSizeBytes) {
        return result;
      }

      quality -= 10;
    }

    // Return the best we could do even if over limit
    return result;
  }

  /// Save an image to the theme's directory.
  /// Returns the ABSOLUTE file path for immediate use in the UI.
  /// When persisting to database, use [toRelativePath] to convert for storage.
  Future<String?> saveThemeImage({
    required String themeId,
    required String
    imageType, // workout, cycles, exercises, more, default, app_icon
    required String sourcePath,
  }) async {
    try {
      final compressedBytes = await compressImage(sourcePath);
      if (compressedBytes == null) return null;

      final themeDir = await getThemeDirectory(themeId);
      final fileName = '$imageType.jpg';
      final targetFile = File(path.join(themeDir.path, fileName));

      await targetFile.writeAsBytes(compressedBytes);

      // Return absolute path for immediate UI use
      return targetFile.path;
    } catch (e) {
      debugPrint('Error saving theme image: $e');
      return null;
    }
  }

  /// Convert an absolute path to a relative path for storage.
  /// This ensures paths survive iOS container ID changes.
  String? toRelativePath(String? absolutePath) {
    if (absolutePath == null || absolutePath.isEmpty) return null;

    // Already relative
    if (!absolutePath.startsWith('/')) return absolutePath;

    // Extract relative path from absolute
    final themesIndex = absolutePath.indexOf('/themes/');
    if (themesIndex != -1) {
      return absolutePath.substring(themesIndex + 1); // Remove leading '/'
    }

    // Can't convert, return as-is
    return absolutePath;
  }

  /// Convert a relative path to an absolute path.
  /// Handles both relative paths (themes/...) and legacy absolute paths.
  Future<String?> resolveImagePath(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;

    // If it's already an absolute path (legacy), check if file exists
    if (relativePath.startsWith('/')) {
      final file = File(relativePath);
      if (await file.exists()) {
        return relativePath;
      }
      // Try to extract relative path from legacy absolute path
      final themesIndex = relativePath.indexOf('/themes/');
      if (themesIndex != -1) {
        relativePath = relativePath.substring(
          themesIndex + 1,
        ); // Remove leading '/'
      } else {
        return null; // Can't recover
      }
    }

    // Build absolute path from relative
    final appDir = await getApplicationDocumentsDirectory();
    final absolutePath = path.join(appDir.path, relativePath);
    final file = File(absolutePath);

    if (await file.exists()) {
      return absolutePath;
    }
    return null;
  }

  /// Delete all images for a theme.
  Future<void> deleteThemeImages(String themeId) async {
    try {
      final themesDir = await getThemesDirectory();
      final themeDir = Directory(path.join(themesDir.path, themeId));
      if (await themeDir.exists()) {
        await themeDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting theme images: $e');
    }
  }

  /// Delete a specific image from a theme.
  Future<void> deleteThemeImage({
    required String themeId,
    required String imageType,
  }) async {
    try {
      final themeDir = await getThemeDirectory(themeId);
      final file = File(path.join(themeDir.path, '$imageType.jpg'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting theme image: $e');
    }
  }

  /// Get the file path for a theme image, or null if it doesn't exist.
  Future<String?> getThemeImagePath({
    required String themeId,
    required String imageType,
  }) async {
    final themeDir = await getThemeDirectory(themeId);
    final file = File(path.join(themeDir.path, '$imageType.jpg'));
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Check if a theme has any images.
  Future<bool> themeHasImages(String themeId) async {
    final themesDir = await getThemesDirectory();
    final themeDir = Directory(path.join(themesDir.path, themeId));
    if (!await themeDir.exists()) return false;

    final files = await themeDir.list().toList();
    return files.isNotEmpty;
  }

  /// Extract dominant colors from an image.
  /// Returns a list of up to 6 dominant colors.
  Future<List<Color>> extractDominantColors(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return [];

      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        FileImage(file),
        maximumColorCount: 6,
      );

      final colors = <Color>[];

      // Add colors in order of preference
      if (paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }
      if (paletteGenerator.vibrantColor != null) {
        colors.add(paletteGenerator.vibrantColor!.color);
      }
      if (paletteGenerator.darkVibrantColor != null) {
        colors.add(paletteGenerator.darkVibrantColor!.color);
      }
      if (paletteGenerator.lightVibrantColor != null) {
        colors.add(paletteGenerator.lightVibrantColor!.color);
      }
      if (paletteGenerator.mutedColor != null) {
        colors.add(paletteGenerator.mutedColor!.color);
      }
      if (paletteGenerator.darkMutedColor != null) {
        colors.add(paletteGenerator.darkMutedColor!.color);
      }

      // Remove duplicates
      final uniqueColors = <Color>[];
      for (final color in colors) {
        if (!uniqueColors.any((c) => _colorsAreSimilar(c, color))) {
          uniqueColors.add(color);
        }
      }

      return uniqueColors.take(6).toList();
    } catch (e) {
      debugPrint('Error extracting colors: $e');
      return [];
    }
  }

  /// Check if two colors are similar (within threshold).
  bool _colorsAreSimilar(Color a, Color b, {double threshold = 0.12}) {
    return (a.r - b.r).abs() < threshold &&
        (a.g - b.g).abs() < threshold &&
        (a.b - b.b).abs() < threshold;
  }

  /// Convert an image file to Base64 string for export.
  Future<String?> imageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  /// Save a Base64 image string to the theme directory.
  Future<String?> saveBase64Image({
    required String themeId,
    required String imageType,
    required String base64String,
  }) async {
    try {
      final bytes = base64Decode(base64String);
      final themeDir = await getThemeDirectory(themeId);
      final fileName = '$imageType.jpg';
      final targetFile = File(path.join(themeDir.path, fileName));

      await targetFile.writeAsBytes(bytes);
      return targetFile.path;
    } catch (e) {
      debugPrint('Error saving base64 image: $e');
      return null;
    }
  }

  /// Get all image paths for a theme as a map.
  Future<Map<String, String>> getAllThemeImagePaths(String themeId) async {
    final imageTypes = [
      'workout',
      'cycles',
      'exercises',
      'more',
      'default',
      'app_icon',
    ];
    final paths = <String, String>{};

    for (final type in imageTypes) {
      final imagePath = await getThemeImagePath(
        themeId: themeId,
        imageType: type,
      );
      if (imagePath != null) {
        paths[type] = imagePath;
      }
    }

    return paths;
  }

  /// Export all theme images as Base64 map.
  Future<Map<String, String>> exportThemeImagesAsBase64(String themeId) async {
    final imagePaths = await getAllThemeImagePaths(themeId);
    final base64Map = <String, String>{};

    for (final entry in imagePaths.entries) {
      final base64 = await imageToBase64(entry.value);
      if (base64 != null) {
        base64Map[entry.key] = base64;
      }
    }

    return base64Map;
  }

  /// Import theme images from Base64 map.
  Future<void> importThemeImagesFromBase64({
    required String themeId,
    required Map<String, String> base64Map,
  }) async {
    for (final entry in base64Map.entries) {
      await saveBase64Image(
        themeId: themeId,
        imageType: entry.key,
        base64String: entry.value,
      );
    }
  }
}

/// Provider for the ThemeImageService.
final themeImageServiceProvider = Provider<ThemeImageService>((ref) {
  return ThemeImageService();
});
