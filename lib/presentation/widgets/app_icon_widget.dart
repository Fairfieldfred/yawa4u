import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/onboarding_providers.dart';

/// A widget that displays the user's selected app icon based on theme
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
    final appIconIndex = ref.watch(userProfileProvider).appIconIndex;
    final brightness = Theme.of(context).brightness;
    final iconPaths = brightness == Brightness.dark
        ? _darkIconPaths
        : _lightIconPaths;

    // Ensure index is within bounds
    final validIndex = appIconIndex.clamp(0, iconPaths.length - 1);
    final iconPath = iconPaths[validIndex];

    // Use AppBar height or provided size
    final iconSize = size ?? kToolbarHeight - 20;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
