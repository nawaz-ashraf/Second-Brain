import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';

/// Collection detail screen showing all items in a collection
final _collectionFutureProvider = FutureProvider.family.autoDispose<CollectionModel?, String>((ref, id) {
  return ref.watch(collectionsRepositoryProvider).getById(id);
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

              // Items list (placeholder — full implementation streams items)
              const Expanded(
                child: EmptyState(
                  icon: Icons.add_rounded,
                  title: 'No items yet',
                  subtitle: 'Add items to this collection from any content screen',
                ),
              ),
            ],
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
