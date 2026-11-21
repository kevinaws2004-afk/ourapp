import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/app_icons.dart';
import '../../../core/design/context_ext.dart';
import '../../../core/design/tokens/spacing.dart';
import '../../../core/design/window_size_class.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/errors/error_copy.dart';
import '../../../shared/widgets/state_views.dart';
import '../domain/note.dart';
import 'note_providers.dart';
import 'notes_screen.dart';

/// One note, full screen: a big title and the text, saved as you type
/// (and when you leave). Pin it, give it a color, or delete it (with Undo).
/// A note left empty disappears.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.id});

  final NoteId id;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _bodyFocus = FocusNode();
  Timer? _debounce;
  bool _loaded = false;
  bool _deleted = false;

  /// Tick boxes instead of plain text (groceries, packing). The text keeps
  /// "☐ " / "☑ " in front of each line, so it reads fine either way.
  bool _checklist = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final note = await ref.read(noteRepositoryProvider).get(widget.id);
    if (!mounted) return;
    _title.text = note?.title ?? '';
    _body.text = note?.body ?? '';
    _checklist = isChecklistText(_body.text);
    setState(() => _loaded = true);
    // A new note: straight into writing.
    if (note != null && note.isEmpty) _bodyFocus.requestFocus();
  }

  void _changed() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _save);
    setState(() {});
  }

  Future<void> _save() async {
    if (!_loaded || _deleted) return;
    await ref
        .read(noteRepositoryProvider)
        .save(widget.id, title: _title.text, body: _body.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final repo = ref.read(noteRepositoryProvider);
    if (_loaded && !_deleted) {
      unawaited(
        repo
            .save(widget.id, title: _title.text, body: _body.text)
            .then((_) => repo.discardIfEmpty(widget.id)),
      );
    }
    _title.dispose();
    _body.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(noteRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    _debounce?.cancel();
    await _save();
    final empty = _title.text.trim().isEmpty && _body.text.trim().isEmpty;
    _deleted = true;
    try {
      await repo.delete(widget.id);
    } catch (error) {
      if (mounted) showMessageSnackBar(context, errorMessage(l10n, error));
      return;
    }
    if (!mounted) return;
    unawaited(HapticFeedback.mediumImpact());
    Navigator.of(context).pop();
    if (empty) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.notesDeleted),
          // Undo stays offered for the usual few seconds, not until dismissed.
          persist: false,
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(repo.restore(widget.id)),
          ),
        ),
      );
  }

  Future<void> _pickColor(String? current) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<({String? key})>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) {
        final c = context.colors;
        Widget swatch(String? key) {
          final color = noteColor(context, key) ?? c.surfaceBase;
          final selected = key == current;
          return Semantics(
            button: true,
            selected: selected,
            label: key ?? l10n.notesColorNone,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop((key: key)),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? c.brandPrimary : c.borderStrong,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: selected
                    ? Icon(AppIcons.check, size: 20, color: c.brandPrimary)
                    : null,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.notesColor, style: context.textStyles.headlineSmall),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  swatch(null),
                  for (final k in noteColorKeys) swatch(k.name),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (picked == null) return;
    await ref.read(noteRepositoryProvider).setColor(widget.id, picked.key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final margin = WindowSizeClass.of(context).screenMargin;
    final note = ref.watch(noteProvider(widget.id)).value;
    final tint = noteColor(context, note?.colorKey);
    final words = RegExp(r'\S+')
        .allMatches(_body.text.replaceAll(RegExp('[☐☑]'), ''))
        .length;
    final edited = note == null
        ? ''
        : MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(note.updatedAt.toLocal()));
    final pinned = note?.pinned ?? false;

    return Scaffold(
      backgroundColor: tint ?? c.surfaceCanvas,
      appBar: AppBar(
        backgroundColor: tint ?? c.surfaceCanvas,
        actions: [
          IconButton(
            tooltip: pinned ? l10n.notesUnpin : l10n.notesPin,
            icon: Icon(
              pinned ? AppIcons.pinned : AppIcons.pin,
              color: pinned ? c.brandPrimary : null,
            ),
            onPressed: () => unawaited(
              ref
                  .read(noteRepositoryProvider)
                  .setPinned(widget.id, pinned: !pinned),
            ),
          ),
          IconButton(
            tooltip: _checklist ? l10n.notesPlainText : l10n.notesChecklist,
            icon: Icon(_checklist ? AppIcons.fieldText : AppIcons.taskDone),
            onPressed: () => setState(() {
              if (!_checklist) _body.text = toChecklistText(_body.text);
              _checklist = !_checklist;
              _changed();
            }),
          ),
          IconButton(
            tooltip: l10n.notesColor,
            icon: const Icon(AppIcons.appearance),
            onPressed: () => unawaited(_pickColor(note?.colorKey)),
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(AppIcons.delete),
            onPressed: () => unawaited(_delete()),
          ),
          // It saves as you type; Save says so, and closes the note.
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton(
              onPressed: () async {
                _debounce?.cancel();
                await _save();
                if (context.mounted) Navigator.of(context).maybePop();
              },
              child: Text(l10n.notesSave),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppContentWidth.reading,
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    margin,
                    AppSpacing.xs,
                    margin,
                    AppSpacing.giant,
                  ),
                  children: [
                    TextField(
                      controller: _title,
                      onChanged: (_) => _changed(),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _bodyFocus.requestFocus(),
                      style: context.textStyles.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      decoration:
                          InputDecoration.collapsed(
                            hintText: l10n.notesTitleHint,
                            hintStyle: context.textStyles.headlineLarge
                                ?.copyWith(
                                  color: c.textTertiary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ).copyWith(
                            // Like a page: no box, even while typing.
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      [
                        if (edited.isNotEmpty) l10n.notesEdited(edited),
                        l10n.notesWords(words),
                      ].join(' · '),
                      style: context.textStyles.labelSmall?.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_checklist)
                      _ChecklistBody(
                        text: _body.text,
                        onChanged: (text) {
                          _body.text = text;
                          _changed();
                        },
                      )
                    else
                      TextField(
                        controller: _body,
                        focusNode: _bodyFocus,
                        onChanged: (_) => _changed(),
                        maxLines: null,
                        minLines: 12,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: context.textStyles.bodyLarge?.copyWith(
                          height: 1.55,
                        ),
                        decoration:
                            InputDecoration.collapsed(
                              hintText: l10n.notesBodyHint,
                              hintStyle: context.textStyles.bodyLarge?.copyWith(
                                color: c.textTertiary,
                              ),
                            ).copyWith(
                              // Like a page: no box, even while typing.
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

const _open = '☐ ';
const _ticked = '☑ ';

/// Whether every non-empty line of [text] is a checklist line.
bool isChecklistText(String text) {
  final lines = text.split('\n').where((l) => l.trim().isNotEmpty);
  return lines.isNotEmpty &&
      lines.every((l) => l.startsWith(_open) || l.startsWith(_ticked));
}

/// [text] as a checklist: each non-empty line gets a box.
String toChecklistText(String text) => [
  for (final line in text.split('\n'))
    if (line.trim().isNotEmpty)
      line.startsWith(_open) || line.startsWith(_ticked)
          ? line
          : '$_open${line.trim()}',
].join('\n');

/// A note as tick boxes: one row per line (tick, text editable in place,
/// remove), "Add item…" at the end, and "Clear ticked" once some are done.
class _ChecklistBody extends StatelessWidget {
  const _ChecklistBody({required this.text, required this.onChanged});

  final String text;
  final ValueChanged<String> onChanged;

  List<(bool, String)> get _items => [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty)
        (
          line.startsWith(_ticked),
          line.startsWith(_open) || line.startsWith(_ticked)
              ? line.substring(2)
              : line,
        ),
  ];

  void _emit(List<(bool, String)> items) => onChanged(
    items.map((i) => '${i.$1 ? _ticked : _open}${i.$2}').join('\n'),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final items = _items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (done, label)) in items.indexed)
          _NoteCheckRow(
            key: ValueKey('$i'),
            done: done,
            label: label,
            removeLabel: l10n.notesRemoveItem,
            onTick: (v) => _emit([...items]..[i] = (v, label)),
            onText: (t) => _emit([...items]..[i] = (done, t)),
            onRemove: () => _emit([...items]..removeAt(i)),
          ),
        _NoteAddRow(
          hint: l10n.notesAddItem,
          onAdd: (t) => _emit([...items, (false, t)]),
        ),
        if (items.any((i) => i.$1))
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: c.textSecondary),
              onPressed: () => _emit([...items.where((i) => !i.$1)]),
              child: Text(l10n.notesClearTicked),
            ),
          ),
      ],
    );
  }
}

class _NoteCheckRow extends StatefulWidget {
  const _NoteCheckRow({
    super.key,
    required this.done,
    required this.label,
    required this.removeLabel,
    required this.onTick,
    required this.onText,
    required this.onRemove,
  });

  final bool done;
  final String label;
  final String removeLabel;
  final ValueChanged<bool> onTick;
  final ValueChanged<String> onText;
  final VoidCallback onRemove;

  @override
  State<_NoteCheckRow> createState() => _NoteCheckRowState();
}

class _NoteCheckRowState extends State<_NoteCheckRow> {
  late final _text = TextEditingController(text: widget.label);
  final _focus = FocusNode();

  @override
  void didUpdateWidget(_NoteCheckRow old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _text.text != widget.label) {
      _text.text = widget.label;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Checkbox(
          value: widget.done,
          onChanged: (v) {
            unawaited(HapticFeedback.selectionClick());
            widget.onTick(v ?? false);
          },
        ),
        Expanded(
          child: TextField(
            controller: _text,
            focusNode: _focus,
            textCapitalization: TextCapitalization.sentences,
            onChanged: widget.onText,
            style: context.textStyles.bodyLarge?.copyWith(
              decoration: widget.done ? TextDecoration.lineThrough : null,
              color: widget.done ? c.textTertiary : c.textPrimary,
            ),
            decoration: const InputDecoration.collapsed(hintText: '').copyWith(
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          tooltip: widget.removeLabel,
          visualDensity: VisualDensity.compact,
          icon: Icon(AppIcons.close, size: 18, color: c.textTertiary),
          onPressed: widget.onRemove,
        ),
      ],
    );
  }
}

class _NoteAddRow extends StatefulWidget {
  const _NoteAddRow({required this.hint, required this.onAdd});

  final String hint;
  final ValueChanged<String> onAdd;

  @override
  State<_NoteAddRow> createState() => _NoteAddRowState();
}

class _NoteAddRowState extends State<_NoteAddRow> {
  final _text = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    widget.onAdd(t);
    _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox(width: 48, child: Icon(AppIcons.add, size: 20)),
      Expanded(
        child: TextField(
          controller: _text,
          focusNode: _focus,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          // Enter adds it and keeps the keyboard up for the next one (the
          // default would move focus away).
          onEditingComplete: _add,
          decoration: InputDecoration.collapsed(hintText: widget.hint).copyWith(
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}
