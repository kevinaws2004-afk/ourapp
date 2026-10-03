import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/app_icons.dart';
import '../../core/design/context_ext.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../errors/error_copy.dart';
import 'app_button.dart';

/// Renders an [AsyncValue] with the shared loading/error states
/// (ui_guidelines.md §5).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncValue(:final value?, hasValue: true) => data(value),
    AsyncValue(:final error?) => AppErrorState(error: error, onRetry: onRetry),
    _ => const DelayedLoadingPlaceholder(),
  };
}

/// Local reads are fast: show nothing for ~150 ms, then quiet skeleton bars.
class DelayedLoadingPlaceholder extends StatefulWidget {
  const DelayedLoadingPlaceholder({super.key});

  @override
  State<DelayedLoadingPlaceholder> createState() =>
      _DelayedLoadingPlaceholderState();
}

class _DelayedLoadingPlaceholderState extends State<DelayedLoadingPlaceholder> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppMotion.fast, () => setState(() => _visible = true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: AppMotion.standard,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                height: AppSpacing.huge,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSunken,
                  borderRadius: AppRadius.mdAll,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Calm, actionable error state; never shows raw errors.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppEmptyState(
      icon: AppIcons.error,
      title: l10n.loadErrorMessage,
      message: errorMessage(l10n, error),
      action: onRetry == null
          ? null
          : AppButton(
              label: l10n.actionTryAgain,
              variant: AppButtonVariant.secondary,
              onPressed: onRetry,
            ),
    );
  }
}

/// Explains what will appear and offers the next step (ui_guidelines.md §5).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.action,
    this.secondaryAction,
  });

  final IconData? icon;
  final String title;
  final String message;
  final Widget? action;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSpacing.xxxl,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(title, style: context.textStyles.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: context.textStyles.bodyLarge?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            action!,
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}

/// Reversible actions act immediately and offer Undo (ui_guidelines.md §7.2).
void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: l10n.actionUndo, onPressed: onUndo),
      ),
    );
}

void showMessageSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
