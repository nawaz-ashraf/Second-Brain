import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes, NoteTags, Tags])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  /// Watch all non-deleted notes ordered by pinned then updated
  Stream<List<Note>> watchAll() {
    return (select(notes)
          ..where((n) => n.deletedAt.isNull())
          ..orderBy([
            (n) => OrderingTerm.desc(n.isPinned),
            (n) => OrderingTerm.desc(n.updatedAt),
          ]))
        .watch();
  }

  /// Watch a single note by ID
  Stream<Note?> watchById(String id) {
    return (select(notes)..where((n) => n.id.equals(id))).watchSingleOrNull();
  }

  /// Get all non-deleted notes once
  Future<List<Note>> getAll() {
    return (select(notes)
          ..where((n) => n.deletedAt.isNull())
          ..orderBy([
            (n) => OrderingTerm.desc(n.isPinned),
            (n) => OrderingTerm.desc(n.updatedAt),
          ]))
        .get();
  }

  /// Get a single note by ID
  Future<Note?> getById(String id) {
    return (select(notes)..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  /// Watch favorite notes
  Stream<List<Note>> watchFavorites() {
    return (select(notes)
          ..where((n) => n.isFavorite.equals(true) & n.deletedAt.isNull())
          ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
        .watch();
  }

  /// Watch recent notes
  Stream<List<Note>> watchRecent({int limit = 10}) {
    return (select(notes)
          ..where((n) => n.deletedAt.isNull())
          ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])
          ..limit(limit))
        .watch();
  }

  /// Insert a note
  Future<void> insertNote(NotesCompanion note) async {
    await into(notes).insertOnConflictUpdate(note);
  }

  /// Update a note
  Future<void> updateNote(NotesCompanion note) async {
    await update(notes).replace(note);
  }

  /// Soft delete a note
  Future<void> deleteNote(String id) async {
    await (update(notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  /// Permanently delete a note
  Future<void> permanentlyDeleteNote(String id) async {
    await (delete(notes)..where((n) => n.id.equals(id))).go();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  /// Toggle pin
  Future<void> togglePin(String id, bool isPinned) async {
    await (update(notes)..where((n) => n.id.equals(id))).write(
      NotesCompanion(isPinned: Value(isPinned)),
    );
  }

  /// Search notes by title or content
  Future<List<Note>> search(String query) {
    final q = '%$query%';
    return (select(notes)
          ..where(
            (n) =>
                n.title.like(q) |
                n.contentPlain.like(q) &
                    n.deletedAt.isNull(),
          )
          ..orderBy([(n) => OrderingTerm.desc(n.updatedAt)]))
        .get();
  }

  // ─── Tag operations ─────────────────────────────────────────────────────

  /// Get tags for a note
  Future<List<Tag>> getTagsForNote(String noteId) async {
    final query = select(noteTags).join([
      innerJoin(tags, tags.id.equalsExp(noteTags.tagId)),
    ])
      ..where(noteTags.noteId.equals(noteId));

    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  /// Add tag to note
  Future<void> addTag(String noteId, String tagId) async {
    await into(noteTags).insertOnConflictUpdate(
      NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId)),
    );
  }

  /// Remove tag from note
  Future<void> removeTag(String noteId, String tagId) async {
    await (delete(noteTags)
          ..where(
            (nt) => nt.noteId.equals(noteId) & nt.tagId.equals(tagId),
          ))
        .go();
  }

  /// Remove all tags from note
  Future<void> clearTags(String noteId) async {
    await (delete(noteTags)..where((nt) => nt.noteId.equals(noteId))).go();
  }
}
