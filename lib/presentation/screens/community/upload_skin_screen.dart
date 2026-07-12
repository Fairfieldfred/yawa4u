import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../data/services/theme_image_service.dart';
import '../../../domain/providers/auth_providers.dart';
import '../../../domain/providers/community_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/auth/email_link_prompt.dart';

/// Screen for selecting a local custom skin and publishing it to the
/// community library, including uploading background images to Firebase
/// Storage.
class UploadSkinScreen extends ConsumerStatefulWidget {
  /// Optional skin ID to pre-select when opening the screen.
  final String? preSelectedSkinId;

  const UploadSkinScreen({super.key, this.preSelectedSkinId});

  @override
  ConsumerState<UploadSkinScreen> createState() => _UploadSkinScreenState();
}

class _UploadSkinScreenState extends ConsumerState<UploadSkinScreen> {
  SkinModel? _selectedSkin;
  final _displayNameController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _displayNameController.text = user.displayName!;
    }

    // Pre-select skin if an ID was passed via route query param.
    if (widget.preSelectedSkinId != null) {
      final skinRepo = ref.read(skinRepositoryProvider);
      final customSkins = skinRepo.getCustomSkins();
      final match = customSkins.where(
        (s) => s.id == widget.preSelectedSkinId,
      );
      if (match.isNotEmpty) {
        _selectedSkin = match.first;
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  /// Reads all background image files from the skin into a map of
  /// `imageType -> bytes` for upload.
  ///
  /// Skin backgrounds store **relative** paths (e.g. `themes/uuid/workout.jpg`)
  /// so we must resolve them to absolute paths via [ThemeImageService] before
  /// reading the actual files from disk.
  Future<Map<String, Uint8List>> _collectImages(SkinModel skin) async {
    final images = <String, Uint8List>{};
    final backgrounds = skin.backgrounds;
    if (backgrounds == null) {
      debugPrint('_collectImages: skin "${skin.name}" has no backgrounds');
      return images;
    }

    final imageService = ref.read(themeImageServiceProvider);

    final paths = <String, String?>{
      'workout': backgrounds.workout,
      'cycles': backgrounds.cycles,
      'exercises': backgrounds.exercises,
      'more': backgrounds.more,
      'default': backgrounds.defaultBackground,
      'app_icon': backgrounds.appIcon,
    };

    for (final entry in paths.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        try {
          // Resolve relative path to absolute using ThemeImageService.
          final resolvedPath = await imageService.resolveImagePath(
            entry.value!,
          );
          if (resolvedPath != null) {
            final file = File(resolvedPath);
            final bytes = await file.readAsBytes();
            images[entry.key] = bytes;
            debugPrint(
              '_collectImages: read ${entry.key} '
              '(${bytes.length} bytes) from $resolvedPath',
            );
          } else {
            debugPrint(
              '_collectImages: could not resolve path for ${entry.key}: '
              '${entry.value}',
            );
          }
        } catch (e) {
          debugPrint('_collectImages: error reading ${entry.key}: $e');
        }
      }
    }

    debugPrint('_collectImages: collected ${images.length} images');
    return images;
  }

  Future<void> _publish() async {
    if (_selectedSkin == null) return;
    final l10n = AppLocalizations.of(context)!;

    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      context.showSnackBar(l10n.uploadEnterDisplayName);
      return;
    }

    // Ensure the user is email-verified.
    final canUpload = ref.read(canUploadProvider);
    if (!canUpload) {
      final verified = await showEmailLinkPrompt(context);
      if (verified != true) return;
    }

    setState(() => _isUploading = true);

    try {
      final user = ref.read(firebaseAuthServiceProvider).currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _isUploading = false);
          context.showErrorSnackBar(l10n.uploadNotSignedIn);
        }
        return;
      }
      final repo = ref.read(communityRepositoryProvider);

      final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      final images = await _collectImages(_selectedSkin!);

      await repo.publishSkin(
        skin: _selectedSkin!,
        authorUid: user.uid,
        authorDisplayName: displayName,
        tags: tags,
        images: images,
      );

      if (mounted) {
        ref.invalidate(communitySkinsProvider);

        context.showSuccessSnackBar(l10n.uploadPublishedToCommunity(_selectedSkin!.name));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        context.showErrorSnackBar(l10n.uploadFailed(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final skinRepo = ref.watch(skinRepositoryProvider);
    final customSkins = skinRepo.getCustomSkins();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadShareThemeTitle), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.uploadSelectThemeDesc,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Skin picker
                Text(
                  l10n.uploadThemeLabel,
                  style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),

                if (customSkins.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 40,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.uploadNoCustomThemes,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.uploadCreateCustomThemeHint,
                          style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  ...customSkins.map((skin) {
                    final selected = _selectedSkin?.id == skin.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedSkin = skin),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selected
                                ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skin.name,
                                      style: context.textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
                                    ),
                                    if (skin.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        skin.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Display name
                Text(
                  l10n.uploadDisplayNameLabel,
                  style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: l10n.uploadDisplayNameHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 24),

                // Tags
                Text(
                  l10n.uploadTagsLabel,
                  style: context.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    hintText: l10n.uploadThemeTagsHint,
                    helperText: l10n.uploadThemeTagsHelper,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.tag),
                  ),
                ),
              ],
            ),
          ),

          // Publish button
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
                  onPressed: _isUploading || _selectedSkin == null ? null : _publish,
                  icon: const Icon(Icons.upload),
                  label: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.uploadPublishThemeButton,
                          style: context.textTheme.titleMedium,
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
}
