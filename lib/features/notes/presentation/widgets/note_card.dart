import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tag_chip.dart';

/// Note card for both grid and list view
class NoteCard extends ConsumerWidget {
  final NoteModel note;
  final bool isGrid;

  const NoteCard({
    super.key,
    required this.note,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color cardColor;
    if (note.color == 0) {
      cardColor = theme.colorScheme.surface;
    } else {
      final colors = isDark ? AppColors.darkNoteCardColors : AppColors.noteCardColors;
      final idx = AppColors.noteCardColors.indexWhere(
        (c) => c.value == note.color,
      );
      cardColor = idx >= 0 ? colors[idx] : Color(note.color);
    }

    return InkWell(
      onTap: () => context.push('${AppRoutes.noteEditor}?id=${note.id}'),
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          color: cardColor == Colors.transparent
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)
              : cardColor,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: isGrid ? _buildGridContent(context, theme) : _buildListContent(context, theme),
      ),
    );
  }

  Widget _buildGridContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            if (note.isPinned)
              Icon(
                Icons.push_pin_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            const Spacer(),
            if (note.isFavorite)
              Icon(
                Icons.star_rounded,
                size: 14,
                color: Colors.amber,
              ),
            _MoreMenu(note: note),
          ],
        ),

        const SizedBox(height: 6),

        // Title
        Text(
          note.title.isEmpty ? 'Untitled' : note.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        // Content preview
        if (note.contentPlain != null && note.contentPlain!.isNotEmpty)
          Flexible(
            child: Text(
              note.contentPlain!,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),

        const Spacer(),

        // Tags
        if (note.tags.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: note.tags.take(2).map((t) => TagChip(tag: t)).toList(),
          ),
        ],

        const SizedBox(height: 6),

        // Date
        Text(
          DateFormat('MMM d').format(note.updatedAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildListContent(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  if (note.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (note.isFavorite)
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                ],
              ),

              if (note.contentPlain != null && note.contentPlain!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  note.contentPlain!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(height: 6),

              Row(
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(note.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                  if (note.wordCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${note.wordCount} words',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                  if (note.tags.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    ...note.tags.take(2).map((t) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: TagChip(tag: t),
                        )),
                  ],
                ],
              ),
            ],
          ),
        ),
        _MoreMenu(note: note),
      ],
    );
  }
}

class _MoreMenu extends ConsumerWidget {
  final NoteModel note;

  const _MoreMenu({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(notesRepositoryProvider);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      padding: EdgeInsets.zero,
      iconSize: 16,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
      onSelected: (val) async {
        switch (val) {
          case 'pin':
            await repo.togglePin(note.id, !note.isPinned);
          case 'favorite':
            await repo.toggleFavorite(note.id, !note.isFavorite);
          case 'delete':
            await repo.delete(note.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Note moved to trash'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      // Restore note
                      await repo.update(note.copyWith(deletedAt: null));
                    },
                  ),
                ),
              );
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(note.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                note.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(note.isFavorite ? 'Unfavorite' : 'Favorite'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
