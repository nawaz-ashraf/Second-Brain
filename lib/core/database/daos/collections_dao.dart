import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'collections_dao.g.dart';

@DriftAccessor(tables: [Collections, CollectionItems])
class CollectionsDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionsDaoMixin {
  CollectionsDao(super.db);

  Stream<List<Collection>> watchAll() {
    return (select(collections)
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<Collection?> getById(String id) {
    return (select(collections)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Collection>> search(String query) {
    final q = '%$query%';
    return (select(collections)
          ..where((c) => (c.name.like(q) | c.description.like(q)) & c.deletedAt.isNull()))
        .get();
  }

  Future<void> insertCollection(CollectionsCompanion collection) async {
    await into(collections).insertOnConflictUpdate(collection);
  }

  Future<void> updateCollection(CollectionsCompanion collection) async {
    await update(collections).replace(collection);
  }

  Future<void> deleteCollection(String id) async {
    await (update(collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> permanentlyDeleteCollection(String id) async {
    await (delete(collections)..where((c) => c.id.equals(id))).go();
    await (delete(collectionItems)
          ..where((ci) => ci.collectionId.equals(id)))
        .go();
  }

  Future<void> restoreCollection(String id) async {
    await (update(collections)..where((c) => c.id.equals(id))).write(
      const CollectionsCompanion(deletedAt: Value(null)),
    );
  }

  Stream<List<Collection>> watchDeleted() {
    return (select(collections)
          ..where((c) => c.deletedAt.isNotNull())
          ..orderBy([(c) => OrderingTerm.desc(c.deletedAt)]))
        .watch();
  }

  // ─── Collection Items ────────────────────────────────────────────────────

  Future<List<CollectionItem>> getItemsForCollection(
    String collectionId,
  ) {
    return (select(collectionItems)
          ..where((ci) => ci.collectionId.equals(collectionId)))
        .get();
  }

  Stream<List<CollectionItem>> watchItemsForCollection(String collectionId) {
    return (select(collectionItems)
          ..where((ci) => ci.collectionId.equals(collectionId)))
        .watch();
  }

  Future<int> getItemCount(String collectionId) async {
    final items = await getItemsForCollection(collectionId);
    return items.length;
  }

  Future<void> addItem(
    String collectionId,
    String itemId,
    String itemType,
  ) async {
    await into(collectionItems).insertOnConflictUpdate(
      CollectionItemsCompanion(
        collectionId: Value(collectionId),
        itemId: Value(itemId),
        itemType: Value(itemType),
      ),
    );
  }

  Future<void> removeItem(
    String collectionId,
    String itemId,
    String itemType,
  ) async {
    await (delete(collectionItems)
          ..where(
            (ci) =>
                ci.collectionId.equals(collectionId) &
                ci.itemId.equals(itemId) &
                ci.itemType.equals(itemType),
          ))
        .go();
  }

  Future<bool> isInCollection(
    String collectionId,
    String itemId,
    String itemType,
  ) async {
    final item = await (select(collectionItems)
          ..where(
            (ci) =>
                ci.collectionId.equals(collectionId) &
                ci.itemId.equals(itemId) &
                ci.itemType.equals(itemType),
          ))
        .getSingleOrNull();
    return item != null;
  }
}
