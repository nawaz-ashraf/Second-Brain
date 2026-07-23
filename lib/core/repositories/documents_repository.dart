import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/documents_dao.dart';
import '../database/tables/app_tables.dart';
import '../models/app_models.dart';
import '../models/mappers.dart';

abstract class DocumentsRepository {
  Stream<List<DocumentModel>> watchAll();
  Stream<List<DocumentModel>> watchFavorites();
  Future<DocumentModel?> getById(String id);
  Future<DocumentModel> create({
    required String title,
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSize,
    List<String> tagIds,
  });
  Future<void> update(DocumentModel doc);
  Future<void> delete(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> restore(String id);
  Future<void> toggleFavorite(String id, bool isFavorite);
  Future<List<DocumentModel>> search(String query);
  Stream<List<DocumentModel>> watchDeleted();
}

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsDao _dao;
  final _uuid = const Uuid();

  DocumentsRepositoryImpl(this._dao);

  @override
  Stream<List<DocumentModel>> watchAll() {
    return _dao.watchAll().asyncMap((docs) async {
      final result = <DocumentModel>[];
      for (final doc in docs) {
        final tags = await _dao.getTagsForDocument(doc.id);
        result.add(doc.toModel(tags: tags.map((t) => t.toModel()).toList()));
      }
      return result;
    });
  }

  @override
  Stream<List<DocumentModel>> watchFavorites() {
    return _dao.watchFavorites().asyncMap((docs) async {
      return docs.map((d) => d.toModel()).toList();
    });
  }

  @override
  Future<DocumentModel?> getById(String id) async {
    final doc = await _dao.getById(id);
    if (doc == null) return null;
    final tags = await _dao.getTagsForDocument(id);
    return doc.toModel(tags: tags.map((t) => t.toModel()).toList());
  }

  @override
  Future<DocumentModel> create({
    required String title,
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSize,
    List<String> tagIds = const [],
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertDocument(
      DocumentsCompanion(
        id: Value(id),
        title: Value(title),
        filePath: Value(filePath),
        fileName: Value(fileName),
        fileType: Value(fileType),
        fileSize: Value(fileSize),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    for (final tagId in tagIds) {
      await _dao.addTag(id, tagId);
    }

    final doc = await _dao.getById(id);
    return doc!.toModel();
  }

  @override
  Future<void> update(DocumentModel doc) async {
    await _dao.updateDocument(
      DocumentsCompanion(
        id: Value(doc.id),
        title: Value(doc.title),
        filePath: Value(doc.filePath),
        fileName: Value(doc.fileName),
        fileType: Value(doc.fileType),
        fileSize: Value(doc.fileSize),
        isFavorite: Value(doc.isFavorite),
        createdAt: Value(doc.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> delete(String id) => _dao.deleteDocument(id);

  @override
  Future<void> permanentlyDelete(String id) => _dao.permanentlyDeleteDocument(id);

  @override
  Future<void> restore(String id) => _dao.restoreDocument(id);

  @override
  Stream<List<DocumentModel>> watchDeleted() {
    return _dao.watchDeleted().asyncMap((docs) async {
      return docs.map((d) => d.toModel()).toList();
    });
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) =>
      _dao.toggleFavorite(id, isFavorite);

  @override
  Future<List<DocumentModel>> search(String query) async {
    final docs = await _dao.search(query);
    return docs.map((d) => d.toModel()).toList();
  }
}
