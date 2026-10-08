import 'package:flutter/material.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/sizes.dart';
import '../../l10n/generated/app_localizations.dart';

/// The done check of every day item (A17, ADR-045): an open ring in the
/// activity's color, or a filled circle with ✓ once done. Tapping toggles
/// done when [onPressed] is set; without it, it only shows the state.
class DoneCheck extends StatelessWidget {
  const DoneCheck({
    super.key,
    required this.done,
    required this.color,
    this.onPressed,
  });

  final bool done;

  /// The open ring's color (the activity color).
  final Color color;
  final VoidCallback? onPressed;

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final mark = done
        ? Icon(AppIcons.taskDone, size: _size + 4, color: c.success)
        : Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
          );
    if (onPressed == null) {
      return SizedBox.square(
        dimension: AppSizes.touchTarget,
        child: Semantics(
          label: done ? l10n.planStatusDone : null,
          child: Center(child: mark),
        ),
      );
    }
    return IconButton(
      tooltip: done ? l10n.planReopenTask : l10n.planCompleteTask,
      icon: mark,
      onPressed: onPressed,
    );
  }
}
