import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../widgets/collection_action_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/app_router.dart';

/// Collection detail screen showing all items in a collection
final _collectionFutureProvider = FutureProvider.family.autoDispose<CollectionModel?, String>((ref, id) {
  return ref.watch(collectionsRepositoryProvider).getById(id);
});

final _collectionItemsStreamProvider = StreamProvider.family.autoDispose<List<dynamic>, String>((ref, id) async* {
  final stream = ref.watch(collectionsRepositoryProvider).watchItems(id);
  await for (final items in stream) {
    final result = <dynamic>[];
    for (final item in items) {
       if (item.itemType == 'note') {
         final n = await ref.read(notesRepositoryProvider).getById(item.itemId);
         if (n != null) result.add(n);
       } else if (item.itemType == 'bookmark') {
         final b = await ref.read(bookmarksRepositoryProvider).getById(item.itemId);
         if (b != null) result.add(b);
       } else if (item.itemType == 'document') {
         final d = await ref.read(documentsRepositoryProvider).getById(item.itemId);
         if (d != null) result.add(d);
       } else if (item.itemType == 'image') {
         final img = await ref.read(imagesRepositoryProvider).getById(item.itemId);
         if (img != null) result.add(img);
       } else if (item.itemType == 'voice') {
         final v = await ref.read(voiceNotesRepositoryProvider).getById(item.itemId);
         if (v != null) result.add(v);
       }
    }
    // sort newest first
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    yield result;
  }
});

class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionAsync = ref.watch(_collectionFutureProvider(collectionId));

    return collectionAsync.when(
      data: (collection) {
        if (collection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Collection')),
            body: const Center(child: Text('Collection not found')),
          );
        }

        final color = collection.collectionColor;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(collection.name),
            backgroundColor: color.withOpacity(0.1),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => _showEditSheet(context, ref, collection),
              ),
            ],
          ),
          body: Column(
            children: [
              // Collection header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spaceXL),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      child: Icon(Icons.folder_rounded, color: color, size: 30),
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    Text(
                      collection.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (collection.description != null) ...[
                      const SizedBox(height: AppTheme.spaceXS),
                      Text(
                        collection.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spaceSM),
                    Text(
                      '${collection.itemCount} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Items list
              Expanded(
                child: ref.watch(_collectionItemsStreamProvider(collection.id)).when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const EmptyState(
                        icon: Icons.add_rounded,
                        title: 'No items yet',
                        subtitle: 'Tap the + button below to add an item to this collection.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        IconData icon;
                        String title;
                        String subtitle;
                        String route;

                        if (item is NoteModel) {
                          icon = Icons.edit_note_rounded;
                          title = item.title;
                          subtitle = DateFormat('MMM d, yyyy').format(item.updatedAt);
                          route = '${AppRoutes.noteEditor}?id=${item.id}';
                        } else if (item is BookmarkModel) {
                          icon = Icons.bookmark_rounded;
                          title = item.title;
                          subtitle = item.url;
                          route = AppRoutes.bookmarks;
                        } else if (item is DocumentModel) {
                          icon = Icons.description_rounded;
                          title = item.title;
                          subtitle = '${(item.fileSize / 1024 / 1024).toStringAsFixed(1)} MB';
                          route = '${AppRoutes.documentViewer}?id=${item.id}';
                        } else if (item is ImageModel) {
                          icon = Icons.image_rounded;
                          title = item.title;
                          subtitle = item.width != null && item.height != null 
                              ? '${item.width}x${item.height}'
                              : 'Image';
                          route = '${AppRoutes.imageViewer}?id=${item.id}';
                        } else if (item is VoiceNoteModel) {
                          icon = Icons.mic_rounded;
                          title = item.title;
                          subtitle = item.durationDisplay;
                          route = AppRoutes.voice;
                        } else {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          onTap: () => context.push(route),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: AppTheme.radiusMedium,
                            ),
                            child: Icon(icon, color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (ctx) => CollectionActionSheet(
                  collectionId: collection.id,
                  parentContext: context,
                  parentRef: ref,
                ),
              );
            },
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('$e')),
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    CollectionModel collection,
  ) {
    final nameController = TextEditingController(text: collection.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Collection',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: AppTheme.spaceXL),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref.read(collectionsRepositoryProvider).update(
                      collection.copyWith(name: nameController.text.trim()),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
