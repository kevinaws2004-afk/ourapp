import 'package:flutter/material.dart';

import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/time/local_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/plan.dart';
import '../activity_chooser.dart';
import 'plan_quick_add.dart';

/// The **+** sheet (ADR-046, AD1): adding to a day lives here, out of the
/// day's way. What, when, Recent, Browse activities and Make your own; it
/// closes once something is added. With [onStartNow] (today) it offers
/// **Start now**: the sheet closes and the new thing starts.
Future<void> showAddSheet(
  BuildContext context, {
  required LocalDate date,
  required String dayName,
  required ActivityChooser chooser,
  ValueChanged<PlanId>? onStartNow,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) {
    final l10n = AppLocalizations.of(sheetContext);
    void close() => Navigator.of(sheetContext).pop();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addSheetTitle(dayName),
              style: sheetContext.textStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            PlanQuickAdd(
              date: date,
              chooser: chooser,
              autofocus: true,
              onAdded: (_) => close(),
              onStartNow: onStartNow == null
                  ? null
                  : (id) {
                      close();
                      onStartNow(id);
                    },
            ),
          ],
        ),
      ),
    );
  },
);
