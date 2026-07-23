import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_tables.dart';

part 'voice_notes_dao.g.dart';

@DriftAccessor(tables: [VoiceNotes, VoiceNoteTags, Tags])
class VoiceNotesDao extends DatabaseAccessor<AppDatabase>
    with _$VoiceNotesDaoMixin {
  VoiceNotesDao(super.db);

  Stream<List<VoiceNote>> watchAll() {
    return (select(voiceNotes)
          ..where((v) => v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm.desc(v.updatedAt)]))
        .watch();
  }

  Stream<List<VoiceNote>> watchFavorites() {
    return (select(voiceNotes)
          ..where((v) => v.isFavorite.equals(true) & v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm.desc(v.updatedAt)]))
        .watch();
  }

  Future<VoiceNote?> getById(String id) {
    return (select(voiceNotes)..where((v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<VoiceNote>> search(String query) {
    final q = '%$query%';
    return (select(voiceNotes)
          ..where((v) => v.title.like(q) & v.deletedAt.isNull())
          ..orderBy([(v) => OrderingTerm.desc(v.updatedAt)]))
        .get();
  }

  Future<void> insertVoiceNote(VoiceNotesCompanion voiceNote) async {
    await into(voiceNotes).insertOnConflictUpdate(voiceNote);
  }

  Future<void> updateVoiceNote(VoiceNotesCompanion voiceNote) async {
    await update(voiceNotes).replace(voiceNote);
  }

  Future<void> deleteVoiceNote(String id) async {
    await (update(voiceNotes)..where((v) => v.id.equals(id))).write(
      VoiceNotesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> permanentlyDeleteVoiceNote(String id) async {
    await (delete(voiceNotes)..where((v) => v.id.equals(id))).go();
  }

  Future<void> restoreVoiceNote(String id) async {
    await (update(voiceNotes)..where((v) => v.id.equals(id))).write(
      const VoiceNotesCompanion(deletedAt: Value(null)),
    );
  }

  Stream<List<VoiceNote>> watchDeleted() {
    return (select(voiceNotes)
          ..where((v) => v.deletedAt.isNotNull())
          ..orderBy([(v) => OrderingTerm.desc(v.deletedAt)]))
        .watch();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await (update(voiceNotes)..where((v) => v.id.equals(id))).write(
      VoiceNotesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<List<Tag>> getTagsForVoiceNote(String voiceNoteId) async {
    final query = select(voiceNoteTags).join([
      innerJoin(tags, tags.id.equalsExp(voiceNoteTags.tagId)),
    ])
      ..where(voiceNoteTags.voiceNoteId.equals(voiceNoteId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(tags)).toList();
  }

  Future<void> addTag(String voiceNoteId, String tagId) async {
    await into(voiceNoteTags).insertOnConflictUpdate(
      VoiceNoteTagsCompanion(
        voiceNoteId: Value(voiceNoteId),
        tagId: Value(tagId),
      ),
    );
  }

  Future<void> clearTags(String voiceNoteId) async {
    await (delete(voiceNoteTags)
          ..where((vnt) => vnt.voiceNoteId.equals(voiceNoteId)))
        .go();
  }
}
