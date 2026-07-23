import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';

part 'trash_provider.g.dart';

@riverpod
class TrashFilter extends _$TrashFilter {
  @override
  ItemType? build() => null;

  void setFilter(ItemType? type) {
    state = type;
  }
}

@riverpod
Stream<List<NoteModel>> deletedNotes(DeletedNotesRef ref) {
  return ref.watch(notesRepositoryProvider).watchDeleted();
}

@riverpod
Stream<List<DocumentModel>> deletedDocuments(DeletedDocumentsRef ref) {
  return ref.watch(documentsRepositoryProvider).watchDeleted();
}

@riverpod
Stream<List<ImageModel>> deletedImages(DeletedImagesRef ref) {
  return ref.watch(imagesRepositoryProvider).watchDeleted();
}

@riverpod
Stream<List<VoiceNoteModel>> deletedVoiceNotes(DeletedVoiceNotesRef ref) {
  return ref.watch(voiceNotesRepositoryProvider).watchDeleted();
}

@riverpod
Stream<List<BookmarkModel>> deletedBookmarks(DeletedBookmarksRef ref) {
  return ref.watch(bookmarksRepositoryProvider).watchDeleted();
}

@riverpod
Stream<List<CollectionModel>> deletedCollections(DeletedCollectionsRef ref) {
  return ref.watch(collectionsRepositoryProvider).watchDeleted();
}

@riverpod
List<TrashItem> trashItems(TrashItemsRef ref) {
  final notes = ref.watch(deletedNotesProvider).valueOrNull ?? [];
  final docs = ref.watch(deletedDocumentsProvider).valueOrNull ?? [];
  final images = ref.watch(deletedImagesProvider).valueOrNull ?? [];
  final voiceNotes = ref.watch(deletedVoiceNotesProvider).valueOrNull ?? [];
  final bookmarks = ref.watch(deletedBookmarksProvider).valueOrNull ?? [];
  final collections = ref.watch(deletedCollectionsProvider).valueOrNull ?? [];

  final items = <TrashItem>[
    ...notes.map((n) => TrashItem(id: n.id, title: n.title, subtitle: n.contentPlain, type: ItemType.note, deletedAt: n.deletedAt!)),
    ...docs.map((d) => TrashItem(id: d.id, title: d.title, subtitle: d.fileName, type: ItemType.document, deletedAt: d.deletedAt!)),
    ...images.map((i) => TrashItem(id: i.id, title: i.title, subtitle: i.dimensions, type: ItemType.image, deletedAt: i.deletedAt!)),
    ...voiceNotes.map((v) => TrashItem(id: v.id, title: v.title, subtitle: v.durationDisplay, type: ItemType.voiceNote, deletedAt: v.deletedAt!)),
    ...bookmarks.map((b) => TrashItem(id: b.id, title: b.title, subtitle: b.url, type: ItemType.bookmark, deletedAt: b.deletedAt!)),
    ...collections.map((c) => TrashItem(id: c.id, title: c.name, subtitle: c.description, type: ItemType.collection, deletedAt: c.deletedAt!)),
  ];

  items.sort((a, b) => b.deletedAt.compareTo(a.deletedAt));

  final filter = ref.watch(trashFilterProvider);
  if (filter != null) {
    return items.where((i) => i.type == filter).toList();
  }
  return items;
}

