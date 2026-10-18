import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/logging/logger_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'me_screen.dart';

/// Where feedback goes. Set it before release; while empty, feedback opens
/// the share sheet so the person picks an app and an address.
const supportEmail = '';

/// Me → Send feedback: write to the developer (with the app and phone
/// versions filled in), or share the on-phone diagnostics report after a
/// problem. Nothing is sent without the person choosing to.
Future<void> showFeedbackSheet(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final log = ref.read(diagnosticsLogProvider);
  final version = ref.read(appVersionProvider).value ?? '';
  final device =
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  final header = '${l10n.appTitle} $version · $device';
  final messenger = ScaffoldMessenger.of(context);
  void failed(Object _) =>
      messenger.showSnackBar(SnackBar(content: Text(l10n.feedbackFailed)));

  Future<void> write(BuildContext sheet) async {
    Navigator.of(sheet).pop();
    final body = '\n\n—\n$header';
    if (supportEmail.isNotEmpty) {
      final uri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        query: _query({'subject': l10n.feedbackSubject, 'body': body}),
      );
      if (await launchUrl(uri)) return;
    }
    await SharePlus.instance.share(
      ShareParams(text: body, subject: l10n.feedbackSubject),
    );
  }

  Future<void> report(BuildContext sheet) async {
    Navigator.of(sheet).pop();
    if (log == null) return;
    final file = await log.report(header: header);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        subject: l10n.feedbackDiagnosticsSubject,
      ),
    );
  }

  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    useSafeArea: true,
    builder: (sheet) {
      final c = sheet.colors;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xs,
              ),
              child: Text(
                l10n.meFeedback,
                style: sheet.textStyles.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.feedbackIntro,
                style: sheet.textStyles.bodyMedium?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            ListTile(
              leading: Icon(AppIcons.feedback, color: c.brandPrimary),
              title: Text(l10n.feedbackWrite),
              subtitle: Text(l10n.feedbackWriteSubtitle),
              onTap: () => unawaited(write(sheet).catchError(failed)),
            ),
            ListTile(
              enabled: log != null,
              leading: Icon(AppIcons.diagnostics, color: c.textSecondary),
              title: Text(l10n.feedbackDiagnostics),
              subtitle: Text(
                (log?.length ?? 0) == 0
                    ? l10n.feedbackDiagnosticsNone
                    : l10n.feedbackDiagnosticsCount(log!.length),
              ),
              onTap: () => unawaited(report(sheet).catchError(failed)),
            ),
          ],
        ),
      );
    },
  );
}

String _query(Map<String, String> params) => params.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .join('&');
