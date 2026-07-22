import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Document viewer screen that shows PDF or metadata for other types
class DocumentViewerScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentViewerScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  DocumentModel? _doc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoc();
  }

  Future<void> _loadDoc() async {
    final doc = await ref
        .read(documentsRepositoryProvider)
        .getById(widget.documentId);
    if (mounted) setState(() {
      _doc = doc;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const Center(child: Text('Document not found')),
      );
    }

    final isPdf = _doc!.fileType.toLowerCase() == 'pdf';
    final fileExists = File(_doc!.filePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(_doc!.title),
        actions: [
          IconButton(
            icon: Icon(
              _doc!.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _doc!.isFavorite ? Colors.amber : null,
            ),
            onPressed: () async {
              await ref.read(documentsRepositoryProvider).toggleFavorite(
                    _doc!.id,
                    !_doc!.isFavorite,
                  );
              await _loadDoc();
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () async {
              final uri = Uri.file(_doc!.filePath);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      ),
      body: isPdf && fileExists
          ? PDFView(
              filePath: _doc!.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              fitEachPage: true,
            )
          : _buildMetadataView(context, theme),
    );
  }

  Widget _buildMetadataView(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceXL),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: AppTheme.radiusLarge,
            ),
            child: Center(
              child: Text(
                _doc!.fileTypeUpper,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          Text(
            _doc!.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Text(
            _doc!.fileName,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXL),
          _MetaRow(label: 'Type', value: _doc!.fileTypeUpper),
          _MetaRow(label: 'Size', value: _doc!.fileSizeDisplay),
          _MetaRow(
            label: 'Imported',
            value: _doc!.createdAt.toLocal().toString().substring(0, 16),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
