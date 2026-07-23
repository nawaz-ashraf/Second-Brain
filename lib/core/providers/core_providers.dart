import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../repositories/notes_repository.dart';
import '../repositories/documents_repository.dart';
import '../repositories/images_repository.dart';
import '../repositories/voice_notes_repository.dart';
import '../repositories/bookmarks_repository.dart';
import '../repositories/collections_repository.dart';
import '../repositories/tags_repository.dart';
import '../services/app_lock_service.dart';

// ─── Database Provider ────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ─── Repository Providers ─────────────────────────────────────────────────────

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NotesRepositoryImpl(db.notesDao);
});

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DocumentsRepositoryImpl(db.documentsDao);
});

final imagesRepositoryProvider = Provider<ImagesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ImagesRepositoryImpl(db.imagesDao);
});

final voiceNotesRepositoryProvider = Provider<VoiceNotesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VoiceNotesRepositoryImpl(db.voiceNotesDao);
});

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BookmarksRepositoryImpl(db.bookmarksDao);
});

final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CollectionsRepositoryImpl(db.collectionsDao);
});

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TagsRepositoryImpl(db.tagsDao);
});

// ─── Settings Provider ────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences before using');
});

final appLockServiceProvider = Provider<AppLockService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppLockService(prefs);
});

// ─── Theme Mode Provider ──────────────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ThemeModeNotifier(prefs);
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.themeKey) ?? 'system';
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await _prefs.setString(AppConstants.themeKey, value);
  }
}

// ─── View Mode Provider ───────────────────────────────────────────────────────

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ViewModeNotifier(prefs);
  },
);

class ViewModeNotifier extends StateNotifier<ViewMode> {
  final SharedPreferences _prefs;

  ViewModeNotifier(this._prefs) : super(_loadViewMode(_prefs));

  static ViewMode _loadViewMode(SharedPreferences prefs) {
    final saved = prefs.getString(AppConstants.viewModeKey) ?? 'grid';
    return saved == 'list' ? ViewMode.list : ViewMode.grid;
  }

  Future<void> toggle() async {
    state = state.toggled;
    await _prefs.setString(
      AppConstants.viewModeKey,
      state == ViewMode.grid ? 'grid' : 'list',
    );
  }
}

// ─── Sort Order Provider ──────────────────────────────────────────────────────

final sortOrderProvider = StateNotifierProvider<SortOrderNotifier, SortOrder>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return SortOrderNotifier(prefs);
  },
);

class SortOrderNotifier extends StateNotifier<SortOrder> {
  final SharedPreferences _prefs;

  SortOrderNotifier(this._prefs) : super(SortOrder.newest);

  Future<void> setSortOrder(SortOrder order) async {
    state = order;
    await _prefs.setString(AppConstants.sortOrderKey, order.name);
  }
}

// ─── Recent Searches Provider ─────────────────────────────────────────────────

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecentSearchesNotifier(prefs);
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const String _key = 'recent_searches';

  RecentSearchesNotifier(this._prefs)
      : super(_prefs.getStringList(_key) ?? []);

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final searches = [...state];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > AppConstants.maxRecentSearches) {
      searches.removeLast();
    }
    state = searches;
    await _prefs.setStringList(_key, searches);
  }

  Future<void> removeSearch(String query) async {
    final searches = state.where((s) => s != query).toList();
    state = searches;
    await _prefs.setStringList(_key, searches);
  }

  Future<void> clearAll() async {
    state = [];
    await _prefs.remove(_key);
  }
}
