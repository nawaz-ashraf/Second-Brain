import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/bookmarks_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class BookmarksRepository {
  Stream<List<BookmarkModel>> watchAll();
  Stream<List<BookmarkModel>> watchFavorites();
  Future<BookmarkModel?> getById(String id);
  Future<BookmarkModel> create({
    required String title,
    required String url,
    String? description,
    String? siteName,
    String? faviconUrl,
    List<String> tagIds,
  });
  Future<void> update(BookmarkModel bookmark);
  Future<void> delete(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> restore(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<BookmarkModel>> search(String query);
  Stream<List<BookmarkModel>> watchDeleted();
}

class BookmarksRepositoryImpl implements BookmarksRepository {
  final BookmarksDao _dao;
  final _uuid = const Uuid();

  BookmarksRepositoryImpl(this._dao);

  @override
  Stream<List<BookmarkModel>> watchAll() {
    return _dao.watchAll().asyncMap((bookmarks) async {
      final result = <BookmarkModel>[];
      for (final bookmark in bookmarks) {
        final tags = await _dao.getTagsForBookmark(bookmark.id);
        result.add(bookmark.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<BookmarkModel>> watchFavorites() {
    return _dao.watchFavorites().asyncMap((bookmarks) async {
      return bookmarks.map((b) => b.toModel()).toList();
    });
  }

  @override
  Future<BookmarkModel?> getById(String id) async {
    final bookmark = await _dao.getById(id);
    if (bookmark == null) return null;
    final tags = await _dao.getTagsForBookmark(id);
    return bookmark.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<BookmarkModel> create({
    required String title,
    required String url,
    String? description,
    String? siteName,
    String? faviconUrl,
    List<String> tagIds = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertBookmark(
      BookmarksCompanion(
        id: Value(id),
        title: Value(title),
        url: Value(url),
        description: Value(description),
        siteName: Value(siteName),
        faviconUrl: Value(faviconUrl),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    for (final tagId in tagIds) {
      await _dao.addTag(id, tagId);
    }

    final bookmark = await _dao.getById(id);
    return bookmark!.toModel();
  }

  @override
  Future<void> update(BookmarkModel bookmark) async {
    await _dao.updateBookmark(
      BookmarksCompanion(
        id: Value(bookmark.id),
        title: Value(bookmark.title),
        url: Value(bookmark.url),
        description: Value(bookmark.description),
        siteName: Value(bookmark.siteName),
        faviconUrl: Value(bookmark.faviconUrl),
        isFavorite: Value(bookmark.isFavorite),
        createdAt: Value(bookmark.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteBookmark(id);

  @override
  Future<void> permanentlyDelete(String id) => _dao.permanentlyDeleteBookmark(id);

  @override
  Future<void> restore(String id) => _dao.restoreBookmark(id);

  @override
  Stream<List<BookmarkModel>> watchDeleted() {
    return _dao.watchDeleted().asyncMap((bookmarks) async {
      return bookmarks.map((b) => b.toModel()).toList();
    });
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _dao.toggleFavorite(id, isFavorite);

  @override
  Future<List<BookmarkModel>> search(String query) async {
    final bookmarks = await _dao.search(query);
    return bookmarks.map((b) => b.toModel()).toList();
  }
}
