import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/sizes.dart';
import '../../l10n/generated/app_localizations.dart';

/// The check at the start of every day row (A17): ✓ when done, an open
/// circle otherwise. Tapping toggles done when [onPressed] is set; without
/// it, it only shows the state.
class DoneCheck extends StatelessWidget {
  const DoneCheck({
    super.key,
    required this.done,
    required this.color,
    this.onPressed,
  });

  final bool done;

  /// The open circle's color (the activity color).
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icon = Icon(
      done ? AppIcons.taskDone : AppIcons.taskOpen,
      color: done ? context.colors.success : color,
    );
    if (onPressed == null) {
      return SizedBox.square(
        dimension: AppSizes.touchTarget,
        child: Semantics(
          label: done ? l10n.planStatusDone : null,
          child: Center(child: icon),
        ),
      );
    }
    return IconButton(
      tooltip: done ? l10n.planReopenTask : l10n.planCompleteTask,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
