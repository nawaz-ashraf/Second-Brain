import '../database/app_database.dart';
import '../models/app_models.dart';
import '../constants/app_constants.dart';

/// Extension methods to convert Drift table rows to domain models
extension NoteMapper on Note {
  NoteModel toModel({List<TagModel> tags = const []}) => NoteModel(
        id: id,
        title: title,
        contentJson: contentJson,
        contentPlain: contentPlain,
        color: color,
        isPinned: isPinned,
        isFavorite: isFavorite,
        wordCount: wordCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        tags: tags,
      );
}

extension DocumentMapper on Document {
  DocumentModel toModel({List<TagModel> tags = const []}) => DocumentModel(
        id: id,
        title: title,
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
}

extension ImageMapper on Image {
  ImageModel toModel({List<TagModel> tags = const []}) => ImageModel(
        id: id,
        title: title,
        filePath: filePath,
        thumbnailPath: thumbnailPath,
        width: width,
        height: height,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
}

extension VoiceNoteMapper on VoiceNote {
  VoiceNoteModel toModel({List<TagModel> tags = const []}) => VoiceNoteModel(
        id: id,
        title: title,
        filePath: filePath,
        durationMs: durationMs,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
}

extension BookmarkMapper on Bookmark {
  BookmarkModel toModel({List<TagModel> tags = const []}) => BookmarkModel(
        id: id,
        title: title,
        url: url,
        description: description,
        siteName: siteName,
        faviconUrl: faviconUrl,
        isFavorite: isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt,
        tags: tags,
      );
}

extension CollectionMapper on Collection {
  CollectionModel toModel({int itemCount = 0}) => CollectionModel(
        id: id,
        name: name,
        description: description,
        color: color,
        icon: icon,
        itemCount: itemCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension TagMapper on Tag {
  TagModel toModel() => TagModel(
        id: id,
        name: name,
        color: color,
        createdAt: createdAt,
      );
}

extension RecentItemMapper on RecentItem {
  RecentItemModel toModel() => RecentItemModel(
        id: id,
        itemId: itemId,
        itemType: _parseItemType(itemType),
        openedAt: openedAt,
      );

  ItemType _parseItemType(String type) {
    return ItemType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ItemType.note,
    );
  }
}
