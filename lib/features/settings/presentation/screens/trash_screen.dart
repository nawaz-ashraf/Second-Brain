import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../providers/trash_provider.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trashItems = ref.watch(trashItemsProvider);
    final filter = ref.watch(trashFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
      ),
      body: Column(
        children: [
          _buildFilterChips(context, ref, filter),
          Expanded(
            child: trashItems.isEmpty
                ? _buildEmptyState(context)
                : _buildList(context, ref, trashItems),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, ItemType? currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == null,
            onSelected: (_) => ref.read(trashFilterProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: 8),
          ...ItemType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _FilterChip(
                label: _getLabelForType(type),
                isSelected: currentFilter == type,
                onSelected: (_) => ref.read(trashFilterProvider.notifier).setFilter(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Trash is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<TrashItem> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _TrashItemCard(item: item, ref: ref);
      },
    );
  }

  String _getLabelForType(ItemType type) {
    switch (type) {
      case ItemType.note:
        return 'Notes';
      case ItemType.document:
        return 'Documents';
      case ItemType.image:
        return 'Images';
      case ItemType.voiceNote:
        return 'Voice Notes';
      case ItemType.bookmark:
        return 'Bookmarks';
      case ItemType.collection:
        return 'Collections';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}

class _TrashItemCard extends StatelessWidget {
  final TrashItem item;
  final WidgetRef ref;

  const _TrashItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showActionDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isNotEmpty ? item.title : 'Untitled',
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Deleted ${DateFormat.yMMMd().add_Hm().format(item.deletedAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showActionDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData iconData;
    Color bgColor = theme.colorScheme.surfaceContainerHighest;
    Color iconColor = theme.colorScheme.onSurfaceVariant;

    switch (item.type) {
      case ItemType.note:
        iconData = Icons.notes;
        break;
      case ItemType.document:
        iconData = Icons.description;
        break;
      case ItemType.image:
        iconData = Icons.image;
        break;
      case ItemType.voiceNote:
        iconData = Icons.mic;
        break;
      case ItemType.bookmark:
        iconData = Icons.bookmark;
        break;
      case ItemType.collection:
        iconData = Icons.folder;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trash Action'),
        content: Text('What would you like to do with "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _permanentlyDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Permanently'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restore();
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _restore() {
    switch (item.type) {
      case ItemType.note:
        ref.read(notesRepositoryProvider).restore(item.id);
        break;
      case ItemType.document:
        ref.read(documentsRepositoryProvider).restore(item.id);
        break;
      case ItemType.image:
        ref.read(imagesRepositoryProvider).restore(item.id);
        break;
      case ItemType.voiceNote:
        ref.read(voiceNotesRepositoryProvider).restore(item.id);
        break;
      case ItemType.bookmark:
        ref.read(bookmarksRepositoryProvider).restore(item.id);
        break;
      case ItemType.collection:
        ref.read(collectionsRepositoryProvider).restore(item.id);
        break;
    }
  }

  void _permanentlyDelete() {
    switch (item.type) {
      case ItemType.note:
        ref.read(notesRepositoryProvider).permanentlyDelete(item.id);
        break;
      case ItemType.document:
        ref.read(documentsRepositoryProvider).permanentlyDelete(item.id);
        break;
      case ItemType.image:
        ref.read(imagesRepositoryProvider).permanentlyDelete(item.id);
        break;
      case ItemType.voiceNote:
        ref.read(voiceNotesRepositoryProvider).permanentlyDelete(item.id);
        break;
      case ItemType.bookmark:
        ref.read(bookmarksRepositoryProvider).permanentlyDelete(item.id);
        break;
      case ItemType.collection:
        ref.read(collectionsRepositoryProvider).permanentlyDelete(item.id);
        break;
    }
  }
}
