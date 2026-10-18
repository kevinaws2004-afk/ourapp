import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/time/clock_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/auto_backup.dart';
import '../data/data_export.dart';
import '../data/data_restore.dart';
import 'backup_providers.dart';
import 'csv_export.dart';

/// Me → Backup & restore (spec §40): save a full backup anywhere, export
/// spreadsheets, restore from a file, and the daily automatic backups kept
/// on the phone (each can be restored or saved elsewhere). Restoring
/// replaces everything, so it asks first and keeps a copy of what was
/// there.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  Future<void> _guard(Future<void> Function() action) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    await DataExport(ref.read(appDatabaseProvider))
        .share(ref.read(clockProvider).nowUtc(), subject: l10n.meExportSubject);
  });

  Future<void> _csv() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    final count = await shareCsvExport(context, ref);
    if (count == 0 && mounted) showMessageSnackBar(context, l10n.csvNothing);
  });

  Future<void> _restoreFromFile() => _guard(() async {
    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || !mounted) return;
    await _restore(await picked.first.xFile.readAsString());
  });

  Future<void> _restoreSnapshot(BackupSnapshot snapshot) =>
      _guard(() async => _restore(await snapshot.file.readAsString()));

  /// Checks [source], shows what's in it, and replaces everything once
  /// confirmed, keeping a copy of what was there first.
  Future<void> _restore(String source) async {
    final l10n = AppLocalizations.of(context);
    final restore = ref.read(dataRestoreProvider);
    final BackupContents contents;
    try {
      contents = restore.parse(source);
    } on RestoreException catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context,
          e.problem == RestoreProblem.newerVersion
              ? l10n.restoreNewerVersion
              : l10n.restoreNotABackup,
        );
      }
      return;
    }
    if (!mounted) return;
    final material = MaterialLocalizations.of(context);
    final made = contents.exportedAt?.toLocal();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(
          [
            if (made != null)
              l10n.restoreFrom(
                '${material.formatMediumDate(made)} '
                '${material.formatTimeOfDay(TimeOfDay.fromDateTime(made))}',
              ),
            l10n.restoreContents(
              contents.activities,
              contents.records,
              contents.plans,
              contents.goals,
              contents.notes,
            ),
            l10n.restoreReplaceWarning,
          ].join('\n\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restoreAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final now = ref.read(clockProvider).nowUtc();
    await ref.read(autoBackupProvider).snapshotBeforeRestore(now);
    await restore.restore(contents);
    ref.invalidate(backupSnapshotsProvider);
    if (mounted) showMessageSnackBar(context, l10n.restoreDone);
  }

  Future<void> _backupNow() => _guard(() async {
    final l10n = AppLocalizations.of(context);
    final backup = ref.read(autoBackupProvider);
    await backup.backupNow(ref.read(clockProvider).nowUtc());
    ref.invalidate(backupSnapshotsProvider);
    if (mounted) showMessageSnackBar(context, l10n.backupMade);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final enabled = ref.watch(autoBackupEnabledProvider).value ?? true;
    final snapshots = ref.watch(backupSnapshotsProvider).value ?? const [];
    final material = MaterialLocalizations.of(context);
    String when(DateTime utc) {
      final local = utc.toLocal();
      return '${material.formatMediumDate(local)} · '
          '${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
    }

    return Scaffold(
      appBar: AppBar(
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.reading),
          child: ListView(
            padding: EdgeInsets.fromLTRB(margin, 0, margin, AppSpacing.xxxl),
            children: [
              ScreenHeader(
                showMark: false,
                title: l10n.backupTitle,
                subtitle: l10n.backupSubtitle,
              ),
              SettingsGroup(
                title: l10n.backupGroupSave,
                children: [
                  SettingsTile(
                    icon: AppIcons.export,
                    iconColor: c.action,
                    iconBackground: c.actionSoft,
                    title: l10n.meExport,
                    subtitle: l10n.meExportSubtitle,
                    onTap: _busy ? null : () => unawaited(_export()),
                  ),
                  SettingsTile(
                    icon: AppIcons.spreadsheet,
                    iconColor: c.success,
                    iconBackground: c.successContainer,
                    title: l10n.csvTitle,
                    subtitle: l10n.csvSubtitle,
                    onTap: _busy ? null : () => unawaited(_csv()),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.backupGroupRestore,
                children: [
                  SettingsTile(
                    icon: AppIcons.importFile,
                    iconColor: c.accent,
                    iconBackground: c.accentSoft,
                    title: l10n.restoreFromFile,
                    subtitle: l10n.restoreFromFileSubtitle,
                    onTap: _busy ? null : () => unawaited(_restoreFromFile()),
                  ),
                ],
              ),
              SettingsGroup(
                title: l10n.backupGroupAuto,
                children: [
                  SettingsTile(
                    icon: AppIcons.backup,
                    title: l10n.backupDaily,
                    subtitle: l10n.backupDailySubtitle(AutoBackup.keep),
                    trailing: Switch(
                      value: enabled,
                      onChanged: (v) => unawaited(
                        ref.read(autoBackupProvider).setEnabled(enabled: v),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: AppIcons.sync,
                    title: l10n.backupNow,
                    onTap: _busy ? null : () => unawaited(_backupNow()),
                  ),
                  for (final s in snapshots)
                    SettingsTile(
                      icon: s.beforeRestore ? AppIcons.restore : AppIcons.date,
                      iconColor: c.textSecondary,
                      iconBackground: c.surfaceSunken,
                      title: when(s.madeAt),
                      subtitle: s.beforeRestore
                          ? l10n.backupBeforeRestore
                          : l10n.backupAutomatic,
                      // Restoring asks first, so a tap can start it.
                      onTap: _busy
                          ? null
                          : () => unawaited(_restoreSnapshot(s)),
                      trailing: PopupMenuButton<bool>(
                        tooltip: l10n.backupOptions,
                        icon: const Icon(AppIcons.more),
                        onSelected: (restore) => restore
                            ? unawaited(_restoreSnapshot(s))
                            : unawaited(
                                SharePlus.instance.share(
                                  ShareParams(
                                    files: [
                                      XFile(
                                        s.file.path,
                                        mimeType: 'application/json',
                                      ),
                                    ],
                                    subject: l10n.meExportSubject,
                                  ),
                                ),
                              ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: true,
                            child: Text(l10n.restoreAction),
                          ),
                          PopupMenuItem(
                            value: false,
                            child: Text(l10n.backupSaveCopy),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  l10n.backupDeviceNote,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
