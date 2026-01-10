import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skin_model.dart';
import '../../core/theme/skins/skin_provider.dart';
import '../../data/services/theme_image_service.dart';
import '../../domain/providers/theme_provider.dart';

/// Screen identifiers for background selection.
enum ScreenType { workout, cycles, exercises, more, other }

/// A widget that wraps screen content with an optional background image.
///
/// The background image is determined by the current skin and screen type.
/// An overlay is applied on top of the image to ensure text readability.
class ScreenBackground extends ConsumerWidget {
  /// The screen type to determine which background image to use.
  final ScreenType screenType;

  /// The child widget to display on top of the background.
  final Widget child;

  /// Optional override for the background image path.
  /// If provided, this takes precedence over the skin's background.
  final String? backgroundOverride;

  const ScreenBackground({
    super.key,
    this.screenType = ScreenType.other,
    required this.child,
    this.backgroundOverride,
  });

  /// Convenience constructor for workout screen.
  const ScreenBackground.workout({
    super.key,
    required this.child,
    this.backgroundOverride,
  }) : screenType = ScreenType.workout;

  /// Convenience constructor for cycles screen.
  const ScreenBackground.cycles({
    super.key,
    required this.child,
    this.backgroundOverride,
  }) : screenType = ScreenType.cycles;

  /// Convenience constructor for exercises screen.
  const ScreenBackground.exercises({
    super.key,
    required this.child,
    this.backgroundOverride,
  }) : screenType = ScreenType.exercises;

  /// Convenience constructor for more screen.
  const ScreenBackground.more({
    super.key,
    required this.child,
    this.backgroundOverride,
  }) : screenType = ScreenType.more;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(activeSkinProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final imageService = ref.watch(themeImageServiceProvider);

    // Get the appropriate background image path (may be relative or absolute)
    final backgroundPath = backgroundOverride ?? _getBackgroundPath(skin);

    // If no background image, just return the child
    if (backgroundPath == null || backgroundPath.isEmpty) {
      return child;
    }

    // Get overlay opacity from skin settings
    final overlayOpacity = isDark
        ? (skin.backgrounds?.darkOverlayOpacity ?? 0.75)
        : (skin.backgrounds?.lightOverlayOpacity ?? 0.7);

    // Check if this is an asset path (built-in themes)
    if (backgroundPath.startsWith('assets/')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: _buildBackgroundImage(backgroundPath)),
          Positioned.fill(
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: overlayOpacity,
              ),
            ),
          ),
          child,
        ],
      );
    }

    // For custom themes, use FutureBuilder to resolve the path
    return FutureBuilder<String?>(
      future: imageService.resolveImagePath(backgroundPath),
      builder: (context, snapshot) {
        final resolvedPath = snapshot.data;

        // If path is not yet resolved or doesn't exist, just show child
        if (resolvedPath == null) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Positioned.fill(child: _buildBackgroundImage(resolvedPath)),

            // Overlay for readability
            Positioned.fill(
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: overlayOpacity,
                ),
              ),
            ),

            // Content
            child,
          ],
        );
      },
    );
  }

  /// Gets the background image path based on screen type and skin.
  String? _getBackgroundPath(SkinModel skin) {
    final backgrounds = skin.backgrounds;
    if (backgrounds == null) return null;

    switch (screenType) {
      case ScreenType.workout:
        return backgrounds.workout ?? backgrounds.defaultBackground;
      case ScreenType.cycles:
        return backgrounds.cycles ?? backgrounds.defaultBackground;
      case ScreenType.exercises:
        return backgrounds.exercises ?? backgrounds.defaultBackground;
      case ScreenType.more:
        return backgrounds.more ?? backgrounds.defaultBackground;
      case ScreenType.other:
        return backgrounds.defaultBackground;
    }
  }

  /// Builds the appropriate image widget based on the path.
  /// File paths (starting with /) use FileImage, otherwise uses asset.
  Widget _buildBackgroundImage(String path) {
    if (path.startsWith('/')) {
      // Custom theme with file path
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    } else {
      // Built-in theme with asset path
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      );
    }
  }
}

/// A Scaffold with an optional background image based on skin settings.
///
/// This is a convenience widget that combines Scaffold with ScreenBackground.
class BackgroundScaffold extends ConsumerWidget {
  final ScreenType screenType;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool extendBody;

  const BackgroundScaffold({
    super.key,
    this.screenType = ScreenType.other,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(activeSkinProvider);
    final hasBackground = _hasBackground(skin);

    return Scaffold(
      appBar: appBar,
      backgroundColor: hasBackground ? Colors.transparent : backgroundColor,
      extendBodyBehindAppBar: hasBackground || extendBodyBehindAppBar,
      extendBody: extendBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: body != null
          ? ScreenBackground(screenType: screenType, child: body!)
          : null,
    );
  }

  bool _hasBackground(SkinModel skin) {
    final backgrounds = skin.backgrounds;
    if (backgrounds == null) return false;

    switch (screenType) {
      case ScreenType.workout:
        return (backgrounds.workout ?? backgrounds.defaultBackground) != null;
      case ScreenType.cycles:
        return (backgrounds.cycles ?? backgrounds.defaultBackground) != null;
      case ScreenType.exercises:
        return (backgrounds.exercises ?? backgrounds.defaultBackground) != null;
      case ScreenType.more:
        return (backgrounds.more ?? backgrounds.defaultBackground) != null;
      case ScreenType.other:
        return backgrounds.defaultBackground != null;
    }
  }
}
