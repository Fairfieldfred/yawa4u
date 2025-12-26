import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/skins/skins.dart';

/// Screen for selecting and previewing app skins/themes.
class SkinSelectionScreen extends ConsumerWidget {
  const SkinSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skinState = ref.watch(skinProvider);
    final activeSkinId = skinState.activeSkin.id;
    final skins = skinState.availableSkins;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance'), centerTitle: true),
      body: skinState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current skin info
                _CurrentSkinCard(skin: skinState.activeSkin),
                const SizedBox(height: 24),

                // Section header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Choose a Theme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
class _SkinCard extends StatelessWidget {
  final SkinModel skin;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = skin.colors.primaryColor;

    return GestureDetector(
      onTap: onTap,
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
