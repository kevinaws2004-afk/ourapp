import 'package:drift/drift.dart';

/// The shared active-row predicate (ADR-022). Every default repository query
/// uses it, which also lets SQLite use the partial `WHERE deleted_at IS NULL`
/// indexes (database.md §6).
Expression<bool> isActive(GeneratedColumn<int> deletedAt) => deletedAt.isNull();
