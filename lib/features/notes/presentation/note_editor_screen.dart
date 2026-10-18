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
    final words = RegExp(r'\S+').allMatches(_body.text).length;
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
            tooltip: l10n.notesColor,
            icon: const Icon(AppIcons.appearance),
            onPressed: () => unawaited(_pickColor(note?.colorKey)),
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(AppIcons.delete),
            onPressed: () => unawaited(_delete()),
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
