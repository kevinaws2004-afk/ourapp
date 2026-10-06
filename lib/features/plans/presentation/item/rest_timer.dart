import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/app_icons.dart';
import '../../../../core/design/context_ext.dart';
import '../../../../core/design/tokens/spacing.dart';
import '../../../../core/design/tokens/typography.dart';
import '../../../../core/time/clock_provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../focus/presentation/focus_providers.dart';
import '../../../focus/presentation/focus_screen.dart';

/// A running rest between rows (B5, ADR-041): when it ends and how long it
/// was set for. Kept in memory only; it isn't logged.
@immutable
class RestTimer {
  const RestTimer({required this.endsAt, required this.length});

  final DateTime endsAt;
  final Duration length;
}

final restTimerProvider = NotifierProvider<RestTimerNotifier, RestTimer?>(
  RestTimerNotifier.new,
);

class RestTimerNotifier extends Notifier<RestTimer?> {
  static const defaultLength = Duration(seconds: 90);
  static const step = Duration(seconds: 15);

  /// The last length used, so the next rest starts the same.
  Duration _length = defaultLength;

  @override
  RestTimer? build() => null;

  void start() => state = RestTimer(
    endsAt: ref.read(clockProvider).nowUtc().add(_length),
    length: _length,
  );

  /// Adds (or with a negative [delta], takes off) time; never below one step.
  void adjust(Duration delta) {
    final current = state;
    if (current == null) return;
    final length = current.length + delta;
    if (length < step) return;
    _length = length;
    state = RestTimer(endsAt: current.endsAt.add(delta), length: length);
  }

  void stop() => state = null;
}

/// The rest countdown at the bottom of an item (B5): time left in DM Mono,
/// −15 s / +15 s and Stop; "Rest over" with a light buzz when it ends.
class RestTimerBar extends ConsumerStatefulWidget {
  const RestTimerBar({super.key});

  @override
  ConsumerState<RestTimerBar> createState() => _RestTimerBarState();
}

class _RestTimerBarState extends ConsumerState<RestTimerBar> {
  DateTime? _buzzedFor;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(restTimerProvider);
    if (timer == null) return const SizedBox.shrink();
    ref.watch(focusTickProvider);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(restTimerProvider.notifier);
    final left = timer.endsAt.difference(ref.watch(clockProvider).nowUtc());
    final over = left <= Duration.zero;
    if (over && _buzzedFor != timer.endsAt) {
      _buzzedFor = timer.endsAt;
      unawaited(HapticFeedback.mediumImpact());
    }
    return SafeArea(
      top: false,
      child: Material(
        color: context.colors.brandPrimarySoft,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Icon(AppIcons.timer, color: context.colors.onBrandPrimarySoft),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Semantics(
                  liveRegion: over,
                  child: Text(
                    over
                        ? l10n.restOver
                        : l10n.restLeft(formatTimer(left.inMilliseconds)),
                    style: AppTypography.numericMedium.copyWith(
                      color: context.colors.onBrandPrimarySoft,
                    ),
                  ),
                ),
              ),
              if (!over) ...[
                TextButton(
                  onPressed: () => notifier.adjust(-RestTimerNotifier.step),
                  child: Text(l10n.restLess),
                ),
                TextButton(
                  onPressed: () => notifier.adjust(RestTimerNotifier.step),
                  child: Text(l10n.restMore),
                ),
              ],
              TextButton(
                onPressed: notifier.stop,
                child: Text(over ? l10n.actionDone : l10n.restStop),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
