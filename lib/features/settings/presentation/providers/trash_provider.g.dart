// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deletedNotesHash() => r'c07627e358c687de62e5274cecbe9b6d6f59a913';

/// See also [deletedNotes].
@ProviderFor(deletedNotes)
final deletedNotesProvider =
    AutoDisposeStreamProvider<List<NoteModel>>.internal(
      deletedNotes,
      name: r'deletedNotesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedNotesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedNotesRef = AutoDisposeStreamProviderRef<List<NoteModel>>;
String _$deletedDocumentsHash() => r'cc371379fa5884021e579726c86d8cdcaf602d9d';

/// See also [deletedDocuments].
@ProviderFor(deletedDocuments)
final deletedDocumentsProvider =
    AutoDisposeStreamProvider<List<DocumentModel>>.internal(
      deletedDocuments,
      name: r'deletedDocumentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedDocumentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedDocumentsRef = AutoDisposeStreamProviderRef<List<DocumentModel>>;
String _$deletedImagesHash() => r'ad8ecbd1cbf4566624580a8ed0a6966f62cb370a';

/// See also [deletedImages].
@ProviderFor(deletedImages)
final deletedImagesProvider =
    AutoDisposeStreamProvider<List<ImageModel>>.internal(
      deletedImages,
      name: r'deletedImagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedImagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedImagesRef = AutoDisposeStreamProviderRef<List<ImageModel>>;
String _$deletedVoiceNotesHash() => r'92006fb52543106dc8708abda01ebe4d2b77d6a3';

/// See also [deletedVoiceNotes].
@ProviderFor(deletedVoiceNotes)
final deletedVoiceNotesProvider =
    AutoDisposeStreamProvider<List<VoiceNoteModel>>.internal(
      deletedVoiceNotes,
      name: r'deletedVoiceNotesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedVoiceNotesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedVoiceNotesRef =
    AutoDisposeStreamProviderRef<List<VoiceNoteModel>>;
String _$deletedBookmarksHash() => r'239671d0f6c13d8f2f53b07d37f93f517b6a063d';

/// See also [deletedBookmarks].
@ProviderFor(deletedBookmarks)
final deletedBookmarksProvider =
    AutoDisposeStreamProvider<List<BookmarkModel>>.internal(
      deletedBookmarks,
      name: r'deletedBookmarksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedBookmarksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedBookmarksRef = AutoDisposeStreamProviderRef<List<BookmarkModel>>;
String _$deletedCollectionsHash() =>
    r'6458c5f2a57a6692b0bb218da6fbea79efac4d3a';

/// See also [deletedCollections].
@ProviderFor(deletedCollections)
final deletedCollectionsProvider =
    AutoDisposeStreamProvider<List<CollectionModel>>.internal(
      deletedCollections,
      name: r'deletedCollectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletedCollectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletedCollectionsRef =
    AutoDisposeStreamProviderRef<List<CollectionModel>>;
String _$trashItemsHash() => r'e0eb089b2c98a3a8efb2ba8e3ab9f6db98a23b4a';

/// See also [trashItems].
@ProviderFor(trashItems)
final trashItemsProvider = AutoDisposeProvider<List<TrashItem>>.internal(
  trashItems,
  name: r'trashItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trashItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrashItemsRef = AutoDisposeProviderRef<List<TrashItem>>;
String _$trashFilterHash() => r'90730c3ab5c91cf208228a21ea3303571a06b8f2';

/// See also [TrashFilter].
@ProviderFor(TrashFilter)
final trashFilterProvider =
    AutoDisposeNotifierProvider<TrashFilter, ItemType?>.internal(
      TrashFilter.new,
      name: r'trashFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trashFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrashFilter = AutoDisposeNotifier<ItemType?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
