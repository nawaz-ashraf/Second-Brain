import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'recent_items_dao.g.dart';

@DriftAccessor(tables: [RecentItems])
class RecentItemsDao extends DatabaseAccessor<AppDatabase>
    with _$RecentItemsDaoMixin {
  RecentItemsDao(super.db);

  Stream<List<RecentItem>> watchRecent({int limit = 20}) {
    return (select(recentItems)
          ..orderBy([(r) => OrderingTerm.desc(r.openedAt)])
          ..limit(limit))
        .watch();
  }

  Future<void> recordOpen(String id, String itemId, String itemType) async {
    // Remove existing entry for same item
    await (delete(recentItems)
          ..where(
            (r) =>
                r.itemId.equals(itemId) & r.itemType.equals(itemType),
          ))
        .go();
    // Insert fresh
    await into(recentItems).insert(
      RecentItemsCompanion(
        id: Value(id),
        itemId: Value(itemId),
        itemType: Value(itemType),
        openedAt: Value(DateTime.now()),
      ),
    );
    // Trim to max 50
    final all = await (select(recentItems)
          ..orderBy([(r) => OrderingTerm.desc(r.openedAt)]))
        .get();
    if (all.length > 50) {
      final toDelete = all.sublist(50);
      for (final item in toDelete) {
        await (delete(recentItems)..where((r) => r.id.equals(item.id))).go();
      }
    }
  }

  Future<void> removeItem(String itemId, String itemType) async {
    await (delete(recentItems)
          ..where(
            (r) =>
                r.itemId.equals(itemId) & r.itemType.equals(itemType),
          ))
        .go();
  }

  Future<void> clearAll() async {
    await delete(recentItems).go();
  }
}
