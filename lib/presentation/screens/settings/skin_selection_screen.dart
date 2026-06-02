import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../l10n/app_localizations.dart';

/// Screen for selecting and previewing app skins/themes.
class SkinSelectionScreen extends ConsumerWidget {
  const SkinSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final skinState = ref.watch(skinProvider);
    final activeSkinId = skinState.activeSkin.id;
    final skins = skinState.availableSkins;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.skinSelectionTitle),
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
                      l10n.skinSelectionShare,
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
                        l10n.skinSelectionChooseTheme,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      FilledButton.icon(
                        onPressed: () => context.push('/theme-editor'),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(l10n.skinSelectionCreate),
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

                // Browse community themes
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.explore),
                    title: Text(l10n.skinSelectionBrowseCommunity),
                    subtitle: Text(
                      l10n.skinSelectionBrowseCommunitySubtitle,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                    ),
                    onTap: () => context.push('/community?tab=1'),
                  ),
                ),
                const SizedBox(height: 8),

                // Skin list
                ...skins.map((skin) {
                  final isSelected = skin.id == activeSkinId;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SkinCard(
                      skin: skin,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(skinProvider.notifier).setActiveSkin(skin.id);
                      },
                    ),
                  );
                }),
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.skinSelectionCurrentTheme,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = skin.colors.primaryColor;
    final isCustomSkin = !skin.isBuiltIn;

    return GestureDetector(
      onTap: onTap,
      onLongPress: isCustomSkin ? () => _showCustomSkinOptions(context, ref) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Color swatch preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: _ColorSwatchPreview(skin: skin),
                ),
              ),
              const SizedBox(width: 12),
              // Name and premium badge
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.skinSelectionPremium,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Color dots row
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _colorDot(skin.colors.primaryColor),
                          const SizedBox(width: 6),
                          _colorDot(skin.colors.successColor),
                          const SizedBox(width: 6),
                          _colorDot(skin.colors.warningColor),
                          const SizedBox(width: 6),
                          _colorDot(skin.colors.infoColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Trailing: selection indicator or edit button
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
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showCustomSkinOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.skinSelectionEditTheme),
              onTap: () {
                Navigator.pop(context);
                context.push('/theme-editor/${skin.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.skinSelectionShareTheme),
              onTap: () async {
                Navigator.pop(context);
                await _shareTheme(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n.skinSelectionDeleteTheme,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    final dialogL10n = AppLocalizations.of(dialogContext)!;
                    return AlertDialog(
                      title: Text(dialogL10n.skinSelectionDeleteThemeTitle),
                      content: Text(
                        dialogL10n.skinSelectionDeleteConfirm(skin.name),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(dialogL10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(dialogL10n.delete),
                        ),
                      ],
                    );
                  },
                );
                if (confirm == true) {
                  await ref.read(skinProvider.notifier).deleteCustomSkin(skin.id);
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

/// Compact preview of a skin's color palette for the list tile.
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
          // Top bar
          Container(
            height: 14,
            color: modeColors.cardBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 6,
                  decoration: BoxDecoration(
                    color: skin.colors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: modeColors.textPrimaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: modeColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color: modeColors.textPrimaryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 2,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: modeColors.textSecondaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom bar
          Container(
            height: 12,
            color: modeColors.cardBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.home,
                  size: 8,
                  color: skin.colors.primaryColor,
                ),
                Icon(
                  Icons.fitness_center,
                  size: 8,
                  color: modeColors.textSecondaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
