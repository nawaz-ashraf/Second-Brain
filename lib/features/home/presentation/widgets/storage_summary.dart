import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Storage summary card showing item counts per type
class StorageSummary extends ConsumerWidget {
  const StorageSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Library',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spaceMD),
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          decoration: BoxDecoration(
            borderRadius: AppTheme.radiusLarge,
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _StatRow(
                icon: Icons.edit_note_rounded,
                label: 'Notes',
                color: const Color(0xFF4CAF50),
                countProvider: (ref) => ref
                    .watch(notesRepositoryProvider)
                    .watchAll()
                    .map((n) => n.length),
              ),
              const Divider(height: 24),
              _StatRow(
                icon: Icons.description_rounded,
                label: 'Documents',
                color: const Color(0xFF2196F3),
                countProvider: (ref) => ref
                    .watch(documentsRepositoryProvider)
                    .watchAll()
                    .map((d) => d.length),
              ),
              const Divider(height: 24),
              _StatRow(
                icon: Icons.image_rounded,
                label: 'Images',
                color: const Color(0xFF009688),
                countProvider: (ref) => ref
                    .watch(imagesRepositoryProvider)
                    .watchAll()
                    .map((i) => i.length),
              ),
              const Divider(height: 24),
              _StatRow(
                icon: Icons.bookmark_rounded,
                label: 'Bookmarks',
                color: const Color(0xFFFF9800),
                countProvider: (ref) => ref
                    .watch(bookmarksRepositoryProvider)
                    .watchAll()
                    .map((b) => b.length),
              ),
              const Divider(height: 24),
              _StatRow(
                icon: Icons.mic_rounded,
                label: 'Voice Notes',
                color: const Color(0xFFF44336),
                countProvider: (ref) => ref
                    .watch(voiceNotesRepositoryProvider)
                    .watchAll()
                    .map((v) => v.length),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends ConsumerWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Stream<int> Function(WidgetRef) countProvider;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.countProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stream = countProvider(ref);

    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: AppTheme.radiusSmall,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                count.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        );
      },
    );
  }
}
