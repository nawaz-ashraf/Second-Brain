// Core application constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Second Brain';
  static const String appTagline = 'Save Everything. Find Anything.';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.secondbrain';

  // Database
  static const String databaseName = 'second_brain.db';
  static const int databaseVersion = 1;

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String recentSearchesBox = 'recent_searches';

  // Settings keys
  static const String themeKey = 'theme_mode';
  static const String viewModeKey = 'view_mode';
  static const String sortOrderKey = 'sort_order';

  // Limits
  static const int maxRecentSearches = 20;
  static const int maxRecentItems = 50;
  static const int maxTagsPerItem = 10;
  static const int maxCollectionItems = 1000;

  // File size limits (bytes)
  static const int maxDocumentSize = 100 * 1024 * 1024; // 100 MB
  static const int maxImageSize = 50 * 1024 * 1024;     // 50 MB
  static const int maxVoiceNoteSize = 200 * 1024 * 1024; // 200 MB

  // Audio
  static const String audioExtension = '.m4a';
  static const String audioMimeType = 'audio/m4a';

  // Supported document types
  static const List<String> supportedDocTypes = [
    'pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'xls', 'xlsx', 'csv', 'md',
  ];

  // Supported image types
  static const List<String> supportedImageTypes = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'bmp',
  ];

  // Animations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 280);

  // Grid columns
  static const int gridColumnsPhone = 2;
  static const int gridColumnsTablet = 3;
  static const double tabletBreakpoint = 600.0;

  // Collection icons
  static const List<String> collectionIcons = [
    'folder', 'work', 'school', 'home', 'favorite', 'star',
    'book', 'code', 'science', 'art', 'music', 'sports',
    'travel', 'health', 'finance', 'shopping', 'food', 'nature',
  ];

  // Note colors (index-based for DB storage)
  static const List<int> noteColors = [
    0x00000000, // transparent (default)
    0xFFFFCDD2, // Red
    0xFFFFE0B2, // Orange
    0xFFFFF9C4, // Yellow
    0xFFC8E6C9, // Green
    0xFFB3E5FC, // Blue
    0xFFE1BEE7, // Purple
    0xFFD7CCC8, // Brown
    0xFFCFD8DC, // Grey
  ];

  // Tag colors
  static const List<int> tagColors = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFF44336, // Red
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
    0xFF00BCD4, // Cyan
    0xFF795548, // Brown
    0xFF607D8B, // BlueGrey
    0xFFE91E63, // Pink
    0xFF009688, // Teal
  ];
}

/// Item type enum for cross-content operations
enum ItemType {
  note,
  document,
  image,
  voiceNote,
  bookmark,
  collection;

  String get displayName {
    switch (this) {
      case ItemType.note: return 'Note';
      case ItemType.document: return 'Document';
      case ItemType.image: return 'Image';
      case ItemType.voiceNote: return 'Voice Note';
      case ItemType.bookmark: return 'Bookmark';
      case ItemType.collection: return 'Collection';
    }
  }

  String get icon {
    switch (this) {
      case ItemType.note: return 'note';
      case ItemType.document: return 'description';
      case ItemType.image: return 'image';
      case ItemType.voiceNote: return 'mic';
      case ItemType.bookmark: return 'bookmark';
      case ItemType.collection: return 'folder';
    }
  }
}

/// Sort order options
enum SortOrder {
  newest,
  oldest,
  alphabetical,
  reverseAlphabetical,
  modified,
  favorites;

  String get displayName {
    switch (this) {
      case SortOrder.newest: return 'Newest First';
      case SortOrder.oldest: return 'Oldest First';
      case SortOrder.alphabetical: return 'A → Z';
      case SortOrder.reverseAlphabetical: return 'Z → A';
      case SortOrder.modified: return 'Last Modified';
      case SortOrder.favorites: return 'Favorites First';
    }
  }
}

/// View mode options
enum ViewMode {
  grid,
  list;

  ViewMode get toggled => this == ViewMode.grid ? ViewMode.list : ViewMode.grid;
}
