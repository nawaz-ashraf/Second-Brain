import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables/app_tables.dart';
import 'daos/notes_dao.dart';
import 'daos/documents_dao.dart';
import 'daos/images_dao.dart';
import 'daos/voice_notes_dao.dart';
import 'daos/bookmarks_dao.dart';
import 'daos/collections_dao.dart';
import 'daos/tags_dao.dart';
import 'daos/recent_items_dao.dart';

part 'app_database.g.dart';

/// The main Drift database for Second Brain.
/// All data is stored locally in SQLite via Drift.
@DriftDatabase(
  tables: [
    Notes,
    Documents,
    Images,
    VoiceNotes,
    Bookmarks,
    Collections,
    Tags,
    RecentItems,
    NoteTags,
    DocumentTags,
    BookmarkTags,
    ImageTags,
    VoiceNoteTags,
    CollectionItems,
  ],
  daos: [
    NotesDao,
    DocumentsDao,
    ImagesDao,
    VoiceNotesDao,
    BookmarksDao,
    CollectionsDao,
    TagsDao,
    RecentItemsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Add deletedAt column to all tables that didn't have it
        await m.addColumn(documents, documents.deletedAt);
        await m.addColumn(images, images.deletedAt);
        await m.addColumn(voiceNotes, voiceNotes.deletedAt);
        await m.addColumn(bookmarks, bookmarks.deletedAt);
        await m.addColumn(collections, collections.deletedAt);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// Opens the SQLite connection backed by a file on disk.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'second_brain.db'));
    return NativeDatabase.createInBackground(file, logStatements: false);
  });
}
