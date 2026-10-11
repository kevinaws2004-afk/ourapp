import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/activity_palette.dart';
import '../../../core/design/tokens/radius.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/screen_header.dart';
import '../domain/note.dart';
import 'note_providers.dart';

/// Notes: everything you jot down that isn't an activity. Search, pinned
/// notes first, then the rest, as a two-column board of cards in their
/// colors. **New note** opens an empty one.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key, required this.onOpen, required this.onNew});

  final ValueChanged<NoteId> onOpen;
  final VoidCallback onNew;

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final notes = ref.watch(notesProvider).value;
    final shown = [
      for (final n in notes ?? const <Note>[])
        if (!n.isEmpty && n.matches(_query)) n,
    ];
    final pinned = [
      for (final n in shown)
        if (n.pinned) n,
    ];
    final others = [
      for (final n in shown)
        if (!n.pinned) n,
    ];
    final hasAny = (notes ?? const []).any((n) => !n.isEmpty);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(
          color: c.textTertiary,
          letterSpacing: 1.1,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: hasAny
          ? FloatingActionButton.extended(
              heroTag: 'new-note',
              onPressed: widget.onNew,
              icon: const Icon(AppIcons.add),
              label: Text(l10n.notesNew),
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
                title: l10n.notesTitle,
                subtitle: hasAny ? l10n.notesCount(shown.length) : null,
                actions: [
                  HeaderIconButton(
                    icon: AppIcons.add,
                    tooltip: l10n.notesNew,
                    onPressed: widget.onNew,
                  ),
                ],
              ),
              if (hasAny) ...[
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.notesSearch,
                    prefixIcon: Icon(
                      AppIcons.search,
                      size: 20,
                      color: c.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (notes != null && !hasAny)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: EmptyStateCard(
                    icon: AppIcons.notes.outline,
                    title: l10n.notesEmptyTitle,
                    message: l10n.notesEmptyMessage,
                    actions: [
                      AppButton(
                        label: l10n.notesNew,
                        icon: AppIcons.add,
                        onPressed: widget.onNew,
                      ),
                    ],
                  ),
                )
              else if (hasAny && shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.notesNoMatch,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
              if (pinned.isNotEmpty) ...[
                label(l10n.notesPinned),
                _Board(notes: pinned, onOpen: widget.onOpen),
              ],
              if (others.isNotEmpty) ...[
                if (pinned.isNotEmpty) label(l10n.notesOthers),
                _Board(notes: others, onOpen: widget.onOpen),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Two columns of note cards, filled to keep the columns even.
class _Board extends StatelessWidget {
  const _Board({required this.notes, required this.onOpen});

  final List<Note> notes;
  final ValueChanged<NoteId> onOpen;

  @override
  Widget build(BuildContext context) {
    final left = <Note>[];
    final right = <Note>[];
    var leftWeight = 0;
    var rightWeight = 0;
    // A rough height per card: longer notes take more room.
    int weight(Note n) =>
        3 + (n.body.length ~/ 40).clamp(0, 8) + (n.title.isEmpty ? 0 : 1);
    for (final n in notes) {
      if (leftWeight <= rightWeight) {
        left.add(n);
        leftWeight += weight(n);
      } else {
        right.add(n);
        rightWeight += weight(n);
      }
    }
    Widget column(List<Note> list) => Expanded(
      child: Column(
        children: [
          for (final n in list)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: NoteCard(note: n, onTap: () => onOpen(n.id)),
            ),
        ],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column(left),
        const SizedBox(width: AppSpacing.md),
        column(right),
      ],
    );
  }
}

/// One note on the board: its title, the start of its text and when it was
/// last edited, on its color.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final material = MaterialLocalizations.of(context);
    final tint = noteColor(context, note.colorKey);
    final local = note.updatedAt.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final when = sameDay
        ? material.formatTimeOfDay(TimeOfDay.fromDateTime(local))
        : material.formatShortMonthDay(local);
    return Material(
      color: tint ?? c.surfaceBase,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(
          color: tint == null ? c.borderSubtle : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    note.title.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (note.body.trim().isNotEmpty)
                Text(
                  note.body.trim(),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: c.textSecondary,
                    height: 1.45,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      when,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ),
                  if (note.pinned)
                    Icon(AppIcons.pinned, size: 13, color: c.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The colors a note can have, in the picker's order.
const noteColorKeys = [
  ActivityColorKey.yellow,
  ActivityColorKey.amber,
  ActivityColorKey.rose,
  ActivityColorKey.lilac,
  ActivityColorKey.sky,
  ActivityColorKey.teal,
  ActivityColorKey.lime,
  ActivityColorKey.slate,
];

/// A note's card color from its key, or null for the plain card.
Color? noteColor(BuildContext context, String? key) {
  if (key == null) return null;
  final k = ActivityColorKey.fromName(key);
  return k == null ? null : context.tokens.activity(k).soft;
}

/// Opens a new, empty note.
Future<void> openNewNote(WidgetRef ref, ValueChanged<NoteId> open) async {
  final id = await ref.read(noteRepositoryProvider).create();
  open(id);
}
