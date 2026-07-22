import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'images_dao.g.dart';

@DriftAccessor(tables: [Images, ImageTags, Tags])
class ImagesDao extends DatabaseAccessor<AppDatabase> with _$ImagesDaoMixin {
  ImagesDao(super.db);

  Stream<List<Image>> watchAll() {
    return (select(images)
          ..orderBy([(i) => OrderingTerm.desc(i.updatedAt)]))
        .watch();
  }

  Stream<List<Image>> watchFavorites() {
    return (select(images)
          ..where((i) => i.isFavorite.equals(true))
          ..orderBy([(i) => OrderingTerm.desc(i.updatedAt)]))
        .watch();
  }

  Future<Image?> getById(String id) {
    return (select(images)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Future<List<Image>> search(String query) {
    final q = '%$query%';
    return (select(images)
          ..where((i) => i.title.like(q))
          ..orderBy([(i) => OrderingTerm.desc(i.updatedAt)]))
        .get();
  }

  Future<void> insertImage(ImagesCompanion image) async {
    await into(images).insertOnConflictUpdate(image);
  }

  Future<void> updateImage(ImagesCompanion image) async {
    await update(images).replace(image);
  }

  Future<void> deleteImage(String id) async {
    await (delete(images)..where((i) => i.id.equals(id))).go();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(images)..where((i) => i.id.equals(id))).write(
      ImagesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<List<Tag>> getTagsForImage(String imageId) async {
    final query = select(imageTags).join([
      innerJoin(tags, tags.id.equalsExp(imageTags.tagId)),
    ])
      ..where(imageTags.imageId.equals(imageId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  Future<void> addTag(String imageId, String tagId) async {
    await into(imageTags).insertOnConflictUpdate(
      ImageTagsCompanion(imageId: Value(imageId), tagId: Value(tagId)),
    );
  }

  Future<void> clearTags(String imageId) async {
    await (delete(imageTags)..where((it) => it.imageId.equals(imageId))).go();
  }
}
