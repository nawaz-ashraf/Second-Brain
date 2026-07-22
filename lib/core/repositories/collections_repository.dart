import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/collections_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class CollectionsRepository {
  Stream<List<CollectionModel>> watchAll();
  Future<CollectionModel?> getById(String id);
  Future<CollectionModel> create({
    required String name,
    String? description,
    int color,
    String icon,
  });
  Future<void> update(CollectionModel collection);
  Future<void> delete(String id);
  Future<List<CollectionModel>> search(String query);
  Future<void> addItem(String collectionId, String itemId, String itemType);
  Future<void> removeItem(String collectionId, String itemId, String itemType);
  Future<bool> isInCollection(String collectionId, String itemId, String itemType);
  Stream<List<CollectionItem>> watchItems(String collectionId);
}

class CollectionsRepositoryImpl implements CollectionsRepository {
  final CollectionsDao _dao;
  final _uuid = const Uuid();

  CollectionsRepositoryImpl(this._dao);

  @override
  Stream<List<CollectionModel>> watchAll() {
    return _dao.watchAll().asyncMap((collections) async {
      final result = <CollectionModel>[];
      for (final collection in collections) {
        final count = await _dao.getItemCount(collection.id);
        result.add(collection.toModel(itemCount: count));
      }
      return result;
    });
  }

  @override
  Future<CollectionModel?> getById(String id) async {
    final collection = await _dao.getById(id);
    if (collection == null) return null;
    final count = await _dao.getItemCount(id);
    return collection.toModel(itemCount: count);
  }

  @override
  Future<CollectionModel> create({
    required String name,
    String? description,
    int color = 0xFF4CAF50,
    String icon = 'folder',
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertCollection(
      CollectionsCompanion(
        id: Value(id),
        name: Value(name),
        description: Value(description),
        color: Value(color),
        icon: Value(icon),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final collection = await _dao.getById(id);
    return collection!.toModel();
  }

  @override
  Future<void> update(CollectionModel collection) async {
    await _dao.updateCollection(
      CollectionsCompanion(
        id: Value(collection.id),
        name: Value(collection.name),
        description: Value(collection.description),
        color: Value(collection.color),
        icon: Value(collection.icon),
        createdAt: Value(collection.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteCollection(id);

  @override
  Future<List<CollectionModel>> search(String query) async {
    final collections = await _dao.search(query);
    return collections.map((c) => c.toModel()).toList();
  }

  @override
  Future<void> addItem(
    String collectionId,
    String itemId,
    String itemType,
  ) => _dao.addItem(collectionId, itemId, itemType);

  @override
  Future<void> removeItem(
    String collectionId,
    String itemId,
    String itemType,
  ) => _dao.removeItem(collectionId, itemId, itemType);

  @override
  Future<bool> isInCollection(
    String collectionId,
    String itemId,
    String itemType,
  ) => _dao.isInCollection(collectionId, itemId, itemType);

  @override
  Stream<List<CollectionItem>> watchItems(String collectionId) {
    return _dao.watchItemsForCollection(collectionId);
  }
}
