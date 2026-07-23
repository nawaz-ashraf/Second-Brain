import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/sort_filter_bar.dart';
import '../../../../core/utils/item_creation_helper.dart';

/// Bookmarks screen — save URLs, auto-fetch metadata, favorite, open in browser
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  void _showAddBookmarkSheet() {
    ItemCreationHelper.showAddBookmarkSheet(context, ref);
  }

final _bookmarksStreamProvider = StreamProvider.autoDispose<List<BookmarkModel>>((ref) {
  return ref.watch(bookmarksRepositoryProvider).watchAll();
});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(viewModeProvider);
    final bookmarksAsync = ref.watch(_bookmarksStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: [
          SortFilterBar(
            currentSort: _sortOrder,
            viewMode: viewMode,
            onSortChanged: (o) => setState(() => _sortOrder = o),
            onViewModeToggled: () => ref.read(viewModeProvider.notifier).toggle(),
          ),
          Expanded(
            child: bookmarksAsync.when(
              data: (bookmarks) {
                if (bookmarks.isEmpty) {
                  return EmptyState(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'No bookmarks yet',
                    subtitle: 'Save URLs to access them anytime',
                    actionLabel: 'Add Bookmark',
                    onAction: _showAddBookmarkSheet,
                  );
                }

                final sorted = [...bookmarks]
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _BookmarkCard(bookmark: sorted[i])
                      .animate(delay: (i * 30).ms)
                      .fadeIn(duration: 250.ms),
                );
              },
              loading: () => const LoadingState(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBookmarkSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Bookmark'),
      ),
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  final BookmarkModel bookmark;

  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final uri = Uri.parse(bookmark.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Favicon or icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: bookmark.faviconUrl != null
                  ? ClipRRect(
                      borderRadius: AppTheme.radiusSmall,
                      child: Image.network(
                        bookmark.faviconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.language_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.language_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bookmark.domain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (bookmark.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      bookmark.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(bookmark.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    bookmark.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: bookmark.isFavorite ? Colors.amber : null,
                    size: 20,
                  ),
                  onPressed: () async {
                    await ref.read(bookmarksRepositoryProvider).toggleFavorite(
                          bookmark.id,
                          !bookmark.isFavorite,
                        );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
                  onSelected: (val) async {
                    if (val == 'delete') {
                      await ref.read(bookmarksRepositoryProvider).delete(bookmark.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
