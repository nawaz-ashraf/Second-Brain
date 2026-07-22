import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Domain model for a Note
class NoteModel {
  final String id;
  final String title;
  final String? contentJson;
  final String? contentPlain;
  final int color;
  final bool isPinned;
  final bool isFavorite;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<TagModel> tags;

  const NoteModel({
    required this.id,
    required this.title,
    this.contentJson,
    this.contentPlain,
    this.color = 0,
    this.isPinned = false,
    this.isFavorite = false,
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.tags = const [],
  });

  Color get backgroundColor {
    if (color == 0) return Colors.transparent;
    return Color(color);
  }

  int get readingTimeMinutes {
    if (wordCount <= 0) return 0;
    return (wordCount / 200).ceil();
  }

  String get readingTimeDisplay {
    final mins = readingTimeMinutes;
    if (mins <= 0) return '< 1 min read';
    return '$mins min read';
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? contentJson,
    String? contentPlain,
    int? color,
    bool? isPinned,
    bool? isFavorite,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<TagModel>? tags,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      contentPlain: contentPlain ?? this.contentPlain,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Domain model for a Document
class DocumentModel {
  final String id;
  final String title;
  final String filePath;
  final String fileName;
  final String fileType;
  final int fileSize;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TagModel> tags;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get fileTypeUpper => fileType.toUpperCase();

  DocumentModel copyWith({
    String? id,
    String? title,
    String? filePath,
    String? fileName,
    String? fileType,
    int? fileSize,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TagModel>? tags,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Domain model for an Image
class ImageModel {
  final String id;
  final String title;
  final String filePath;
  final String? thumbnailPath;
  final int? width;
  final int? height;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TagModel> tags;

  const ImageModel({
    required this.id,
    required this.title,
    required this.filePath,
    this.thumbnailPath,
    this.width,
    this.height,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  String? get dimensions {
    if (width == null || height == null) return null;
    return '${width}×$height';
  }

  ImageModel copyWith({
    String? id,
    String? title,
    String? filePath,
    String? thumbnailPath,
    int? width,
    int? height,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TagModel>? tags,
  }) {
    return ImageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      width: width ?? this.width,
      height: height ?? this.height,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Domain model for a Voice Note
class VoiceNoteModel {
  final String id;
  final String title;
  final String filePath;
  final int durationMs;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TagModel> tags;

  const VoiceNoteModel({
    required this.id,
    required this.title,
    required this.filePath,
    this.durationMs = 0,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  String get durationDisplay {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  VoiceNoteModel copyWith({
    String? id,
    String? title,
    String? filePath,
    int? durationMs,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TagModel>? tags,
  }) {
    return VoiceNoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Domain model for a Bookmark
class BookmarkModel {
  final String id;
  final String title;
  final String url;
  final String? description;
  final String? siteName;
  final String? faviconUrl;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TagModel> tags;

  const BookmarkModel({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.siteName,
    this.faviconUrl,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  String get domain {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  BookmarkModel copyWith({
    String? id,
    String? title,
    String? url,
    String? description,
    String? siteName,
    String? faviconUrl,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TagModel>? tags,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      siteName: siteName ?? this.siteName,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Domain model for a Collection
class CollectionModel {
  final String id;
  final String name;
  final String? description;
  final int color;
  final String icon;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectionModel({
    required this.id,
    required this.name,
    this.description,
    this.color = 0xFF4CAF50,
    this.icon = 'folder',
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get collectionColor => Color(color);

  CollectionModel copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    String? icon,
    int? itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Domain model for a Tag
class TagModel {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;

  const TagModel({
    required this.id,
    required this.name,
    this.color = 0xFF4CAF50,
    required this.createdAt,
  });

  Color get tagColor => Color(color);

  TagModel copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Domain model for a Recent Item
class RecentItemModel {
  final String id;
  final String itemId;
  final ItemType itemType;
  final DateTime openedAt;

  const RecentItemModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.openedAt,
  });
}

/// Unified search result model
class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final ItemType type;
  final bool isFavorite;
  final DateTime updatedAt;

  const SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.isFavorite,
    required this.updatedAt,
  });
}
