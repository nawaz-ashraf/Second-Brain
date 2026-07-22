import 'package:flutter/material.dart';
import '../../core/models/app_models.dart';
import '../../core/theme/app_theme.dart';

/// Colored tag chip widget
class TagChip extends StatelessWidget {
  final TagModel tag;
  final bool deletable;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.deletable = false,
    this.onDeleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = tag.tagColor;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radiusFull,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: deletable ? 10 : 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: tagColor.withOpacity(0.15),
          borderRadius: AppTheme.radiusFull,
          border: Border.all(
            color: tagColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tagColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              tag.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tagColor.computeLuminance() > 0.5
                    ? tagColor.withOpacity(0.8)
                    : tagColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (deletable) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onDeleted,
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: tagColor.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wrap of tag chips
class TagsRow extends StatelessWidget {
  final List<TagModel> tags;
  final bool deletable;
  final void Function(TagModel)? onDelete;
  final void Function(TagModel)? onTap;

  const TagsRow({
    super.key,
    required this.tags,
    this.deletable = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => TagChip(
              tag: tag,
              deletable: deletable,
              onDeleted: onDelete != null ? () => onDelete!(tag) : null,
              onTap: onTap != null ? () => onTap!(tag) : null,
            ),
          )
          .toList(),
    );
  }
}
