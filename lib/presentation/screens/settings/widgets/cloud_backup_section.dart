import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/providers/auth_providers.dart';
import '../../../../domain/providers/cloud_backup_providers.dart';
import '../../../../domain/providers/sync_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/auth/email_link_prompt.dart';

/// "Cloud backup" section of the Sync screen: enable toggle, account state,
/// last-backup info, and back-up / restore / delete actions.
class CloudBackupSection extends ConsumerWidget {
  const CloudBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(cloudBackupSettingsProvider);
    final status = ref.watch(cloudBackupControllerProvider);
    final canUpload = ref.watch(canUploadProvider);
    final isRunning = status.state == CloudBackupRunState.running;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.cloudBackupSectionTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.cloudBackupSectionSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.cloudBackupEnableTitle),
          subtitle: settings.enabled ? Text(l10n.cloudBackupDisabledNote) : null,
          value: settings.enabled,
          onChanged: (value) => _onToggle(context, ref, value),
        ),
        if (settings.enabled) ...[
          _AccountRow(canUpload: canUpload),
          _LastBackupRow(localLastBackupAt: settings.lastBackupAt),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: canUpload && !isRunning ? () => _backupNow(context, ref) : null,
            icon: isRunning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(isRunning ? l10n.cloudBackupInProgress : l10n.cloudBackupNowButton),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: canUpload && !isRunning ? () => _restore(context, ref) : null,
            icon: const Icon(Icons.cloud_download_outlined),
            label: Text(l10n.cloudBackupRestoreButton),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
          if (canUpload) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: isRunning ? null : () => _deleteBackup(context, ref),
              child: Text(l10n.cloudBackupDeleteButton),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _onToggle(BuildContext context, WidgetRef ref, bool value) async {
    await ref.read(cloudBackupSettingsProvider.notifier).setEnabled(value);
    if (!value || !context.mounted) return;

    // Turning on: make sure there's a verified email behind the backup.
    // Cancelling keeps the toggle on — the section shows a pending state
    // with a "Finish sign-in" affordance.
    if (!ref.read(canUploadProvider)) {
      final verified = await showEmailLinkPrompt(context);
      if (verified == true) ref.invalidate(cloudBackupMetadataProvider);
    }
  }

  Future<void> _backupNow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Backing up an empty database over a non-empty cloud backup would
    // destroy the only copy — require explicit confirmation (this is the
    // fresh-device-before-restore trap).
    final stats = await ref.read(dataBackupServiceProvider).getStats();
    if (stats.total == 0) {
      final existing = await ref.read(cloudBackupServiceProvider).fetchMetadata();
      final cloudHasData = existing != null && existing.stats.values.any((count) => count > 0);
      if (cloudHasData) {
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.cloudBackupOverwriteEmptyTitle),
            content: Text(l10n.cloudBackupOverwriteEmptyMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.cloudBackupNowButton),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
    }

    if (!context.mounted) return;
    final result = await ref.read(cloudBackupControllerProvider.notifier).backupNow();
    if (!context.mounted) return;
    if (result.success) {
      context.showSuccessSnackBar(l10n.cloudBackupSuccess);
    } else {
      context.showErrorSnackBar(l10n.cloudBackupError(result.error ?? ''));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloudBackupRestoreConfirmTitle),
        content: Text(l10n.cloudBackupRestoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cloudBackupRestoreButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(cloudBackupControllerProvider.notifier).restore();
    if (!context.mounted) return;
    if (result.notFound) {
      context.showSnackBar(l10n.cloudBackupNoBackupFound);
    } else if (result.success) {
      context.showSuccessSnackBar(
        l10n.cloudBackupRestoreSuccess(result.importResult?.totalImported ?? 0),
      );
    } else {
      context.showErrorSnackBar(l10n.cloudBackupRestoreError(result.error ?? ''));
    }
  }

  Future<void> _deleteBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloudBackupDeleteConfirmTitle),
        content: Text(l10n.cloudBackupDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.cloudBackupDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(cloudBackupServiceProvider).deleteBackup();
      ref.invalidate(cloudBackupMetadataProvider);
      if (context.mounted) context.showSnackBar(l10n.cloudBackupDeleted);
    } catch (e) {
      if (context.mounted) context.showErrorSnackBar(l10n.cloudBackupError(e.toString()));
    }
  }
}

/// Shows the signed-in account, or a pending-sign-in state with a
/// "Finish sign-in" action when there's no verified email yet.
class _AccountRow extends ConsumerWidget {
  const _AccountRow({required this.canUpload});

  final bool canUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (canUpload) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
        title: Text(l10n.cloudBackupAccountLabel),
        subtitle: Text(user?.email ?? ''),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.warning_amber_outlined, color: Theme.of(context).colorScheme.error),
      title: Text(l10n.cloudBackupPendingSignIn),
      trailing: TextButton(
        onPressed: () async {
          final verified = await showEmailLinkPrompt(context);
          if (verified == true) ref.invalidate(cloudBackupMetadataProvider);
        },
        child: Text(l10n.cloudBackupFinishSignIn),
      ),
    );
  }
}

/// Shows when the latest cloud backup was made, preferring the cloud
/// metadata and falling back to the locally recorded timestamp.
class _LastBackupRow extends ConsumerWidget {
  const _LastBackupRow({required this.localLastBackupAt});

  final DateTime? localLastBackupAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final metadata = ref.watch(cloudBackupMetadataProvider).value;

    final lastBackupAt = metadata?.updatedAt ?? localLastBackupAt;
    final subtitle = lastBackupAt == null ? l10n.cloudBackupNever : DateFormat.yMMMd().add_jm().format(lastBackupAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text(l10n.cloudBackupLastBackupLabel),
      subtitle: Text(metadata?.deviceName == null ? subtitle : '$subtitle — ${metadata!.deviceName}'),
    );
  }
}
