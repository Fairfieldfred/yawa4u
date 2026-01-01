import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skin_provider.dart';
import '../../data/services/theme_image_service.dart';
import '../../domain/providers/onboarding_providers.dart';

/// A widget that displays the user's selected app icon based on theme
/// If the active skin has a custom appIcon, it will be used instead.
class AppIconWidget extends ConsumerWidget {
  final double? size;

  const AppIconWidget({super.key, this.size});

  // Light mode icons
  static const List<String> _lightIconPaths = [
    'assets/common/app-icon.png',
    'assets/common/yawa4u-icon.png',
    'assets/common/female-app-icon.png',
  ];

  // Dark mode icons
  static const List<String> _darkIconPaths = [
    'assets/common/app-icon-dark.png',
    'assets/common/yawa4u-icon-dark.png',
    'assets/common/female-app-icon-dark.png',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSkin = ref.watch(activeSkinProvider);
    final customAppIcon = activeSkin.backgrounds?.appIcon;
    final imageService = ref.watch(themeImageServiceProvider);

    // Use AppBar height or provided size
    final iconSize = size ?? kToolbarHeight - 20;

    // If the active skin has a custom app icon, use it
    if (customAppIcon != null && customAppIcon.isNotEmpty) {
      // Check if this is an asset path (built-in themes)
      if (customAppIcon.startsWith('assets/')) {
        return Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              customAppIcon,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultIcon(context, ref, iconSize),
            ),
          ),
        );
      }

      // For custom themes, resolve the file path
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FutureBuilder<String?>(
            future: imageService.resolveImagePath(customAppIcon),
            builder: (context, snapshot) {
              final resolvedPath = snapshot.data;
              if (resolvedPath == null) {
                return _buildDefaultIcon(context, ref, iconSize);
              }
              return Image.file(
                File(resolvedPath),
                width: iconSize,
                height: iconSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultIcon(context, ref, iconSize),
              );
            },
          ),
        ),
      );
    }

    // Fall back to default icon selection
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildDefaultIcon(context, ref, iconSize),
      ),
    );
  }

  Widget _buildDefaultIcon(
    BuildContext context,
    WidgetRef ref,
    double iconSize,
  ) {
    final appIconIndex = ref.watch(userProfileProvider).appIconIndex;
    final brightness = Theme.of(context).brightness;
    final iconPaths = brightness == Brightness.dark
        ? _darkIconPaths
        : _lightIconPaths;

    // Ensure index is within bounds
    final validIndex = appIconIndex.clamp(0, iconPaths.length - 1);
    final iconPath = iconPaths[validIndex];

    return Image.asset(
      iconPath,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.cover,
    );
  }
}
