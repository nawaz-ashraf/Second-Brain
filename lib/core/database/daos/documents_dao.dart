import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'documents_dao.g.dart';

@DriftAccessor(tables: [Documents, DocumentTags, Tags])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  Stream<List<Document>> watchAll() {
    return (select(documents)
          ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]))
        .watch();
  }

  Stream<List<Document>> watchFavorites() {
    return (select(documents)
          ..where((d) => d.isFavorite.equals(true))
          ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]))
        .watch();
  }

  Future<Document?> getById(String id) {
    return (select(documents)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<List<Document>> search(String query) {
    final q = '%$query%';
    return (select(documents)
          ..where((d) => d.title.like(q) | d.fileName.like(q))
          ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]))
        .get();
  }

  Future<void> insertDocument(DocumentsCompanion doc) async {
    await into(documents).insertOnConflictUpdate(doc);
  }

  Future<void> updateDocument(DocumentsCompanion doc) async {
    await update(documents).replace(doc);
  }

  Future<void> deleteDocument(String id) async {
    await (delete(documents)..where((d) => d.id.equals(id))).go();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(documents)..where((d) => d.id.equals(id))).write(
      DocumentsCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<List<Tag>> getTagsForDocument(String documentId) async {
    final query = select(documentTags).join([
      innerJoin(tags, tags.id.equalsExp(documentTags.tagId)),
    ])
      ..where(documentTags.documentId.equals(documentId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  Future<void> addTag(String documentId, String tagId) async {
    await into(documentTags).insertOnConflictUpdate(
      DocumentTagsCompanion(
        documentId: Value(documentId),
        tagId: Value(tagId),
      ),
    );
  }

  Future<void> clearTags(String documentId) async {
    await (delete(documentTags)
          ..where((dt) => dt.documentId.equals(documentId)))
        .go();
  }
}
