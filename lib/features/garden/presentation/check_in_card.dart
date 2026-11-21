import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/time/local_date.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import 'garden_providers.dart';

/// The five moods, rough to great.
const moodFaces = ['😣', '😕', '😐', '🙂', '😄'];

String moodWord(AppLocalizations l10n, int mood) => switch (mood) {
  1 => l10n.mood1,
  2 => l10n.mood2,
  3 => l10n.mood3,
  4 => l10n.mood4,
  _ => l10n.mood5,
};

/// Each mood's color in the year in pixels.
Color moodColor(int mood) => switch (mood) {
  1 => const Color(0xFFE5737A),
  2 => const Color(0xFFF0A86E),
  3 => const Color(0xFFF2D06B),
  4 => const Color(0xFF8BCF7A),
  _ => const Color(0xFF4FB3A9),
};

/// The evening check-in on [date]: how it felt (five faces) and one line.
/// A few seconds; it fills the year in pixels and closes the day kindly.
/// Once saved, one line with **Change**.
class CheckInCard extends ConsumerStatefulWidget {
  const CheckInCard({super.key, required this.date});

  final LocalDate date;

  @override
  ConsumerState<CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends ConsumerState<CheckInCard> {
  final _line = TextEditingController();
  int? _mood;
  bool _editing = false;

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mood = _mood;
    if (mood == null) return;
    unawaited(HapticFeedback.mediumImpact());
    await saveCheckIn(
      ref,
      widget.date,
      DayCheckIn(mood: mood, line: _line.text),
    );
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).checkInSaved)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final saved = ref.watch(checkInsProvider).value?[widget.date];
    if (saved != null && !_editing) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: AppCard(
          child: Row(
            children: [
              Text(
                moodFaces[saved.mood - 1],
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.checkInDone(moodWord(l10n, saved.mood)),
                      style: context.textStyles.titleSmall,
                    ),
                    if (saved.line.isNotEmpty)
                      Text(
                        saved.line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _editing = true;
                  _mood = saved.mood;
                  _line.text = saved.line;
                }),
                child: Text(l10n.checkInEdit),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.checkInTitle, style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var m = 1; m <= 5; m++)
                  Semantics(
                    button: true,
                    selected: _mood == m,
                    label: moodWord(l10n, m),
                    child: InkWell(
                      borderRadius: AppRadius.lgAll,
                      onTap: () {
                        unawaited(HapticFeedback.selectionClick());
                        setState(() => _mood = m);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _mood == m
                              ? moodColor(m).withValues(alpha: 0.3)
                              : Colors.transparent,
                          borderRadius: AppRadius.lgAll,
                        ),
                        child: AnimatedScale(
                          scale: _mood == m ? 1.2 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Text(
                            moodFaces[m - 1],
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_mood != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _line,
                maxLength: 140,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.checkInHint,
                  counterText: '',
                ),
                onSubmitted: (_) => unawaited(_save()),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => unawaited(_save()),
                  child: Text(l10n.checkInSave),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
