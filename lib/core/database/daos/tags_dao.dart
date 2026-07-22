import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, NoteTags, DocumentTags, BookmarkTags, ImageTags, VoiceNoteTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Stream<List<Tag>> watchAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Tag>> getAll() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<Tag?> getById(String id) {
    return (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Tag?> getByName(String name) {
    return (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<List<Tag>> search(String query) {
    final q = '%$query%';
    return (select(tags)
          ..where((t) => t.name.like(q))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<void> insertTag(TagsCompanion tag) async {
    await into(tags).insertOnConflictUpdate(tag);
  }

  Future<void> updateTag(TagsCompanion tag) async {
    await update(tags).replace(tag);
  }

  Future<void> deleteTag(String id) async {
    // Remove from all junction tables first
    await (delete(noteTags)..where((nt) => nt.tagId.equals(id))).go();
    await (delete(documentTags)..where((dt) => dt.tagId.equals(id))).go();
    await (delete(bookmarkTags)..where((bt) => bt.tagId.equals(id))).go();
    await (delete(imageTags)..where((it) => it.tagId.equals(id))).go();
    await (delete(voiceNoteTags)..where((vnt) => vnt.tagId.equals(id))).go();
    // Delete the tag itself
    await (delete(tags)..where((t) => t.id.equals(id))).go();
  }
}
