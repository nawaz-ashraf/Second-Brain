import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/notes_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class NotesRepository {
  Stream<List<NoteModel>> watchAll();
  Stream<List<NoteModel>> watchFavorites();
  Stream<List<NoteModel>> watchRecent({int limit = 10});
  Stream<NoteModel?> watchById(String id);
  Future<NoteModel?> getById(String id);
  Future<NoteModel> create({
    required String title,
    String? contentJson,
    String? contentPlain,
    int color,
    bool isPinned,
    List<String> tagIds,
  });
  Future<void> update(NoteModel note, {List<String>? tagIds});
  Future<void> delete(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> restore(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<void> togglePin(String id, bool isPinned);
  Future<List<NoteModel>> search(String query);
  Stream<List<NoteModel>> watchDeleted();
}

class NotesRepositoryImpl implements NotesRepository {
  final NotesDao _dao;
  final _uuid = const Uuid();

  NotesRepositoryImpl(this._dao);

  @override
  Stream<List<NoteModel>> watchAll() {
    return _dao.watchAll().asyncMap((notes) async {
      final result = <NoteModel>[];
      for (final note in notes) {
        final tags = await _dao.getTagsForNote(note.id);
        result.add(note.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<NoteModel>> watchFavorites() {
    return _dao.watchFavorites().asyncMap((notes) async {
      final result = <NoteModel>[];
      for (final note in notes) {
        final tags = await _dao.getTagsForNote(note.id);
        result.add(note.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<NoteModel>> watchRecent({int limit = 10}) {
    return _dao.watchRecent(limit: limit).asyncMap((notes) async {
      return notes.map((n) => n.toModel()).toList();
    });
  }

  @override
  Stream<NoteModel?> watchById(String id) {
    return _dao.watchById(id).map((n) => n?.toModel());
  }

  @override
  Future<NoteModel?> getById(String id) async {
    final note = await _dao.getById(id);
    if (note == null) return null;
    final tags = await _dao.getTagsForNote(id);
    return note.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<NoteModel> create({
    required String title,
    String? contentJson,
    String? contentPlain,
    int color = 0,
    bool isPinned = false,
    List<String> tagIds = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final wordCount = _countWords(contentPlain);

    await _dao.insertNote(
      NotesCompanion(
        id: Value(id),
        title: Value(title),
        contentJson: Value(contentJson),
        contentPlain: Value(contentPlain),
        color: Value(color),
        isPinned: Value(isPinned),
        wordCount: Value(wordCount),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    for (final tagId in tagIds) {
      await _dao.addTag(id, tagId);
    }

    final note = await _dao.getById(id);
    final tags = await _dao.getTagsForNote(id);
    return note!.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<void> update(NoteModel note, {List<String>? tagIds}) async {
    final wordCount = _countWords(note.contentPlain);
    await _dao.updateNote(
      NotesCompanion(
        id: Value(note.id),
        title: Value(note.title),
        contentJson: Value(note.contentJson),
        contentPlain: Value(note.contentPlain),
        color: Value(note.color),
        isPinned: Value(note.isPinned),
        isFavorite: Value(note.isFavorite),
        wordCount: Value(wordCount),
        createdAt: Value(note.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (tagIds != null) {
      await _dao.clearTags(note.id);
      for (final tagId in tagIds) {
        await _dao.addTag(note.id, tagId);
      }
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteNote(id);

  @override
  Future<void> permanentlyDelete(String id) => _dao.permanentlyDeleteNote(id);

  @override
  Future<void> restore(String id) => _dao.restoreNote(id);

  @override
  Stream<List<NoteModel>> watchDeleted() {
    return _dao.watchDeleted().asyncMap((notes) async {
      final result = <NoteModel>[];
      for (final note in notes) {
        final tags = await _dao.getTagsForNote(note.id);
        result.add(note.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _dao.toggleFavorite(id, isFavorite);

  @override
  Future<void> togglePin(String id, bool isPinned) =>
      _dao.togglePin(id, isPinned);

  @override
  Future<List<NoteModel>> search(String query) async {
    final notes = await _dao.search(query);
    final result = <NoteModel>[];
    for (final note in notes) {
      final tags = await _dao.getTagsForNote(note.id);
      result.add(note.toModel(tags: tags.map((t) => t.toModel()).toList()));
    }
    return result;
  }

  int _countWords(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
