import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Fullscreen image viewer with zoom, hero, and favorite toggle
class ImageViewerScreen extends ConsumerStatefulWidget {
  final String imageId;

  const ImageViewerScreen({super.key, required this.imageId});

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  ImageModel? _image;
  bool _isLoading = true;
  bool _showUi = true;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final img = await ref.read(imagesRepositoryProvider).getById(widget.imageId);
    if (mounted) setState(() { _image = img; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_image == null) {
      return const Scaffold(body: Center(child: Text('Image not found')));
    }

    final file = File(_image!.filePath);
    final exists = file.existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showUi
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.7),
              foregroundColor: Colors.white,
              title: Text(_image!.title),
              actions: [
                IconButton(
                  icon: Icon(
                    _image!.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _image!.isFavorite ? Colors.amber : Colors.white,
                  ),
                  onPressed: () async {
                    await ref.read(imagesRepositoryProvider).toggleFavorite(
                          _image!.id,
                          !_image!.isFavorite,
                        );
                    await _loadImage();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  onPressed: () async {
                    await ref.read(imagesRepositoryProvider).delete(_image!.id);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showUi = !_showUi),
        child: Center(
          child: Hero(
            tag: 'image_${_image!.id}',
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 5.0,
              child: exists
                  ? Image.file(file, fit: BoxFit.contain)
                  : const Icon(
                      Icons.broken_image_rounded,
                      size: 80,
                      color: Colors.white54,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
