import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Global search screen with instant results across all content types
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SearchResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() { _results = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    try {
      final notesRepo = ref.read(notesRepositoryProvider);
      final docsRepo = ref.read(documentsRepositoryProvider);
      final imagesRepo = ref.read(imagesRepositoryProvider);
      final voiceRepo = ref.read(voiceNotesRepositoryProvider);
      final bookmarksRepo = ref.read(bookmarksRepositoryProvider);

      final futures = await Future.wait([
        notesRepo.search(query),
        docsRepo.search(query),
        imagesRepo.search(query),
        voiceRepo.search(query),
        bookmarksRepo.search(query),
      ]);

      final results = <SearchResult>[];

      for (final note in futures[0] as List<NoteModel>) {
        results.add(SearchResult(
          id: note.id,
          title: note.title.isEmpty ? 'Untitled' : note.title,
          subtitle: note.contentPlain,
          type: ItemType.note,
          isFavorite: note.isFavorite,
          updatedAt: note.updatedAt,
        ));
      }

      for (final doc in futures[1] as List<DocumentModel>) {
        results.add(SearchResult(
          id: doc.id,
          title: doc.title,
          subtitle: doc.fileSizeDisplay,
          type: ItemType.document,
          isFavorite: doc.isFavorite,
          updatedAt: doc.updatedAt,
        ));
      }

      for (final img in futures[2] as List<ImageModel>) {
        results.add(SearchResult(
          id: img.id,
          title: img.title,
          subtitle: img.dimensions,
          type: ItemType.image,
          isFavorite: img.isFavorite,
          updatedAt: img.updatedAt,
        ));
      }

      for (final vn in futures[3] as List<VoiceNoteModel>) {
        results.add(SearchResult(
          id: vn.id,
          title: vn.title,
          subtitle: vn.durationDisplay,
          type: ItemType.voiceNote,
          isFavorite: vn.isFavorite,
          updatedAt: vn.updatedAt,
        ));
      }

      for (final bm in futures[4] as List<BookmarkModel>) {
        results.add(SearchResult(
          id: bm.id,
          title: bm.title,
          subtitle: bm.domain,
          type: ItemType.bookmark,
          isFavorite: bm.isFavorite,
          updatedAt: bm.updatedAt,
        ));
      }

      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (mounted && _searchController.text.trim() == query) {
        // Save to recent searches
        ref.read(recentSearchesProvider.notifier).addSearch(query);
        setState(() { _results = results; _isSearching = false; });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _navigateToResult(SearchResult result) {
    switch (result.type) {
      case ItemType.note:
        context.push('${AppRoutes.noteEditor}?id=${result.id}');
      case ItemType.document:
        context.push('${AppRoutes.documentViewer}?id=${result.id}');
      case ItemType.image:
        context.push('${AppRoutes.imageViewer}?id=${result.id}');
      case ItemType.voiceNote:
        context.push(AppRoutes.voice);
      case ItemType.bookmark:
        context.push(AppRoutes.bookmarks);
      case ItemType.collection:
        context.push('/collections/${result.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentSearches = ref.watch(recentSearchesProvider);
    final query = _searchController.text.trim();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search everything...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
          style: theme.textTheme.titleMedium,
          textInputAction: TextInputAction.search,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : query.isEmpty
              ? _buildRecentSearches(context, recentSearches)
              : _results.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results for "$query"',
                      subtitle: 'Try different keywords or check the spelling',
                    )
                  : _buildResults(context, _results, query),
    );
  }

  Widget _buildRecentSearches(BuildContext context, List<String> searches) {
    final theme = Theme.of(context);

    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Search notes, documents, images,\nbookmarks, and voice notes',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clearAll(),
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searches.length,
            itemBuilder: (context, i) => ListTile(
              leading: Icon(
                Icons.history_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(searches[i]),
              trailing: IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).removeSearch(searches[i]),
              ),
              onTap: () {
                _searchController.text = searches[i];
                _onSearchChanged();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    List<SearchResult> results,
    String query,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${results.length} result${results.length != 1 ? 's' : ''} for "$query"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final result = results[i];
              return _SearchResultTile(
                result: result,
                query: query,
                onTap: () => _navigateToResult(result),
              )
                  .animate(delay: (i * 20).ms)
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.05, duration: 200.ms, curve: Curves.easeOut);
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.result,
    required this.query,
    required this.onTap,
  });

  Color _colorForType(ItemType type) {
    switch (type) {
      case ItemType.note: return const Color(0xFF4CAF50);
      case ItemType.document: return const Color(0xFF2196F3);
      case ItemType.image: return const Color(0xFF009688);
      case ItemType.voiceNote: return const Color(0xFFF44336);
      case ItemType.bookmark: return const Color(0xFFFF9800);
      case ItemType.collection: return const Color(0xFF9C27B0);
    }
  }

  IconData _iconForType(ItemType type) {
    switch (type) {
      case ItemType.note: return Icons.edit_note_rounded;
      case ItemType.document: return Icons.description_rounded;
      case ItemType.image: return Icons.image_rounded;
      case ItemType.voiceNote: return Icons.mic_rounded;
      case ItemType.bookmark: return Icons.bookmark_rounded;
      case ItemType.collection: return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(result.type);

    return InkWell(
      onTap: onTap,
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(_iconForType(result.type), color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: result.title,
                    query: query,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    highlightStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    ),
                  ),
                  if (result.subtitle != null && result.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.subtitle!,
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
                Chip(
                  label: Text(result.type.displayName),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(fontSize: 10, color: typeColor),
                  backgroundColor: typeColor.withOpacity(0.1),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                if (result.isFavorite)
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Highlights search query in text
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: style));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: highlightStyle ?? style,
      ));
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
