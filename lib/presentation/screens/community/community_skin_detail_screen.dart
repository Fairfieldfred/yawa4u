import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../domain/providers/community_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Detail + download screen for a single community skin/theme.
class CommunitySkinDetailScreen extends ConsumerStatefulWidget {
  final CommunitySkin skin;

  const CommunitySkinDetailScreen({super.key, required this.skin});

  @override
  ConsumerState<CommunitySkinDetailScreen> createState() => _CommunitySkinDetailScreenState();
}

class _CommunitySkinDetailScreenState extends ConsumerState<CommunitySkinDetailScreen> {
  bool _isDownloading = false;
  bool _downloaded = false;

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.skin.skin == null) {
      context.showErrorSnackBar(l10n.communityInvalidThemeData);
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.downloadSkin(widget.skin);

      // Refresh the skin list so the Appearance screen sees the new skin.
      // downloadSkin saves via SkinRepository directly, which doesn't
      // notify SkinNotifier — so we invalidate it here.
      ref.invalidate(skinProvider);

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloaded = true;
        });
        context.showSuccessSnackBar(l10n.communitySavedToThemes(widget.skin.name));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        context.showErrorSnackBar(l10n.communityDownloadFailed(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final skin = widget.skin;

    return Scaffold(
      appBar: AppBar(title: Text(skin.name), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Thumbnail
                if (skin.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        skin.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.palette,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.palette,
                        size: 48,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Author + download count
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      skin.authorDisplayName,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.download_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.communityDownloadCount(skin.downloadCount),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (skin.description.isNotEmpty)
                  Text(
                    skin.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                if (skin.description.isNotEmpty) const SizedBox(height: 24),

                // Tags
                if (skin.tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: skin.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                if (skin.tags.isNotEmpty) const SizedBox(height: 24),

                // Color preview (if skin data available)
                if (skin.skin != null) ...[
                  Text(
                    l10n.communityColorPreview,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildColorPreview(skin.skin!.colors, colorScheme, l10n),
                ],
              ],
            ),
          ),

          // Download button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isDownloading || _downloaded || skin.skin == null ? null : _download,
                  icon: _downloaded ? const Icon(Icons.check) : const Icon(Icons.download),
                  label: _isDownloading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _downloaded ? l10n.communitySavedButton : l10n.communityDownloadThemeButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a grid of color swatches from the skin's color configuration.
  Widget _buildColorPreview(
    dynamic colors,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    // SkinColors has a toJson() that produces a map of color strings.
    // We'll show a simple grid of the raw color values if available.
    try {
      final colorMap = colors.toJson() as Map<String, dynamic>;
      final entries = colorMap.entries
          .where((e) => e.value is String && (e.value as String).isNotEmpty)
          .take(8)
          .toList();

      if (entries.isEmpty) {
        return Text(
          l10n.communityNoColorData,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: entries.map((entry) {
          Color? color;
          try {
            final hex = (entry.value as String).replaceFirst('#', '');
            color = Color(int.parse('FF$hex', radix: 16));
          } catch (_) {
            color = null;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color ?? colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }).toList(),
      );
    } catch (_) {
      return Text(
        l10n.communityColorPreviewUnavailable,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      );
    }
  }
}
