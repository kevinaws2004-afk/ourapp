import 'package:flutter/material.dart';

import '../../../core/design/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';

enum StartChoice { focus, record }

/// For a timer-capable activity (F5 step 2): time it with a focus session,
/// or record it right away.
Future<StartChoice?> showStartChoice(BuildContext context, String title) =>
    showModalBottomSheet<StartChoice>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(AppIcons.timer),
                title: Text(l10n.focusStart),
                subtitle: Text(l10n.focusStartHint),
                onTap: () => Navigator.of(context).pop(StartChoice.focus),
              ),
              ListTile(
                leading: const Icon(AppIcons.edit),
                title: Text(l10n.recordNow),
                subtitle: Text(l10n.recordNowHint),
                onTap: () => Navigator.of(context).pop(StartChoice.record),
              ),
            ],
          ),
        );
      },
    );
