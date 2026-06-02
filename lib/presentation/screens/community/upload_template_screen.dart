import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../data/models/training_cycle_template.dart';
import '../../../domain/providers/auth_providers.dart';
import '../../../domain/providers/community_providers.dart';
import '../../../domain/providers/template_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/auth/email_link_prompt.dart';
import '../../widgets/skeleton_loader.dart';

/// Screen for selecting a local template and publishing it to the
/// community library.
class UploadTemplateScreen extends ConsumerStatefulWidget {
  /// Optional template ID to pre-select when opening the screen.
  final String? preSelectedTemplateId;

  const UploadTemplateScreen({super.key, this.preSelectedTemplateId});

  @override
  ConsumerState<UploadTemplateScreen> createState() => _UploadTemplateScreenState();
}

class _UploadTemplateScreenState extends ConsumerState<UploadTemplateScreen> {
  TrainingCycleTemplate? _selectedTemplate;
  final _displayNameController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill display name from Firebase user displayName if available.
    final user = ref.read(currentUserProvider);
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _displayNameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_selectedTemplate == null) return;
    final l10n = AppLocalizations.of(context)!;

    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.uploadEnterDisplayName)),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.uploadNotSignedIn),
              backgroundColor: context.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final repo = ref.read(communityRepositoryProvider);

      final tags = _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      await repo.publishTemplate(
        template: _selectedTemplate!,
        authorUid: user.uid,
        authorDisplayName: displayName,
        tags: tags,
      );

      if (mounted) {
        // Refresh community list.
        ref.invalidate(communityTemplatesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.uploadPublishedToCommunity(_selectedTemplate!.name),
            ),
            backgroundColor: context.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.uploadFailed(e)),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final templatesAsync = ref.watch(availableTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.uploadShareProgramTitle), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.uploadSelectProgramDesc,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Template picker
                Text(
                  l10n.uploadProgramLabel,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                templatesAsync.when(
                  data: (templates) {
                    // Pre-select template from route param (once).
                    if (_selectedTemplate == null && widget.preSelectedTemplateId != null) {
                      final match = templates.where(
                        (t) => t.id == widget.preSelectedTemplateId,
                      );
                      if (match.isNotEmpty) {
                        // Schedule after build to avoid setState during build.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedTemplate = match.first);
                          }
                        });
                      }
                    }
                    if (templates.isEmpty) {
                      return Text(
                        l10n.uploadNoSavedPrograms,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: templates.map((t) {
                        final selected = _selectedTemplate?.id == t.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedTemplate = t),
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
                                          t.name,
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.uploadTemplateSummary(
                                            t.periodsTotal,
                                            t.daysPerPeriod,
                                            t.workouts.length,
                                          ),
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const SkeletonCardList(itemCount: 2),
                  error: (e, _) => Text(l10n.uploadErrorLoadingTemplates(e)),
                ),
                const SizedBox(height: 24),

                // Display name
                Text(
                  l10n.uploadDisplayNameLabel,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    hintText: l10n.uploadTemplateTagsHint,
                    helperText: l10n.uploadTemplateTagsHelper,
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
                  onPressed: _isUploading || _selectedTemplate == null ? null : _publish,
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
                          l10n.uploadPublishProgramButton,
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
}
