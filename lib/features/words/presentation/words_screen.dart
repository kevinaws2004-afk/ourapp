import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/my_words.dart';
import 'words_providers.dart';
import 'words_reader.dart';

/// My words: lines from books, quotes, proverbs, or a paragraph of your
/// own, to read again each day. Every day ones always show; the rest take
/// turns. Whether they show as the app opens.
class WordsScreen extends ConsumerWidget {
  const WordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final words = ref.watch(myWordsProvider).value;
    final hasAny = words?.isNotEmpty ?? false;
    void add() => unawaited(showWordsEditor(context, ref));
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: hasAny
          ? FloatingActionButton.extended(
              heroTag: 'new-words',
              onPressed: add,
              icon: const Icon(AppIcons.add),
              label: Text(l10n.wordsAdd),
            )
          : null,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppContentWidth.list),
          child: ListView(
            padding: EdgeInsets.fromLTRB(margin, 0, margin, 120),
            children: [
              ScreenHeader(
                showMark: false,
                title: l10n.wordsTitle,
                subtitle: l10n.wordsSubtitle,
              ),
              if (words != null && !hasAny)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: EmptyStateCard(
                    icon: AppIcons.quote,
                    title: l10n.wordsEmptyTitle,
                    message: l10n.wordsEmptyMessage,
                    actions: [
                      AppButton(
                        label: l10n.wordsAdd,
                        icon: AppIcons.add,
                        onPressed: add,
                      ),
                    ],
                  ),
                ),
              if (hasAny) ...[
                SettingsGroup(
                  children: [
                    SettingsTile(
                      icon: AppIcons.lightMode,
                      iconColor: c.warning,
                      iconBackground: c.warningContainer,
                      title: l10n.wordsOnOpen,
                      subtitle: l10n.wordsOnOpenSubtitle,
                      trailing: Switch(
                        value: ref.watch(wordsOnOpenProvider).value ?? true,
                        onChanged: (v) => unawaited(setWordsOnOpen(ref, on: v)),
                      ),
                    ),
                    SettingsTile(
                      icon: AppIcons.bookOpen,
                      title: l10n.wordsReadToday,
                      subtitle: l10n.wordsReadTodaySubtitle,
                      onTap: () => unawaited(
                        showWordsReader(context, ref.read(todaysWordsProvider)),
                      ),
                    ),
                  ],
                ),
                for (final w in words!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _WordsTile(
                      words: w,
                      onTap: () =>
                          unawaited(showWordsEditor(context, ref, editing: w)),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WordsTile extends StatelessWidget {
  const _WordsTile({required this.words, required this.onTap});

  final MyWords words;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            words.text.trim(),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (words.from.trim().isNotEmpty || words.everyDay) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (words.from.trim().isNotEmpty)
                  Expanded(
                    child: Text(
                      '— ${words.from.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (words.everyDay)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.brandPrimarySoft,
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.pinned,
                          size: 12,
                          color: c.onBrandPrimarySoft,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.wordsEveryDayChip,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: c.onBrandPrimarySoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Adds words, or changes or deletes [editing].
Future<void> showWordsEditor(
  BuildContext context,
  WidgetRef ref, {
  MyWords? editing,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (_) => _WordsEditor(editing: editing, parent: context),
);

class _WordsEditor extends ConsumerStatefulWidget {
  const _WordsEditor({this.editing, required this.parent});

  final MyWords? editing;

  /// The screen behind, for the Undo message after a delete.
  final BuildContext parent;

  @override
  ConsumerState<_WordsEditor> createState() => _WordsEditorState();
}

class _WordsEditorState extends ConsumerState<_WordsEditor> {
  late final _text = TextEditingController(text: widget.editing?.text);
  late final _from = TextEditingController(text: widget.editing?.from);
  late bool _everyDay = widget.editing?.everyDay ?? false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    _from.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final words =
        widget.editing?.copyWith(
          text: text,
          from: _from.text.trim(),
          everyDay: _everyDay,
        ) ??
        MyWords(
          id: ref.read(idGeneratorProvider).newId(),
          text: text,
          from: _from.text.trim(),
          everyDay: _everyDay,
        );
    await saveWords(ref, words);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final removed = await deleteWords(ref, widget.editing!.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (removed == null || !widget.parent.mounted) return;
    showUndoSnackBar(
      widget.parent,
      message: l10n.wordsDeleted,
      onUndo: () => unawaited(restoreWords(ref, removed.$1, removed.$2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.editing == null ? l10n.wordsAdd : l10n.wordsEdit,
              style: context.textStyles.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _text,
              autofocus: widget.editing == null,
              minLines: 4,
              maxLines: 12,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: l10n.wordsTextHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _from,
              maxLength: 120,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.wordsFrom,
                hintText: l10n.wordsFromHint,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _everyDay,
              onChanged: (v) => setState(() => _everyDay = v),
              title: Text(l10n.wordsEveryDay),
              subtitle: Text(
                l10n.wordsEveryDaySubtitle,
                style: context.textStyles.bodySmall?.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (widget.editing != null)
                  TextButton.icon(
                    onPressed: () => unawaited(_delete()),
                    style: TextButton.styleFrom(foregroundColor: c.danger),
                    icon: const Icon(AppIcons.delete, size: 18),
                    label: Text(l10n.wordsDelete),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _text.text.trim().isEmpty
                      ? null
                      : () => unawaited(_save()),
                  child: Text(l10n.wordsSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
