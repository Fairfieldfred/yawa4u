import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../domain/providers/auth_providers.dart';
import '../../../domain/providers/community_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/auth/email_link_prompt.dart';
import 'community_skin_detail_screen.dart';
import '../../widgets/skeleton_loader.dart';
import 'community_template_detail_screen.dart';

/// Tabbed browse screen for the community library.
///
/// Two tabs: Templates and Themes (skins). Each has sort controls and
/// navigates to a detail screen on tap.
class CommunityBrowseScreen extends ConsumerStatefulWidget {
  /// Which tab to open initially (0 = Templates, 1 = Themes).
  final int initialTab;

  const CommunityBrowseScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<CommunityBrowseScreen> createState() => _CommunityBrowseScreenState();
}

class _CommunityBrowseScreenState extends ConsumerState<CommunityBrowseScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canUpload = ref.watch(canUploadProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityLibraryTitle),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.communityTabPrograms),
            Tab(text: l10n.communityTabThemes),
            Tab(text: l10n.communityTabMyUploads),
          ],
        ),
        actions: [
          // Always visible so uploading is discoverable — unverified users
          // get the email link prompt instead of a hidden button.
          PopupMenuButton<String>(
            icon: const Icon(Icons.upload_outlined),
            tooltip: l10n.communityUploadTooltip,
            onSelected: (value) async {
              if (!canUpload) {
                final verified = await showEmailLinkPrompt(context);
                if (verified != true || !context.mounted) return;
              }
              if (!context.mounted) return;
              switch (value) {
                case 'template':
                  context.push('/community/upload-template');
                case 'skin':
                  context.push('/community/upload-skin');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'template',
                child: ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(l10n.communityShareProgram),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PopupMenuItem(
                value: 'skin',
                child: ListTile(
                  leading: const Icon(Icons.palette),
                  title: Text(l10n.communityShareTheme),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TemplatesTab(colorScheme: colorScheme),
          _SkinsTab(colorScheme: colorScheme),
          _MyUploadsTab(colorScheme: colorScheme),
        ],
      ),
    );
  }
}

// ── Templates tab ────────────────────────────────────────────────────────

class _TemplatesTab extends ConsumerWidget {
  const _TemplatesTab({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(communityTemplatesProvider);
    final sort = ref.watch(communityTemplateSortProvider);

    return Column(
      children: [
        // Sort controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(l10n.communitySortBy),
              const SizedBox(width: 8),
              SegmentedButton<CommunitySortOrder>(
                segments: [
                  ButtonSegment(
                    value: CommunitySortOrder.popular,
                    label: Text(l10n.communitySortPopular),
                    icon: const Icon(Icons.trending_up, size: 16),
                  ),
                  ButtonSegment(
                    value: CommunitySortOrder.recent,
                    label: Text(l10n.communitySortRecent),
                    icon: const Icon(Icons.schedule, size: 16),
                  ),
                ],
                selected: {sort},
                onSelectionChanged: (selection) {
                  ref.read(communityTemplateSortProvider.notifier).set(selection.first);
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),

        // Template list
        Expanded(
          child: templatesAsync.when(
            data: (page) {
              if (page.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.communityNoProgramsTitle,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.communityNoProgramsSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: page.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = page.items[index];
                  return _CommunityTemplateCard(
                    template: item,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommunityTemplateDetailScreen(
                          template: item,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SkeletonCardList(itemCount: 3),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: context.errorColor),
                  const SizedBox(height: 12),
                  Text(
                    l10n.communityCouldNotLoadPrograms,
                    style: TextStyle(color: context.errorColor),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(communityTemplatesProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Skins tab ────────────────────────────────────────────────────────────

class _SkinsTab extends ConsumerWidget {
  const _SkinsTab({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final skinsAsync = ref.watch(communitySkinsProvider);
    final sort = ref.watch(communitySkinSortProvider);

    return Column(
      children: [
        // Sort controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(l10n.communitySortBy),
              const SizedBox(width: 8),
              SegmentedButton<CommunitySortOrder>(
                segments: [
                  ButtonSegment(
                    value: CommunitySortOrder.popular,
                    label: Text(l10n.communitySortPopular),
                    icon: const Icon(Icons.trending_up, size: 16),
                  ),
                  ButtonSegment(
                    value: CommunitySortOrder.recent,
                    label: Text(l10n.communitySortRecent),
                    icon: const Icon(Icons.schedule, size: 16),
                  ),
                ],
                selected: {sort},
                onSelectionChanged: (selection) {
                  ref.read(communitySkinSortProvider.notifier).set(selection.first);
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),

        // Skin list
        Expanded(
          child: skinsAsync.when(
            data: (page) {
              if (page.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.communityNoThemesTitle,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.communityNoThemesSubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: page.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = page.items[index];
                  return _CommunitySkinCard(
                    skin: item,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommunitySkinDetailScreen(
                          skin: item,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const SkeletonCardList(itemCount: 3),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: context.errorColor),
                  const SizedBox(height: 12),
                  Text(
                    l10n.communityCouldNotLoadThemes,
                    style: TextStyle(color: context.errorColor),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(communitySkinsProvider),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── My Uploads tab ──────────────────────────────────────────────────────

class _MyUploadsTab extends ConsumerWidget {
  const _MyUploadsTab({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.communitySignInToSeeUploads,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => showEmailLinkPrompt(context),
              icon: const Icon(Icons.login),
              label: Text(l10n.communitySignInButton),
            ),
          ],
        ),
      );
    }

    final templatesAsync = ref.watch(myUploadedTemplatesProvider);
    final skinsAsync = ref.watch(myUploadedSkinsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Templates section
        Text(
          l10n.communityMyPrograms,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        templatesAsync.when(
          data: (templates) {
            if (templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.communityNoProgramsUploaded,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return Column(
              children: templates.map((item) {
                return _MyUploadTemplateCard(
                  template: item,
                  onDelete: () => _confirmDeleteTemplate(context, ref, item),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(
            l10n.communityFailedToLoadPrograms,
            style: TextStyle(color: context.errorColor),
          ),
        ),

        const SizedBox(height: 24),

        // Skins section
        Text(
          l10n.communityMyThemes,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        skinsAsync.when(
          data: (skins) {
            if (skins.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.communityNoThemesUploaded,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return Column(
              children: skins.map((item) {
                return _MyUploadSkinCard(
                  skin: item,
                  onDelete: () => _confirmDeleteSkin(context, ref, item),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Text(
            l10n.communityFailedToLoadThemes,
            style: TextStyle(color: context.errorColor),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteTemplate(
    BuildContext context,
    WidgetRef ref,
    CommunityTemplate item,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.communityDeleteProgramTitle),
        content: Text(
          l10n.communityDeleteProgramContent(item.template.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelUpper),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteUpper),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(communityRepositoryProvider);
        await repo.deleteTemplate(item.firestoreId);
        ref.invalidate(myUploadedTemplatesProvider);
        ref.invalidate(communityTemplatesProvider);
        if (context.mounted) {
          context.showSuccessSnackBar(l10n.communityItemDeleted(item.template.name));
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar(l10n.communityFailedToDelete(e));
        }
      }
    }
  }

  Future<void> _confirmDeleteSkin(
    BuildContext context,
    WidgetRef ref,
    CommunitySkin item,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.communityDeleteThemeTitle),
        content: Text(
          l10n.communityDeleteThemeContent(item.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelUpper),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteUpper),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(communityRepositoryProvider);
        await repo.deleteSkin(item.firestoreId);
        ref.invalidate(myUploadedSkinsProvider);
        ref.invalidate(communitySkinsProvider);
        if (context.mounted) {
          context.showSuccessSnackBar(l10n.communityItemDeleted(item.name));
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorSnackBar(l10n.communityFailedToDelete(e));
        }
      }
    }
  }
}

class _MyUploadTemplateCard extends StatelessWidget {
  const _MyUploadTemplateCard({
    required this.template,
    required this.onDelete,
  });

  final CommunityTemplate template;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final t = template.template;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.communityDownloadCount(template.downloadCount),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.errorColor),
              onPressed: onDelete,
              tooltip: l10n.communityDeleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyUploadSkinCard extends StatelessWidget {
  const _MyUploadSkinCard({
    required this.skin,
    required this.onDelete,
  });

  final CommunitySkin skin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail or placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.palette, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skin.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.communityDownloadCount(skin.downloadCount),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.errorColor),
              onPressed: onDelete,
              tooltip: l10n.communityDeleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card widgets ─────────────────────────────────────────────────────────

class _CommunityTemplateCard extends StatelessWidget {
  const _CommunityTemplateCard({
    required this.template,
    required this.onTap,
  });

  final CommunityTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final t = template.template;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _DownloadCountChip(count: template.downloadCount),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template.authorDisplayName,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.communityPeriodsCount(t.periodsTotal),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.communitySessionsCount(t.workouts.length),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (template.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: template.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunitySkinCard extends StatelessWidget {
  const _CommunitySkinCard({
    required this.skin,
    required this.onTap,
  });

  final CommunitySkin skin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail or placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: skin.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          skin.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.palette,
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(Icons.palette, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skin.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (skin.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        skin.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          skin.authorDisplayName,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _DownloadCountChip(count: skin.downloadCount),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chip showing the download count with an icon.
class _DownloadCountChip extends StatelessWidget {
  const _DownloadCountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_outlined,
            size: 14,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
