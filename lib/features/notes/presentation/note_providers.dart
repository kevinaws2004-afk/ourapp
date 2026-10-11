import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/ids/id_generator_provider.dart';
import '../../../core/time/clock_provider.dart';
import '../data/note_repository.dart';
import '../domain/note.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final notesProvider = StreamProvider.autoDispose<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).watchAll(),
);

final noteProvider = StreamProvider.autoDispose.family<Note?, NoteId>(
  (ref, id) => ref.watch(noteRepositoryProvider).watch(id),
);
