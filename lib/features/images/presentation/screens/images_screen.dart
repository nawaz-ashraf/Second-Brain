import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/sort_filter_bar.dart';

/// Images screen — import from gallery, capture from camera, view, manage
class ImagesScreen extends ConsumerStatefulWidget {
  const ImagesScreen({super.key});

  @override
  ConsumerState<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends ConsumerState<ImagesScreen> {
  SortOrder _sortOrder = SortOrder.newest;
  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 90);
      for (final image in images) {
        await _saveImage(image.path, image.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      if (photo != null) {
        await _saveImage(photo.path, photo.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  Future<void> _saveImage(String path, String name) async {
    final title = name.split('.').first;
    await ref.read(imagesRepositoryProvider).create(
      title: title,
      filePath: path,
    );
  }

final _imagesStreamProvider = StreamProvider.autoDispose<List<ImageModel>>((ref) {
  return ref.watch(imagesRepositoryProvider).watchAll();
});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewMode = ref.watch(viewModeProvider);
    final imagesAsync = ref.watch(_imagesStreamProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Images'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined),
            onPressed: _capturePhoto,
            tooltip: 'Take Photo',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickFromGallery,
            tooltip: 'Import from Gallery',
          ),
        ],
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
            child: imagesAsync.when(
              data: (images) {
                if (images.isEmpty) {
                  return EmptyState(
                    icon: Icons.image_rounded,
                    title: 'No images yet',
                    subtitle: 'Import from gallery or capture with camera',
                    actionLabel: 'Import Images',
                    onAction: _pickFromGallery,
                  );
                }

                final sorted = [...images]
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return viewMode == ViewMode.grid
                    ? _buildGrid(sorted)
                    : _buildList(sorted);
              },
              loading: () => const LoadingState(isGrid: true),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImportSheet,
        child: const Icon(Icons.add_photo_alternate_rounded),
      ),
    );
  }

  void _showImportSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Import from Gallery'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(ctx);
              _capturePhoto();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ImageModel> images) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) => _ImageTile(image: images[i])
          .animate(delay: (i * 20).ms)
          .fadeIn(duration: 200.ms),
    );
  }

  Widget _buildList(List<ImageModel> images) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _ImageListTile(image: images[i])
          .animate(delay: (i * 30).ms)
          .fadeIn(duration: 250.ms),
    );
  }
}

class _ImageTile extends ConsumerWidget {
  final ImageModel image;

  const _ImageTile({required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = File(image.filePath);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: () => context.push('${AppRoutes.imageViewer}?id=${image.id}'),
      child: Hero(
        tag: 'image_${image.id}',
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: exists
              ? Image.file(file, fit: BoxFit.cover)
              : const Icon(Icons.broken_image_rounded, size: 32),
        ),
      ),
    );
  }
}

class _ImageListTile extends ConsumerWidget {
  final ImageModel image;

  const _ImageListTile({required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final file = File(image.filePath);
    final exists = file.existsSync();

    return InkWell(
      onTap: () => context.push('${AppRoutes.imageViewer}?id=${image.id}'),
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppTheme.radiusSmall,
              child: SizedBox(
                width: 60,
                height: 60,
                child: exists
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_rounded),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(image.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (image.isFavorite)
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
