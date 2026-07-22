import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Recent items horizontal scroll section
final _recentNotesStreamProvider = StreamProvider.autoDispose<List<NoteModel>>((ref) {
  return ref.watch(notesRepositoryProvider).watchRecent(limit: 10);
});

class RecentItemsSection extends ConsumerWidget {
  const RecentItemsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentNotesAsync = ref.watch(_recentNotesStreamProvider);

    return recentNotesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No recent items yet. Start saving!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              return _RecentNoteCard(note: notes[i]);
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 130,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => const _RecentCardSkeleton(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecentNoteCard extends StatelessWidget {
  final NoteModel note;

  const _RecentNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = note.color != 0
        ? Color(note.color).withOpacity(0.3)
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
    final dateStr = DateFormat('MMM d').format(note.updatedAt);

    return GestureDetector(
      onTap: () => context.push(
        '${AppRoutes.noteEditor}?id=${note.id}',
      ),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          borderRadius: AppTheme.radiusMedium,
          color: bg,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (note.isPinned)
                  Icon(
                    Icons.push_pin_rounded,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCardSkeleton extends StatelessWidget {
  const _RecentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusMedium,
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      ),
    );
  }
}
