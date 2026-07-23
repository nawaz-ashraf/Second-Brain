import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/sort_filter_bar.dart';
import '../../../../core/utils/item_creation_helper.dart';

/// Documents feature screen — import, view, favorite, and manage documents
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

final _documentsStreamProvider = StreamProvider.autoDispose<List<DocumentModel>>((ref) {
  return ref.watch(documentsRepositoryProvider).watchAll();
});

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  void _importDocument() {
    ItemCreationHelper.importDocument(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(viewModeProvider);
    final docsAsync = ref.watch(_documentsStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Documents'),
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
            child: docsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return EmptyState(
                    icon: Icons.description_rounded,
                    title: 'No documents yet',
                    subtitle: 'Import PDFs, Word docs, and more',
                    actionLabel: 'Import Document',
                    onAction: _importDocument,
                  );
                }

                final sorted = _sortDocs(docs, _sortOrder);
                return viewMode == ViewMode.grid
                    ? _buildGrid(sorted)
                    : _buildList(sorted);
              },
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(message: e.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importDocument,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Import'),
      ),
    );
  }

  List<DocumentModel> _sortDocs(List<DocumentModel> docs, SortOrder order) {
    final list = [...docs];
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

  Widget _buildGrid(List<DocumentModel> docs) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: docs.length,
      itemBuilder: (context, i) => _DocumentCard(doc: docs[i], isGrid: true)
          .animate(delay: (i * 30).ms)
          .fadeIn(duration: 250.ms),
    );
  }

  Widget _buildList(List<DocumentModel> docs) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _DocumentCard(doc: docs[i], isGrid: false)
          .animate(delay: (i * 30).ms)
          .fadeIn(duration: 250.ms),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel doc;
  final bool isGrid;

  const _DocumentCard({required this.doc, this.isGrid = false});

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return const Color(0xFFE53935);
      case 'doc':
      case 'docx': return const Color(0xFF1565C0);
      case 'xls':
      case 'xlsx': return const Color(0xFF2E7D32);
      case 'ppt':
      case 'pptx': return const Color(0xFFE65100);
      case 'txt':
      case 'md': return const Color(0xFF546E7A);
      default: return const Color(0xFF78909C);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(doc.fileType);

    return InkWell(
      onTap: () => context.push('${AppRoutes.documentViewer}?id=${doc.id}'),
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        ),
        child: isGrid ? _buildGrid(context, theme, typeColor) : _buildList(context, theme, typeColor),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ThemeData theme, Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File type icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: AppTheme.radiusMedium,
          ),
          child: Center(
            child: Text(
              doc.fileTypeUpper,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          doc.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Row(
          children: [
            Text(
              doc.fileSizeDisplay,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (doc.isFavorite)
              Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          ],
        ),
        Text(
          DateFormat('MMM d').format(doc.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, ThemeData theme, Color typeColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.12),
            borderRadius: AppTheme.radiusMedium,
          ),
          child: Center(
            child: Text(
              doc.fileTypeUpper,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '${doc.fileSizeDisplay} · ${DateFormat('MMM d, yyyy').format(doc.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (doc.isFavorite)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          ),
        _DocMoreMenu(doc: doc),
      ],
    );
  }
}

class _DocMoreMenu extends ConsumerWidget {
  final DocumentModel doc;

  const _DocMoreMenu({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
      onSelected: (val) async {
        if (val == 'favorite') {
          await ref
              .read(documentsRepositoryProvider)
              .toggleFavorite(doc.id, !doc.isFavorite);
        } else if (val == 'delete') {
          await ref.read(documentsRepositoryProvider).delete(doc.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document deleted')),
            );
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, size: 18),
              const SizedBox(width: 8),
              Text(doc.isFavorite ? 'Unfavorite' : 'Favorite'),
            ],
          ),
        ),
        const PopupMenuDivider(),
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
    );
  }
}
