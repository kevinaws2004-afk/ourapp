import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import 'words_providers.dart';
import 'words_reader.dart';

/// Today's words on Today: the first of them, tap to read them all full
/// screen. Nothing when none are saved.
class WordsCard extends ConsumerWidget {
  const WordsCard({super.key, required this.onOpenWords});

  /// Opens My words.
  final VoidCallback onOpenWords;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = ref.watch(todaysWordsProvider);
    if (words.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final first = words.first;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Semantics(
        button: true,
        hint: l10n.wordsCardHint,
        child: AppCard(
          color: c.brandPrimarySoft.withValues(alpha: 0.6),
          onTap: () => unawaited(showWordsReader(context, words)),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(AppIcons.quote, size: 18, color: c.brandPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      words.length > 1
                          ? l10n.wordsTodayCount(words.length)
                          : l10n.wordsTodayTitle,
                      style: context.textStyles.labelMedium?.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.wordsTitle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(AppIcons.edit, size: 18, color: c.textTertiary),
                    onPressed: onOpenWords,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      first.text.trim(),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    if (first.from.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '— ${first.from.trim()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
