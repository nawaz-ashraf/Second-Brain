import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/tags_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class TagsRepository {
  Stream<List<TagModel>> watchAll();
  Future<List<TagModel>> getAll();
  Future<TagModel?> getById(String id);
  Future<TagModel?> getByName(String name);
  Future<TagModel> create({required String name, int color});
  Future<void> update(TagModel tag);
  Future<void> delete(String id);
  Future<List<TagModel>> search(String query);
}

class TagsRepositoryImpl implements TagsRepository {
  final TagsDao _dao;
  final _uuid = const Uuid();

  TagsRepositoryImpl(this._dao);

  @override
  Stream<List<TagModel>> watchAll() {
    return _dao.watchAll().map((tags) => tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<List<TagModel>> getAll() async {
    final tags = await _dao.getAll();
    return tags.map((t) => t.toModel()).toList();
  }

  @override
  Future<TagModel?> getById(String id) async {
    final tag = await _dao.getById(id);
    return tag?.toModel();
  }

  @override
  Future<TagModel?> getByName(String name) async {
    final tag = await _dao.getByName(name);
    return tag?.toModel();
  }

  @override
  Future<TagModel> create({required String name, int color = 0xFF4CAF50}) async {
    // Check if tag with this name already exists
    final existing = await _dao.getByName(name);
    if (existing != null) return existing.toModel();

    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertTag(
      TagsCompanion(
        id: Value(id),
        name: Value(name),
        color: Value(color),
        createdAt: Value(now),
      ),
    );

    final tag = await _dao.getById(id);
    return tag!.toModel();
  }

  @override
  Future<void> update(TagModel tag) async {
    await _dao.updateTag(
      TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        color: Value(tag.color),
        createdAt: Value(tag.createdAt),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteTag(id);

  @override
  Future<List<TagModel>> search(String query) async {
    final tags = await _dao.search(query);
    return tags.map((t) => t.toModel()).toList();
  }
}
