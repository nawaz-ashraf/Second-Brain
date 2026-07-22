import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/images_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class ImagesRepository {
  Stream<List<ImageModel>> watchAll();
  Stream<List<ImageModel>> watchFavorites();
  Future<ImageModel?> getById(String id);
  Future<ImageModel> create({
    required String title,
    required String filePath,
    String? thumbnailPath,
    int? width,
    int? height,
    List<String> tagIds,
  });
  Future<void> update(ImageModel image);
  Future<void> delete(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<ImageModel>> search(String query);
}

class ImagesRepositoryImpl implements ImagesRepository {
  final ImagesDao _dao;
  final _uuid = const Uuid();

  ImagesRepositoryImpl(this._dao);

  @override
  Stream<List<ImageModel>> watchAll() {
    return _dao.watchAll().asyncMap((images) async {
      final result = <ImageModel>[];
      for (final image in images) {
        final tags = await _dao.getTagsForImage(image.id);
        result.add(image.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<ImageModel>> watchFavorites() {
    return _dao.watchFavorites().asyncMap((images) async {
      return images.map((i) => i.toModel()).toList();
    });
  }

  @override
  Future<ImageModel?> getById(String id) async {
    final image = await _dao.getById(id);
    if (image == null) return null;
    final tags = await _dao.getTagsForImage(id);
    return image.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<ImageModel> create({
    required String title,
    required String filePath,
    String? thumbnailPath,
    int? width,
    int? height,
    List<String> tagIds = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertImage(
      ImagesCompanion(
        id: Value(id),
        title: Value(title),
        filePath: Value(filePath),
        thumbnailPath: Value(thumbnailPath),
        width: Value(width),
        height: Value(height),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    for (final tagId in tagIds) {
      await _dao.addTag(id, tagId);
    }

    final image = await _dao.getById(id);
    return image!.toModel();
  }

  @override
  Future<void> update(ImageModel image) async {
    await _dao.updateImage(
      ImagesCompanion(
        id: Value(image.id),
        title: Value(image.title),
        filePath: Value(image.filePath),
        thumbnailPath: Value(image.thumbnailPath),
        width: Value(image.width),
        height: Value(image.height),
        isFavorite: Value(image.isFavorite),
        createdAt: Value(image.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteImage(id);

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _dao.toggleFavorite(id, isFavorite);

  @override
  Future<List<ImageModel>> search(String query) async {
    final images = await _dao.search(query);
    return images.map((i) => i.toModel()).toList();
  }
}
