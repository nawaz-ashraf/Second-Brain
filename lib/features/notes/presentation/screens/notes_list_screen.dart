import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/models/app_models.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/sort_filter_bar.dart';
import '../widgets/note_card.dart';

/// Notes list screen with grid/list toggle, search, sort, and pin support
class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

final _notesStreamProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
});

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(viewModeProvider);
    final notesAsync = ref.watch(_notesStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go(AppRoutes.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort/filter bar
          SortFilterBar(
            currentSort: _sortOrder,
            viewMode: viewMode,
            onSortChanged: (order) => setState(() => _sortOrder = order),
            onViewModeToggled: () => ref.read(viewModeProvider.notifier).toggle(),
          ),

          // Notes list/grid
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                final sorted = _sortNotes(notes, _sortOrder);
                final pinned = sorted.where((n) => n.isPinned).toList();
                final unpinned = sorted.where((n) => !n.isPinned).toList();

                if (notes.isEmpty) {
                  return EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'No notes yet',
                    subtitle: 'Tap the + button to create your first note',
                    actionLabel: 'Create Note',
                    onAction: () => context.push(AppRoutes.noteEditor),
                  );
                }

                return viewMode == ViewMode.grid
                    ? _buildGrid(context, pinned, unpinned)
                    : _buildList(context, pinned, unpinned);
              },
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                message: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(_notesStreamProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.noteEditor),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
    );
  }

  List<NoteModel> _sortNotes(List<NoteModel> notes, SortOrder order) {
    final list = [...notes];
    switch (order) {
      case SortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortOrder.alphabetical:
        list.sort((a, b) => a.title.compareTo(b.title));
      case SortOrder.reverseAlphabetical:
        list.sort((a, b) => b.title.compareTo(a.title));
      case SortOrder.modified:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SortOrder.favorites:
        list.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
    }
    return list;
  }

  Widget _buildGrid(
    BuildContext context,
    List<NoteModel> pinned,
    List<NoteModel> unpinned,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (pinned.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Pinned',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _noteGrid(pinned),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Others',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: _noteGrid(unpinned),
        ),
      ],
    );
  }

  SliverGrid _noteGrid(List<NoteModel> notes) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) => NoteCard(
          note: notes[i],
          isGrid: true,
        )
            .animate(delay: (i * 30).ms)
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.05, duration: 250.ms, curve: Curves.easeOut),
        childCount: notes.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<NoteModel> pinned,
    List<NoteModel> unpinned,
  ) {
    final all = [...pinned, ...unpinned];
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: all.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => NoteCard(
        note: all[i],
        isGrid: false,
      )
          .animate(delay: (i * 30).ms)
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.05, duration: 250.ms, curve: Curves.easeOut),
    );
  }
}
