import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';

/// Favorites screen — shows all favorited items across all types
final _favNotesStreamProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchFavorites();
});
final _favDocsStreamProvider = StreamProvider.autoDispose<List<DocumentModel>>((ref) {
  return ref.watch(documentsRepositoryProvider).watchFavorites();
});
final _favImagesStreamProvider = StreamProvider.autoDispose<List<ImageModel>>((ref) {
  return ref.watch(imagesRepositoryProvider).watchFavorites();
});
final _favVoiceNotesStreamProvider = StreamProvider.autoDispose<List<VoiceNoteModel>>((ref) {
  return ref.watch(voiceNotesRepositoryProvider).watchFavorites();
});
final _favBookmarksStreamProvider = StreamProvider.autoDispose<List<BookmarkModel>>((ref) {
  return ref.watch(bookmarksRepositoryProvider).watchFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch favorites from all repositories
    final notesAsync = ref.watch(_favNotesStreamProvider);
    final docsAsync = ref.watch(_favDocsStreamProvider);
    final imagesAsync = ref.watch(_favImagesStreamProvider);
    final voiceAsync = ref.watch(_favVoiceNotesStreamProvider);
    final bookmarksAsync = ref.watch(_favBookmarksStreamProvider);

    final allLoading = notesAsync.isLoading ||
        docsAsync.isLoading ||
        imagesAsync.isLoading ||
        voiceAsync.isLoading ||
        bookmarksAsync.isLoading;

    if (allLoading) {
      return const Scaffold(body: LoadingState());
    }

    final notes = notesAsync.value ?? [];
    final docs = docsAsync.value ?? [];
    final images = imagesAsync.value ?? [];
    final voices = voiceAsync.value ?? [];
    final bookmarks = bookmarksAsync.value ?? [];

    final allFavorites = <_FavoriteItem>[
      ...notes.map((n) => _FavoriteItem(
            id: n.id,
            title: n.title.isEmpty ? 'Untitled' : n.title,
            subtitle: n.contentPlain,
            type: ItemType.note,
            date: n.updatedAt,
          )),
      ...docs.map((d) => _FavoriteItem(
            id: d.id,
            title: d.title,
            subtitle: d.fileSizeDisplay,
            type: ItemType.document,
            date: d.updatedAt,
          )),
      ...images.map((i) => _FavoriteItem(
            id: i.id,
            title: i.title,
            subtitle: i.dimensions,
            type: ItemType.image,
            date: i.updatedAt,
          )),
      ...voices.map((v) => _FavoriteItem(
            id: v.id,
            title: v.title,
            subtitle: v.durationDisplay,
            type: ItemType.voiceNote,
            date: v.updatedAt,
          )),
      ...bookmarks.map((b) => _FavoriteItem(
            id: b.id,
            title: b.title,
            subtitle: b.domain,
            type: ItemType.bookmark,
            date: b.updatedAt,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: allFavorites.isEmpty
          ? const EmptyState(
              icon: Icons.star_outline_rounded,
              title: 'No favorites yet',
              subtitle: 'Star any note, document, image, bookmark, or voice note to see it here',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    '${allFavorites.length} favorite${allFavorites.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: allFavorites.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = allFavorites[i];
                      return _FavoriteTile(item: item)
                          .animate(delay: (i * 30).ms)
                          .fadeIn(duration: 250.ms)
                          .slideY(begin: 0.05, duration: 250.ms, curve: Curves.easeOut);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _FavoriteItem {
  final String id;
  final String title;
  final String? subtitle;
  final ItemType type;
  final DateTime date;

  _FavoriteItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.date,
  });
}

class _FavoriteTile extends StatelessWidget {
  final _FavoriteItem item;

  const _FavoriteTile({required this.item});

  Color get _typeColor {
    switch (item.type) {
      case ItemType.note: return const Color(0xFF4CAF50);
      case ItemType.document: return const Color(0xFF2196F3);
      case ItemType.image: return const Color(0xFF009688);
      case ItemType.voiceNote: return const Color(0xFFF44336);
      case ItemType.bookmark: return const Color(0xFFFF9800);
      case ItemType.collection: return const Color(0xFF9C27B0);
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case ItemType.note: return Icons.edit_note_rounded;
      case ItemType.document: return Icons.description_rounded;
      case ItemType.image: return Icons.image_rounded;
      case ItemType.voiceNote: return Icons.mic_rounded;
      case ItemType.bookmark: return Icons.bookmark_rounded;
      case ItemType.collection: return Icons.folder_rounded;
    }
  }

  void _navigate(BuildContext context) {
    switch (item.type) {
      case ItemType.note:
        context.push('${AppRoutes.noteEditor}?id=${item.id}');
      case ItemType.document:
        context.push('${AppRoutes.documentViewer}?id=${item.id}');
      case ItemType.image:
        context.push('${AppRoutes.imageViewer}?id=${item.id}');
      case ItemType.voiceNote:
        context.push(AppRoutes.voice);
      case ItemType.bookmark:
        context.push(AppRoutes.bookmarks);
      case ItemType.collection:
        context.push('/collections/${item.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _navigate(context),
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.12),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(item.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
