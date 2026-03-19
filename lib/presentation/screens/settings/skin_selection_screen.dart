import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/skins/skins.dart';
import '../../data/services/theme_image_service.dart';

/// Screen for selecting and previewing app skins/themes.
class SkinSelectionScreen extends ConsumerWidget {
  const SkinSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skinState = ref.watch(skinProvider);
    final activeSkinId = skinState.activeSkin.id;
    final skins = skinState.availableSkins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => context.push('/skin-share'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, size: 22),
                    const SizedBox(height: 2),
                    Text(
                      'Share',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: skinState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current skin info
                _CurrentSkinCard(skin: skinState.activeSkin),
                const SizedBox(height: 24),

                // Section header with Create button
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose a Theme',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      FilledButton.icon(
                        onPressed: () => context.push('/theme-editor'),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Create'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Skin grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: skins.length,
                  itemBuilder: (context, index) {
                    final skin = skins[index];
                    final isSelected = skin.id == activeSkinId;
                    return _SkinCard(
                      skin: skin,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(skinProvider.notifier).setActiveSkin(skin.id);
                      },
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Future<void> _importTheme(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      // Check file extension
      if (!file.path!.endsWith('.yawa-theme')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a .yawa-theme file')),
          );
        }
        return;
      }

      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Read and parse the file
      final fileContent = await File(file.path!).readAsString();
      final skinRepository = ref.read(skinRepositoryProvider);
      final themeImageService = ref.read(themeImageServiceProvider);

      final parsed = await skinRepository.parseThemeFile(fileContent);

      // Import images
      await themeImageService.importThemeImagesFromBase64(
        themeId: parsed.skin.id,
        base64Map: parsed.imagesBase64,
      );

      // Get the actual image paths
      final imagePaths = await themeImageService.getAllThemeImagePaths(
        parsed.skin.id,
      );

      // Update skin with image paths
      final updatedSkin = parsed.skin.copyWith(
        backgrounds: SkinBackgrounds(
          workout: imagePaths['workout'],
          cycles: imagePaths['cycles'],
          exercises: imagePaths['exercises'],
          more: imagePaths['more'],
          defaultBackground: imagePaths['default'],
          appIcon: imagePaths['app_icon'],
        ),
      );

      // Save the skin
      await ref.read(skinProvider.notifier).saveCustomSkin(updatedSkin);

      // Close loading dialog and show success
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Theme "${updatedSkin.name}" imported!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog if open
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing theme: $e')));
      }
    }
  }
}

/// Card showing the currently active skin.
class _CurrentSkinCard extends StatelessWidget {
  final SkinModel skin;

  const _CurrentSkinCard({required this.skin});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Color preview circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skin.colors.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: skin.colors.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.palette, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Skin info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Theme',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skin.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skin.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for a single skin option.
class _SkinCard extends ConsumerWidget {
  final SkinModel skin;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = skin.colors.primaryColor;
    final isCustomSkin = !skin.isBuiltIn;

    return GestureDetector(
      onTap: onTap,
      onLongPress: isCustomSkin
          ? () => _showCustomSkinOptions(context, ref)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color swatches preview
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
                child: _ColorSwatchPreview(skin: skin),
              ),
            ),

            // Skin name and selection indicator
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skin.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (skin.isPremium)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Premium',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.amber[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else if (isCustomSkin)
                    GestureDetector(
                      onTap: () => context.push('/theme-editor/${skin.id}'),
                      child: Icon(
                        Icons.edit,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSkinOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Theme'),
              onTap: () {
                Navigator.pop(context);
                context.push('/theme-editor/${skin.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Theme'),
              onTap: () async {
                Navigator.pop(context);
                await _shareTheme(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Theme',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Theme?'),
                    content: Text(
                      'Are you sure you want to delete "${skin.name}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(skinProvider.notifier)
                      .deleteCustomSkin(skin.id);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTheme(BuildContext context, WidgetRef ref) async {
    // Navigate to the skin share screen with this skin pre-selected
    context.push('/skin-share?skinId=${skin.id}&autoStart=true');
  }
}

/// Preview of a skin's color palette.
class _ColorSwatchPreview extends StatelessWidget {
  final SkinModel skin;

  const _ColorSwatchPreview({required this.skin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modeColors = isDark ? skin.darkMode : skin.lightMode;

    return Container(
      color: modeColors.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Top bar simulation
          Container(
            height: 32,
            color: modeColors.cardBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skin.colors.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: modeColors.textPrimaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content simulation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Card simulation
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: modeColors.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text lines
                          Container(
                            height: 6,
                            width: 40,
                            decoration: BoxDecoration(
                              color: modeColors.textPrimaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: modeColors.textSecondaryColor.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Spacer(),
                          // Color dots row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _colorDot(skin.colors.primaryColor),
                              _colorDot(skin.colors.successColor),
                              _colorDot(skin.colors.warningColor),
                              _colorDot(skin.colors.infoColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar simulation
          Container(
            height: 24,
            color: modeColors.cardBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.home, size: 14, color: skin.colors.primaryColor),
                Icon(
                  Icons.fitness_center,
                  size: 14,
                  color: modeColors.textSecondaryColor,
                ),
                Icon(
                  Icons.more_horiz,
                  size: 14,
                  color: modeColors.textSecondaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
