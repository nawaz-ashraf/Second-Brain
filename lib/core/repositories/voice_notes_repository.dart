import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/voice_notes_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class VoiceNotesRepository {
  Stream<List<VoiceNoteModel>> watchAll();
  Stream<List<VoiceNoteModel>> watchFavorites();
  Future<VoiceNoteModel?> getById(String id);
  Future<VoiceNoteModel> create({
    required String title,
    required String filePath,
    int durationMs,
    List<String> tagIds,
  });
  Future<void> update(VoiceNoteModel voiceNote);
  Future<void> delete(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<VoiceNoteModel>> search(String query);
}

class VoiceNotesRepositoryImpl implements VoiceNotesRepository {
  final VoiceNotesDao _dao;
  final _uuid = const Uuid();

  VoiceNotesRepositoryImpl(this._dao);

  @override
  Stream<List<VoiceNoteModel>> watchAll() {
    return _dao.watchAll().asyncMap((vns) async {
      final result = <VoiceNoteModel>[];
      for (final vn in vns) {
        final tags = await _dao.getTagsForVoiceNote(vn.id);
        result.add(vn.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<VoiceNoteModel>> watchFavorites() {
    return _dao.watchFavorites().asyncMap((vns) async {
      return vns.map((v) => v.toModel()).toList();
    });
  }

  @override
  Future<VoiceNoteModel?> getById(String id) async {
    final vn = await _dao.getById(id);
    if (vn == null) return null;
    final tags = await _dao.getTagsForVoiceNote(id);
    return vn.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<VoiceNoteModel> create({
    required String title,
    required String filePath,
    int durationMs = 0,
    List<String> tagIds = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertVoiceNote(
      VoiceNotesCompanion(
        id: Value(id),
        title: Value(title),
        filePath: Value(filePath),
        durationMs: Value(durationMs),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    for (final tagId in tagIds) {
      await _dao.addTag(id, tagId);
    }

    final vn = await _dao.getById(id);
    return vn!.toModel();
  }

  @override
  Future<void> update(VoiceNoteModel voiceNote) async {
    await _dao.updateVoiceNote(
      VoiceNotesCompanion(
        id: Value(voiceNote.id),
        title: Value(voiceNote.title),
        filePath: Value(voiceNote.filePath),
        durationMs: Value(voiceNote.durationMs),
        isFavorite: Value(voiceNote.isFavorite),
        createdAt: Value(voiceNote.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteVoiceNote(id);

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _dao.toggleFavorite(id, isFavorite);

  @override
  Future<List<VoiceNoteModel>> search(String query) async {
    final vns = await _dao.search(query);
    return vns.map((v) => v.toModel()).toList();
  }
}
