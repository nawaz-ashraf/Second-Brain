import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'bookmarks_dao.g.dart';

@DriftAccessor(tables: [Bookmarks, BookmarkTags, Tags])
class BookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarksDaoMixin {
  BookmarksDao(super.db);

  Stream<List<Bookmark>> watchAll() {
    return (select(bookmarks)
          ..where((b) => b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)]))
        .watch();
  }

  Stream<List<Bookmark>> watchFavorites() {
    return (select(bookmarks)
          ..where((b) => b.isFavorite.equals(true) & b.deletedAt.isNull())
          ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)]))
        .watch();
  }

  Future<Bookmark?> getById(String id) {
    return (select(bookmarks)..where((b) => b.id.equals(id))).getSingleOrNull();
  }

  Future<List<Bookmark>> search(String query) {
    final q = '%$query%';
    return (select(bookmarks)
          ..where(
            (b) =>
                (b.title.like(q) | b.url.like(q) | b.description.like(q)) &
                b.deletedAt.isNull(),
          )
          ..orderBy([(b) => OrderingTerm.desc(b.updatedAt)]))
        .get();
  }

  Future<void> insertBookmark(BookmarksCompanion bookmark) async {
    await into(bookmarks).insertOnConflictUpdate(bookmark);
  }

  Future<void> updateBookmark(BookmarksCompanion bookmark) async {
    await update(bookmarks).replace(bookmark);
  }

  Future<void> deleteBookmark(String id) async {
    await (update(bookmarks)..where((b) => b.id.equals(id))).write(
      BookmarksCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> permanentlyDeleteBookmark(String id) async {
    await (delete(bookmarks)..where((b) => b.id.equals(id))).go();
  }

  Future<void> restoreBookmark(String id) async {
    await (update(bookmarks)..where((b) => b.id.equals(id))).write(
      const BookmarksCompanion(deletedAt: Value(null)),
    );
  }

  Stream<List<Bookmark>> watchDeleted() {
    return (select(bookmarks)
          ..where((b) => b.deletedAt.isNotNull())
          ..orderBy([(b) => OrderingTerm.desc(b.deletedAt)]))
        .watch();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(bookmarks)..where((b) => b.id.equals(id))).write(
      BookmarksCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<List<Tag>> getTagsForBookmark(String bookmarkId) async {
    final query = select(bookmarkTags).join([
      innerJoin(tags, tags.id.equalsExp(bookmarkTags.tagId)),
    ])
      ..where(bookmarkTags.bookmarkId.equals(bookmarkId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  Future<void> addTag(String bookmarkId, String tagId) async {
    await into(bookmarkTags).insertOnConflictUpdate(
      BookmarkTagsCompanion(
        bookmarkId: Value(bookmarkId),
        tagId: Value(tagId),
      ),
    );
  }

  Future<void> clearTags(String bookmarkId) async {
    await (delete(bookmarkTags)
          ..where((bt) => bt.bookmarkId.equals(bookmarkId)))
        .go();
  }
}
