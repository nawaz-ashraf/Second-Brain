import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/theme/app_theme.dart';

/// Helper to unify the creation/import logic for different item types
/// (Bookmarks, Documents, Images) so they can be called from anywhere.
class ItemCreationHelper {
  // ─── Bookmarks ──────────────────────────────────────────────────────────

  static void showAddBookmarkSheet(
    BuildContext context,
    WidgetRef ref, {
    String? collectionId,
  }) {
    final urlController = TextEditingController();

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
                'Add Bookmark',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppTheme.spaceLG),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com',
                ),
                keyboardType: TextInputType.url,
                autofocus: true,
              ),
              const SizedBox(height: AppTheme.spaceXL),
              SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (ctx, ref, _) {
                    return FilledButton(
                      onPressed: () async {
                        final url = urlController.text.trim();
                        if (url.isEmpty) return;

                        // Extract repos synchronously before any await
                        final bookmarksRepo = ref.read(bookmarksRepositoryProvider);
                        final collectionsRepo = ref.read(collectionsRepositoryProvider);
                        final scaffoldMessenger = ScaffoldMessenger.of(ctx);
                        final navigator = Navigator.of(ctx);

                        // Ensure valid url scheme
                        final validUrl = url.startsWith('http') ? url : 'https://$url';

                        // Attempt to fetch title
                        final meta = await _fetchMetadata(validUrl);
                        final title = meta?['title'] ?? validUrl;

                        try {
                          final bookmark = await bookmarksRepo.create(
                            title: title,
                            url: validUrl,
                          );

                          if (collectionId != null) {
                            await collectionsRepo.addItem(
                              collectionId,
                              bookmark.id,
                              'bookmark',
                            );
                          }

                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Bookmark saved')),
                          );
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Failed to save bookmark: $e')),
                          );
                        }
                      },
                      child: const Text('Save Bookmark'),
                    );
                  }
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Map<String, String>?> _fetchMetadata(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final body = response.body;
        final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false).firstMatch(body);
        final title = titleMatch?.group(1)?.trim();
        return {'title': title ?? ''};
      }
    } catch (_) {}
    return null;
  }

  // ─── Documents ──────────────────────────────────────────────────────────

  static Future<void> importDocument(
    BuildContext context,
    WidgetRef ref, {
    String? collectionId,
  }) async {
    // Extract dependencies synchronously
    final docsRepo = ref.read(documentsRepositoryProvider);
    final collectionsRepo = ref.read(collectionsRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedDocTypes,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      final ext = file.extension?.toLowerCase() ?? 'txt';
      final fileName = file.name;
      final fileSize = file.size;

      // Copy file to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/documents');
      if (!await dir.exists()) await dir.create(recursive: true);

      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final destPath = '${dir.path}/$uniqueName';
      await File(file.path!).copy(destPath);

      final doc = await docsRepo.create(
        title: fileName.replaceAll('.$ext', ''),
        filePath: destPath,
        fileName: fileName,
        fileType: ext,
        fileSize: fileSize,
      );

      if (collectionId != null) {
        await collectionsRepo.addItem(
          collectionId,
          doc.id,
          'document',
        );
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Document imported successfully')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to import: $e')),
      );
    }
  }

  // ─── Images ─────────────────────────────────────────────────────────────

  static void showImageImportSheet(
    BuildContext context,
    WidgetRef ref, {
    String? collectionId,
  }) {
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
              _pickImage(context, ref, ImageSource.gallery, collectionId: collectionId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(context, ref, ImageSource.camera, collectionId: collectionId);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source, {
    String? collectionId,
  }) async {
    // Extract dependencies synchronously
    final imagesRepo = ref.read(imagesRepositoryProvider);
    final collectionsRepo = ref.read(collectionsRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(source: source);
      if (xFile == null) return;

      final file = File(xFile.path);
      
      // Copy file to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/images');
      if (!await dir.exists()) await dir.create(recursive: true);

      final ext = xFile.name.split('.').last;
      final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';
      final destPath = '${dir.path}/$uniqueName';
      await file.copy(destPath);

      final image = await imagesRepo.create(
        title: xFile.name,
        filePath: destPath,
      );

      if (collectionId != null) {
        await collectionsRepo.addItem(
          collectionId,
          image.id,
          'image',
        );
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Image imported successfully')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to import image: $e')),
      );
    }
  }
}
