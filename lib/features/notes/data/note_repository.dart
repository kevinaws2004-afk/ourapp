import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../../core/time/clock.dart';
import '../domain/note.dart';

/// Notes in the `notes` table: pinned first, then most recently edited.
/// Deleting is soft, so it can be undone.
class NoteRepository {
  NoteRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  Stream<List<Note>> watchAll() =>
      (_db.select(_db.notes)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.desc(t.pinned),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .watch()
          .map((rows) => [for (final r in rows) _toNote(r)]);

  Stream<Note?> watch(NoteId id) =>
      (_db.select(_db.notes)
            ..where((t) => t.publicId.equals(id.value) & t.deletedAt.isNull()))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _toNote(r));

  Future<Note?> get(NoteId id) async {
    final row = await (_db.select(
      _db.notes,
    )..where((t) => t.publicId.equals(id.value))).getSingleOrNull();
    return row == null ? null : _toNote(row);
  }

  /// A new, empty note.
  Future<NoteId> create({String? colorKey}) async {
    final now = _clock.nowUtc().millisecondsSinceEpoch;
    final id = _ids.newId();
    await _db
        .into(_db.notes)
        .insert(
          NotesCompanion.insert(
            publicId: id,
            colorKey: Value(colorKey),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return NoteId(id);
  }

  Future<void> save(NoteId id, {required String title, required String body}) =>
      _update(id, NotesCompanion(title: Value(title), body: Value(body)));

  Future<void> setPinned(NoteId id, {required bool pinned}) =>
      _update(id, NotesCompanion(pinned: Value(pinned ? 1 : 0)), touch: false);

  Future<void> setColor(NoteId id, String? colorKey) =>
      _update(id, NotesCompanion(colorKey: Value(colorKey)), touch: false);

  Future<void> delete(NoteId id) => _update(
    id,
    NotesCompanion(deletedAt: Value(_clock.nowUtc().millisecondsSinceEpoch)),
    touch: false,
  );

  Future<void> restore(NoteId id) =>
      _update(id, const NotesCompanion(deletedAt: Value(null)), touch: false);

  /// Removes a note that was never written in (no undo needed).
  Future<void> discardIfEmpty(NoteId id) async {
    final note = await get(id);
    if (note != null && note.isEmpty) {
      await (_db.delete(
        _db.notes,
      )..where((t) => t.publicId.equals(id.value))).go();
    }
  }

  Future<void> _update(
    NoteId id,
    NotesCompanion changes, {
    bool touch = true,
  }) =>
      (_db.update(_db.notes)..where((t) => t.publicId.equals(id.value))).write(
        touch
            ? changes.copyWith(
                updatedAt: Value(_clock.nowUtc().millisecondsSinceEpoch),
              )
            : changes,
      );

  Note _toNote(NoteRow r) => Note(
    id: NoteId(r.publicId),
    title: r.title,
    body: r.body,
    colorKey: r.colorKey,
    pinned: r.pinned == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt, isUtc: true),
  );
}
