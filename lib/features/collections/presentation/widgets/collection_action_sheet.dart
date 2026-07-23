import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/item_creation_helper.dart';

/// Modal bottom sheet that shows all available quick actions for a collection
class CollectionActionSheet extends ConsumerWidget {
  final String collectionId;
  final BuildContext parentContext;
  final WidgetRef parentRef;

  const CollectionActionSheet({
    super.key,
    required this.collectionId,
    required this.parentContext,
    required this.parentRef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        const SizedBox(height: AppTheme.spaceSM),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
            borderRadius: AppTheme.radiusFull,
          ),
        ),
        const SizedBox(height: AppTheme.spaceLG),
        Text(
          'Add Item',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppTheme.spaceMD),
        _ActionItem(
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF4CAF50),
          label: 'New Note',
          onTap: () {
            Navigator.pop(context);
            context.push('${AppRoutes.noteEditor}?collectionId=$collectionId');
          },
        ),
        _ActionItem(
          icon: Icons.bookmark_rounded,
          color: const Color(0xFFFF9800),
          label: 'New Bookmark',
          onTap: () {
            Navigator.pop(context);
            ItemCreationHelper.showAddBookmarkSheet(parentContext, parentRef, collectionId: collectionId);
          },
        ),
        _ActionItem(
          icon: Icons.description_rounded,
          color: const Color(0xFF2196F3),
          label: 'Import Document',
          onTap: () {
            Navigator.pop(context);
            ItemCreationHelper.importDocument(parentContext, parentRef, collectionId: collectionId);
          },
        ),
        _ActionItem(
          icon: Icons.image_rounded,
          color: const Color(0xFF009688),
          label: 'Add Image',
          onTap: () {
            Navigator.pop(context);
            ItemCreationHelper.showImageImportSheet(parentContext, parentRef, collectionId: collectionId);
          },
        ),
        _ActionItem(
          icon: Icons.mic_rounded,
          color: const Color(0xFFF44336),
          label: 'Record Voice Note',
          onTap: () {
            Navigator.pop(context);
            context.push('${AppRoutes.voice}?collectionId=$collectionId');
          },
        ),
        const SizedBox(height: AppTheme.spaceXL),
        ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: AppTheme.radiusMedium,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}
